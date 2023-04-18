package com.didichuxing.doraemonkit.database

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity
data class BlockEntity(
    val time: Long,
    val timeCost: Long,
    val info: String,
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
)
