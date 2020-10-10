//
//  NetworkTools.swift
//  DouYuTV
//
//  Created by 许一宁 on 2020/6/16.
//  Copyright © 2020 许一宁. All rights reserved.
//

import Cocoa
import Alamofire

enum MethodType {
    case GET
    case POST
}

class NetworkTools {
//  测试： http://httpbin.org/get 
    class func requestJsonData(URL : String,
                           method: MethodType? = .GET,
                           parameters : [String : Any]? = nil,
                           finishCallBack : @escaping (_ iSuccess: Bool ,_ result : Any) -> ()) {
        // 1. 获取类型
        let httpMethod = method == .GET ? HTTPMethod.get : HTTPMethod.post
        
        // 2. 发送网络请求
        let headers: HTTPHeaders = [
//            "Accept": "text/html,application/xhtml+xml,application/xml",
//            "User-Agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 Safari/537.36"
        ]
        AF.request(URL, method: httpMethod, parameters: parameters, headers: headers)
            .responseJSON { response in
            switch response.result {
            case let .success(success):
                finishCallBack(true, success)
            case let .failure(error):
                finishCallBack(false, error)
            }
        }
    }
}
