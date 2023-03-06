package com.didichuxing.doraemonkit.kit.webdoor.bean

import com.didichuxing.doraemonkit.database.Counter

data class CounterBean(
    val launchCost: Long,
    val time: Long,
    val uid: String
)

fun convertToCounters(counter: List<Counter>): List<CounterBean> {
    val counters = arrayListOf<CounterBean>()

    counter.forEach {
        counters.add(
            CounterBean(
                it.totalCost,
                it.time,
                it.uid.toString()
            )
        )
    }
    return counters
}
