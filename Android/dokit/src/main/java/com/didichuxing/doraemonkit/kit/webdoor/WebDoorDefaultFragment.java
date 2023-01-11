package com.didichuxing.doraemonkit.kit.webdoor;

import android.annotation.SuppressLint;
import android.os.Build;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.appcompat.widget.AppCompatButton;

import android.util.Log;
import android.view.View;
import android.webkit.ConsoleMessage;
import android.webkit.WebChromeClient;

import com.didichuxing.doraemonkit.R;
import com.didichuxing.doraemonkit.kit.core.BaseFragment;
import com.didichuxing.doraemonkit.kit.webdoor.bean.FpsJsBridgeBean;
import com.didichuxing.doraemonkit.kit.webview.WebViewManager;
import com.didichuxing.doraemonkit.util.GsonUtils;
import com.github.lzyzsd.jsbridge.BridgeWebView;
import com.github.lzyzsd.jsbridge.CallBackFunction;

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

    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        initWebView();
        AppCompatButton button = findViewById(R.id.button);

        if (WebViewManager.INSTANCE.getUrl() != null && !WebViewManager.INSTANCE.getUrl().isEmpty()) {
            mWebView.loadUrl(WebViewManager.INSTANCE.getUrl());
            button.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    FpsJsBridgeBean fpsJsBridgeBean = new FpsJsBridgeBean(new FpsJsBridgeBean.Fps(new double[]{12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.7}, new int[]{120, 100, 150, 80, 70, 110, 130}));
                    mWebView.callHandler("testJavascriptHandler", GsonUtils.toJson(fpsJsBridgeBean), new CallBackFunction() {
                        @Override
                        public void onCallBack(String data) {
                            Log.i("Testtt","call succeed,return value is "+data);
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
        // 设置支持javascript
        mWebView.getSettings().setJavaScriptEnabled(true);
        // 进行缩放
        mWebView.getSettings().setBuiltInZoomControls(true);
        // 设置UserAgent
        mWebView.getSettings().setUserAgentString(mWebView.getSettings().getUserAgentString() + "app");
        // 设置不用系统浏览器打开,直接显示在当前WebView
        mWebView.setWebChromeClient(new WebChromeClient() {
            @Override
            public boolean onConsoleMessage(ConsoleMessage consoleMessage) {
                Log.i("Testtt", consoleMessage.message() + " -- From line "
                    + consoleMessage.lineNumber() + " of "
                    + consoleMessage.sourceId());
                return true;
            }
        });
//        mWebView.setWebViewClient(new MyWebViewClient(mWebView!!));
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
