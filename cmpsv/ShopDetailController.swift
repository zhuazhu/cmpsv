//
//  ShopDetailController.swift
//  cmpsv
//
//  Created by apple on 16/1/2.
//  Copyright © 2016年 cmp. All rights reserved.
//

import UIKit

class ShopDetailController: BaseViewController,UIAlertViewDelegate {
    ///店铺信息
    var shop:Dictionary<String,AnyObject>!
    var sub_module_id:NSString!
    var module_id:NSString!
    let bounds = UIScreen.mainScreen().bounds
    ///标题
    @IBOutlet weak var tle: UILabel!
    ///收藏按钮
    @IBOutlet weak var colect: UIView!
    ///立即联系的文字
    @IBOutlet weak var colect_t: UILabel!
    
    ///呼叫电话按钮
    @IBOutlet weak var phoneBtn: UIView!
    ///店铺logo
    @IBOutlet weak var logo: UIImageView!
    ///名称
    @IBOutlet weak var name: UILabel!
    ///描述
    @IBOutlet weak var ms: UILabel!
    ///营业时间
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var scl: UIScrollView!
    ///图片
    @IBOutlet weak var imgs: UIView!
    ///地址
    @IBOutlet weak var address: UILabel!
    ///联系人
    @IBOutlet weak var contact: UILabel!
    ///电话号码
    @IBOutlet weak var phoneNo: UILabel!
    ///店铺图片的高度约束
    @IBOutlet weak var imgsView_heightContent: NSLayoutConstraint!
    
    init(){
        super.init(nibName: "ShopDetailController")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        // Do any additional setup after loading the view.
    }
    let ht = 400
    private func initView(){
        self.colect.layer.cornerRadius = 5
        let colect = self.shop["collect"] as! Int
        if(colect==0){
            self.colect_t.text = "收藏店铺"
        }else{
            self.colect_t.text = "取消收藏"
        }
        self.phoneBtn.layer.cornerRadius = 5
        let sname = self.shop["shop_name"] as? String
        self.tle.text = sname
        let imgurl = self.shop["shop_icon_name"] as! String
        self.logo.layer.cornerRadius = 25
        self.logo.kf_setImageWithURL(NSURL(string: imgurl)!)
        self.name.text = sname
        self.ms.text = self.shop["shop_brief"] as? String
        let btime = self.shop["shop_open_time"] as! String
        let etime = self.shop["shop_close_time"] as! String
        self.time.text = "营业时间: "+btime+"-"+etime
        self.address.text = self.shop["shop_address"] as? String
        let linkman = self.shop["shop_linkman"] as? String
        if CommonUtil.isEmpty(linkman) {
            self.contact.text = "店小二"
        }else{
            self.contact.text = CommonUtil.trim(linkman)
        }
        
        self.phoneNo.text = self.shop["shop_tel_number"] as? String
        
    }
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    ///收藏
    @IBAction func celect(sender: AnyObject) {
        let user = UserUtil.get_user()
        if(user==nil){
            let controller = LoginController()
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            var param = Dictionary<String, AnyObject>()
            param["method"] = "collect_shop"
            param["module_id"] = self.module_id
            param["sub_module_id"] = self.sub_module_id
            param["shop_id"] = self.shop["shop_id"]
            param["id"] = user!["id"]
            var colect = self.shop["collect"] as! Int
            colect = (++colect)%2
            param["collect"] = colect
            HttpUtil.post(param){ (response) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), {
                    if(response.result.isSuccess){
                        let rst = response.result.value as! Dictionary<String,AnyObject>
                        let code = rst["code"] as! Int
                        if(code==0){
                            self.shop["collect"] = colect
                            if(colect==0){
                                self.view.makeToast(message: "取消成功")
                                self.colect_t.text = "收藏店铺"
                            }else{
                                self.view.makeToast(message: "收藏成功")
                                self.colect_t.text = "取消收藏"
                            }
                        }else{
                            if(colect==0){
                                self.view.makeToast(message: "取消失败")
                            }else{
                                self.view.makeToast(message: "收藏成功")
                            }
                        }
                    } else {
                        if(colect==0){
                            self.view.makeToast(message: "取消失败")
                        }else{
                            self.view.makeToast(message: "收藏成功")
                        }
                        
                    }
                })
                
            }
        }
        
    }
    ///拨打电话
    @IBAction func callPhone(sender: AnyObject) {
        let alert = UIAlertView()
        alert.message = self.shop["shop_tel_number"] as? String
        alert.addButtonWithTitle("取消")
        alert.addButtonWithTitle("呼叫")
        alert.cancelButtonIndex = 0
        alert.delegate = self
        alert.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if(buttonIndex==1){
            let url = NSURL(string: "tel://"+alertView.message!)
            UIApplication.sharedApplication().openURL(url!)
            self.callShop()
        }
    }
    
    ///记录拨打电话的次数
    func callShop(){
        var param = Dictionary<String, AnyObject>()
        param["method"] = "call_shop"
        param["shop_id"] = self.shop["shop_id"] as! String
        HttpUtil.post(param) { (response) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                
            })
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        let imgarr:Array<String>? = self.shop["shop_detail_image_list"] as? Array
        if(imgarr != nil){
            self.imgsView_heightContent.constant = CGFloat(ht*imgarr!.count)
            for(var i=0;i<imgarr!.count;i++){
                let img = UIImageView(frame: CGRect(x: 0, y: i*ht, width: Int(self.bounds.width), height: ht))
                img.kf_setImageWithURL(NSURL(string: imgarr![i])!)
                self.imgs.addSubview(img)
            }
            self.scl.contentSize = CGSize(width: 0, height: ht*imgarr!.count+360)
        }else{
            let h = self.phoneNo.frame.origin.y
            self.scl.contentSize = CGSize(width: 0, height: h+50)
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
