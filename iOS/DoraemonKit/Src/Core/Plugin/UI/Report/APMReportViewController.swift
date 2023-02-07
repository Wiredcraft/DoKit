//
//  APMReportViewController.swift
//  DoKitSwiftDemo
//
//  Created by Jun Ma on 2023/1/11.
//  Copyright © 2023 WCL. All rights reserved.
//

import UIKit
import WKWebViewJavascriptBridge
import WebKit

open class APMReportViewController: UIViewController {
    
    public let webView = WKWebView(frame: .zero)
    public var bridge: WKWebViewJavascriptBridge!
    open var fpsTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "mm:ss"
        return f
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        webView.navigationDelegate = self
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bridge = WKWebViewJavascriptBridge(webView: webView)
        
//        let url = URL(string: "https://trailsquad.github.io/wiredexam-react-app/index.html")!
        let url = URL(string: "http://192.168.31.109:3000/wiredexam-react-app")!
        let req = URLRequest(url: url)
        self.webView.load(req)
    }
}

extension APMReportViewController: WKNavigationDelegate {
    open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.updateFps()
    }
    
    public func updateFps() {
        let appName = Bundle.main.infoDictionary?["CFBundleExecutable"]
        let version = "iOS " + UIDevice.current.systemVersion

        DispatchQueue.global().async {
            let data = DoraemonFPSDataManager.sharedInstance().allData()
            let time = data.map { self.fpsTimeFormatter.string(from: Date(timeIntervalSince1970: $0.timestamp)) }
            let value = data.map { $0.value }

            let netData = DoraemonNetFlowAnalysisReport().reportDic()

            let launchTimeData = DoraemonLaunchTimeNamager.shareInstance().modelDics()

            DispatchQueue.main.async {
                self.bridge.call(handlerName: "testJavascriptHandler", data: [
                    "appName": appName,
                    "version": version,
                    "fps": [
                        "xValues": time,
                        "data": value
                    ],
                    "network": netData,
                    "launchTimeData": launchTimeData,
                ]) { responseData in
                    print("back from js: \(String(describing: responseData))")
                }
            }
        }

    }
}

