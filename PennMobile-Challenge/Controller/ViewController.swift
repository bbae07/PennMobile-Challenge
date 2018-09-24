//
//  ViewController.swift
//  PennMobile-Challenge
//
//  Created by brian bae on 2018. 9. 22..
//  Copyright © 2018년 brian bae. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD
import Alamofire // :( should've used alamofire ealier if i knew i was gonna check internet connectivity
import JSSAlertView

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let notif = Notification.Name.NSCalendarDayChanged
    let dining_array = ["1920 Commons", "McClelland", "NCH Dining", "Hill House", "English House", "Falk Kosher"] //Array of "Dining Halls"
    let retail_array = ["Houston Market", "Tortas Frontera", "Gourmet Grocer", "Joe's Café", "Mark's Café", "Starbucks", "Pret a Manger", "MBA Café"] //Array of "Retail Dining"
    var final_dic = Dictionary<String,[String: String]>() //Dictionary in which we will store the data we want from the api
    
    @IBOutlet weak var dining_table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(midnight(notification:)), name: notif, object: nil) //Listener to update past midnight
        SVProgressHUD.show() //Added a second delay and a HUD to ensure that all the data will be loaded in the table
        fetchData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.dining_table.delegate = self
            self.dining_table.dataSource = self
            self.dining_table.rowHeight = 90.0
            self.dining_table.addSubview(self.ref)
            self.dining_table.reloadData() //reload to make sure the tableview is filled appropriately
            SVProgressHUD.dismiss()
        }
        
    }
    
    @objc func midnight(notification: NSNotification) //function called when the day changes
    {
        fetchData()
        self.dining_table.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Set up "pull to refresh"
    lazy var ref: UIRefreshControl = {
        let n = UIRefreshControl()
        n.addTarget(self, action: #selector(self.update(_:)),for: UIControlEvents.valueChanged)
        return n
    }()
    
    @objc func update(_ ref: UIRefreshControl){ //function called when the user pulls the table down
        fetchData()
        self.dining_table.reloadData()
        ref.endRefreshing()
    }
    //End of "pull to refresh"
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 //Dining Halls and Retail Dining
    }
    
    //Set title of section headers
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {return "Dining Halls"}
        return "Retail Dining"
    }
    
    //Set the number of rows per section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {return 6} //Could've done the count of the elements of dining_array, but same thing :D
        return 8
    }
    
    //Header Design
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.frame.size = CGSize(width: tableView.frame.width, height: CGFloat(300.0))
            headerView.contentView.backgroundColor = .white
            headerView.textLabel?.textColor = .black
            headerView.textLabel?.font = UIFont(name: "AvenirNext-Medium", size: 21)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    //End of Header Design
    
    //A dateformatting function that takes the date (HH:mm:ss) from the api and changes it into the form we want
    func changeDateFormat(str: String, sec: Int) -> String{
        let o = DateFormatter()
        o.dateFormat = "HH:mm:ss"
        let temp_date = o.date(from: str)
        let comp = str.split(separator: ":") //Split HH:mm:ss into [HH,mm,ss]
        let minute = comp[1]
        let hour = comp[0]
        if minute == "30" { //Only when it's HH:30 do we want the table to show the minutes
            if sec == 1 {o.dateFormat = "h:mm a"} //AM and PM for retail dining
            else {o.dateFormat = "h:mm"}
        }
        else if hour == "23" && minute == "59" { //23:59 is essentially 00:00, so save some space in the cell
            if sec == 1 {return "12 AM"} //AM and PM for retail dining
            else {return "12"}
        }
        else { //For all other cases, just return the hour
            if sec == 1 {o.dateFormat = "h a"} //AM and PM for retail dining
            else {o.dateFormat = "h"}
        }
        let fin_str = o.string(from: temp_date!)
        return fin_str
        
    }
    
    //Use the pennlabs api to fetch desired data
    func fetchData() {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "EST")
        let today = formatter.string(from: date) //Today's date in the format "yyyy-MM-dd" so we can find the times we want from the data
        
        let url = URL(string: "http://api.pennlabs.org/dining/venues")
        
        let task = URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error") //In case the request returns an error
                    return }
            let json_data = JSON(dataResponse) //Use SwiftyJSON so we don't have to deal with annoying type stuff (cis 120..?)
            let arr = json_data["document"]["venue"].array! //Navigate through the data and get the array of the info we want
            for json in arr {
                let name = json["name"].stringValue //Save the name of the place that each json corresponds to
                var actual_name = ""
                switch name { //Realized a bit too late that the names in the API didn't match the names on the app, so matching them up here
                case "1920 Commons": actual_name = "1920 Commons"
                case "McClelland Express": actual_name = "McClelland"
                case "New College House": actual_name = "NCH Dining"
                case "Hill House": actual_name = "Hill House"
                case "English House": actual_name = "English House"
                case "Falk Kosher Dining": actual_name = "Falk Kosher"
                case "Houston Market": actual_name = "Houston Market"
                case "Tortas Frontera at the ARCH": actual_name = "Tortas Frontera"
                case "1920 Gourmet Grocer": actual_name = "Gourmet Grocer"
                case "Joe's Caf\\u00e9": actual_name = "Joe's Café"
                case "Mark's Caf\\u00e9": actual_name = "Mark's Café"
                case "1920 Starbucks": actual_name = "Starbucks"
                case "Pret a Manger Locust Walk": actual_name = "Pret a Manger"
                case "Pret a Manger MBA": actual_name = "MBA Café"
                default: actual_name = name
                }
                
                let url = json["facilityURL"].stringValue //Save the url of the place
                
                for a in (json["dateHours"].array!) {
                    if (a["date"].stringValue == today) { //If the date
                        let meal = a["meal"] //save the meal info
                        
                        var time_arr: [String] = [] //array to store all the time strings of a place in order to join them with a | later
                        for times in meal.array! { //meal.array can contain multiple times, ex) Commons closes at 2pm and reopens at 5
                            if self.retail_array.contains(actual_name){ //Since we are going to parse the time differently for retail dining, check if we're going through one right now
                                if actual_name == "Houston Market" {
                                    if(times["type"].stringValue == "Houston Market") { //We only want the time of type "Houston Market" not "The Market Caf\u00e9"
                                        time_arr.append(self.changeDateFormat(str: times["open"].stringValue, sec: 1) + " - " + self.changeDateFormat(str: times["close"].stringValue, sec: 1)) //Call on the date parser and join the opening and closing times with a dash
                                    }
                                }
                                else if actual_name == "Gourmet Grocer" {
                                    if(times["type"].stringValue == "Gourmet Grocer") { //We only want the time of type "Gourmet Grocer"
                                        time_arr.append(self.changeDateFormat(str: times["open"].stringValue, sec: 1) + " - " + self.changeDateFormat(str: times["close"].stringValue, sec: 1))
                                    }
                                }
                                else {
                                    time_arr.append(self.changeDateFormat(str: times["open"].stringValue, sec: 1) + " - " + self.changeDateFormat(str: times["close"].stringValue, sec: 1))
                                }
                            }
                            else{
                                if actual_name == "McClelland" {
                                    if(times["type"].stringValue != "Closed") { //Data from the API contained "Closed" times as well, so ignore that
                                        time_arr.append(self.changeDateFormat(str: times["open"].stringValue, sec: 0) + " - " + self.changeDateFormat(str: times["close"].stringValue, sec: 0))
                                    }
                                }
                                else {
                                    time_arr.append(self.changeDateFormat(str: times["open"].stringValue, sec: 0) + " - " + self.changeDateFormat(str: times["close"].stringValue, sec: 0))
                                }
                            }
                        }
                        
                        self.final_dic[actual_name] = ["url": url, "meal": time_arr.joined(separator: " | ")] //Join the time strings with | between them
                        break
                    }
                    else{
                        self.final_dic[actual_name] = ["url": url, "meal": "CLOSED"] //If there is no corresponding time, then the place is closed for today
                    }
                }
            }
        })
        task.resume()
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dining_table.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        
        //set name of cell
        if indexPath.section == 0 {
            cell.name?.text = dining_array[indexPath.row]
        }
        else {
            cell.name?.text = retail_array[indexPath.row]
        }
        
        
        //set image of cell - just hardcoded it since there's only a dozen-ish places
        switch cell.name?.text {
        case "1920 Commons": cell.img?.image = UIImage(named: "1920Commons")
        case "McClelland": cell.img?.image = UIImage(named: "mcclelland")
        case "NCH Dining": cell.img?.image = UIImage(named: "nch")
        case "Hill House": cell.img?.image = UIImage(named: "Hill House")
        case "English House": cell.img?.image = UIImage(named: "kceh")
        case "Falk Kosher": cell.img?.image = UIImage(named: "hillel")
        case "Houston Market": cell.img?.image = UIImage(named: "houston")
        case "Tortas Frontera": cell.img?.image = UIImage(named: "tortas")
        case "Gourmet Grocer": cell.img?.image = UIImage(named: "gourmetgrocer")
        case "Joe's Café": cell.img?.image = UIImage(named: "Penn.JoesCafe-Int5.72W")
        case "Mark's Café": cell.img?.image = UIImage(named: "marks")
        case "Starbucks": cell.img?.image = UIImage(named: "starbucks")
        case "Pret a Manger": cell.img?.image = UIImage(named: "beefsteak")
        case "MBA Café": cell.img?.image = UIImage(named: "beefsteak")
        default: cell.img?.image = UIImage(named: "quad")
        }
        
        //round corners to image
        cell.img?.layer.cornerRadius = 8.0
        cell.img?.clipsToBounds = true
        
        //set the hours of each place according to final_dic
        cell.hours?.text = self.final_dic[(cell.name?.text)!]?["meal"]!
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue" {
            if let indexPath = self.dining_table.indexPathForSelectedRow {
                let cell = self.dining_table.cellForRow(at: indexPath) as! CustomCell
                let dest = segue.destination as? MenuVC
                dest?.to_url = (self.final_dic[(cell.name?.text)!]?["url"]!)! //set the value of the to_url variable in MenuVC to the corresponding url
                self.dining_table.deselectRow(at: indexPath, animated: false) //deselect the row/cell so that when the user presses back from the webview, the cell won't be selected
            }
        }
    }
    
    //--------------------Extra--------------------
    
    //Only perform the segue (transition to webview from the cell on touch) when there is internet connection. Otherwise, show alert
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if !Connectivity.isConnectedToInternet() { //If no connection, show alert
            JSSAlertView().show(
                self,
                title: "No Network Connection Found",
                text: "Please Retry",
                buttonText: "OK")
            let indexPath = dining_table.indexPathForSelectedRow
            dining_table.deselectRow(at: indexPath!, animated: false)
            return false
        }
        return true //Otherwise, go through the segue
    }
}

// taken from https://stackoverflow.com/questions/49732620/attempt-to-check-internet-connection-on-ios-device-with-alamofire
class Connectivity {
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
