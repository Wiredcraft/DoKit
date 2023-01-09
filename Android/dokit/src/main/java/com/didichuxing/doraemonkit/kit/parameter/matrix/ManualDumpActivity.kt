package com.didichuxing.doraemonkit.kit.parameter.matrix

import android.app.Activity
import android.os.Bundle
import android.view.View
import android.widget.TextView
import com.didichuxing.doraemonkit.R
import com.tencent.matrix.resource.config.SharePluginInfo
import com.tencent.matrix.resource.processor.ManualDumpProcessor.ManualDumpData

class ManualDumpActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_manual_dump)
        (findViewById<View>(R.id.leak_activity) as TextView).text =
            intent.getStringExtra(SharePluginInfo.ISSUE_ACTIVITY_NAME)
        (findViewById<View>(R.id.leak_process) as TextView).text =
            intent.getStringExtra(SharePluginInfo.ISSUE_LEAK_PROCESS)
        val data = intent.getParcelableExtra<ManualDumpData>(SharePluginInfo.ISSUE_DUMP_DATA)
        if (data != null) {
            (findViewById<View>(R.id.reference_chain) as TextView).text = data.refChain
        } else {
            (findViewById<View>(R.id.reference_chain) as TextView).text =
                "Empty reference chain."
        }
    }

    companion object {
        private const val TAG = "ManualDumpActivity"
    }
}
