//
//  CommonUtil.swift
//  cmpsv
//
//  Created by apple on 15/11/4.
//  Copyright © 2015年 cmp. All rights reserved.
//

import Foundation
class CommonUtil {
    ///获取guid
    static func get_uuid() ->String{
        return NSUUID().UUIDString
    }
    static func trim(str:String?)->String?{
        if str == nil {
            return str
        }
        let whitespace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        return String(str!.stringByTrimmingCharactersInSet(whitespace))
    }
    ///字符串是否为空
    static func isEmpty(str:String?)->Bool{
        if str == nil {
            return true
        }
        let whitespace = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        let s = String(str!.stringByTrimmingCharactersInSet(whitespace))
        if(s == ""){
            return true
        }
        return false
    }
    ///验证手机号
    static func validatePhone(phone:String?)->Bool{
        if(phone==nil){
            return false
        }
        let len = phone!.characters.count
        if(len != 11){
            return false
        }
        let c  = (phone! as NSString).substringToIndex(1)
        if(c != "1"){
            return false
        }
        return true
    }
    ///验证密码
    static func validatePwd(pwd:String?)->Bool{
        if(pwd==nil){
            return false
        }
        let len = pwd!.characters.count
        if(len<6 || len>16){
            return false
        }
        return true
    }
}