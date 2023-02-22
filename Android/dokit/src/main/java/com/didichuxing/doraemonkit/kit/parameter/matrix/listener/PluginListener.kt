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
package com.didichuxing.doraemonkit.kit.parameter.matrix.listener

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.widget.Toast
import com.didichuxing.doraemonkit.database.FpsEntity
import com.didichuxing.doraemonkit.database.MemoryEntity
import com.didichuxing.doraemonkit.kit.core.DoKitViewManager.Companion.INSTANCE
import com.didichuxing.doraemonkit.kit.parameter.matrix.issue.IssueFilter
import com.didichuxing.doraemonkit.kit.parameter.matrix.issue.IssuesMap
import com.tencent.matrix.plugin.DefaultPluginListener
import com.tencent.matrix.report.Issue
import com.tencent.matrix.util.MatrixLog
import java.lang.ref.SoftReference

class PluginListener(context: Context) : DefaultPluginListener(context) {
    var softReference: SoftReference<Context>
    private val mHandler = Handler(Looper.getMainLooper())

    init {
        softReference = SoftReference(context)
    }

    override fun onReportIssue(issue: Issue) {
        super.onReportIssue(issue)
        MatrixLog.e(TAG, issue.toString())
        IssuesMap.put(IssueFilter.getCurrentFilter(), issue)
        mHandler.post { showToast(issue) }
        INSTANCE.counterDb.wclDao().insertMemory(MemoryEntity(type = issue.type, info = issue.toString()))
    }

    private fun showToast(issue: Issue) {
        val message = String.format("Report an issue - [%s].", issue.tag)
        val context = softReference.get()
        if (context != null) {
            Toast.makeText(context, message, Toast.LENGTH_LONG)
        }
    }

    companion object {
        const val TAG = "PluginListener:"
    }
}
