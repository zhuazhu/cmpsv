//
//  RegisterController.swift
//  cmpsv
//
//  Created by apple on 16/1/3.
//  Copyright © 2016年 cmp. All rights reserved.
//
enum SendCodeStates{
    case Init,Loading,Restart
}

import UIKit
import Alamofire
import CryptoSwift

class RegisterController: BaseViewController {
    ///手机号
    @IBOutlet weak var phone: UITextField!
    ///验证码
    @IBOutlet weak var code: UITextField!
    ///发送验证码按钮
    @IBOutlet weak var send_code: UIButton!
    ///密码
    @IBOutlet weak var pwd: UITextField!
    ///确认密码
    @IBOutlet weak var rpwd: UITextField!
    ///注册按钮
    @IBOutlet weak var register: UIButton!
    
    var timer:NSTimer!
    var timerNumber = 60
    var codeState = SendCodeStates.Init
    init(){
        super.init(nibName: "RegisterController")
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
        self.register.layer.cornerRadius = 5
    }
    var phoneNo:String?
    ///注册
    @IBAction func register(sender: AnyObject) {
        self.hiddenStoryboad()
        if(self.codeState==SendCodeStates.Init){
            self.view.makeToast(message: "请先发送验证码")
            return
        }
        if CommonUtil.isEmpty(self.phoneNo) {
            self.view.makeToast(message: "请输入手机号")
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
        let pwd = CommonUtil.trim(self.pwd.text)
        if !CommonUtil.validatePwd(pwd) {
            self.view.makeToast(message: "密码必须为6到16位")
            return
        }
        let pwd1 = CommonUtil.trim(self.rpwd.text)
        if !CommonUtil.validatePwd(pwd1) {
            self.view.makeToast(message: "确认密码必须为6到16位")
            return
        }
        if(pwd != pwd1){
            self.view.makeToast(message: "两次密码输入一致")
            return
        }
        var param:Dictionary<String,AnyObject> = Dictionary()
        param["method"] = "register"
        param["id"] = self.phoneNo
        param["sms_code"] =  code
        param["password"] = pwd?.md5()
        self.view.makeToastActivityWithMessage(message: "注册中")
        HttpUtil.post(param, callback: self.register_callback)
    }
    ///注册回调
    func register_callback(response:Dictionary<String,AnyObject>){
        dispatch_async(dispatch_get_main_queue(), {
            self.view.hideToastActivity()
            let code = response["code"] as! Int
            switch code {
            case 0:
                self.navigationController?.popViewControllerAnimated(true)
                self.view.makeToast(message: "注册成功")
                break
            case 4:
                self.view.makeToast(message: "验证码错误")
                break
            default:
                self.view.makeToast(message: "注册失败")
                break
            }
        })
    }
    ///发送验证码
    @IBAction func sendCode(sender: AnyObject) {
        self.hiddenStoryboad()
        let ph = CommonUtil.trim(self.phone.text)
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
        param["method"] = "register"
        param["id"] = ph
        self.view.makeToastActivity()
        HttpUtil.post(param, callback: self.code_callback)
        
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
    ///隐藏键盘
    func hiddenStoryboad(){
        self.phone.resignFirstResponder()
        self.code.resignFirstResponder()
        self.pwd.resignFirstResponder()
        self.rpwd.resignFirstResponder()
    }
    @IBAction func clickV(sender: AnyObject) {
        self.hiddenStoryboad()
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
