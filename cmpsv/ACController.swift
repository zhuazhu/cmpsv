//
//  ACController.swift
//  cmpsv
//
//  Created by apple on 16/1/9.
//  Copyright © 2016年 cmp. All rights reserved.
//

import UIKit
import Alamofire
///广告合作
class ACController: BaseViewController {

    @IBOutlet weak var scl: UIScrollView!
    @IBOutlet weak var context: UILabel!
    @IBOutlet weak var contact_phone: UILabel!
    init(){
        super.init(nibName: "ACController")
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
        param["method"] = "query_ad_cooperation"
        self.view.makeToastActivity()
        HttpUtil.post(param, callback: self.callback)
    }
    func callback(response:Dictionary<String, AnyObject>){
        dispatch_async(dispatch_get_main_queue(), {
            self.view.hideToastActivity()
            let code = response["code"] as! Int
            if(code==0){
                self.context.text = response["content"]!["text"] as? String
                self.contact_phone.text = "联系电话: " + (response["content"]!["contact_number"] as? String)!
            }
        })
    }

    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        let y = self.contact_phone.frame.origin.y
        self.scl.contentSize = CGSize(width: 0, height: y+50)
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
