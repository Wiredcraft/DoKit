package com.didichuxing.doraemonkit.kit.webdoor.bean

import com.didichuxing.doraemonkit.database.BlockEntity

data class BlockBean(
    val duration: Long,
    val info: String,
    val count: Int,
)

fun convertToBlockFrom(cpuEntities: List<BlockEntity>): List<BlockBean> {
    return cpuEntities.filter { !isDoKitClass(it.info) }.groupBy { it.info }.entries.map {
        val avgDuration = it.value.map { it.timeCost }.average()
        BlockBean(avgDuration.toLong(), it.key, it.value.size)
    }.sortedByDescending { it.duration }.take(5)
}
