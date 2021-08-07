//
//  SyNetwork.swift
//  万物叁仟
//
//  Created by sxm on 2017/5/17.
//  Copyright © 2017年 wwsq. All rights reserved.
//

import UIKit
import SystemConfiguration

let ReachabilityStatusChangedNotification = "ReachabilityStatusChangedNotification"

enum ReachabilityType: CustomStringConvertible {
    case wwan
    case wiFi
    
    var description: String {
        switch self {
        case .wwan: return "WWAN"
        case .wiFi: return "WiFi"
        }
    }
}

enum ReachabilityStatus: CustomStringConvertible  {
    case offline
    case online(ReachabilityType)
    case unknown
    
    var description: String {
        switch self {
        case .offline: return "Offline"
        case .online(let type): return "Online (\(type))"
        case .unknown: return "Unknown"
        }
    }
}

public class Reach {
    
    func connectionStatus() -> ReachabilityStatus {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .unknown
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .unknown
        }
        
        return ReachabilityStatus(reachabilityFlags: flags)
    }
    
    
    func monitorReachabilityChanges() {
        let host = "google.com"
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        let reachability = SCNetworkReachabilityCreateWithName(nil, host)!
        
        SCNetworkReachabilitySetCallback(reachability, { (_, flags, _) in
            let status = ReachabilityStatus(reachabilityFlags: flags)
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: ReachabilityStatusChangedNotification),
                                            object: nil,
                                            userInfo: ["Status": status.description])
            
        }, &context)
        
        SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetMain(), RunLoop.Mode.common as CFString)
    }
    
}

extension ReachabilityStatus {
    init(reachabilityFlags flags: SCNetworkReachabilityFlags) {
        let connectionRequired = flags.contains(.connectionRequired)
        let isReachable = flags.contains(.reachable)
        let isWWAN = flags.contains(.isWWAN)
        
        if !connectionRequired && isReachable {
            if isWWAN {
                self = .online(.wwan)
            } else {
                self = .online(.wiFi)
            }
        } else {
            self =  .offline
        }
    }
}

func checkNetWorkStatus() -> Bool {
    let status = Reach().connectionStatus()
    switch status {
    case .unknown, .offline:
        return false
    case .online(.wwan), .online(.wiFi) : break
      //  progressHUDShowSuccessWithStatus(status: "有网络！")
    }
    return true
}

func networkError(error: NSError) -> String{
    var errorDescription: String = ""
    switch (error.code) {
    case NSURLErrorCancelled://取消网络请求
        errorDescription = strCommon(key: "sy_connect_exception")
    case NSURLErrorBadServerResponse: //404 not found
        errorDescription = strCommon(key: "sy_connect_exception")
    case NSURLErrorTimedOut://超时
        errorDescription = strCommon(key: "sy_outtimer")
    case NSURLErrorNotConnectedToInternet://无网络
        errorDescription = strCommon(key: "sy_network_nil")
    default:
        errorDescription = strCommon(key: "sy_connect_exception")
    }
    return errorDescription
}
