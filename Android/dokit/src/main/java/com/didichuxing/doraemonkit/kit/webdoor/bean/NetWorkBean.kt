package com.didichuxing.doraemonkit.kit.webdoor.bean

import com.didichuxing.doraemonkit.database.NetworkRecordDBEntity

data class NetWorkBean(
    val downloadDataRank: List<DownloadDataRank>,
    val failReqCountRank: List<FailReqCountRank>,
    val reqCountRank: List<ReqCountRank>,
    val reqTimeRank: List<ReqTimeRank>,
    val requestAverageTime: Double,
    val requestSucsessRate: Double,
    val slowRequestCount: Int,
    val summaryRequestCount: Int,
    val summaryRequestDownFlow: String,
    val summaryRequestTime: Double,
    val summaryRequestUploadFlow: String,
    val uploadDataRank: List<UploadDataRank>,
)

data class NetWorkFlowBean(
    val time: Long,
    val duration: Long
)

private const val NETWORK_DATA_MAXSIZE = 5
private const val ONE_HOUR_IN_MILLISECOND = 1000 * 60 * 60

fun convertToNetWorkFrom(list: List<NetworkRecordDBEntity>): NetWorkBean {
    val downloadDataRank = ArrayList<DownloadDataRank>(NETWORK_DATA_MAXSIZE)
    val failReqCountRank = ArrayList<FailReqCountRank>(NETWORK_DATA_MAXSIZE)
    val reqCountRank = ArrayList<ReqCountRank>(NETWORK_DATA_MAXSIZE)
    val reqTimeRank = ArrayList<ReqTimeRank>(NETWORK_DATA_MAXSIZE)
    var requestAverageTime = 0.0
    var requestSucsessRate = 0.0
    var slowRequestCount = 0
    var summaryRequestCount = 0
    var summaryRequestDownFlow = 0.0
    var summaryRequestTime = 0.0
    var summaryRequestUploadFlow = 0.0
    val uploadDataRank = ArrayList<UploadDataRank>(NETWORK_DATA_MAXSIZE)
    list.forEach { net ->

        if (net.url.contains("dokit")) {
            return@forEach
        }

        if (net.responseLength > 0) {
            if (downloadDataRank.size < NETWORK_DATA_MAXSIZE) {
                downloadDataRank.add(DownloadDataRank("${net.method} ${net.url}", net.responseLength))
            }
        } else {
            if (failReqCountRank.size < NETWORK_DATA_MAXSIZE) {
                failReqCountRank.add(FailReqCountRank("${net.method} ${net.url}", net.responseLength))
            }
        }
        if (net.requestLength > 0) {
            if (uploadDataRank.size < NETWORK_DATA_MAXSIZE) {
                uploadDataRank.add(UploadDataRank("${net.method} ${net.url}", net.requestLength))
            }
        }

        if (reqCountRank.any { it.key == net.url }) {
            reqCountRank.forEach {
                if (it.key == net.url) {
                    it.value++
                }
            }
        } else {
            reqCountRank.add(ReqCountRank(net.url, 1))
        }

        if (reqTimeRank.any { it.key == net.url }) {
            reqTimeRank.forEach {
                if (it.key == net.url) {
                    it.value = it.value + (net.endTime - net.startTime)
                }
            }
        } else {
            if (reqTimeRank.size < NETWORK_DATA_MAXSIZE) {
                reqTimeRank.add(ReqTimeRank(net.url, (net.endTime - net.startTime)))
            }
        }
        if ((net.startTime - net.endTime) / ONE_HOUR_IN_MILLISECOND > 1000) {
            slowRequestCount++
        }
        summaryRequestCount++
        summaryRequestDownFlow += net.requestLength
        summaryRequestUploadFlow += net.responseLength
        summaryRequestTime += ((net.startTime - net.endTime) / ONE_HOUR_IN_MILLISECOND)
    }

    if (summaryRequestCount != 0) {
        requestAverageTime = summaryRequestTime / summaryRequestCount
        requestSucsessRate = failReqCountRank.size.toDouble() / summaryRequestCount
    }
    return NetWorkBean(
        downloadDataRank,
        failReqCountRank,
        reqCountRank,
        reqTimeRank,
        requestAverageTime,
        requestSucsessRate,
        slowRequestCount,
        summaryRequestCount,
        "$summaryRequestDownFlow kb",
        summaryRequestTime,
        "$summaryRequestUploadFlow kb",
        uploadDataRank,
    )
}

fun convertToNetWorkFlowFrom(list: List<NetworkRecordDBEntity>): List<NetWorkFlowBean> {
    return list.filter { !it.url.contains("dokit") }.map {
        NetWorkFlowBean(it.startTime, it.endTime - it.startTime)
    }
}

data class DownloadDataRank(
    val key: String,
    val value: Long,
)

data class FailReqCountRank(
    val key: String,
    val value: Long,
)

data class ReqCountRank(
    val key: String,
    var value: Int,
)

data class ReqTimeRank(
    val key: String,
    var value: Long,
)

data class UploadDataRank(
    val key: String,
    val value: Long,
)
