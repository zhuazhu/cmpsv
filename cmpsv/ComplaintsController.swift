//
//  ComplaintsController.swift
//  cmpsv
//
//  Created by apple on 16/1/9.
//  Copyright © 2016年 cmp. All rights reserved.
//

import UIKit
import Alamofire

class ComplaintsController: BaseViewController {
    
    @IBOutlet weak var scl: UIScrollView!
    @IBOutlet weak var context: UITextView!
    @IBOutlet weak var btn: UIButton!
    init(){
        super.init(nibName: "ComplaintsController")
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
        self.context.layer.cornerRadius = 2
        self.context.layer.borderColor = ColorUtil.getColorForRGB("#33BCF0").CGColor
        self.context.layer.borderWidth = 1
        self.btn.layer.cornerRadius = 5
    }
    @IBAction func save(sender: AnyObject) {
        self.hiddenStoryboad()
        let txt = self.context.text
        if(CommonUtil.isEmpty(txt)){
            self.view.makeToast(message: "请输入投诉建议")
            return
        }
        var param:Dictionary<String,AnyObject> = Dictionary()
        param["method"] = "complaint_advice_info"
        param["content"] = txt
        self.view.makeToastActivityWithMessage(message: "提交中")
        HttpUtil.post(param, callback: self.callback)
    }
    func callback(response:Dictionary<String, AnyObject>){
        dispatch_async(dispatch_get_main_queue(), {
            self.view.hideToastActivity()
            let code = response["code"] as! Int
            if(code==0){
                self.view.makeToast(message: "提交成功")
                self.navigationController?.popViewControllerAnimated(true)
            }else{
                self.view.makeToast(message: "提交失败")
            }
        })
    }
    
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    ///隐藏键盘
    func hiddenStoryboad(){
        self.context.resignFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.scl.contentSize = CGSize(width: 0, height: 400)
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
