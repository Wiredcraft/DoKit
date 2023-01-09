/*
 * Tencent is pleased to support the open source community by making wechat-matrix available.
 * Copyright (C) 2018 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the BSD 3-Clause License (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/**
 * @author zhoushaotao
 * Created by zhoushaotao on 2018/10/9.
 */
package com.didichuxing.doraemonkit.kit.parameter.matrix.config

import android.util.Log
import com.tencent.mrs.plugin.IDynamicConfig
import com.tencent.mrs.plugin.IDynamicConfig.ExptEnum
import com.tencent.matrix.util.MatrixLog
import java.util.concurrent.TimeUnit

class DynamicConfigImpl : IDynamicConfig {
    val isFPSEnable: Boolean
        get() = true
    val isTraceEnable: Boolean
        get() = true
    val isSignalAnrTraceEnable: Boolean
        get() = true
    val isMatrixEnable: Boolean
        get() = true

    override fun get(key: String, defStr: String): String {
        //TODO here return default value which is inside sdk, you can change it as you wish. matrix-sdk-key in class MatrixEnum.

        // for Activity leak detect
        if (ExptEnum.clicfg_matrix_resource_detect_interval_millis.name == key || ExptEnum.clicfg_matrix_resource_detect_interval_millis_bg.name == key) {
            Log.d(
                "DynamicConfig",
                "Matrix.ActivityRefWatcher: clicfg_matrix_resource_detect_interval_millis 10s"
            )
            return TimeUnit.SECONDS.toMillis(5).toString()
        }
        if (ExptEnum.clicfg_matrix_resource_max_detect_times.name == key) {
            Log.d(
                "DynamicConfig",
                "Matrix.ActivityRefWatcher: clicfg_matrix_resource_max_detect_times 5"
            )
            return 3.toString()
        }
        return defStr
    }

    override fun get(key: String, defInt: Int): Int {
        //TODO here return default value which is inside sdk, you can change it as you wish. matrix-sdk-key in class MatrixEnum.
        if (MatrixEnum.clicfg_matrix_resource_max_detect_times.name == key) {
            MatrixLog.i(TAG, "key:$key, before change:$defInt, after change, value:2")
            return 2 //new value
        }
        if (MatrixEnum.clicfg_matrix_trace_fps_report_threshold.name == key) {
            return 10000
        }
        return if (MatrixEnum.clicfg_matrix_trace_fps_time_slice.name == key) {
            12000
        } else defInt
    }

    override fun get(key: String, defLong: Long): Long {
        //TODO here return default value which is inside sdk, you can change it as you wish. matrix-sdk-key in class MatrixEnum.
        if (MatrixEnum.clicfg_matrix_trace_fps_report_threshold.name == key) {
            return 10000L
        }
        if (MatrixEnum.clicfg_matrix_resource_detect_interval_millis.name == key) {
            MatrixLog.i(TAG, "$key, before change:$defLong, after change, value:2000")
            return 2000
        }
        return defLong
    }

    override fun get(key: String, defBool: Boolean): Boolean {
        //TODO here return default value which is inside sdk, you can change it as you wish. matrix-sdk-key in class MatrixEnum.
        return defBool
    }

    override fun get(key: String, defFloat: Float): Float {
        //TODO here return default value which is inside sdk, you can change it as you wish. matrix-sdk-key in class MatrixEnum.
        return defFloat
    }

    companion object {
        private const val TAG = "Matrix.DynamicConfigImplDemo"
    }
}
