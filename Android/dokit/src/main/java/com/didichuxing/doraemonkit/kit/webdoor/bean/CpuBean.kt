package com.didichuxing.doraemonkit.kit.webdoor.bean

import com.didichuxing.doraemonkit.database.CpuEntity

data class CpuBean(
    val itemList: List<CpuNormalBean>,
    val temporaryAnomalies: List<CpuAnomalyBean>,
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
)

fun convertToCpuFrom(cpuEntities: List<CpuEntity>): CpuBean {
    return CpuBean(
        cpuEntities.map {
            CpuNormalBean(it.time, it.usageRate)
        },
        getAnomalies(cpuEntities, 5, 50).take(5),
        getAnomalies(cpuEntities, 15, 30).take(5),
    )
}

fun getAnomalies(cpuEntities: List<CpuEntity>, count: Int, minCpuUsageRate: Long): List<CpuAnomalyBean> {
    val tmpList = mutableListOf<CpuEntity>()
    val list = mutableListOf<CpuAnomalyBean>()
    cpuEntities.forEach {
        if (it.usageRate >= minCpuUsageRate) {
            tmpList.add(it)
        } else {
            if (tmpList.size >= count) {
                var sum = 0L
                var max = 0L
                tmpList.forEach {
                    sum += it.usageRate
                    if (it.usageRate > max) {
                        max = it.usageRate
                    }
                }
                list.add(CpuAnomalyBean("${tmpList[0]}-${tmpList[tmpList.size - 1]}", sum / tmpList.size, max))
            }
            tmpList.clear()
        }
    }
    return list
}


