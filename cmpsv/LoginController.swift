//
//  LoginController.swift
//  cmpsv
//
//  Created by apple on 16/1/3.
//  Copyright © 2016年 cmp. All rights reserved.
//

import UIKit
import Alamofire

class LoginController: BaseViewController {
    
    @IBOutlet weak var login_img: UIImageView!
    ///普通登录按钮
    @IBOutlet weak var loginBtn: UIButton!
    ///普通登录的手机号
    @IBOutlet weak var uname: UITextField!
    ///密码
    @IBOutlet weak var password: UITextField!
    ///快速登录的视图
    @IBOutlet weak var fview: UIView!
    ///发送验证码的按钮
    @IBOutlet weak var send_code: UIButton!
    ///快速登录的手机号
    @IBOutlet weak var ph: UITextField!
    ///验证码
    @IBOutlet weak var code: UITextField!
    ///快速登录的按钮
    @IBOutlet weak var fast_btn: UIButton!
    
    var timer:NSTimer!
    var timerNumber = 60
    var codeState = SendCodeStates.Init
    init() {
        super.init(nibName: "LoginController")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        // Do any additional setup after loading the view.
    }
    
    private func initView(){
        self.login_img.layer.cornerRadius = 30
        self.loginBtn.layer.cornerRadius = 5
        self.fast_btn.layer.cornerRadius = 5
    }
    ///普通登录
    @IBAction func login(sender: AnyObject) {
        self.hiddenStoryboad()
        let phone = self.uname.text
        if !CommonUtil.validatePhone(phone) {
            self.view.makeToast(message: "请输入正确的手机号")
            return
        }
        
        let pwd = self.password.text
        if !CommonUtil.validatePwd(pwd) {
            self.view.makeToast(message: "密码必须为6到16位")
            return
        }
        var param:Dictionary<String,AnyObject> = Dictionary()
        param["method"] = "login"
        param["device_id"] = CommonUtil.get_uuid()
        param["login_type"] = 1
        param["platform"] = "ios"
        param["password"] = pwd?.md5()
        param["id"] = phone
        self.view.makeToastActivityWithMessage(message: "登录中")
        HttpUtil.post(param, callback: self.loginResponse)
    }
    
    func loginResponse(response:Dictionary<String,AnyObject>){
        dispatch_async(dispatch_get_main_queue(), {
            self.view.hideToastActivity()
            let code = response["code"] as! Int
            switch code {
            case 0:
                self.view.makeToast(message: "登录成功")
                let user:Dictionary<String,AnyObject> = response["content"]!["user_info"] as! Dictionary
                UserUtil.save_user(user)
                self.navigationController?.popViewControllerAnimated(true)
                break
            case 2:
                self.view.makeToast(message: "请输入正确的手机号")
                break
            case 7:
                self.view.makeToast(message: "手机号未注册")
                break
            case 8:
                self.view.makeToast(message: "密码错误")
                break
            default:
                self.view.makeToast(message: "登录失败")
                break
            }
        })
        
        
    }
    var phoneNo:String?
    ///发送验证码
    @IBAction func sendCode(sender: AnyObject) {
        self.hiddenStoryboad()
        let ph = CommonUtil.trim(self.ph.text)
        if CommonUtil.isEmpty(ph) {
            self.view.makeToast(message: "请输入手机号")
            return
        }
        if !CommonUtil.validatePhone(ph) {
            self.view.makeToast(message: "请输入正确的手机号")
            return
        }
        self.phoneNo = ph
        var param:Dictionary<String,AnyObject> = Dictionary()
        param["method"] = "login"
        param["device_id"] = CommonUtil.get_uuid()
        param["login_type"] = 0
        param["id"] = ph
        param["get_sms_code"] = 1
        self.view.makeToastActivity()
        HttpUtil.post(param, callback:self.code_callback)
        
    }
    ///发送验证码回调
    func code_callback(response:Dictionary<String,AnyObject>){
        dispatch_async(dispatch_get_main_queue(), {
            self.view.hideToastActivity()
            let code = response["code"] as! Int
            switch code {
            case 0:
                if self.codeState == SendCodeStates.Init || self.codeState==SendCodeStates.Restart {
                    self.codeState = SendCodeStates.Loading
                    self.send_code.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Normal)
                    self.send_code.titleLabel?.userInteractionEnabled = false
                    self.send_code.setTitle("大约需要"+self.timerNumber.description+"秒", forState: UIControlState.Normal)
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timerAction", userInfo: nil, repeats: true)
                }
                break
            case 2:
                self.view.makeToast(message: "手机格式不正确")
                break
            case 3:
                self.view.makeToast(message: "手机号已经被注册")
                break
            case 6:
                self.view.makeToast(message: "该手机号当天发送验证码次数已经超过5次,明天才能发送")
                break
            case 7:///手机号未注册
                let alert = UIAlertView()
                alert.message = "手机号未注册,请先注册"
                alert.addButtonWithTitle("注册")
                alert.delegate = self
                alert.show()
                break
            default:
                self.view.makeToast(message: "发送失败")
                break
            }
        })
    }
    func timerAction(){
        self.timerNumber--
        if(self.timerNumber==0){
            self.timer.fireDate = NSDate.distantFuture()
            self.send_code.setTitle("重新发送", forState: UIControlState.Normal)
            send_code.setTitleColor(ColorUtil.getColorForRGB("#007AFF"), forState: UIControlState.Normal)
            self.send_code.userInteractionEnabled = true
            self.codeState = SendCodeStates.Restart
            self.timerNumber = 60
        }else{
            self.send_code.setTitle("大约需要"+self.timerNumber.description+"秒", forState: UIControlState.Normal)
        }
    }
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if(buttonIndex==0){
            let controller = RegisterController()
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    ///快速登录
    @IBAction func fast_login(sender: AnyObject) {
        self.hiddenStoryboad()
        if(self.codeState==SendCodeStates.Init){
            self.view.makeToast(message: "请先发送验证码")
            return
        }
        if !CommonUtil.validatePhone(self.phoneNo) {
            self.view.makeToast(message: "请输入正确的手机号")
            return
        }
        let code = CommonUtil.trim(self.code.text)
        if CommonUtil.isEmpty(code) {
            self.view.makeToast(message: "请输入验证码")
            return
        }
        var param:Dictionary<String,AnyObject> = Dictionary()
        param["method"] = "login"
        param["device_id"] = CommonUtil.get_uuid()
        param["login_type"] = 0
        param["id"] = self.phoneNo
        param["get_sms_code"] = 0
        param["sms_code"] = code
        self.view.makeToastActivityWithMessage(message: "登录中")
        HttpUtil.post(param, callback: self.fast_login_callback)
    }
    func fast_login_callback(response:Dictionary<String,AnyObject>){
        dispatch_async(dispatch_get_main_queue(), {
            self.view.hideToastActivity()
            let code = response["code"] as! Int
            switch code {
            case 0:
                self.view.makeToast(message: "登录成功")
                let user:Dictionary<String,AnyObject> = response["content"]!["user_info"] as! Dictionary
                UserUtil.save_user(user)
                self.navigationController?.popViewControllerAnimated(true)
                break
            case 4:
                self.view.makeToast(message: "验证码错误")
                break
            default:
                self.view.makeToast(message: "登录失败")
                break
            }
        })
        
        
    }
    ///注册
    @IBAction func register(sender: AnyObject) {
        let controller = RegisterController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    ///找回密码
    @IBAction func find_pwd(sender: AnyObject) {
    }
    @IBAction func check_login_type(sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        switch(index){
        case 0://普通登录
            self.fview.hidden = true
            break
        case 1://快速登录
            self.fview.hidden = false
            break
        default:
            break
        }
    }
    ///点击事件,消失键盘
    @IBAction func clickV(sender: AnyObject) {
        self.hiddenStoryboad()
    }
    ///隐藏键盘
    func hiddenStoryboad(){
        self.uname.resignFirstResponder()
        self.password.resignFirstResponder()
        self.ph.resignFirstResponder()
        self.code.resignFirstResponder()
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
