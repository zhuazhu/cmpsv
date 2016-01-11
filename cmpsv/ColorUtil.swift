//
//  ColorUtil.swift
//  cmpsv
//
//  Created by apple on 15/11/3.
//  Copyright © 2015年 cmp. All rights reserved.
//

import Foundation
import UIKit

class ColorUtil:NSObject{
    /*
    通过rgb的方式获取颜色
    透明度设置为1
    */
    //asdas
    class func getColorForRGB(rgb: NSString)->UIColor{
        return getColorForRGB(rgb, alpha: 1);
    }
    /*
    通过rgb的方式获取颜色
    alpha:透明度
    */
    static func getColorForRGB(rgb: NSString,alpha: Float)->UIColor{
        let red:Int = strtol(rgb.substringWithRange(NSMakeRange(1, 2)), nil, 16)
        let green:Int = strtol(rgb.substringWithRange(NSMakeRange(3, 2)), nil, 16)
        let blue:Int = strtol(rgb.substringWithRange(NSMakeRange(5, 2)), nil, 16)
        return UIColor(red: CGFloat(Float(red)/Float(255)), green: CGFloat(Float(green)/Float(255)), blue: CGFloat(Float(blue)/Float(255)), alpha: CGFloat(alpha))
    }
}

