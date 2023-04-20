package com.didichuxing.doraemonkit.database

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity
data class CpuEntity(
    @PrimaryKey val time: Long,
    @ColumnInfo(defaultValue = "0")
    val usageRate: Long,
    val stackString: String?
)
