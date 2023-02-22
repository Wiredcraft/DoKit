package com.didichuxing.doraemonkit.database

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query

@Dao
interface WclDao {
    @Query("SELECT * FROM counter")
    fun getAllCounter(): List<Counter>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertCounter(counter: Counter)

    @Query("SELECT * FROM networkrecorddbentity")
    fun getAllNetWork(): List<NetworkRecordDBEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertNetworkRequest(networkReqDBEntity: NetworkRecordDBEntity)

    @Query("SELECT * FROM fpsEntity")
    fun getAllFpsEntity(): List<FpsEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertFps(fpsEntity: FpsEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertMemory(memoryEntity: MemoryEntity)

    @Query("SELECT * FROM memoryEntity")
    fun getAllMemoryEntity(): List<MemoryEntity>
}
