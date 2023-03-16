package com.didichuxing.doraemonkit.kit.webdoor;

import android.annotation.SuppressLint;
import android.os.Build;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatButton;

import android.util.Log;
import android.view.View;
import android.webkit.ConsoleMessage;
import android.webkit.DownloadListener;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;

import com.didichuxing.doraemonkit.R;
import com.didichuxing.doraemonkit.database.Counter;
import com.didichuxing.doraemonkit.database.FpsEntity;
import com.didichuxing.doraemonkit.database.LocationEntity;
import com.didichuxing.doraemonkit.database.LocationEntityKt;
import com.didichuxing.doraemonkit.database.MemoryEntity;
import com.didichuxing.doraemonkit.database.NetworkRecordDBEntity;
import com.didichuxing.doraemonkit.kit.core.BaseFragment;
import com.didichuxing.doraemonkit.kit.core.DoKitViewManager;
import com.didichuxing.doraemonkit.kit.webdoor.bean.CounterBeanKt;
import com.didichuxing.doraemonkit.kit.webdoor.bean.FpsBeanKt;
import com.didichuxing.doraemonkit.kit.webdoor.bean.JsbridgeBean;
import com.didichuxing.doraemonkit.kit.webdoor.bean.MemoryLeakBeanKt;
import com.didichuxing.doraemonkit.kit.webdoor.bean.NetWorkBeanKt;
import com.didichuxing.doraemonkit.kit.webview.WebViewManager;
import com.didichuxing.doraemonkit.util.GsonUtils;
import com.github.lzyzsd.jsbridge.BridgeWebView;
import com.github.lzyzsd.jsbridge.CallBackFunction;

import java.util.List;
import java.util.Objects;

/**
 * Created by wanglikun on 2019/4/4
 */
public class WebDoorDefaultFragment extends BaseFragment {

    //private String mUrl;

    private BridgeWebView mWebView;

    @Override
    protected int onRequestLayout() {
        return R.layout.dk_fragment_web_door_default;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //mUrl = getArguments() == null ? null : getArguments().getString(BundleKey.KEY_URL);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initWebView();
        AppCompatButton button = findViewById(R.id.button);
        List<FpsEntity> fpsEntities = DoKitViewManager.getINSTANCE().getCounterDb().wclDao().getAllFpsEntity();
        List<NetworkRecordDBEntity> networkRecordDBEntities = DoKitViewManager.getINSTANCE().getCounterDb().wclDao().getAllNetWork();
        List<Counter> counters = DoKitViewManager.getINSTANCE().getCounterDb().wclDao().getAllCounter();
        List<MemoryEntity> memoryEntities = DoKitViewManager.getINSTANCE().getCounterDb().wclDao().getAllMemoryEntity();
        List<LocationEntity> locationEntities = DoKitViewManager.getINSTANCE().getCounterDb().wclDao().getAllLocationEntity();

        if (WebViewManager.INSTANCE.getUrl() != null && !WebViewManager.INSTANCE.getUrl().isEmpty()) {
            mWebView.loadUrl(WebViewManager.INSTANCE.getUrl());
            button.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    JsbridgeBean fpsJsBridgeBean = null;
                    fpsJsBridgeBean = new JsbridgeBean("Android", Build.DEVICE +" , "+ Build.VERSION.SDK_INT,
                        FpsBeanKt.convertToFpsFromList(fpsEntities),
                        NetWorkBeanKt.convertToNetWorkFrom(networkRecordDBEntities),
                        CounterBeanKt.convertToCounters(counters),
                        MemoryLeakBeanKt.convertToMemoryFromList(memoryEntities),
                        LocationEntityKt.convertToLocationFrom(locationEntities)
                    );
                    mWebView.callHandler("testJavascriptHandler", GsonUtils.toJson(fpsJsBridgeBean), new CallBackFunction() {
                        @Override
                        public void onCallBack(String data) {
                            Log.i(TAG, "call succeed,return value is " + data);
                        }
                    });
                }
            });
        }
    }

    @SuppressLint("SetJavaScriptEnabled")
    private void initWebView() {
        mWebView = findViewById(R.id.webview);

        mWebView.getSettings().setAllowFileAccess(true);
        mWebView.getSettings().setAppCacheEnabled(true);
        mWebView.getSettings().setDatabaseEnabled(true);
        // 开启 localStorage
        mWebView.getSettings().setDomStorageEnabled(true);
        mWebView.getSettings().setCacheMode(WebSettings.LOAD_DEFAULT);
        // 设置支持javascript
        mWebView.getSettings().setJavaScriptEnabled(true);
        // 进行缩放
        mWebView.getSettings().setBuiltInZoomControls(true);
        mWebView.getSettings().setAppCachePath(Objects.requireNonNull(getContext()).getCacheDir().getAbsolutePath());
        // 设置UserAgent
        mWebView.getSettings().setUserAgentString(mWebView.getSettings().getUserAgentString() + "app");
        // 设置不用系统浏览器打开,直接显示在当前WebView
        mWebView.setWebChromeClient(new WebChromeClient() {
            @Override
            public boolean onConsoleMessage(ConsoleMessage consoleMessage) {
                Log.i(TAG, consoleMessage.message() + " -- From line "
                    + consoleMessage.lineNumber() + " of "
                    + consoleMessage.sourceId());
                return true;
            }
        });

        // 2. 添加JavascriptInterface
        DownloadBlobFileJSInterface mDownloadBlobFileJSInterface = new DownloadBlobFileJSInterface(getContext());
        mWebView.addJavascriptInterface(mDownloadBlobFileJSInterface, "Android");
//        mWebView.setWebViewClient(new MyWebViewClient(mWebView!!));
        mWebView.setDownloadListener(new DownloadListener() {
            @Override
            public void onDownloadStart(String url, String s1, String s2, String s3, long l) {
                // 3. 执行JS代码
                mWebView.loadUrl(DownloadBlobFileJSInterface.getBase64StringFromBlobUrl(url));
            }
        });
    }

    @Override
    public boolean onBackPressed() {
        if (mWebView.canGoBack()) {
            mWebView.goBack();
            return true;
        } else {
            return super.onBackPressed();
        }
    }
}
