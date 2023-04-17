package com.didichuxing.doraemonkit.kit.timecounter.counter

import android.os.SystemClock
import android.view.View
import androidx.fragment.app.Fragment
import com.didichuxing.doraemonkit.DoKit.getDoKitView
import com.didichuxing.doraemonkit.database.Counter
import com.didichuxing.doraemonkit.kit.blockmonitor.FileManager.save
import com.didichuxing.doraemonkit.kit.core.DoKitManager
import com.didichuxing.doraemonkit.kit.core.DoKitViewManager.Companion.INSTANCE
import com.didichuxing.doraemonkit.kit.health.AppHealthInfoUtil
import com.didichuxing.doraemonkit.kit.health.model.AppHealthInfo.DataBean.PageLoadBean
import com.didichuxing.doraemonkit.kit.health.model.FileConstants
import com.didichuxing.doraemonkit.kit.health.model.LocalFile
import com.didichuxing.doraemonkit.kit.timecounter.TimeCounterDoKitView
import com.didichuxing.doraemonkit.kit.timecounter.bean.CounterInfo
import com.didichuxing.doraemonkit.kit.webdoor.bean.isDoKitClass
import com.didichuxing.doraemonkit.util.ActivityUtils

class FragmentCounter {
    private var mStartTime: Long = 0
    private var mPauseCostTime: Long = 0
    private var mLaunchStartTime: Long = 0
    private var mLaunchCostTime: Long = 0
    private var mRenderStartTime: Long = 0
    private var mRenderCostTime: Long = 0
    private var mTotalCostTime: Long = 0
    private var mOtherCostTime: Long = 0
    private var mCurrentActivity: String? = null
    private val mCounterInfos: MutableList<CounterInfo> = ArrayList()

    fun launch() {
        // 可能不走pause，直接打开新页面，比如从后台点击通知栏
        if (mStartTime == 0L) {
            mStartTime = SystemClock.elapsedRealtime()
            mPauseCostTime = 0
            mRenderCostTime = 0
            mOtherCostTime = 0
            mLaunchCostTime = 0
            mLaunchStartTime = 0
            mTotalCostTime = 0
        }
        mLaunchStartTime = SystemClock.elapsedRealtime()
        mLaunchCostTime = 0
    }

    fun launchEnd(f: Fragment, view: View) {
        mLaunchCostTime = SystemClock.elapsedRealtime() - mLaunchStartTime
        //LogHelper.d(TAG, "create cost：" + mLaunchCostTime);
        render(f, view)
    }

    fun render(f: Fragment, view: View) {
        mRenderStartTime = SystemClock.elapsedRealtime()
        mCurrentActivity = f.javaClass.canonicalName
        view.viewTreeObserver.addOnWindowFocusChangeListener { hasFocus ->
            if (hasFocus) {
                renderEnd(f)
            }
        }
    }

    /**
     * 用户退到后台，点击通知栏打开新页面，这时候需要清空下上次pause记录的时间
     */
    fun enterBackground() {
        mStartTime = 0
    }

    private fun renderEnd(f: Fragment) {
        mRenderCostTime = SystemClock.elapsedRealtime() - mRenderStartTime
        //LogHelper.d(TAG, "render cost：" + mRenderCostTime);
        mTotalCostTime = SystemClock.elapsedRealtime() - mStartTime
        //LogHelper.d(TAG, "total cost：" + mTotalCostTime);
        mOtherCostTime = mTotalCostTime - mRenderCostTime - mPauseCostTime - mLaunchCostTime
        print(f)
    }

    private fun print(f: Fragment) {
        if (isDoKitClass(f.javaClass.canonicalName)) return

        val counterInfo = CounterInfo()
        counterInfo.time = System.currentTimeMillis()
        counterInfo.type = CounterInfo.TYPE_FRAGMENT
        counterInfo.title = mCurrentActivity
        counterInfo.launchCost = mLaunchCostTime
        counterInfo.pauseCost = mPauseCostTime
        counterInfo.renderCost = mRenderCostTime
        counterInfo.totalCost = mTotalCostTime
        counterInfo.otherCost = mOtherCostTime
        try {
            //将Activity 打开耗时 添加到AppHealth 中
            if (DoKitManager.APP_HEALTH_RUNNING) {
                if (ActivityUtils.getTopActivity().javaClass.canonicalName != "com.didichuxing.doraemonkit.kit.base.UniversalActivity") {
                    val pageLoadBean = PageLoadBean()
                    pageLoadBean.page = ActivityUtils.getTopActivity().javaClass.canonicalName
                    pageLoadBean.time = "" + counterInfo.totalCost
                    pageLoadBean.trace = counterInfo.title
                    AppHealthInfoUtil.getInstance().addPageLoadInfo(pageLoadBean)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        //如果文件记录已启用
        if (DoKitManager.SAVE_LOCAL_FILE_START) {
            if (mTotalCostTime > DoKitManager.PAGE_LOAD_SPEED_THRESHOLD_MILLIS) {
                val localFile = LocalFile(counterInfo.title, counterInfo.totalCost, counterInfo.toString())
                save(FileConstants.DIR_PAGE_LOAD_SPEED, FileConstants.PREFIX_FILE_PAGE_LOAD_SPEED, localFile)
            }
        }
        mCounterInfos.add(counterInfo)
        INSTANCE.counterDb.wclDao().insertCounter(
            Counter(
                System.currentTimeMillis(),
                counterInfo.title,
                counterInfo.time,
                counterInfo.type,
                counterInfo.totalCost,
                counterInfo.pauseCost,
                counterInfo.launchCost,
                counterInfo.renderCost,
                counterInfo.otherCost
            )
        )
        val dokitView = getDoKitView(ActivityUtils.getTopActivity(), TimeCounterDoKitView::class.java)
        dokitView?.showInfo(counterInfo)
    }

    val history: List<CounterInfo>
        get() = mCounterInfos

    companion object {
        private const val TAG = "FragmentCounter"
    }
}
