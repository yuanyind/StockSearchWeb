//
//  HistoricController.swift
//  StockSearch
//
//  Created by 杜袁茵 on 5/2/16.
//  Copyright © 2016 Yuanyin Du. All rights reserved.
//

import UIKit

class HistoricController: UIViewController {

    @IBOutlet weak var historicChat: UIWebView!
    var transData : String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let localfilePath = NSBundle.mainBundle().URLForResource("hw9", withExtension: "html");
        let myRequest = NSURLRequest(URL: localfilePath!);
        self.historicChat.loadRequest(myRequest);
        viewWillAppear(true)
        
        self.navigationController?.navigationBar.topItem?.title = "Back"
        self.title = transData
        let index = (self.navigationController?.viewControllers.count)!-2
        self.navigationController?.viewControllers.removeAtIndex(index)
        
    }
    override func viewWillAppear(animated: Bool) {
        let script = "window.onload = function() { historic('" + transData + "')}"
        if let result = historicChat.stringByEvaluatingJavaScriptFromString(script) {
           print(result)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*****************************       Segue           *********************************/
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NewsDetail" {
            let return_news = getNews()
            let news:NewsController = segue.destinationViewController as! NewsController
            news.transData = return_news
            news.navTitle = transData
        } else if segue.identifier == "His2Detail" {
            let detail : DetailController = segue.destinationViewController as! DetailController
            detail.symbol = transData
        
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
        getNewsString += transData
        
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
