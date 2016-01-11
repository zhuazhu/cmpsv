//
//  UserUtil.swift
//  cmpsv
//
//  Created by apple on 16/1/3.
//  Copyright © 2016年 cmp. All rights reserved.
//

import Foundation

class UserUtil {
    ///保存用户信息
    static func save_user(var u:Dictionary<String,AnyObject>){
        let user:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        for (key,value) in u {
            if (value as? String)==nil {
                u[key] = ""
            }
        }
        user.setObject(u, forKey: "cmpsv_user")
    }
    ///获得用户信息
    static func get_user()->Dictionary<String,AnyObject>?{
        let user:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        return user.objectForKey("cmpsv_user") as? Dictionary
    }
    ///删除用户信息
    static func clear_user(){
        let user:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        user.removeObjectForKey("cmpsv_user")
    }
}