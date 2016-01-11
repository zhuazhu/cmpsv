//
//  EditUserController.swift
//  cmpsv
//
//  Created by apple on 16/1/9.
//  Copyright © 2016年 cmp. All rights reserved.
//

import UIKit
import Alamofire

class EditUserController: BaseViewController {
    ///昵称
    @IBOutlet weak var name: UITextField!
    ///公司名称
    @IBOutlet weak var cname: UITextField!
    ///公司地址
    @IBOutlet weak var cadress: UITextField!
    ///联系电话
    @IBOutlet weak var cphone: UITextField!
    
    init(){
        super.init(nibName: "EditUserController")
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
        //        let user:Dictionary<String,AnyObject>! = UserUtil.get_user()
        //        self.name.text = user["name"] as? String
        //        self.cname.text = user["company_name"] as? String
        //        self.cadress.text = user["company_address"] as? String
        //        self.cphone.text = user["contact_number"] as? String
        self.query_user()
    }
    func query_user(){
        let user:Dictionary<String,AnyObject>! = UserUtil.get_user()
        var param:Dictionary<String,AnyObject> = Dictionary()
        param["method"] = "get_person_info"
        param["user_id"] = user["id"]
        HttpUtil.post(param, callback: self.user_callback)
    }
    func user_callback(response:Dictionary<String, AnyObject>){
        dispatch_async(dispatch_get_main_queue(), {
            self.view.hideToastActivity()
            let code = response["code"] as! Int
            if(code==0){
                let rst = response["content"] as! Dictionary<String,AnyObject>
                self.name.text = rst["nick"] as? String
                self.cname.text = rst["company_name"] as? String
                self.cadress.text = rst["company_address"] as? String
                self.cphone.text = rst["contact_number"] as? String
            }
        })
    }
    ///保存用户信息
    @IBAction func save(sender: AnyObject) {
        self.hiddenStoryboad()
        let user:Dictionary<String,AnyObject>! = UserUtil.get_user()
        var param:Dictionary<String,AnyObject> = Dictionary()
        param["method"] = "save_person_info"
        param["user_id"] = user["id"]
        param["nick"] = self.name.text
        param["company_name"] = self.cname.text
        param["company_address"] = self.cadress.text
        param["contact_number"] = self.cphone.text
        self.view.makeToastActivityWithMessage(message: "保存中")
        HttpUtil.post(param, callback: self.save_user_callback)
    }
    func save_user_callback(response:Dictionary<String, AnyObject>){
        dispatch_async(dispatch_get_main_queue(), {
            self.view.hideToastActivity()
            let code = response["code"] as! Int
            if(code==0){
                self.view.makeToast(message: "保存成功")
                self.navigationController?.popViewControllerAnimated(true)
            }else{
                self.view.makeToast(message: "保存失败")
            }
        })
    }
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    ///隐藏键盘
    func hiddenStoryboad(){
        self.name.resignFirstResponder()
        self.cname.resignFirstResponder()
        self.cadress.resignFirstResponder()
        self.cphone.resignFirstResponder()
    }
    @IBAction func hiden(sender: AnyObject) {
        self.hiddenStoryboad()
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
