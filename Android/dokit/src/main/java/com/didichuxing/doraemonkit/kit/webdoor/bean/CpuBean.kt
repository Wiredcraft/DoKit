package com.didichuxing.doraemonkit.kit.webdoor.bean

import com.didichuxing.doraemonkit.database.CpuEntity
import com.didichuxing.doraemonkit.kit.performance.CpuUtil

data class CpuBean(
    val itemList: List<CpuNormalBean>,
    val anomalies: List<CpuAnomalyBean>,
)

data class CpuNormalBean(
    val time: Long,
    val usageRate: Long,
)

data class CpuAnomalyBean(
    val beginEndTime: String,
    val averageCpuUsageRate: Long,
    val maxCpuUsageRate: Long,
    val count: Int,
)

fun convertToCpuFrom(cpuEntities: List<CpuEntity>): CpuBean {
    return CpuBean(
        cpuEntities.map {
            CpuNormalBean(it.time, it.usageRate)
        },
        getAnomalies(cpuEntities, 15, CpuUtil.RECORD_ANOMALY_THRESHOLD).take(5),
    )
}

fun getAnomalies(cpuEntities: List<CpuEntity>, count: Int, minCpuUsageRate: Long): List<CpuAnomalyBean> {
    val tmpList = mutableListOf<CpuEntity>()
    val list = mutableListOf<CpuAnomalyBean>()
    cpuEntities.forEach { ce ->
        if (ce.usageRate >= minCpuUsageRate) {
            tmpList.add(ce)
        } else {
            if (tmpList.size >= count) {
                var sum = 0L
                var max = 0L
                tmpList.forEach { tce ->
                    sum += tce.usageRate
                    if (tce.usageRate > max) {
                        max = tce.usageRate
                    }
                }
                list.add(
                    CpuAnomalyBean(
                        beginEndTime = "${tmpList[0]}-${tmpList[tmpList.size - 1]}",
                        averageCpuUsageRate = sum / tmpList.size,
                        maxCpuUsageRate = max,
                        count = tmpList.size,
                    )
                )
            }
            tmpList.clear()
        }
    }
    return list
}
