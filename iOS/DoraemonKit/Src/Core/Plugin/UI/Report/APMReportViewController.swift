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
        
        let url = URL(string: "https://trailsquad.github.io/wiredexam-react-app/index.html")!
        let req = URLRequest(url: url)
        self.webView.load(req)

        let dismissButton = UIButton(frame: CGRect(x: 20, y: 80, width: 40, height: 20))
        dismissButton.setTitle("返回", for: .normal)
        dismissButton.addTarget(self, action: #selector(clickBack), for: .touchUpInside)
        view.addSubview(dismissButton)
    }

    @objc func clickBack() {
        self.dismiss(animated: true)
    }
}

extension APMReportViewController: WKNavigationDelegate {
    open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.updateFps()
    }
    
    public func updateFps() {
        let data = DoraemonFPSDataManager.sharedInstance().allData()
        let time = data.map { self.fpsTimeFormatter.string(from: Date(timeIntervalSince1970: $0.timestamp)) }
        let value = data.map { $0.value }
        self.bridge.call(handlerName: "testJavascriptHandler", data: [
            "fps": [
                "xValues": time,
                "data": value
            ]
        ]) { responseData in
            print("back from js: \(String(describing: responseData))")
        }
    }
}

