package com.didichuxing.doraemonkit.kit.webdoor.bean

import androidx.annotation.Keep

@Keep
data class FpsJsBridgeBean(
    val fps: Fps
): java.io.Serializable {

    @Keep
    data class Fps(
        val xValues: DoubleArray,
        val data: IntArray,
    )
}
