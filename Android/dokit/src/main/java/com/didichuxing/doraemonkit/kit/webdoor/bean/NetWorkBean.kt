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
    val uploadDataRank: List<UploadDataRank>
)

fun convertToNetWorkFrom(list: List<NetworkRecordDBEntity>): NetWorkBean {
    val maxSize = 5
    val limiTime = 1000 * 60 * 60
    val downloadDataRank = ArrayList<DownloadDataRank>(maxSize)
    val failReqCountRank = ArrayList<FailReqCountRank>(maxSize)
    val reqCountRank = ArrayList<ReqCountRank>(maxSize)
    val reqTimeRank = ArrayList<ReqTimeRank>(maxSize)
    var requestAverageTime = 0.0
    var requestSucsessRate = 0.0
    var slowRequestCount = 0
    var summaryRequestCount = 0
    var summaryRequestDownFlow = 0.0
    var summaryRequestTime = 0.0
    var summaryRequestUploadFlow = 0.0
    val uploadDataRank = ArrayList<UploadDataRank>(maxSize)
    list.forEach { net ->
        if (net.responseLength > 0) {
            if (downloadDataRank.size < maxSize) {
                downloadDataRank.add(DownloadDataRank("${net.method} ${net.url}", net.responseLength))
            }
        } else {
            if (failReqCountRank.size < maxSize) {
                failReqCountRank.add(FailReqCountRank("${net.method} ${net.url}", net.responseLength))
            }
        }
        if (net.requestLength > 0) {
            if (uploadDataRank.size < maxSize) {
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
            if (reqTimeRank.size < maxSize) {
                reqTimeRank.add(ReqTimeRank(net.url, (net.endTime - net.startTime)))
            }
        }

        if ((net.startTime - net.endTime) > limiTime) {
            slowRequestCount++
        }
        summaryRequestCount++
        summaryRequestDownFlow += net.requestLength
        summaryRequestUploadFlow += net.responseLength
        summaryRequestTime += ((net.startTime - net.endTime) / 1000 / 60 / 60)
    }

    requestAverageTime = summaryRequestTime / summaryRequestCount
    requestSucsessRate = failReqCountRank.size.toDouble() / summaryRequestCount
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
        uploadDataRank
    )
}

data class DownloadDataRank(
    val key: String,
    val value: Long
)

data class FailReqCountRank(
    val key: String,
    val value: Long
)

data class ReqCountRank(
    val key: String,
    var value: Int
)

data class ReqTimeRank(
    val key: String,
    var value: Long
)

data class UploadDataRank(
    val key: String,
    val value: Long
)
