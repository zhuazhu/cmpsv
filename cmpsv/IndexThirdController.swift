//
//  IndexThirdController.swift
//  cmpsv
//
//  Created by apple on 15/11/23.
//  Copyright © 2015年 cmp. All rights reserved.
//

import UIKit
import XWSwiftRefresh

class IndexThirdController: BaseViewController,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate {
    var info:NSDictionary!
    var sub_module_id:NSString!
    var pageIndex = 0
    var shops:Array<AnyObject> = Array()
    ///标题
    @IBOutlet weak var tle: UILabel!
    
    @IBOutlet weak var tableview: UITableView!
    
    init(){
        super.init(nibName: "IndexThirdController")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        // Do any additional setup after loading the view.
    }
    var footer:XWRefreshAutoNormalFooter!
    private func initView(){
        self.tle.text = info["module_name"] as? String
        self.tableview.dataSource = self
        self.tableview.delegate = self
        self.tableview.registerNib(UINib(nibName: "index_third_cell", bundle: self.bundle), forCellReuseIdentifier: "cell")
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
        
        //添加下拉刷新的控件
        self.footer = XWRefreshAutoNormalFooter(target: self, action: "loadMore")
        self.footer.refreshingTitleHidden = true
        
    }
    
    func refresh(){
        self.pageIndex = 0;
        self.loadData()
    }
    
    func loadMore(){
        self.pageIndex++
        self.loadData()
    }
    private func loadData(){
        var param = Dictionary<String, AnyObject>()
        param["method"] = "query_shop_list"
        param["cm_id"] = Global.cm_id
        param["module_id"] = self.sub_module_id
        param["sub_module_id"] = self.info["module_id"] as! String
        param["page"] = self.pageIndex
        let user = UserUtil.get_user()
        if(user != nil){
            param["id"] = user!["id"]
        }
        HttpUtil.post(param, callback: self.callback)
    }
    
    func callback(response:Dictionary<String,AnyObject>){
        self.tableview.headerView?.endRefreshing()
        self.tableview.footerView?.endRefreshing()
        dispatch_async(dispatch_get_main_queue(), {
            let code = response["code"] as! Int
            if(code==0){
                if(self.pageIndex==0){
                    self.shops = response["content"] as! Array
                    if(self.shops.count==Global.count){
                        self.tableview.footerView = self.footer
                    }
                    self.tableview.reloadData()
                }else{
                    let arr:Array<AnyObject> = response["content"] as! Array
                    for number in arr
                    {
                        self.shops.append(number)
                    }
                    self.tableview.reloadData()
                }
            }else{
                if(self.pageIndex != 0){
                    self.pageIndex--
                }
                self.view.makeToast(message: "加载失败")
            }
            
        })

    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        let img = cell?.viewWithTag(1) as! UIImageView
        let name = cell?.viewWithTag(2) as! UILabel
        let brief = cell?.viewWithTag(3) as! UILabel
        let time = cell?.viewWithTag(4) as! UILabel
        let callCount = cell?.viewWithTag(5) as! UILabel
        let phoneImg = cell?.viewWithTag(6) as! UIButton
        img.layer.masksToBounds = true
        img.layer.cornerRadius = 30
        let imgurl = self.shops[indexPath.row]["shop_icon_name"] as! String
        img.kf_setImageWithURL(NSURL(string: imgurl)!)
        name.text = self.shops[indexPath.row]["shop_name"] as? String
        brief.text = self.shops[indexPath.row]["shop_brief"] as? String
        let btime = self.shops[indexPath.row]["shop_open_time"] as? String
        let etime = self.shops[indexPath.row]["shop_close_time"] as? String
        time.text = "营业时间: "+btime!+"-"+etime!
        let cunt = self.shops[indexPath.row]["shop_call_count"] as? Int
        if cunt>999 {
            callCount.text = "拨打999+次"
        }else{
            callCount.text = "拨打"+(cunt?.description)!+"次"
        }
        
        phoneImg.addTarget(self, action: "call_phone:", forControlEvents: UIControlEvents.TouchUpInside)
        return cell!
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shops.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = ShopDetailController()
        controller.shop = self.shops[indexPath.row] as! Dictionary
        controller.sub_module_id = self.info["module_id"] as! String
        controller.module_id = self.sub_module_id
        self.navigationController?.pushViewController(controller, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    ///拨打电话的行数
    var call_row:Int!
    ///拨打电话
    func call_phone(btn:UIButton){
        let cell = btn.superview?.superview as! UITableViewCell
        let indexPath = self.tableview.indexPathForCell(cell)
        let phone = self.shops[(indexPath?.row)!]["shop_tel_number"] as! String
        let alert = UIAlertView()
        alert.message = phone
        self.call_row = indexPath?.row
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
        param["shop_id"] = self.shops[self.call_row]["shop_id"] as! String
        HttpUtil.post(Config.base_url, param: param) { (response) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                if(response.result.isSuccess){
                    let rst = response.result.value as! Dictionary<String,AnyObject>
                    let cnt = rst["call_count"] as! Int
                    var d:Dictionary<String,AnyObject> = self.shops[self.call_row] as! Dictionary
                    d["shop_call_count"] = cnt
                    self.shops[self.call_row] = d
                    self.tableview.reloadData()
                }
                
            })
            
        }
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
