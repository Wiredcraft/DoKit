package com.didichuxing.doraemonkit

import android.content.Context
import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import com.didichuxing.doraemonkit.kit.timecounter.TimeCounterManager
import com.didichuxing.doraemonkit.util.LifecycleListenerUtil

/**
 * ================================================
 * 作    者：jint（金台）
 * 版    本：1.0
 * 创建日期：2019-12-31-10:56
 * 描    述：全局的fragment 生命周期回调
 * 修订历史：
 * ================================================
 */
class DoKitFragmentLifecycleCallbacks : FragmentManager.FragmentLifecycleCallbacks() {

    override fun onFragmentPreAttached(fm: FragmentManager, fragment: Fragment, context: Context) {
        super.onFragmentPreAttached(fm, fragment, context)
        TimeCounterManager.get().onFragmentLaunch()
    }

    override fun onFragmentAttached(fm: FragmentManager, fragment: Fragment, context: Context) {
        super.onFragmentAttached(fm, fragment, context)
        for (listener in LifecycleListenerUtil.LIFECYCLE_LISTENERS) {
            listener.onFragmentAttached(fragment)
        }
    }

    override fun onFragmentViewCreated(fm: FragmentManager, f: Fragment, v: View, savedInstanceState: Bundle?) {
        super.onFragmentViewCreated(fm, f, v, savedInstanceState)
        TimeCounterManager.get().onFragmentLaunched(f, v)
    }

    override fun onFragmentDetached(fm: FragmentManager, fragment: Fragment) {
        super.onFragmentDetached(fm, fragment)
        for (listener in LifecycleListenerUtil.LIFECYCLE_LISTENERS) {
            listener.onFragmentDetached(fragment)
        }
    }

    companion object {
        private const val TAG = "DokitFragmentLifecycleCallbacks"
    }
}
