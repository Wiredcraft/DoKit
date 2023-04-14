package com.didichuxing.doraemonkit.kit.webdoor

import android.annotation.SuppressLint
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.View
import android.webkit.ConsoleMessage
import android.webkit.DownloadListener
import android.webkit.WebChromeClient
import android.webkit.WebSettings
import androidx.appcompat.widget.AppCompatButton
import com.didichuxing.doraemonkit.R
import com.didichuxing.doraemonkit.database.*
import com.didichuxing.doraemonkit.kit.core.BaseFragment
import com.didichuxing.doraemonkit.kit.core.DoKitManager
import com.didichuxing.doraemonkit.kit.core.DoKitViewManager.Companion.INSTANCE
import com.didichuxing.doraemonkit.kit.webdoor.bean.*
import com.didichuxing.doraemonkit.util.AppUtils
import com.didichuxing.doraemonkit.util.GsonUtils
import com.github.lzyzsd.jsbridge.BridgeWebView
import java.util.*

class ReportFragment : BaseFragment() {

    lateinit var mWebView: BridgeWebView

    override fun onRequestLayout(): Int {
        return R.layout.dk_fragment_web_door_default
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        initWebView()
        findViewById<AppCompatButton>(R.id.button).visibility = View.GONE

        context?.getString(R.string.dk_page_tested)?.let { url ->
            mWebView.loadUrl(url)
            init()
        }
    }

    private fun init() {
        val fpsEntities = INSTANCE.counterDb.wclDao().getAllFpsEntity()
        val networkRecordDBEntities = INSTANCE.counterDb.wclDao().getAllNetWork()
        val counters = INSTANCE.counterDb.wclDao().getAllCounter()
        val memoryEntities = INSTANCE.counterDb.wclDao().getAllMemoryEntity()
        val locationEntities = INSTANCE.counterDb.wclDao().getAllLocationEntity()
        val cpuEntities = INSTANCE.counterDb.wclDao().getAllCpuEntity()

        var jsBridgeBean: JsbridgeBean? = null
        val appName = "${AppUtils.getAppName()} v${
            AppUtils.getAppVersionName()
        }(${AppUtils.getAppVersionCode()})"
        val deviceInfo = "${Build.MANUFACTURER} ${Build.MODEL}, Android ${Build.VERSION.RELEASE}"
        jsBridgeBean = JsbridgeBean(
            appName, deviceInfo,
            convertToFpsFromList(fpsEntities),
            convertToNetWorkFrom(networkRecordDBEntities),
            convertToNetWorkFlowFrom(networkRecordDBEntities),
            convertToCounters(counters),
            convertToMemoryFromList(memoryEntities),
            convertToLocationFrom(locationEntities),
            convertToCpuFrom(cpuEntities),
        )
        Log.i(TAG, "jsBridgeBean.cpuData: ${jsBridgeBean.cpuData}")
        val b = GsonUtils.toJson(jsBridgeBean)
        DoKitManager.CALLBACK?.onPdfCallBack(b)
        mWebView.callHandler(
            "testJavascriptHandler", b.replace("%22","")
        ) { data -> Log.i(TAG, "call succeed,return value is $data") }
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun initWebView() {
        mWebView = findViewById<BridgeWebView>(R.id.webview)
        mWebView.settings.allowFileAccess = true
        mWebView.settings.setAppCacheEnabled(true)
        mWebView.settings.databaseEnabled = true
        // 开启 localStorage
        mWebView.settings.domStorageEnabled = true
        mWebView.settings.cacheMode = WebSettings.LOAD_DEFAULT
        // 设置支持javascript
        mWebView.settings.javaScriptEnabled = true
        // 进行缩放
        mWebView.settings.builtInZoomControls = true
        mWebView.settings.setAppCachePath(Objects.requireNonNull(context)?.cacheDir?.absolutePath)
        // 设置UserAgent
        mWebView.settings.setUserAgentString(mWebView.settings.userAgentString + "app")
        // 设置不用系统浏览器打开,直接显示在当前WebView
        mWebView.setWebChromeClient(object : WebChromeClient() {
            override fun onConsoleMessage(consoleMessage: ConsoleMessage): Boolean {
                Log.i(
                    TAG, consoleMessage.message() + " -- From line "
                        + consoleMessage.lineNumber() + " of "
                        + consoleMessage.sourceId()
                )
                return true
            }
        })

        // 2. 添加JavascriptInterface
        val mDownloadBlobFileJSInterface = DownloadBlobFileJSInterface(context)
        mWebView.addJavascriptInterface(mDownloadBlobFileJSInterface, "Android")
        //        mWebView.setWebViewClient(new MyWebViewClient(mWebView!!));
        mWebView.setDownloadListener(DownloadListener { url, s1, s2, s3, l -> // 3. 执行JS代码
            mWebView.loadUrl(DownloadBlobFileJSInterface.getBase64StringFromBlobUrl(url))
        })
    }

    override fun onBackPressed(): Boolean {
        return if (mWebView.canGoBack()) {
            mWebView.goBack()
            true
        } else {
            super.onBackPressed()
        }
    }
}
