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
//        let url = URL(string: "http://192.168.31.109:3000/wiredexam-react-app")!
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
        DispatchQueue.global().async {
            let appName = Bundle.main.infoDictionary?["CFBundleExecutable"]
            let version = "iOS " + UIDevice.current.systemVersion
            let fpsData = DoraemonFPSDataManager.sharedInstance().dataForReport()
            let netData = DoraemonNetFlowAnalysisReport().reportDic()
            let netFlowData = DoraemonNetFlowAnalysisReport().reportFlowdata()
            let launchTimeData = DoraemonLaunchTimeManager.shareInstance().modelDics()
            let leakData = DoraemonMemoryLeakData.shareInstance().dataForReport()
            let locationData = DoraemonUseLocationManager.shareInstance().dicForReport()

            let netdataStr = self.getJSONStringFromArray(array: netFlowData ?? [])
            let locationdataStr = self.getJSONStringFromArray(array: locationData ?? [])
            print(netdataStr)
            print("=====")
            print(locationdataStr)

            DispatchQueue.main.async {
                self.bridge.call(handlerName: "testJavascriptHandler", data: [
                    "appName": appName,
                    "version": version,
                    "fps": fpsData,
                    "network": netData,
                    "networkFlowData": netFlowData,
                    "launchTimeData": launchTimeData,
                    "memoryLeakData": leakData,
                    "locationData": locationData,
                ]) { responseData in
                    print("back from js: \(String(describing: responseData))")
                }
            }
        }

    }

    private func getJSONStringFromDictionary(dictionary: NSDictionary) -> String {
        if (!JSONSerialization.isValidJSONObject(dictionary)) {
            return ""
        }
        if let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) {
            let JSONString = NSString(data:data, encoding: String.Encoding.utf8.rawValue)
            return JSONString! as String
        } else {
            return ""
        }
    }
    private func getJSONStringFromArray(array: [Any]) -> String {
       if (!JSONSerialization.isValidJSONObject(array)) {
           return " "
       }
       if let data = try? JSONSerialization.data(withJSONObject: array, options: []), let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue) as String? {
           return JSONString
       }
       return " "
   }
}

