package com.didichuxing.doraemonkit.kit.webdoor.bean

import com.didichuxing.doraemonkit.database.NetworkRecordDBEntity

data class NetWorkBean(
    val downloadDataRank: List<LongValuePair>,
    val failReqCountRank: List<IntValuePair>,
    val reqCountRank: List<IntValuePair>,
    val reqTimeRank: List<LongValuePair>,
    val requestAverageTime: Long,
    val requestSuccessRate: Double,
    val slowRequestCount: Int,
    val summaryRequestCount: Int,
    val summaryRequestDownFlow: Long,
    val summaryRequestTime: Long,
    val summaryRequestUploadFlow: Long,
    val uploadDataRank: List<LongValuePair>,
)

data class NetWorkFlowBean(
    val time: Long,
    val duration: Long
)

private const val NETWORK_DATA_MAXSIZE = 5
private const val NETWORK_SLOW_REQUEST = 2000

fun convertToNetWorkFrom(list: List<NetworkRecordDBEntity>): NetWorkBean {
    val failReqCountRank = mutableListOf<LongValueBean>()
    val reqTimeRank = mutableListOf<LongValueBean>()
    val uploadDataRank = mutableListOf<LongValueBean>()
    val downloadDataRank = mutableListOf<LongValueBean>()
    var requestAverageTime = 0L
    var requestSuccessRate = 0.0
    var slowRequestCount = 0
    var summaryRequestCount = 0
    var failReqCount = 0
    var summaryRequestDownFlow = 0L
    var summaryRequestTime = 0L
    var summaryRequestUploadFlow = 0L
    list.forEach { net ->

        if (net.url.contains("dokit")) {
            return@forEach
        }

        if (net.responseLength > 0) {
            downloadDataRank.log("${net.method} ${net.url}", net.responseLength)
        }
        if (!net.isSuccess) {
            failReqCountRank.log("${net.method} ${net.url}", net.responseLength)
            failReqCount++
        }
        if (net.requestLength > 0) {
            uploadDataRank.log("${net.method} ${net.url}", net.requestLength)
        }

        reqTimeRank.log("${net.method} ${net.url}", net.endTime - net.startTime)

        if ((net.endTime - net.startTime) >= NETWORK_SLOW_REQUEST) {
            slowRequestCount++
        }
        summaryRequestCount++
        summaryRequestDownFlow += net.requestLength
        summaryRequestUploadFlow += net.responseLength
        summaryRequestTime += net.endTime - net.startTime
    }

    if (summaryRequestCount != 0) {
        requestAverageTime = summaryRequestTime / summaryRequestCount
        requestSuccessRate = (summaryRequestCount - failReqCount).toDouble() / summaryRequestCount
    }
    return NetWorkBean(
        downloadDataRank = downloadDataRank.toAvgRank(),
        failReqCountRank = failReqCountRank.toCount(),
        reqCountRank = reqTimeRank.toCount(),
        reqTimeRank = reqTimeRank.toAvgRank(),
        requestAverageTime = requestAverageTime,
        requestSuccessRate = requestSuccessRate,
        slowRequestCount = slowRequestCount,
        summaryRequestCount = summaryRequestCount,
        summaryRequestDownFlow = summaryRequestDownFlow,
        summaryRequestTime = summaryRequestTime,
        summaryRequestUploadFlow = summaryRequestUploadFlow,
        uploadDataRank = uploadDataRank.toAvgRank(),
    )
}

fun MutableList<LongValueBean>.log(url: String, value: Long) {
    firstOrNull { it.key == url }?.let {
        it.value += value
        it.count++
    } ?: run {
        add(LongValueBean(url, value, 1))
    }
}

fun MutableList<LongValueBean>.toAvgRank(): List<LongValuePair> {
    return map { LongValuePair(it.key, it.value / it.count) }.sortedByDescending { it.value }.take(NETWORK_DATA_MAXSIZE)
}

fun MutableList<LongValueBean>.toCount(): List<IntValuePair> {
    return map { IntValuePair(it.key, it.count) }.sortedByDescending { it.value }.take(NETWORK_DATA_MAXSIZE)
}

fun convertToNetWorkFlowFrom(list: List<NetworkRecordDBEntity>): List<NetWorkFlowBean> {
    return list.filter { !it.url.contains("dokit") }.map {
        NetWorkFlowBean(it.startTime, it.endTime - it.startTime)
    }
}

data class LongValueBean(
    val key: String,
    var value: Long,
    var count: Int,
)

data class LongValuePair(
    val key: String,
    val value: Long,
)

data class IntValuePair(
    val key: String,
    val value: Int,
)
