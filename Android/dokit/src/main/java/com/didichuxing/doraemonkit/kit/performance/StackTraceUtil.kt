package com.didichuxing.doraemonkit.kit.performance

import android.content.Context
import android.text.TextUtils
import com.didichuxing.doraemonkit.util.DoKitSystemUtil

object StackTraceUtil {

    private var sProcessName: String? = null
    private var sProcessNameFirstGetFlag = false

    fun concernStackString(context: Context, stackTraceElements: Array<StackTraceElement>?): String {
        val result = ""
        stackTraceElements?.let {
            it.forEach { stackEntry ->
                if (!TextUtils.isEmpty(stackEntry.toString())) {
                    val line = stackEntry.toString()
                    val keyStackString = concernStackStringSub(context, line)
                    if (keyStackString != null) {
                        return keyStackString
                    }
                }
            }
            return classSimpleName(it.getOrNull(0)?.toString().orEmpty())
        }
        return result
    }

    private fun concernStackStringSub(context: Context, line: String?): String? {
        if (line == null) {
            return null
        }
        if (!sProcessNameFirstGetFlag) {
            sProcessNameFirstGetFlag = true
            sProcessName = DoKitSystemUtil.obtainProcessName(context)
        }
        return if (sProcessName == null || line.startsWith(sProcessName.orEmpty())) {
            classSimpleName(line)
        } else null
    }

    private fun classSimpleName(stackLine: String): String {
        val index1 = stackLine.indexOf('(')
        val index2 = stackLine.indexOf(')')
        return if (index1 >= 0 && index2 >= 0) {
            stackLine.substring(index1 + 1, index2)
        } else stackLine
    }
}
