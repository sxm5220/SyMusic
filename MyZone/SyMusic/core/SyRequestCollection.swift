//
//  SyRequestCollection.swift
//  SyMusic
//
//  Created by sxm on 2020/5/10.
//  Copyright © 2020 wwsq. All rights reserved.
//  网络请求集合

import Foundation
class SyRequestCollection: NSObject {
    
    private static var _sharedInstance: SyRequestCollection?
    // player 单例
    class func getSharedInstance() -> SyRequestCollection {
        guard let instance = _sharedInstance else {
            _sharedInstance = SyRequestCollection()
            return _sharedInstance!
        }
        return instance
    }
    
    //销毁单例对象
    class func requestCollectionDestroy() {
        _sharedInstance = nil
    }
    
    //判断app是否需要升级
    func appVersionRequest() {
        var params = [String: Any]()
        params["version"] = currentVersion()
        params["type"] = "1"
        SyNetworkRequest.sharedInstance.httpRequest(method: .post, urlString: "", params: params) { (item) in
            
        }
    }
}
