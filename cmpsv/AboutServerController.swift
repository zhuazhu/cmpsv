//
//  AboutServerController.swift
//  cmpsv
//
//  Created by apple on 16/1/9.
//  Copyright © 2016年 cmp. All rights reserved.
//

import UIKit
import Alamofire

class AboutServerController: BaseViewController {

    @IBOutlet var scl: UIScrollView!
    @IBOutlet var context: UILabel!
    init(){
        super.init(nibName: "AboutServerController")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        // Do any additional setup after loading the view.
    }
    func initView(){
        var param:Dictionary<String,AnyObject> = Dictionary()
        param["method"] = "about_us"
        self.view.makeToastActivity()
        HttpUtil.post(param, callback: self.callback)
    }
    
    func callback(response:Dictionary<String, AnyObject>){
        dispatch_async(dispatch_get_main_queue(), {
            self.view.hideToastActivity()
            let code = response["code"] as! Int
            if(code==0){
                self.context.text = response["content"]!["text"] as? String
            }
        })
    }


    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
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
