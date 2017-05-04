//
//  NewsController.swift
//  StockSearch
//
//  Created by 杜袁茵 on 5/1/16.
//  Copyright © 2016 Yuanyin Du. All rights reserved.
//

import UIKit

class NewsController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    var transData : NSDictionary = [:]
    var navTitle : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.topItem?.title = "Back"
        self.title = navTitle
        let index = (self.navigationController?.viewControllers.count)!-2
        self.navigationController?.viewControllers.removeAtIndex(index)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let d : NSDictionary = (transData["d"] as? NSDictionary)!
        let results : NSArray = (d["results"] as? NSArray)!
        
        return results.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let newsCell = tableView.dequeueReusableCellWithIdentifier("newsCell", forIndexPath: indexPath) as! NewsCell
        let d : NSDictionary = (transData["d"] as? NSDictionary)!
        let results : NSArray = (d["results"] as? NSArray)!
        let newsItem = results[indexPath.row]
        
        newsCell.newsTitle.text = newsItem["Title"] as? String
        newsCell.newsDescription.text = newsItem["Description"] as? String
        newsCell.newsPublisher.text = newsItem["Source"] as? String
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let dateString = newsItem["Date"] as! String
        let date = dateFormatter.dateFromString(dateString)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let time = dateFormatter.stringFromDate(date!)
        newsCell.newsDate.text = time
        
        return newsCell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let d : NSDictionary = (transData["d"] as? NSDictionary)!
        let results : NSArray = (d["results"] as? NSArray)!
        let item : NSDictionary = results[indexPath.row] as! NSDictionary
        if let url = NSURL(string: item["Url"] as! String) {
            UIApplication.sharedApplication().openURL(url)
        }
       
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "News2His" {
            let historic:HistoricController = segue.destinationViewController as! HistoricController
            historic.transData = self.navTitle
        } else if segue.identifier == "News2Detail" {
            let detail : DetailController = segue.destinationViewController as! DetailController
            detail.symbol = self.navTitle
            
        }
        
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
