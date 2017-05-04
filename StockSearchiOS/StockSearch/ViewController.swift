//
//  ViewController.swift
//  StockSearch
//
//  Created by 杜袁茵 on 4/15/16.
//  Copyright © 2016 Yuanyin Du. All rights reserved.
//

import UIKit
import CoreData
import CCAutocomplete

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource {

    @IBOutlet weak var stockName: UITextField!
    
    @IBOutlet weak var changeView: UIButton!
    
    var parseQuoteJson : NSDictionary = [:]
   
    @IBOutlet weak var refreshIndicator: UIActivityIndicatorView!
    @IBOutlet weak var favoTable: UITableView!
    
    @IBAction func refreshTable(sender: AnyObject) {
        refreshTable()
    }
    
    var refreshTimer : NSTimer!
    
    var transData : String = ""
    
    @IBOutlet weak var autoSwitch: UISwitch!
    
    @IBAction func autoRefresh(sender: AnyObject) {
        
        if self.autoSwitch.on {
            refreshTable()
            self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "refreshTable:", userInfo: nil, repeats: true)
        } else {
            self.refreshTimer.invalidate()
        }
    }
    
    func refreshTable() {
        self.refreshIndicator.startAnimating()
        dispatch_async(dispatch_get_main_queue(), {
            self.favoTable.reloadData()
            self.refreshIndicator.stopAnimating()
            print("refresh")
        })
    }
    
    
    
    @IBAction func getQuote(sender: AnyObject) {
        self.stockName.resignFirstResponder()
        
        if stockName.text == "" {
            let alertEmpty: UIAlertController = UIAlertController(title: "Please Enter a Stock Name or Symbol", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            let actionEmpty: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default){ (a: UIAlertAction) -> Void in
                print("alert Empty")
            }
            alertEmpty.addAction(actionEmpty)
            self.presentViewController(alertEmpty, animated: true) { () -> Void in
                print("alert present")
            }
        } else {
            
            getStcokDetail(stockName.text!)
        }
        
       
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "GetDetail" {
            let detailVC = segue.destinationViewController as! DetailController
            //detailVC.value = self.parseQuoteJson
            detailVC.symbol = self.transData
            print("executed")
            
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /*Hide the changeView Button*/
        changeView.hidden = true
    }
    
    
    var stocks = [NSManagedObject]()
    /*Hide the navigate bar in the first page*/
    /*Fetching from Core Data*/
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        
        super.viewWillAppear(animated)
        //1
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext

        //2
        let fetchRequest = NSFetchRequest(entityName: "FavoStock")
        
        //3
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
            stocks = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        //refresh table
        favoTable.reloadData()
        
        if(autoSwitch.on) {
            refreshTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector:"refreshTable", userInfo: nil, repeats: true)
        }
        refreshIndicator.stopAnimating()
        
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if(autoSwitch.on) {
            refreshTimer.invalidate()
        }
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**********************Get Stock Detail******************************/
    func getStcokDetail(stockSymbol: String) {
        /*
         * get Quote through Post
         */
        let serverUrl = NSURL(string: "http://duyyios-env.us-west-2.elasticbeanstalk.com")
        let getQuoteRequest = NSMutableURLRequest(URL: serverUrl!)
        getQuoteRequest.HTTPMethod = "POST"
        
        //Compose a query string
        let getQuoteString = "func=search&input=" + stockSymbol
        getQuoteRequest.HTTPBody = getQuoteString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let getQuote = NSURLSession.sharedSession().dataTaskWithRequest(getQuoteRequest) {
            data, response,error in
            if error != nil {
                print("error = \(error)")
                return
            }
            
            do {
                let getQuoteJson = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                if let _ = getQuoteJson {
                    
                    self.parseQuoteJson = getQuoteJson!
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        //self.presentViewController(parseString, animated: true, completion: nil)
                        self.transData = stockSymbol
                        self.performSegueWithIdentifier("GetDetail", sender: self)
                    }
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
        
    }
    
    
    /**********************Auto Complete************************/
    var autoCompleteViewController: AutoCompleteViewController!
    var isFirstLoad: Bool = true
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.isFirstLoad {
            self.isFirstLoad = false
            Autocomplete.setupAutocompleteForViewcontroller(self)
        }
    }
    
    /**********************Favo Table**************************/
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let favoCell = tableView.dequeueReusableCellWithIdentifier("favoCell", forIndexPath: indexPath) as!FavoStockCell
        var wait_until_cell_load = false
        
        let favoItem = stocks[indexPath.row]
        let favoSymbol = favoItem.valueForKey("symbol") as!String
        
        /*
         * the favo stock
         */
        let serverUrl = NSURL(string: "http://duyyios-env.us-west-2.elasticbeanstalk.com")
        let getQuoteRequest = NSMutableURLRequest(URL: serverUrl!)
        getQuoteRequest.HTTPMethod = "POST"
        
        //Compose a query string
        let getQuoteString = "func=search&input=" + favoSymbol
        getQuoteRequest.HTTPBody = getQuoteString.dataUsingEncoding(NSUTF8StringEncoding)
        
        let getQuote = NSURLSession.sharedSession().dataTaskWithRequest(getQuoteRequest) {
            data, response,error in
            if error != nil {
                print("error = \(error)")
                return
            }
            
            do {
                let getQuoteJson = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                if let value = getQuoteJson {
                    
                    favoCell.symbol.text = value["Symbol"] as? String
                    let lastPrice = value["LastPrice"] as! Float
                    favoCell.currentPrice.text = String(format: "$ %.2f", lastPrice)
                    let change = value["Change"] as! Float
                    let changePercent = value["ChangePercent"] as! Float
                    if change >= 0 {
                        favoCell.changePercent.text = String(format: "+%.2f(+%.2f%%)", change, changePercent)
                        favoCell.changePercent.backgroundColor = UIColor.greenColor()
                    } else {
                        favoCell.changePercent.text = String(format: "%.2f(%.2f%%)", change, changePercent)
                        favoCell.changePercent.backgroundColor = UIColor.redColor()
                    }
                    
                    favoCell.name.text = value["Name"] as? String
                    var marketCap = value["MarketCap"] as? Float
                    if marketCap >= 1000000000 {
                        marketCap = marketCap! / 1000000000
                        favoCell.marketCap.text = String(format: "Market Cap: %.2f Billion", marketCap!)
                    }
                    else if marketCap >= 1000000 {
                        marketCap = marketCap! / 1000000
                        favoCell.marketCap.text = String(format: "Market Cap: %.2f Million", marketCap!)
                    }
                    else {
                        favoCell.marketCap.text = String(format: "Market Cap: %.2f", marketCap!)
                    }
                    
                    wait_until_cell_load = true
  
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
        
        while(!wait_until_cell_load) {}
        
        return favoCell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let appDelegate =
                UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            let fetchRequest = NSFetchRequest(entityName: "FavoStock")
            let favoItem = stocks[indexPath.row]
            let favoSymbol = favoItem.valueForKey("symbol") as!String
            let predicate = NSPredicate(format: "symbol == %@", favoSymbol)
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
            
            // remove the deleted item from the `UITableView`
            stocks.removeAtIndex(indexPath.row)
            favoTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let favoItem = stocks[indexPath.row]
        let favoSymbol = favoItem.valueForKey("symbol") as!String
        getStcokDetail(favoSymbol)
        
    }
    

    
    
    
    /****************************************************************************************/
    
    
   
}

extension ViewController: AutocompleteDelegate {
    //Returns UITextField we want to apply autocomplete for
    func autoCompleteTextField() -> UITextField {
        return self.stockName
    }
    
    //Returns minimum number of characters to start showing autocomplete
    func autoCompleteThreshold(textField: UITextField) -> Int {
        return 2
    }
    
    
    //Returns array of objects
    func autoCompleteItemsForSearchTerm(term: String) -> [AutocompletableOption] {
        
        var autoListItems : [AutocompletableOption] = []
        var wait_until_getData = false
        /*
         * get Auto through Post
         */
        
        let serverUrl = NSURL(string: "http://duyyios-env.us-west-2.elasticbeanstalk.com")
        let getAutoRequest = NSMutableURLRequest(URL: serverUrl!)
        getAutoRequest.HTTPMethod = "POST"
        
        //Compose a query string
        let getAutoString = "func=auto&input=" + stockName.text!
        getAutoRequest.HTTPBody = getAutoString.dataUsingEncoding(NSUTF8StringEncoding)
        
        
        let getAuto = NSURLSession.sharedSession().dataTaskWithRequest(getAutoRequest) {
            data, response, error in
            if error != nil {
                print("error = \(error)")
                return
            }
            
            do {
                let getAutoJson = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? [NSDictionary]
                
                if let _ = getAutoJson {
                    
                    //self.parseQuoteJson = getAutoJson![0]
                    for item in getAutoJson! {
                        var item_text = item["Symbol"] as! String + "-"
                        item_text += item["Name"] as!String + "-"
                        item_text += item["Exchange"] as!String
                        autoListItems.append(AutocompleteCellData(text:item_text, image: nil))
                    }
                }
                else {
                    print("error")
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
                
            }
            wait_until_getData = true
        }
        getAuto.resume()
        
        while(!wait_until_getData){}
        
        
        return autoListItems;
        
        
    }
    
    //Maximum height which shows autocomplete items
    func autoCompleteHeight() -> CGFloat {
        return CGRectGetHeight(self.view.frame) / 3.0
    }
    
    //Is getting called when we tapped on the autocomplete item
    func didSelectItem(item: AutocompletableOption) {
        let indexOfDash = item.text.lowercaseString.characters.indexOf("-")
        let returnItemSymbol = item.text.substringToIndex(indexOfDash!)
        self.stockName.text = returnItemSymbol
    }
}
