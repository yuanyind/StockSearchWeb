//
//  DetailController.swift
//  StockSearch
//
//  Created by 杜袁茵 on 4/17/16.
//  Copyright © 2016 Yuanyin Du. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

class DetailController: UIViewController, UITableViewDataSource,FBSDKSharingDelegate{


    @IBAction func shareFacebook(sender: AnyObject) {
        let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: "https://finance.yahoo.com/")
        
        var shareTitle = "Current Stock Price of "
        shareTitle += value["Name"] as! String + " is "
        let lastPrice = value["LastPrice"] as! Float
        shareTitle += String(format: "$ %.2f", lastPrice)
        
        content.contentTitle = shareTitle
        var description = "Stock Information of "
        description += value["Name"] as! String + " ("
        description += value["Symbol"] as!String + ")"
        content.contentDescription = description
        var imageURL = "http://chart.finance.yahoo.com/t?s="
        imageURL += self.value["Symbol"] as! String + "&lang=en-US&width=180&height=160"

        content.imageURL = NSURL(string: imageURL)
        FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: self)
    
    }
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        if results.count > 0 {
            let alertSuccess: UIAlertController = UIAlertController(title: "Post Success", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            let actionSuccess: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default){ (a: UIAlertAction) -> Void in
                print("post Success")
            }
            alertSuccess.addAction(actionSuccess)
            self.presentViewController(alertSuccess, animated: true) { () -> Void in
                print("alert Success present")
            }
        } else {
            sharerDidCancel(sharer)
        }
        

    }
    func sharerDidCancel(sharer: FBSDKSharing!) {
        let alertCancel: UIAlertController = UIAlertController(title: "Canceled", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let actionCancel: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default){ (a: UIAlertAction) -> Void in
            print("post Canceled")
        }
        alertCancel.addAction(actionCancel)
        self.presentViewController(alertCancel, animated: true) { () -> Void in
            print("alert Canceled present")
        }
    }
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        let alertFailed: UIAlertController = UIAlertController(title: "Post Failed", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let actionFailed: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default){ (a: UIAlertAction) -> Void in
            print("post Failed")
        }
        alertFailed.addAction(actionFailed)
        self.presentViewController(alertFailed, animated: true) { () -> Void in
            print("alert Failed present")
        }
    }
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var symbols = [NSManagedObject]()
    
    @IBAction func addFavo(sender: AnyObject) {
        if(isSymbolInData) {
            delFavo(value["Symbol"] as!String)
            if let image = UIImage(named: "Star.png") {
                addFavo.setBackgroundImage(image, forState: .Normal)
            }
            isSymbolInData = false
        } else {
            self.saveFavo(value["Symbol"]as!String)
            if let image = UIImage(named: "StarFilled.png") {
                addFavo.setBackgroundImage(image, forState: .Normal)
            }
            isSymbolInData = true
        }
    }
 
    
    @IBOutlet weak var addFavo: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var text: UILabel!
    
    var isSymbolInData = false
    
    func saveFavo(symbol: String) {
        //1
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let entity =  NSEntityDescription.entityForName("FavoStock",
                                                        inManagedObjectContext:managedContext)
        
        let stock = NSManagedObject(entity: entity!,
                                    insertIntoManagedObjectContext: managedContext)
        
        //3
        stock.setValue(symbol, forKey: "symbol")
        
        //4
        do {
            try managedContext.save()
            //5
            symbols.append(stock)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func delFavo(symbol: String) {
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "FavoStock")
        let predicate = NSPredicate(format: "symbol == %@", value["Symbol"]as!String)
        fetchRequest.predicate = predicate
        
        do{
            let fetchResults = try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            managedContext.deleteObject(fetchResults![0])
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save \(error), \(error.userInfo)")
            }
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }
    
    
    var value : NSDictionary = [:]
    var symbol : String = ""
    
    func getStockDetail(symbol: String) -> Bool{
        let serverUrl = NSURL(string: "http://duyyios-env.us-west-2.elasticbeanstalk.com")
        let getQuoteRequest = NSMutableURLRequest(URL: serverUrl!)
        getQuoteRequest.HTTPMethod = "POST"
        
        var wait_until_getData = true
        
        //Compose a query string
        let getQuoteString = "func=search&input=" + symbol
        getQuoteRequest.HTTPBody = getQuoteString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let getQuote = NSURLSession.sharedSession().dataTaskWithRequest(getQuoteRequest) {
            data, response,error in
            if error != nil {
                print("error = \(error)")
                return
            }
            
            do {
                let getQuoteJson = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                if let detail = getQuoteJson {
                    self.value = detail
                    wait_until_getData = false
                }
                else {
                    print("error")
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
                /*Dispatch the block into main thread*/
                dispatch_async(dispatch_get_main_queue()) {
                    // alert Invalid
                    let alertInvalid: UIAlertController = UIAlertController(title: "Invalid Symbol", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                    let actionInvalid: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default){ (a: UIAlertAction) -> Void in
                        print("alert Invalid")
                    }
                    alertInvalid.addAction(actionInvalid)
                    self.presentViewController(alertInvalid, animated: true, completion: nil)
                    
                }
            }
        }
        
        getQuote.resume()
        while(wait_until_getData) {}
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getStockDetail(symbol)
        
        // Do any additional setup after loading the view.
        
        // show the navigate bar
        self.navigationController?.navigationBarHidden = false
        
        let index = self.navigationController?.viewControllers.count
        if index > 2 {
            self.navigationController?.navigationBar.topItem?.title = "Back"
            self.title = symbol
            let index = (self.navigationController?.viewControllers.count)!-2
            self.navigationController?.viewControllers.removeAtIndex(index)
        } else {
            self.navigationController?.navigationBar.topItem?.title = value["Symbol"] as? String
        }
        
        
        // show image of yahoo
        var yahooUrl = "http://chart.finance.yahoo.com/t?s="
        yahooUrl += value["Symbol"] as!String + "&lang=en-US&width=400&height=300"

        let url = NSURL(string: yahooUrl)
        let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
        imageView.image = UIImage(data: data!)
        
        // set favo button
        
        let fetchRequest = NSFetchRequest(entityName: "FavoStock")
        let predicate = NSPredicate(format: "symbol == %@", value["Symbol"]as!String)
        fetchRequest.predicate = predicate
        
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        do {
            let fetchResults = try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            if (fetchResults! != [])  {
                if let image = UIImage(named: "StarFilled.png") {
                    addFavo.setBackgroundImage(image, forState: .Normal)
                }
                isSymbolInData = true
                print("in")
            } else {
                print("not in")
            }
            
        } catch let fetchError as NSError {
            print("getGalleryForItem error: \(fetchError.localizedDescription)")
            
        }
        
        print("output\(symbols)")
        
    }
    
    override func viewDidLayoutSubviews() {
        self.scrollView.contentSize=CGSizeMake(343, 750)
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let index : Int = indexPath.row
        switch index {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath) as! StockDetailCell
            cell.firstCol.text = "Name"
            cell.secondCol.text = value["Name"] as? String
             return cell;
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath) as! StockDetailCell
            cell.firstCol.text = "Symbol"
            cell.secondCol.text = value["Symbol"] as? String
             return cell;
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath) as! StockDetailCell
            cell.firstCol.text = "Last Price"
            let lastPrice = value["LastPrice"] as! Float
            cell.secondCol.text = String(format: "$ %.2f", lastPrice)
            return cell
        case 3:
            let cellWithPic = tableView.dequeueReusableCellWithIdentifier("DetailWithPic", forIndexPath: indexPath) as! DetailWithPicCell
            cellWithPic.firstCol.text = "Change"
            let change = value["Change"] as! Float
            let changePercent = value["ChangePercent"] as! Float
            cellWithPic.secondCol.text = String(format: "%.2f(%.2f%%)", change, changePercent)
            if change >= 0 {
                cellWithPic.img.image = UIImage(named: "Up.png")
            } else {
                cellWithPic.img.image = UIImage(named: "Down.png")
            }
             return cellWithPic;
        case 4:
            let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath) as! StockDetailCell
            cell.firstCol.text = "Time and Date"
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "EEE MMM d HH:mm:ss zzzz yyyy"
            let dateString = value["Timestamp"] as! String
            let date = dateFormatter.dateFromString(dateString)
            dateFormatter.dateFormat = "MMM d yyyy HH:mm"
            let time = dateFormatter.stringFromDate(date!)
            cell.secondCol.text = time
             return cell;
        case 5:
            let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath) as! StockDetailCell
            cell.firstCol.text = "Market Cap"
            var marketCap = value["MarketCap"] as? Float
            if marketCap >= 1000000000 {
                marketCap = marketCap! / 1000000000
                cell.secondCol.text = String(format: "%.2f Billion", marketCap!)
            }
            else if marketCap >= 1000000 {
                marketCap = marketCap! / 1000000
                cell.secondCol.text = String(format: "%.2f Million", marketCap!)
            }
            else {
                cell.secondCol.text = String(format: "%.2f", marketCap!)
            }
             return cell;
        case 6:
            let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath) as! StockDetailCell
            cell.firstCol.text = "Volume"
            cell.secondCol.text = String("\(value["Volume"] as! Int)")
             return cell;
        case 7:
            let cellWithPic = tableView.dequeueReusableCellWithIdentifier("DetailWithPic", forIndexPath: indexPath) as! DetailWithPicCell
            cellWithPic.firstCol.text = "Change YTD"
            let changeYTD = value["ChangeYTD"] as! Float
            let changePercentYTD = value["ChangePercentYTD"] as! Float
            cellWithPic.secondCol.text = String(format: "%.2f(%.2f%%)", changeYTD, changePercentYTD)
            if changeYTD >= 0 {
                cellWithPic.img.image = UIImage(named: "Up.png")
            } else {
                cellWithPic.img.image = UIImage(named: "Down.png")
            }
             return cellWithPic;
        case 8:
            let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath) as! StockDetailCell
            cell.firstCol.text = "High Price"
            let highPrice = value["High"] as! Float
            cell.secondCol.text = String(format: "$ %.2f", highPrice)
             return cell;
        case 9:
            let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath) as! StockDetailCell
            cell.firstCol.text = "Low Price"
            let lowPrice = value["Low"] as! Float
            cell.secondCol.text = String(format: "$ %.2f", lowPrice)
             return cell;
        case 10:
            let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath) as! StockDetailCell
            cell.firstCol.text = "Opening Price"
            let openPrice = value["Open"] as! Float
            cell.secondCol.text = String(format: "$ %.2f", openPrice)
             return cell;
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell", forIndexPath: indexPath) as! StockDetailCell
            print("stock Detail error")
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
        
    /*****************************       Segue           *********************************/
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "NewsDetail" {
            let return_news = getNews()
            let news:NewsController = segue.destinationViewController as! NewsController
            news.transData = return_news
            news.navTitle = value["Symbol"] as! String
        }
        else if segue.identifier == "historic" {
            let historic:HistoricController = segue.destinationViewController as! HistoricController
            historic.transData = value["Symbol"] as! String
        }
    }
    
    /*****************************       Get News           *********************************/
    func getNews() -> NSDictionary {
        var newsData : NSDictionary = [:]
        var wait_until_getData = false
        /*
         * get Quote through Post
         */
        let serverUrl = NSURL(string: "http://duyyios-env.us-west-2.elasticbeanstalk.com")
        let getNewsRequest = NSMutableURLRequest(URL: serverUrl!)
        getNewsRequest.HTTPMethod = "POST"
        
        //Compose a query string
        var getNewsString = "func=news&input="
        getNewsString += value["Symbol"] as! String
        
        getNewsRequest.HTTPBody = getNewsString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let getNews = NSURLSession.sharedSession().dataTaskWithRequest(getNewsRequest) {
            data, response,error in
            if error != nil {
                print("error = \(error)")
                return
            }
            
            do {
                let getNewsJson = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                if let _ = getNewsJson {
                    newsData = getNewsJson!
                    wait_until_getData = true
                }
                else {
                    print("error")
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
                /*Dispatch the block into main thread*/
                dispatch_async(dispatch_get_main_queue()) {
                    // alert Invalid
                    let alertInvalid: UIAlertController = UIAlertController(title: "Invalid Symbol", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                    let actionInvalid: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default){ (a: UIAlertAction) -> Void in
                        print("alert Invalid")
                    }
                    alertInvalid.addAction(actionInvalid)
                    self.presentViewController(alertInvalid, animated: true, completion: nil)
                    
                }
            }
        }
        
        getNews.resume()
        
        while(!wait_until_getData){}
        
        return newsData

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
