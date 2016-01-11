//
//  TabSaleController.swift
//  cmpsv
//
//  Created by apple on 15/11/21.
//  Copyright © 2015年 cmp. All rights reserved.
//

import UIKit
import XWSwiftRefresh

class TabSaleController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var shops:Array<AnyObject> = Array()
    var bundle = NSBundle.mainBundle()
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        // Do any additional setup after loading the view.
    }
    
    func initView(){
        self.tableview.dataSource = self
        self.tableview.delegate = self
        self.tableview.registerNib(UINib(nibName: "sale_cell", bundle: self.bundle), forCellReuseIdentifier: "cell")
        let head = XWRefreshNormalHeader(target: self, action: "refresh")
        //隐藏状态栏 默认不隐藏，就显示 用户的状态
        head.refreshingTitleHidden = true
        //隐藏时间状态  默认隐藏，就显示 时间的状态
        head.refreshingTimeHidden = true
        //根据上拉比例设置透明度  默认 是 false
        head.automaticallyChangeAlpha = true
        self.tableview.headerView = head
        //立刻上拉刷新
        self.tableview.headerView?.beginRefreshing()
    }
    func refresh(){
        loadData()
    }
    func loadData(){
        var param = Dictionary<String, AnyObject>()
        param["method"] = "query_promote_sales_shop"
        param["cm_id"] = Global.cm_id
        HttpUtil.post(param, callback: self.sales_callback)
    }
    func sales_callback(response:Dictionary<String,AnyObject>){
        self.tableview.headerView?.endRefreshing()
        dispatch_async(dispatch_get_main_queue(), {
            let code = response["code"] as! Int
            if(code==0){
                self.shops = response["content"] as! Array
                self.tableview.reloadData()
            }else{
                self.view.makeToast(message: "加载失败")
            }
        })
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        let img = cell?.viewWithTag(1) as! UIImageView
        let name = cell?.viewWithTag(2) as! UILabel
        let imgarr = self.shops[indexPath.row]["shop_icon_name"] as! String
        img.kf_setImageWithURL(NSURL(string: imgarr)!)
        name.text = self.shops[indexPath.row]["shop_name"] as? String
        return cell!
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shops.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let controller = ShopDetailController()
//        controller.shop = self.shops[indexPath.row] as! Dictionary
//        controller.sub_module_id = self.info["module_id"] as! String
//        controller.module_id = self.sub_module_id
//        self.navigationController?.pushViewController(controller, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        self.hidesBottomBarWhenPushed = false
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
