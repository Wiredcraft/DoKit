package com.didichuxing.doraemonkit.kit.parameter.matrix

import android.Manifest
import android.app.Activity
import android.app.Application
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.didichuxing.doraemonkit.kit.parameter.matrix.canary.MemoryCanaryBoot.Companion.configure
import com.didichuxing.doraemonkit.kit.parameter.matrix.config.DynamicConfigImpl
import com.tencent.matrix.Matrix
import com.tencent.matrix.backtrace.WarmUpReporter.ReportEvent
import com.tencent.matrix.backtrace.WeChatBacktrace
import com.tencent.matrix.hook.HookManager
import com.tencent.matrix.hook.HookManager.HookFailedException
import com.tencent.matrix.hook.memory.MemoryHook
import com.tencent.matrix.hook.pthread.PthreadHook
import com.tencent.matrix.hook.pthread.PthreadHook.ThreadStackShrinkConfig
import com.tencent.matrix.lifecycle.LifecycleThreadConfig
import com.tencent.matrix.lifecycle.MatrixLifecycleConfig
import com.tencent.matrix.lifecycle.supervisor.SupervisorConfig
import com.tencent.matrix.memory.canary.MemoryCanaryPlugin
import com.tencent.matrix.memory.canary.trim.TrimCallback
import com.tencent.matrix.memory.canary.trim.TrimMemoryNotifier.addProcessBackgroundTrimCallback
import com.tencent.matrix.resource.ResourcePlugin
import com.tencent.matrix.resource.config.ResourceConfig
import com.tencent.matrix.resource.config.ResourceConfig.DumpMode
import com.tencent.matrix.util.MatrixLog
import com.didichuxing.doraemonkit.kit.parameter.matrix.lifecycle.MatrixLifecycleLogger.start
import com.didichuxing.doraemonkit.kit.parameter.matrix.listener.PluginListener

object MatrixApplication {
    private const val TAG = "Matrix.Application"
    fun is64BitRuntime(): Boolean {
        val currRuntimeABI = Build.CPU_ABI
        return (
            "arm64-v8a".equals(currRuntimeABI, ignoreCase = true) ||
                "x86_64".equals(currRuntimeABI, ignoreCase = true) ||
                "mips64".equals(currRuntimeABI, ignoreCase = true)
            )
    }

    @JvmStatic
    fun initMemoryCanary(app: Context?) {
        // Reporter
        WeChatBacktrace.setReporter { type: ReportEvent, args: Array<Any> ->
            if (type == ReportEvent.WarmedUp) {
                Log.i(TAG, "WeChat QUT has warmed up.")
            } else if (type == ReportEvent.WarmUpDuration && args.size == 1) {
                Log.i(TAG, String.format("WeChat QUT Warm-up duration: %sms", args[0] as Long))
            }
        }
        // Init backtrace
        if (is64BitRuntime()) {
            WeChatBacktrace.instance()
                .configure(app)
                .setBacktraceMode(WeChatBacktrace.Mode.Fp)
                .setQuickenAlwaysOn()
                .commit()
        } else {
            WeChatBacktrace.instance()
                .configure(app)
                .warmUpSettings(WeChatBacktrace.WarmUpTiming.PostStartup, 0)
                .directoryToWarmUp(WeChatBacktrace.getSystemFrameworkOATPath() + "boot.oat")
                .directoryToWarmUp(
                    WeChatBacktrace.getSystemFrameworkOATPath() + "boot-framework.oat"
                )
                .commit()
        }

        // Init Hooks.
        try {
            PthreadHook.INSTANCE
                .addHookThread(".*")
                .setThreadTraceEnabled(true)
                .enableTracePthreadRelease(true)
                .enableQuicken(false)
            PthreadHook.INSTANCE.enableLogger(false)
            HookManager.INSTANCE // Memory hook
                .addHook(
                    MemoryHook.INSTANCE
                        .addHookSo(".*libnative-lib\\.so$")
                        .enableStacktrace(true)
                        .stacktraceLogThreshold(0)
                        .enableMmapHook(true)
                ) // Thread hook
                .addHook(PthreadHook.INSTANCE)
                .commitHooks()
        } catch (e: HookFailedException) {
            e.printStackTrace()
        }
    }

    fun init(app: Application) {
        if (!is64BitRuntime()) {
            try {
                val config = ThreadStackShrinkConfig()
                    .setEnabled(true)
                    .addIgnoreCreatorSoPatterns(".*/app_tbs/.*")
                    .addIgnoreCreatorSoPatterns(".*/libany\\.so$")
                HookManager.INSTANCE.addHook(PthreadHook.INSTANCE.setThreadStackShrinkConfig(config))
                    .commitHooks()
            } catch (e: HookFailedException) {
                e.printStackTrace()
            }
        }
        // Switch.
        val dynamicConfig = DynamicConfigImpl()
        MatrixLog.i(TAG, "============Start Matrix configurations.")
        // Builder. Not necessary while some plugins can be configured separately.
        val builder = Matrix.Builder(app)
        // Reporter. Matrix will callback this listener when found issue then emitting it.
        builder.pluginListener(PluginListener(app))
        val memoryCanaryPlugin = MemoryCanaryPlugin(configure(app))
        builder.plugin(memoryCanaryPlugin)
        val resourcePlugin = configureResourcePlugin(dynamicConfig, app)
        builder.plugin(resourcePlugin)
        builder.matrixLifecycleConfig(configureMatrixLifecycle())
        Matrix.init(builder.build())
        Matrix.with().startAllPlugins()
        start()
        addProcessBackgroundTrimCallback(object : TrimCallback {
            override fun systemTrim(i: Int) {
                MatrixLog.d(TAG, "systemTrim: ")
            }

            override fun backgroundTrim() {
                MatrixLog.d(TAG, "backgroundTrim: ")
            }
        })
        MatrixLog.i(TAG, "=================Matrix configurations done.")
    }

    private fun configureResourcePlugin(
        dynamicConfig: DynamicConfigImpl,
        app: Application
    ): ResourcePlugin {
        val intent = Intent()
        val mode = DumpMode.MANUAL_DUMP
        MatrixLog.i(TAG, "Dump Activity Leak Mode=%s", mode)
        intent.setClassName(
            app.packageName,
            "sample.didichuxing.doraemonkit.kit.parameter.matrix.ManualDumpActivity"
        )
        val resourceConfig = ResourceConfig.Builder()
            .dynamicConfig(dynamicConfig)
            .setAutoDumpHprofMode(mode)
            .setManualDumpTargetActivity(ManualDumpActivity::class.java.name)
            .setManufacture(Build.MANUFACTURER)
            .build()
        ResourcePlugin.activityLeakFixer(app)
        return ResourcePlugin(resourceConfig)
    }

    fun checkPermission(app: Activity?): Boolean {
        // Here, thisActivity is the current activity
        return if (ContextCompat.checkSelfPermission(
                app!!,
                Manifest.permission.READ_CONTACTS
            )
            != PackageManager.PERMISSION_GRANTED
        ) {
            // Permission is not granted
            // Should we show an explanation?
            if (ActivityCompat.shouldShowRequestPermissionRationale(
                    app,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE
                )
            ) {
                // Show an explanation to the user *asynchronously* -- don't block
                // this thread waiting for the user's response! After the user
                // sees the explanation, try again to request the permission.
            } else {
                // No explanation needed; request the permission
                ActivityCompat.requestPermissions(
                    app,
                    arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
                    1
                )
                // MY_PERMISSIONS_REQUEST_READ_CONTACTS is an
                // app-defined int constant. The callback method gets the
                // result of the request.
            }
            false
        } else {
            // Permission has already been granted
            true
        }
    }

    private fun configureMatrixLifecycle(): MatrixLifecycleConfig {
        return MatrixLifecycleConfig(
            SupervisorConfig(true, true, ArrayList()),
            true,
            true,
            LifecycleThreadConfig()
        )
    }
}
