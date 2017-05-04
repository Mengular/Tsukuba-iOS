//
//  Response.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import Alamofire

class Response: NSObject {

    var data: [String: Any]!
    
    init(_ response: DataResponse<Any>) {
        if DEBUG && response.response != nil {
            NSLog("New response, status:\n\(response.response!)")
        }
        if DEBUG && response.data != nil {
            NSLog("Response body:\n\(String.init(data: response.data!, encoding: .utf8)!)")
        }
        data = response.result.value as! Dictionary<String, Any>!
        if DEBUG {
            if data != nil {
                NSLog("Response with JSON:\n\(data!)")
            }
        }
    }
    
    func statusOK() -> Bool {
        if data == nil {
            return false
        }
        return data["status"] as! Int == 200
    }
    
    func getResult() -> [String: Any]! {
        if data == nil {
            return nil
        }
        return data["result"] as! [String: Any]
    }
    
    func errorCode() -> Int {
        if data == nil {
            return ErrorCode.badRequest.rawValue
        }
        return data["errorCode"] as! Int
    }
    
}
