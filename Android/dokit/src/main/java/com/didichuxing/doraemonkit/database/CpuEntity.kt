package com.didichuxing.doraemonkit.database

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity
data class CpuEntity(
    @PrimaryKey val time: Long,
    val usageRate: Long,
)
