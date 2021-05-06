//
//  SyNetworkRequest.swift
//  SyMusic
//
//  Created by sxm on 2020/5/10.
//  Copyright © 2020 wwsq. All rights reserved.
//

import Foundation
import Alamofire

private let NetworkRequestShareInstance = SyNetworkRequest()

class SyNetworkRequest {
    
    class var sharedInstance: SyNetworkRequest{
        return NetworkRequestShareInstance
    }
    
    func httpRequest(method: HTTPMethod,
                     urlString: String,
                     params: [String : Any],
                     success: @escaping ((_ item: [String: AnyObject]) -> Void)) {
        var params = params
        /*params["access_token"] = userDefaultsForString(forKey: userDefaultAccessTokenKey())
        params["lang"] = language()
        params["countryCode"] = userDefaultsForString(forKey: userDefaultCountryCodeKey())
        params["country"] = userDefaultsForString(forKey: userDefaultCountryNameKey())
        params["city"] = userDefaultsForString(forKey: userDefaultCityNameKey())*/
        params["systemVersion"] = systemVersion() //当前手机系统版本号
        params["appVersion"] = currentVersion() //当前app版本号
        var request = URLRequest(url: URL.init(string: "")!)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: params)
        AF.request(request).responseJSON { (response) in
            switch response.result{
            case .success:
                if let value = response as? [String: AnyObject] {
                    let errcode = String(describing: value["errcode"] as AnyObject)
                    //let errmsg = String(describing: value["errmsg"] as AnyObject)
                    if errcode.trimmingCharactersCount > 0 {
                        if errcode != "0" {
                            //SyRequestCollection.getSharedInstance().loginOut(errcode: errcode, errmsg: errmsg, url: urlString)
                            return
                        } else {
                            return success(value)
                        }
                    }
                }
            case .failure(let error as NSError):
                DispatchQueue.main.async {
                    if error.code != 0 {
                        progressHUDShowErrorWithNetwork(error: error)
                    }
                }
            }
        }
    }
    
    //服务器端音频文件
    func playVoiceSession(url: String, success: @escaping ((_ data: Data) -> Void)) {
        let url: NSURL = NSURL(string: url)!
        let request: NSURLRequest = NSURLRequest(url: url as URL)
        let dataTask: URLSessionDataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if(error == nil && data != nil){
                return success(data!)
            }
        }
        dataTask.resume()
    }
    
    
}
