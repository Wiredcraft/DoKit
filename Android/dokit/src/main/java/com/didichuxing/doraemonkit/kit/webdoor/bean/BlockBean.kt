package com.didichuxing.doraemonkit.kit.webdoor.bean

import com.didichuxing.doraemonkit.database.BlockEntity

data class BlockBean(
    val duration: Long,
    val info: String,
)

fun convertToBlockFrom(cpuEntities: List<BlockEntity>): List<BlockBean> {
    return cpuEntities.map {
        BlockBean(it.timeCost, it.info)
    }
}
