package com.didichuxing.doraemonkit.kit.webdoor.bean

import android.os.Build
import androidx.annotation.RequiresApi
import com.didichuxing.doraemonkit.database.MemoryEntity

data class MemoryLeakBean(
    var count: Int,
    val info: String
)

@RequiresApi(Build.VERSION_CODES.N)
fun convertToMemoryFromList(memoryLeaks: MutableList<MemoryEntity>): ArrayList<MemoryLeakBean> {
    val memoryMap = mutableMapOf<Int, MemoryLeakBean>()
    val memoryList = arrayListOf<MemoryLeakBean>()

    memoryLeaks.forEach { m ->
        val contains = memoryMap.contains(m.type)
        if (contains) {
            val memoryLeak = memoryMap[m.type]
            memoryLeak?.count = memoryLeak?.count?.plus(1) ?: 1
        } else {
            memoryMap.put(m.type, MemoryLeakBean(1, m.info))
        }
    }
    memoryMap.forEach { (_, memoryLeak) ->
        memoryList.add(memoryLeak)
    }
    return memoryList
}
