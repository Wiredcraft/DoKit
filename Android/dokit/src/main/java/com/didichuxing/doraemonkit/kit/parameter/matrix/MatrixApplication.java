package com.didichuxing.doraemonkit.kit.parameter.matrix;

import android.Manifest;
import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.util.Log;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.didichuxing.doraemonkit.kit.parameter.matrix.config.DynamicConfigImplDemo;
import com.didichuxing.doraemonkit.kit.parameter.matrix.listener.TestPluginListener;
import com.tencent.matrix.Matrix;
//import com.tencent.matrix.backtrace.WarmUpReporter;
//import com.tencent.matrix.backtrace.WeChatBacktrace;
import com.tencent.matrix.backtrace.WarmUpReporter;
import com.tencent.matrix.backtrace.WeChatBacktrace;
import com.tencent.matrix.hook.HookManager;
import com.tencent.matrix.hook.memory.MemoryHook;
import com.tencent.matrix.hook.pthread.PthreadHook;
import com.tencent.matrix.lifecycle.LifecycleThreadConfig;
import com.tencent.matrix.lifecycle.MatrixLifecycleConfig;
import com.tencent.matrix.lifecycle.supervisor.SupervisorConfig;
import com.tencent.matrix.memory.canary.MemoryCanaryPlugin;
import com.tencent.matrix.memory.canary.trim.TrimCallback;
import com.tencent.matrix.memory.canary.trim.TrimMemoryNotifier;
//import com.tencent.matrix.resource.ResourcePlugin;
//import com.tencent.matrix.resource.config.ResourceConfig;
import com.tencent.matrix.resource.ResourcePlugin;
import com.tencent.matrix.resource.config.ResourceConfig;
import com.tencent.matrix.util.MatrixLog;

import java.util.ArrayList;

import sample.tencent.matrix.kt.lifecycle.MatrixLifecycleLogger;
import com.didichuxing.doraemonkit.kit.parameter.matrix.canary.MemoryCanaryBoot;

public class MatrixApplication {
    private static final String TAG = "Matrix.Application";

    public static boolean is64BitRuntime() {
        final String currRuntimeABI = Build.CPU_ABI;
        return "arm64-v8a".equalsIgnoreCase(currRuntimeABI)
            || "x86_64".equalsIgnoreCase(currRuntimeABI)
            || "mips64".equalsIgnoreCase(currRuntimeABI);
    }

    public static void initMemoryCanary(Context app){

        // Reporter
        WeChatBacktrace.setReporter((type, args) -> {
            if (type == WarmUpReporter.ReportEvent.WarmedUp) {
                Log.i(TAG, "WeChat QUT has warmed up.");
            } else if (type == WarmUpReporter.ReportEvent.WarmUpDuration && args.length == 1) {
                Log.i(TAG, String.format("WeChat QUT Warm-up duration: %sms", (long) args[0]));
            }
        });


        // Init backtrace
        if (is64BitRuntime()) {
            WeChatBacktrace.instance()
                .configure(app)
                .setBacktraceMode(WeChatBacktrace.Mode.Fp)
                .setQuickenAlwaysOn()
                .commit();
        } else {
            WeChatBacktrace.instance()
                .configure(app)
                .warmUpSettings(WeChatBacktrace.WarmUpTiming.PostStartup, 0)
                .directoryToWarmUp(WeChatBacktrace.getSystemFrameworkOATPath() + "boot.oat")
                .directoryToWarmUp(
                    WeChatBacktrace.getSystemFrameworkOATPath() + "boot-framework.oat")
                .commit();
        }

        // Init Hooks.
        try {

            PthreadHook.INSTANCE
                .addHookThread(".*")
                .setThreadTraceEnabled(true)
                .enableTracePthreadRelease(true)
                .enableQuicken(false);

            PthreadHook.INSTANCE.enableLogger(false);

            HookManager.INSTANCE

                // Memory hook
                .addHook(MemoryHook.INSTANCE
                    .addHookSo(".*libnative-lib\\.so$")
                    .enableStacktrace(true)
                    .stacktraceLogThreshold(0)
                    .enableMmapHook(true)
                )

                // Thread hook
                .addHook(PthreadHook.INSTANCE)
                .commitHooks();
        } catch (HookManager.HookFailedException e) {
            e.printStackTrace();
        }

//        Log.d(TAG,
//            "mallocTest after malloc: native heap:" + Debug.getNativeHeapSize() + ", allocated:"
//                + Debug.getNativeHeapAllocatedSize() + ", free:"
//                + Debug.getNativeHeapFreeSize());
//
//        String output = app.getExternalCacheDir() + "/memory_hook77.log";
//        MemoryHook.INSTANCE.dump(output, output + ".json");
    }


    public static void init(Application app){
        if (!is64BitRuntime()) {
            try {
                final PthreadHook.ThreadStackShrinkConfig config = new PthreadHook.ThreadStackShrinkConfig()
                    .setEnabled(true)
                    .addIgnoreCreatorSoPatterns(".*/app_tbs/.*")
                    .addIgnoreCreatorSoPatterns(".*/libany\\.so$");
                HookManager.INSTANCE.addHook(PthreadHook.INSTANCE.setThreadStackShrinkConfig(config)).commitHooks();
            } catch (HookManager.HookFailedException e) {
                e.printStackTrace();
            }
        }
        // Switch.
       DynamicConfigImplDemo dynamicConfig = new DynamicConfigImplDemo();
        MatrixLog.i(TAG, "============Start Matrix configurations.");
        // Builder. Not necessary while some plugins can be configured separately.
        Matrix.Builder builder = new Matrix.Builder(app);
        // Reporter. Matrix will callback this listener when found issue then emitting it.
        builder.pluginListener(new TestPluginListener(app));
        MemoryCanaryPlugin memoryCanaryPlugin = new MemoryCanaryPlugin(MemoryCanaryBoot.configure(app));
        builder.plugin(memoryCanaryPlugin);
        ResourcePlugin resourcePlugin = configureResourcePlugin(dynamicConfig,app);
        builder.plugin(resourcePlugin);
        builder.matrixLifecycleConfig(configureMatrixLifecycle());
        Matrix.init(builder.build());
        Matrix.with().startAllPlugins();
        MatrixLifecycleLogger.INSTANCE.start();
        TrimMemoryNotifier.INSTANCE.addProcessBackgroundTrimCallback(new TrimCallback() {
            @Override
            public void systemTrim(int i) {
                MatrixLog.d(TAG, "systemTrim: ");
            }

            @Override
            public void backgroundTrim() {
                MatrixLog.d(TAG, "backgroundTrim: ");
            }
        });

        MatrixLog.i(TAG, "=================Matrix configurations done.");

    }

    private static ResourcePlugin configureResourcePlugin(DynamicConfigImplDemo dynamicConfig,Application app) {
        Intent intent = new Intent();
        ResourceConfig.DumpMode mode = ResourceConfig.DumpMode.MANUAL_DUMP;
        MatrixLog.i(TAG, "Dump Activity Leak Mode=%s", mode);
        intent.setClassName(app.getPackageName(), "sample.didichuxing.doraemonkit.kit.parameter.matrix.ManualDumpActivity");
        ResourceConfig resourceConfig = new ResourceConfig.Builder()
            .dynamicConfig(dynamicConfig)
            .setAutoDumpHprofMode(mode)
            .setManualDumpTargetActivity(ManualDumpActivity.class.getName())
            .setManufacture(Build.MANUFACTURER)
            .build();
        ResourcePlugin.activityLeakFixer(app);

        return new ResourcePlugin(resourceConfig);
    }

    public static boolean checkPermission(Activity app) {
        // Here, thisActivity is the current activity
        if (ContextCompat.checkSelfPermission(app,
            Manifest.permission.READ_CONTACTS)
            != PackageManager.PERMISSION_GRANTED) {

            // Permission is not granted
            // Should we show an explanation?
            if (ActivityCompat.shouldShowRequestPermissionRationale(app,
                Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                // Show an explanation to the user *asynchronously* -- don't block
                // this thread waiting for the user's response! After the user
                // sees the explanation, try again to request the permission.
            } else {
                // No explanation needed; request the permission
                ActivityCompat.requestPermissions(app,
                    new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE},
                    1);
                // MY_PERMISSIONS_REQUEST_READ_CONTACTS is an
                // app-defined int constant. The callback method gets the
                // result of the request.
            }
            return false;
        } else {
            // Permission has already been granted
            return true;
        }
    }
    private  static MatrixLifecycleConfig configureMatrixLifecycle() {
        return new MatrixLifecycleConfig(new SupervisorConfig(true, true, new ArrayList<String>()), true, true, new LifecycleThreadConfig());
    }
}
