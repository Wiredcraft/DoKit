package com.didichuxing.doraemonkit.database

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity
data class MemoryEntity(
    val type: Int,
    val info: String,
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0
)
