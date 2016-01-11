//
//  ReleaseController.swift
//  cmpsv
//
//  Created by apple on 16/1/9.
//  Copyright © 2016年 cmp. All rights reserved.
//

import UIKit

class ReleaseController: BaseViewController {

    @IBOutlet weak var bview: UIView!
    @IBOutlet weak var aview: UIView!
    ///公司名称
    @IBOutlet weak var cname: UITextField!
    ///联系电话
    @IBOutlet weak var phone: UITextField!
    ///主要内容
    @IBOutlet weak var context: UITextView!
    init(){
        super.init(nibName: "ReleaseController")
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
        self.bview.layer.cornerRadius = 2
        self.bview.layer.borderWidth = 1
        self.bview.layer.borderColor = ColorUtil.getColorForRGB("#999999").CGColor
        self.aview.layer.cornerRadius = 2
        self.aview.layer.borderWidth = 1
        self.aview.layer.borderColor = ColorUtil.getColorForRGB("#999999").CGColor
    }

    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    ///隐藏键盘
    func hiddenStoryboad(){
        self.cname.resignFirstResponder()
        self.phone.resignFirstResponder()
        self.context.resignFirstResponder()
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
