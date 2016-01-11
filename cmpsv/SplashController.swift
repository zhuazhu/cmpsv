//
//  SplashController.swift
//  cmpsv
//
//  Created by apple on 15/11/4.
//  Copyright © 2015年 cmp. All rights reserved.
//

import UIKit
import Kingfisher

class SplashController: UIViewController {

    @IBOutlet weak var img: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        var param = Dictionary<String, AnyObject>();
        let uuid = CommonUtil.get_uuid()
        param["device_id"] = uuid
        param["method"] = "post_phone_info"
        param["imei"] = ""
        HttpUtil.post(param, callback:self.callback)
    }
    private func callback(response:Dictionary<String, AnyObject>){
        let code = response["code"] as! Int
        if(code==0){
            let urls = (response["content"]!["splash_ad"]!!.valueForKey("urls")) as! NSArray
            self.img.kf_setImageWithURL(NSURL(string: urls[0] as! String)!, placeholderImage: nil, optionsInfo: nil) { (image, error, cacheType, imageURL) -> () in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    NSThread.sleepForTimeInterval(3)
                    dispatch_async(dispatch_get_main_queue(), {
                        let board = UIStoryboard(name: "Main", bundle: nil)
                        let controller = board.instantiateViewControllerWithIdentifier("main") as! MainTabBarController
                        self.presentViewController(controller, animated: false) { () -> Void in
                            self.view.removeFromSuperview()
                        }
                    })
                })
            }
        }else{
            let board = UIStoryboard(name: "Main", bundle: nil)
            let controller = board.instantiateViewControllerWithIdentifier("main") as! MainTabBarController
            self.presentViewController(controller, animated: false) { () -> Void in
                self.view.removeFromSuperview()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
