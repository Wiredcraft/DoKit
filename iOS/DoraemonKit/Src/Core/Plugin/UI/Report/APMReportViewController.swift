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
        
       let url = URL(string: "https://trailsquad.github.io/wiredexam-react-app/index.html")!
//        let url = URL(string: "http://192.168.31.109:3000/wiredexam-react-app")!
        // let url = URL(string: "http://10.10.4.86:3000/wiredexam-react-app")!
        let req = URLRequest(url: url)
        self.webView.load(req)

        webView.scrollView.isScrollEnabled = false
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bridge.register(handlerName: "lookPdf") {[weak self] parameters, callback in
            let str = (parameters?["pdfData"] as? String)?.replacingOccurrences(of: "data:application/pdf;base64,", with: "")
            print(str?.count)
            let data = Data(base64Encoded: str ?? "", options: .ignoreUnknownCharacters)
            DispatchQueue.main.async {
                self?.sharedPdf(data: (data ?? str?.data(using: .utf8)) ?? Data())
            }
        }
    }

    func sharedPdf(data: Data) {
        let activityVC = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        self.present(activityVC, animated: true)
    }
}

extension APMReportViewController: WKNavigationDelegate {
    open func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.updateFps()
    }
    
    public func updateFps() {
        DispatchQueue.global().async {
            let modelName = UIDevice.modelName()

            let appName = Bundle.main.infoDictionary?["CFBundleExecutable"]
            let deviceInfo = modelName + ", " + "iOS " + UIDevice.current.systemVersion
            let fpsData = DoraemonFPSDataManager.sharedInstance().dataForReport()
            let netData = DoraemonNetFlowAnalysisReport().reportDic()
            let netFlowData = DoraemonNetFlowAnalysisReport().reportFlowdata()
            let launchTimeData = DoraemonLaunchTimeManager.shareInstance().modelDics()
            let leakData = DoraemonMemoryLeakData.shareInstance().dataForReport()
            let locationData = DoraemonUseLocationManager.shareInstance().dicForReport()

            let pageSpeedData = DoraemonPageSpeedManager.shareInstance().dataForReport()

//            let netdataStr = self.getJSONStringFromArray(array: netFlowData ?? [])
//            let locationdataStr = self.getJSONStringFromArray(array: locationData ?? [])
//            print("=====")
//            print(netdataStr)
//            print("=====")
//            print(locationdataStr)
            print("=====")
            print(self.getJSONStringFromArray(array: pageSpeedData ?? []))
            print("=====")

            DispatchQueue.main.async {
                self.bridge.call(handlerName: "testJavascriptHandler", data: [
                    "appName": appName,
                    "deviceInfo": deviceInfo,
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

extension UIDevice {
      static func modelName() -> String {

        var systemInfo = utsname()
        uname(&systemInfo)

        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else {return identifier}
           return identifier + String(UnicodeScalar(UInt8(value)))
        }

        switch identifier {
        //iPod1
        case "iPod1,1":  return "iPod Touch 1G"
        case "iPod2,1":  return "iPod Touch 2G"
        case "iPod3,1":  return "iPod Touch 3G"
        case "iPod4,1":  return "iPod Touch 4G"
        case "iPod5,1":  return "iPod Touch 5G"
        case "iPod7,1":  return "iPod Touch 6G"
        //iPhone
        case "iPhone1,1":  return "iPhone 2G"
        case "iPhone1,2":  return "iPhone 3G"
        case "iPhone2,1":  return "iPhone 3GS"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": return "iPhone 4"
        case "iPhone4,1":  return "iPhone 4s"

        case "iPhone5,1","iPhone5,2":  return "iPhone 5"
        case "iPhone5,3","iPhone5,4":  return "iPhone 5c"
        case "iPhone6,1","iPhone6,2":  return "iPhone 5s"

        case "iPhone7,2":  return "iPhone 6"
        case "iPhone7,1":  return "iPhone 6 Plus"
        case "iPhone8,1":  return "iPhone 6s"
        case "iPhone8,2":  return "iPhone 6s Plus"

        case "iPhone8,4":  return "iPhone SE"
        case "iPhone9,1","iPhone9,3":  return "iPhone 7"
        case "iPhone9,2","iPhone9,4":  return "iPhone 7 Plus"

        case "iPhone10,1","iPhone10,4":   return "iPhone 8"
        case "iPhone10,2","iPhone10,5":   return "iPhone 8 Plus"

        case "iPhone10,3","iPhone10,6":   return "iPhone X"

        case "iPhone11,2":   return "iPhone XS"
        case "iPhone11,4", "iPhone11,6": return "iPhone XS Max"
        case "iPhone11,8":   return "iPhone XR"

        case "iPhone12,1":   return "iPhone 11"
        case "iPhone12,3":   return "iPhone 11 Pro"
        case "iPhone12,5":   return "iPhone 11 Pro Max"
        case "iPhone12,8":   return "iPhone SE"

        case "iPhone13,1":   return "iPhone 12 mini"
        case "iPhone13,2":   return "iPhone 12"
        case "iPhone13,3":   return "iPhone 12  Pro"
        case "iPhone13,4":   return "iPhone 12  Pro Max"

        case "iPhone14,4":   return "iPhone 13 mini"
        case "iPhone14,5":   return "iPhone 13"
        case "iPhone14,2":   return "iPhone 13  Pro"
        case "iPhone14,3":   return "iPhone 13  Pro Max"
        case "iPhone14,6":   return "iPhone SE"

        case "iPhone14,7":   return "iPhone 14"
        case "iPhone14,8":   return "iPhone 14 Plus"
        case "iPhone15,2":   return "iPhone 14 Pro"
        case "iPhone15,3":   return "iPhone 14 Pro Max"

        //ipad
        case "iPad1,1":      return "iPod Touch 1G"
        case "iPad1,2":      return "iPad 3G"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return "iPod Touch 2G"
        case "iPad2,5", "iPad2,6", "iPad2,7":  return "iPad Mini 1G"
        case "iPad3,1", "iPad3,2", "iPad3,3":  return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":  return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":  return "iPad Air"
        case "iPad4,4", "iPad4,5", "iPad4,6":  return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":  return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":             return "iPad Mini 4"
        case "iPad5,3", "iPad5,4":  return "iPad Air 2"
        case "iPad6,3", "iPad6,4":  return "iPad Pro 9.7"
        case "iPad8,1","iPad8,2","iPad8,3", "iPad8,4","iPad8,10","iPad8,9","iPad13,7", "iPad13,6","iPad13,5","iPad13,4":  return "iPad Pro 11"
        case "iPad13,11", "iPad13,10","iPad13,9","iPad13,8","iPad8,5","iPad8,6","iPad8,7","iPad8,8","iPad8,11","iPad8,12","iPad6,7", "iPad6,8":  return "iPad Pro 12.9"
        case "iPad14,2", "iPad14,1","iPad11,1","iPad11,2":  return "iPad Mini"

        case "AppleTV2,1":  return "Apple TV 2"
        case "AppleTV3,1", "AppleTV3,2":  return "Apple TV 3"
        case "AppleTV5,3":  return "Apple TV 4"
        //模拟器
        case "i386", "x86_64": return "iPhone Simulator"
        default:
            return "unknown iPhone" //未知iPhone
        }
    }
 }

