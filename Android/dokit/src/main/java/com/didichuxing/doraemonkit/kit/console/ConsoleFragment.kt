package com.didichuxing.doraemonkit.kit.console

import android.os.Bundle
import android.view.View
import android.widget.Button
import androidx.appcompat.app.AlertDialog
import com.didichuxing.doraemonkit.DoKitReal
import com.didichuxing.doraemonkit.R
import com.didichuxing.doraemonkit.kit.core.BaseFragment
import com.didichuxing.doraemonkit.kit.core.DoKitViewManager
import com.didichuxing.doraemonkit.kit.webdoor.ReportFragment

class ConsoleFragment : BaseFragment() {
    override fun onRequestLayout(): Int {
        return R.layout.dk_fragment_console
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        findViewById<Button>(R.id.btn_template_preview).setOnClickListener {
            DoKitReal.launchFullScreen(ReportFragment::class.java, context)
        }
        findViewById<Button>(R.id.btn_clear_data).setOnClickListener {
            context?.let { con ->
                AlertDialog.Builder(con)
                    .setMessage(R.string.dk_clear_data_inquiry)
                    .setPositiveButton(
                        R.string.dk_confirm,
                    ) { dialog, _ ->
                        DoKitViewManager.INSTANCE.counterDb.clearAllTables()
                        dialog.dismiss()
                    }.setNegativeButton(R.string.dk_cancel) { dialog, _ ->
                        dialog.dismiss()
                    }.show()
            }
        }
    }
}
