package com.didichuxing.doraemonkit.database

import androidx.room.AutoMigration
import androidx.room.Database
import androidx.room.RoomDatabase

@Database(
    entities = [
        Counter::class,
        NetworkRecordDBEntity::class,
        FpsEntity::class,
        MemoryEntity::class,
        LocationEntity::class,
        CpuEntity::class,
    ],
    version = 1,
    exportSchema = true,
    autoMigrations = [
//        AutoMigration(from = 1, to = 2),
    ]
)
abstract class WclDatabase : RoomDatabase() {
    abstract fun wclDao(): WclDao
}
