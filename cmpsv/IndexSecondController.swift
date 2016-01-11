//
//  IndexSecondController.swift
//  cmpsv
//
//  Created by apple on 15/11/19.
//  Copyright © 2015年 cmp. All rights reserved.
//

import UIKit
import XWSwiftRefresh

class IndexSecondController: BaseViewController,UITableViewDataSource,UITableViewDelegate {
    var module_id:String!
    var module_name:String!
    var module_root_url:String!
    var modules:NSArray = NSArray()
    
    @IBOutlet weak var tle: UILabel!
    @IBOutlet weak var table: UITableView!
    init(){
        super.init(nibName: "IndexSecondController")
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
        self.setNeedsStatusBarAppearanceUpdate()
        self.tle.text = self.module_name
        self.table.dataSource = self
        self.table.delegate = self
        self.table.registerNib(UINib(nibName: "index_second_cell", bundle: self.bundle), forCellReuseIdentifier: "cell")
        
        let head = XWRefreshNormalHeader(target: self, action: "refresh")
        //隐藏状态栏 默认不隐藏，就显示 用户的状态
        head.refreshingTitleHidden = true
        //隐藏时间状态  默认隐藏，就显示 时间的状态
        head.refreshingTimeHidden = true
        //根据上拉比例设置透明度  默认 是 false
        head.automaticallyChangeAlpha = true
        self.table.headerView = head
        //立刻上拉刷新
        self.table.headerView?.beginRefreshing()
        
    }
    ///刷新
    func refresh(){
        var param = Dictionary<String, AnyObject>()
        param["method"] = "query_sub_module"
        param["cm_id"] = Global.cm_id
        param["module_id"] = self.module_id
        HttpUtil.post(param, callback: self.callback)
    }
    func callback(response:Dictionary<String,AnyObject>){
        self.table.headerView?.endRefreshing()
        dispatch_async(dispatch_get_main_queue(), {
            let code = response["code"] as! Int
            if(code==0){
                self.modules = response["content"] as! NSArray
                self.table.reloadData()
            }else{
               self.view.makeToast(message: "加载失败")
            }
            
        })
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if(indexPath.row%2==0){
            cell?.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        }else{
            cell?.backgroundColor = UIColor.whiteColor()
        }
        let img = cell?.viewWithTag(1) as! UIImageView
        let name = cell?.viewWithTag(2) as! UILabel
        img.layer.masksToBounds = true
        img.layer.cornerRadius = 30
        let imgurl = self.modules[indexPath.row]["small_icon_name"] as! String
        img.kf_setImageWithURL(NSURL(string: Config.base_img_url+self.module_root_url+"/"+imgurl)!)
        name.text = self.modules[indexPath.row]["module_name"] as? String
        return cell!
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.modules.count;
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = IndexThirdController()
        controller.info = self.modules[indexPath.row] as! NSDictionary
        controller.sub_module_id = self.module_id
        self.navigationController?.pushViewController(controller, animated: true)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    ///返回
    @IBAction func back(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
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
