//
//  TabIndexController.swift
//  cmpsv
//
//  Created by apple on 15/11/4.
//  Copyright © 2015年 cmp. All rights reserved.
//

import UIKit

class TabIndexController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{

    @IBOutlet weak var collection_view: UICollectionView!
    var adv_scroll: UIScrollView!
    var adv_points: UIPageControl!
    var width = UIScreen.mainScreen().bounds.width
    var ads:NSArray = NSArray()
    var modules:NSArray = NSArray()
    var module_root_url:String!
    var ad_root_url:String!
    var bundle:NSBundle = NSBundle.mainBundle()
    var timer:NSTimer!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        self.querycmList()
        // Do any additional setup after loading the view.
    }

    private func initView(){
        self.collection_view.dataSource = self
        self.collection_view.delegate = self
        self.collection_view.registerNib(UINib(nibName: "module_cell", bundle: self.bundle), forCellWithReuseIdentifier: "module")
        self.collection_view.registerNib(UINib(nibName: "tab_index_adv_head", bundle: self.bundle), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "adv_head")
        self.timer = NSTimer.scheduledTimerWithTimeInterval(8.0, target: self, selector: "timerAction", userInfo: nil, repeats: true)
    }
    private var cm_id:String?
    ///查询小区列表
    func querycmList(){
        var param = Dictionary<String, AnyObject>()
        param["method"] = "query_cm_list"
        HttpUtil.post(param,callback: self.cm_callback)
    }
    ///小区列表回调
    func cm_callback(response:Dictionary<String,AnyObject>){
        dispatch_async(dispatch_get_main_queue(), {
            let code = response["code"] as! Int
            if(code==0){
                Global.cm_id = response["content"]!["cm_id"] as! String
                self.querycmAdvert()
            }else{
                
            }
            
        })
    }
    ///查询广告位
    func querycmAdvert(){
        var param = Dictionary<String, AnyObject>()
        param["method"] = "query_cm_info"
        param["cm_id"] = Global.cm_id
        HttpUtil.post(param,callback: self.cm_advert_callback)
    }
    ///广告位回调
    func cm_advert_callback(response:Dictionary<String,AnyObject>){
        dispatch_async(dispatch_get_main_queue(), {
            let code = response["code"] as! Int
            if(code==0){
                let content = response["content"] as! Dictionary<String,AnyObject>
                self.ads = content["ad"] as! NSArray
                self.modules = content["module"] as! NSArray
                self.ad_root_url = content["ad_root_url"] as! String
                self.module_root_url = content["module_root_url"] as! String
                self.collection_view.reloadData()
            }else{
                
            }
            
        })
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.modules.count
    }
    ///每个cell的大小
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.width/4, height: 100)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("module", forIndexPath: indexPath)
        let img = cell.viewWithTag(1) as! UIImageView
        let name = cell.viewWithTag(2) as! UILabel
        let img_name = self.modules[indexPath.row]["small_image_name"] as! String
        let module_name = self.modules[indexPath.row]["module_name"] as! String
        img.kf_setImageWithURL(NSURL(string: Config.base_img_url+self.module_root_url+"/"+img_name)!)
        name.text = module_name
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell_module = self.modules[indexPath.row]
        let is_second_dir = cell_module["is_second_dir"] as! Bool
        let module_id = cell_module["module_id"] as! String
        let module_name = cell_module["module_name"] as! String
        if(is_second_dir){
            let controller = IndexSecondController()
            controller.module_id = module_id
            controller.module_name = module_name
            controller.module_root_url = self.module_root_url
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            let controller = IndexThirdController()
            controller.info = cell_module as! NSDictionary
            controller.sub_module_id = module_name
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    ///返回头headerView的大小
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.width, height: 181)
    }
    ///首页的头部
    var head_cell:UICollectionReusableView!
    ///广告图片的高度
    let img_height:CGFloat = 180
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        self.head_cell = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "adv_head", forIndexPath: indexPath)
        self.adv_scroll = self.head_cell.viewWithTag(1) as! UIScrollView
        self.adv_scroll.delegate = self
        for img in self.adv_scroll.subviews {
            img.removeFromSuperview()
        }
        
        let count = self.ads.count
        adv_scroll.contentSize=CGSize(width:self.width*CGFloat(count), height: 0)
        self.adv_points = self.head_cell.viewWithTag(2) as! UIPageControl
        self.adv_points.numberOfPages = count
        for var i=0;i<count;i++ {
            let img =  UIImageView(frame: CGRect(x: CGFloat(i)*self.width, y: 0, width: self.width, height: self.img_height))
            img.contentMode = UIViewContentMode.ScaleAspectFill
            let name = self.ads[i]["ad_image_name"] as! String
            img.kf_setImageWithURL(NSURL(string: Config.base_img_url+self.ad_root_url+"/"+name)!)
            self.adv_scroll.addSubview(img)
        }
        
        return self.head_cell
    }
    
    ///广告循环定时器
    func timerAction(){
        var num = self.adv_points.currentPage
        if(self.ads.count>0){
            if((++num)>=self.ads.count){
                self.adv_scroll.contentOffset.x = 0
                self.adv_points.currentPage = 0;
            }else{
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.adv_scroll.contentOffset.x = self.width*CGFloat(num)
                })
                self.adv_points.currentPage = num
            }
        }
        
    }
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let tag = scrollView.tag
        if(tag==1){
            let xOffset = scrollView.contentOffset.x
            let num = Int(xOffset/self.width)
            self.adv_points.currentPage = num
        }
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let tag = scrollView.tag
        if(tag==2){
            let yOffset = scrollView.contentOffset.y
            let rect = self.head_cell.frame
            if(yOffset<0){
                self.head_cell.frame = CGRect(x: rect.origin.x, y:yOffset, width: self.width, height: self.img_height-yOffset)
                let arr = self.adv_scroll.subviews
                let img = arr[self.adv_points.currentPage]
                let irect = img.frame
                img.frame = CGRect(x: irect.origin.x, y: 0, width: self.width, height: self.img_height-yOffset)
            }else{
                self.head_cell.frame = CGRect(x: rect.origin.x, y:0, width: self.width, height: self.img_height)
                for img in self.adv_scroll.subviews {
                    let irect = img.frame
                    img.frame = CGRect(x: irect.origin.x, y: 0, width: self.width, height: self.img_height)
                }
            }
            
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.hidesBottomBarWhenPushed = false
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
