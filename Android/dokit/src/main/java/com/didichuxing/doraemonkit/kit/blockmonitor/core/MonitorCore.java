package com.didichuxing.doraemonkit.kit.blockmonitor.core;

import android.os.SystemClock;
import android.util.Printer;

import com.didichuxing.doraemonkit.kit.blockmonitor.bean.BlockInfo;
import com.didichuxing.doraemonkit.kit.core.DoKitManager;

import java.util.ArrayList;

/**
 * @desc: 检测卡顿的日志类
 */
class MonitorCore implements Printer {
    private static final String TAG = "MonitorCore";

    private long mStartTime = 0;
    private long mStartThreadTime = 0;
    private boolean mPrintingStarted = false;

    private StackSampler mStackSampler;


    public MonitorCore() {
        mStackSampler = new StackSampler();
        mStackSampler.init();
    }

    @Override
    public void println(String x) {
        if (!mPrintingStarted) {
            mStartTime = System.currentTimeMillis();
            mStartThreadTime = SystemClock.currentThreadTimeMillis();
            mPrintingStarted = true;
            mStackSampler.startDump();
        } else {
            final long endTime = System.currentTimeMillis();
            long endThreadTime = SystemClock.currentThreadTimeMillis();
            mPrintingStarted = false;
            if (isBlock(endTime)) {
                final ArrayList<String> entries = mStackSampler.getThreadStackEntries(mStartTime, endTime);
                if (entries.size() > 0) {
                    final BlockInfo blockInfo = BlockInfo.newInstance()
                            .setMainThreadTimeCost(mStartTime, endTime, mStartThreadTime, endThreadTime)
                            .setThreadStackEntries(entries)
                            .flushString();
                    BlockMonitorManager.getInstance().notifyBlockEvent(blockInfo);
                }
            }
            mStackSampler.stopDump();
        }
    }

    private boolean isBlock(long endTime) {
        return endTime - mStartTime > DoKitManager.BLOCK_THRESHOLD_MILLIS;
    }

    public void shutDown() {
        mStackSampler.shutDown();
    }
}
