//
//  UserManager.swift
//  Tsukuba-iOS
//
//  Created by 李大爷的电脑 on 04/05/2017.
//  Copyright © 2017 MuShare. All rights reserved.
//

import Alamofire
import SwiftyUserDefaults

let UserTypeEmail = "email"
let UserTypeFacebook = "facebook"

class UserManager {
    
    var dao: DaoManager!
    var config: Config!
    
    var login: Bool {
        set {
            Defaults[.login] = newValue
        }
        get {
            return Defaults[.login] ?? false
        }
    }
    
    var token: String {
        set {
            Defaults[.token] = newValue
        }
        get {
            return Defaults[.token] ?? ""
        }
    }

    var type: String {
        set {
            Defaults[.type] = newValue
        }
        get {
            return Defaults[.type] ?? ""
        }
    }

    var identifier: String {
        set {
            Defaults[.identifier] = newValue
        }
        get {
            return Defaults[.identifier] ?? ""
        }
    }
    
    var name: String {
        set {
            Defaults[.name] = newValue
        }
        get {
            return Defaults[.name] ?? ""
        }
    }
    
    var avatar: String {
        set {
            Defaults[.avatar] = newValue
        }
        get {
            return Defaults[.avatar] ?? ""
        }
    }
    
    var avatarURL: URL? {
        get {
            return login ? URL(string: createUrl(avatar)) : nil
        }
    }
    
    var contact: String {
        set {
            Defaults[.contact] = newValue
        }
        get {
            return Defaults[.contact] ?? ""
        }
    }
    
    var address: String  {
        set {
            Defaults[.address] = newValue
        }
        get {
            return Defaults[.address] ?? ""
        }
    }
    
    var userRev: Int {
        set {
            Defaults[.userRev] = newValue
        }
        get {
            return Defaults[.userRev] ?? 0
        }
    }
    
    var avatarUploadingProgress: Double! = 0
    
    static let sharedInstance: UserManager = {
        let instance = UserManager()
        return instance
    }()
    
    init() {
        dao = DaoManager.sharedInstance
        config = Config.sharedInstance
    }
    
    func pullUser(completion: ((Bool) -> Void)?) {
        let params: Parameters = [
            "rev": self.userRev
        ]
        Alamofire.request(createUrl("/api/user"),
                          method: .get,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: config.tokenHeader)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                let result = response.getResult()
                if (result["update"].boolValue) {
                    let user = result["user"]
                    self.name = user["name"].stringValue
                    self.avatar = user["avatar"].stringValue
                    self.contact = user["contact"].stringValue
                    self.address = user["address"].stringValue
                    self.userRev = user["rev"].intValue
                }
                completion?(true)
            } else {
                completion?(false)
            }
        }
    }
    
    func get(_ uid: String, completion: ((Bool, User?) -> Void)?) {
        Alamofire.request(createUrl("api/user/" + uid),
                          method: .get,
                          parameters: nil,
                          encoding: URLEncoding.default,
                          headers: nil)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                let user = User(user: response.getResult()["user"])
                completion?(true, user)
            } else {
                completion?(false, nil)
            }
        }
    }
    
    func login(email: String, password: String, completion: ((Bool, String?) -> Void)?) {
        let params: Parameters = [
            "email": email,
            "password": password,
            "identifier": UIDevice.current.identifierForVendor!.uuidString,
            "deviceToken": Defaults[.deviceToken] ?? "",
            "os": "iOS",
            "version": UIDevice.current.systemVersion,
            "lan": config.lan
        ]
        Alamofire.request(createUrl("api/user/login/email"),
                          method: .post,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: nil)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                let result = response.getResult()
                // Login success, save user information to NSUserDefaults.
                self.type = UserTypeEmail;
                self.token = result["token"].stringValue
                let user = result["user"]
                self.identifier = email
                self.name = user["name"].stringValue
                self.avatar = user["avatar"].stringValue
                self.contact = user["contact"].stringValue
                self.address = user["address"].stringValue
                self.userRev = user["rev"].intValue
                self.login = true
                completion?(true, nil);
            } else {
                switch response.errorCode() {
                case .emailNotExist:
                    completion?(false, NSLocalizedString("email_not_exist", comment: ""))
                case .passwordWrong:
                    completion?(false, NSLocalizedString("password_wrong", comment: ""))
                default:
                    completion?(false, NSLocalizedString("error_unknown", comment: ""))
                }
            }
        }
    }
    
    func facebookLogin(_ token: String, completion: ((Bool, String?) -> Void)?) {
        let params: Parameters = [
            "accessToken": token,
            "identifier": UIDevice.current.identifierForVendor!.uuidString,
            "deviceToken": Defaults[.deviceToken] ?? "",
            "os": "iOS",
            "version": UIDevice.current.systemVersion,
            "lan": config.lan
        ]
        
        Alamofire.request(createUrl("/api/user/login/facebook"),
                          method: .post,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: nil)
        .responseJSON(completionHandler: { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                let result = response.getResult()
                // Login success, save user information to NSUserDefaults.
                self.type = UserTypeFacebook;
                self.token = result["token"].stringValue
                let user = result["user"]
                self.identifier = user["identifier"].stringValue
                self.name = user["name"].stringValue
                self.avatar = user["avatar"].stringValue
                self.contact = user["contact"].stringValue
                self.address = user["address"].stringValue
                self.userRev = user["rev"].intValue
                self.login = true
                completion?(true, nil);
            } else {
                switch response.errorCode() {
                case .facebookAccessTokenInvalid:
                    completion?(false, NSLocalizedString("facebook_oauth_error", comment: ""))
                default:
                    completion?(false, NSLocalizedString("error_unknown", comment: ""))
                }
            }
        })
    }
    
    func reset(email: String, comletion:((Bool, String?) -> Void)?) {
        let params: Parameters = [
            "email": email,
            "lan": config.lan
        ]
        
        Alamofire.request(createUrl("api/user/modify/password"),
                          method: .get,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: config.tokenHeader)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                comletion?(true, nil)
            } else {
                switch response.errorCode() {
                case .emailNotExist:
                    comletion?(false, NSLocalizedString("email_not_exist", comment: ""))
                case .sendResetPasswordMail:
                    comletion?(false, NSLocalizedString("reset_password_failed", comment: ""))
                default:
                    comletion?(false, NSLocalizedString("error_unknown", comment: ""))
                }
            }
        }

    }
    
    func register(email: String, name: String, password: String, completion: ((Bool, String?) -> Void)?) {
        let parameters: Parameters = [
            "email": email,
            "name": name,
            "password": password
        ]
        
        Alamofire.request(createUrl("api/user/register"),
                          method: HTTPMethod.post,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: nil)
        .responseJSON { responseObject in
            let response = Response(responseObject)
            if response.statusOK() {
                completion?(true, nil)
            } else {
                switch response.errorCode() {
                case .emailRegistered:
                    completion?(false, NSLocalizedString("email_registered", comment: ""))
                default:
                    completion?(false, NSLocalizedString("error_unknown", comment: ""))
                }
            }
        }
    }
    
    func logout() {
        self.login = false
        self.userRev = 0
        self.token = ""
        self.type = ""
        self.name = ""
        self.avatar = ""
        self.identifier = ""
        self.address = ""
        self.contact = ""
    }
    
    func uploadAvatar(_ image: UIImage, completion: ((Bool) -> Void)?) {
        let data = UIImageJPEGRepresentation(resizeImage(image: image, newWidth: 480)!, 1.0)
        Alamofire.upload(multipartFormData:{ multipartFormData in
            multipartFormData.append(data!, withName: "avatar", fileName: UUID().uuidString, mimeType: "image/jpeg")
        },
                         usingThreshold: UInt64.init(),
                         to: createUrl("api/user/avatar"),
                         method: .post,
                         headers: config.tokenHeader,
                         encodingCompletion:
            { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.uploadProgress { progress in
                        self.avatarUploadingProgress = progress.fractionCompleted
                    }
                    upload.responseJSON { responseObject in
                        let response = Response(responseObject)
                        if response.statusOK() {
                            let result = response.getResult()
                            self.avatar = result["avatar"].stringValue
                            self.avatarUploadingProgress = 0
                            completion?(true)
                        } else {
                            completion?(false)
                        }
                    }
                case .failure(let encodingError):
                    if DEBUG {
                        debugPrint(encodingError)
                    }
                    completion?(false)
            }
        })
    }
    
    func modify(name: String, contact: String, address: String, completion:((Bool) -> Void)?) {
        let params: Parameters = [
            "name": name,
            "contact": contact,
            "address": address
        ]
        
        Alamofire.request(createUrl("api/user/modify/info"),
                          method: .post,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: config.tokenHeader)
        .responseJSON { (responseObject) in
            let response = Response(responseObject)
            if response.statusOK() {
                let result = response.getResult()
                if result["success"].boolValue {
                    self.userRev = result["rev"].intValue
                    self.name = name
                    self.contact = contact
                    self.address = address
                    completion?(true)
                } else {
                    completion?(false)
                }
            } else {
                completion?(false)
            }
            
        }
    }

}