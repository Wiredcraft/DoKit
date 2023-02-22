package com.didichuxing.doraemonkit.database

import androidx.room.Database
import androidx.room.RoomDatabase

@Database(
    entities = [
        Counter::class,
        NetworkRecordDBEntity::class,
        FpsEntity::class,
        MemoryEntity::class,
    ], version = 4, exportSchema = false
)
abstract class WclDatabase : RoomDatabase() {
    abstract fun wclDao(): WclDao
}
