//
//  TabMyController.swift
//  cmpsv
//
//  Created by apple on 15/11/21.
//  Copyright © 2015年 cmp. All rights reserved.
//

import UIKit

class TabMyController: UIViewController,UIScrollViewDelegate {

    @IBOutlet weak var topc: NSLayoutConstraint!
    @IBOutlet weak var heightc: NSLayoutConstraint!
    @IBOutlet weak var scl: UIScrollView!
    @IBOutlet weak var ttlview: UIView!
    ///用户头像
    @IBOutlet weak var logo: UIImageView!
    ///用户名称
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var ttlname: UILabel!
    ///退出登录按钮
    @IBOutlet weak var logout_btn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        // Do any additional setup after loading the view.
    }
    
    func initView(){
        self.logout_btn.layer.cornerRadius = 5
        self.scl.delegate = self
        self.logo.layer.cornerRadius = 25
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        if(yOffset < -20){
            self.topc.constant = yOffset
            self.heightc.constant = 130+(-20-yOffset)
        }else{
            let h = yOffset+20
            if(h<65){
                self.ttlview.backgroundColor = ColorUtil.getColorForRGB("#33BCF0", alpha: Float(h/65))
                self.ttlname.hidden = true
            }else{
                self.ttlview.backgroundColor = ColorUtil.getColorForRGB("#33BCF0")
                self.ttlname.hidden = false
            }
        }
    }
    ///点击用户头像
    @IBAction func click_logo(sender: AnyObject) {
        let user = UserUtil.get_user()
        if(user == nil ){
            let controller = LoginController()
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    ///修改用户信息
    @IBAction func edit_user(sender: AnyObject) {
        let user = UserUtil.get_user()
        if(user==nil){
            let controller = LoginController()
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            let controller = EditUserController()
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
    ///点击收藏
    @IBAction func click_colect(sender: AnyObject) {
        let user = UserUtil.get_user()
        if(user==nil){
            let controller = LoginController()
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            let controller = ColectController()
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    ///需求发布
    @IBAction func click_analysis(sender: AnyObject) {
        let controller = ReleaseController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    ///投诉建议
    @IBAction func click_complaints(sender: AnyObject) {
        let controller = ComplaintsController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    ///广告合作
    @IBAction func click_advertor(sender: AnyObject) {
        let controller = ACController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    ///关于我们
    @IBAction func click_server(sender: AnyObject) {
        let controller = AboutServerController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.scl.contentSize = CGSize(width: 0, height: 500)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        let user = UserUtil.get_user()
        if(user != nil ){
            let phonenumber = user!["id"] as! String
            self.query_user(phonenumber)
            self.logout_btn.hidden = false
        }else{
            self.name.text = "登录"
            self.logout_btn.hidden = true
        }
        self.hidesBottomBarWhenPushed = false
    }
    func query_user(user_id:String!){
        var param:Dictionary<String,AnyObject> = Dictionary()
        param["method"] = "get_person_info"
        param["user_id"] = user_id
        HttpUtil.post(param, callback: self.user_callback)
    }
    func user_callback(response:Dictionary<String, AnyObject>){
        dispatch_async(dispatch_get_main_queue(), {
            self.view.hideToastActivity()
            let code = response["code"] as! Int
            if(code==0){
                let rst = response["content"] as! Dictionary<String,AnyObject>
                self.name.text = rst["nick"] as? String
            }
        })
    }
    ///退出登录
    @IBAction func logout(sender: AnyObject) {
        UserUtil.clear_user()
        self.name.text = "登录"
        self.logout_btn.hidden = true
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
