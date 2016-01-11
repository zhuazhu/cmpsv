//
//  HttpUtil.swift
//  cmpsv
//
//  Created by apple on 15/11/3.
//  Copyright © 2015年 cmp. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

typealias Callback=(response:Dictionary<String,AnyObject>)->Void
class HttpUtil {
    ///get请求
    class func get(url:String,param:Dictionary<String,AnyObject>?,ajaxCallBack:Response<AnyObject, NSError> -> Void){
        Alamofire.request(.GET, url, parameters: param, encoding: ParameterEncoding.JSON, headers: nil).responseJSON(completionHandler: ajaxCallBack)
    }
    ///get请求
    class func get(param:Dictionary<String,AnyObject>?,ajaxCallBack:Response<AnyObject, NSError> -> Void){
        Alamofire.request(.GET, Config.base_url, parameters: param, encoding: ParameterEncoding.JSON, headers: nil).responseJSON(completionHandler: ajaxCallBack)
    }
    ///post请求
    class func post(url:String,param:Dictionary<String,AnyObject>?,ajaxCallBack:Response<AnyObject, NSError> -> Void){
        Alamofire.request(.POST, url, parameters: param, encoding: ParameterEncoding.JSON, headers: nil).responseJSON(completionHandler: ajaxCallBack)
    }
    ///post请求
    class func post(param:Dictionary<String,AnyObject>?,ajaxCallBack:Response<AnyObject, NSError> -> Void){
        Alamofire.request(.POST, Config.base_url, parameters: param, encoding: ParameterEncoding.JSON, headers: nil).responseJSON(completionHandler: ajaxCallBack)
    }
    ///post请求
    class func post(param:Dictionary<String,AnyObject>?,callback:Callback?){
        Alamofire.request(.POST, Config.base_url, parameters: param, encoding: ParameterEncoding.JSON, headers: nil).responseJSON(){(response) -> Void in
            var d:Dictionary<String,AnyObject>!
            if(response.result.isSuccess){
                d = response.result.value as! Dictionary
            }else{
                d = Dictionary()
                d["code"] = -1
            }
            if(callback != nil){
                callback!(response: d)
            }
        }
    }

    ///下载图片
    class func download(url:String){
        Alamofire.download(.GET, url) { (temporaryURL, response) -> NSURL in

            if let directoryURL = NSFileManager.defaultManager()
                .URLsForDirectory(.DocumentDirectory,
                    inDomains: .UserDomainMask)[0] as? NSURL {
                    let pathComponent = response.suggestedFilename
                    let nsurl = directoryURL.URLByAppendingPathComponent(pathComponent!)
                    return nsurl
            }
            
            return temporaryURL
        }
    }
}
