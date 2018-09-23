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

    let dining_array = ["1920 Commons", "McClelland", "NCH Dining", "Hill House", "English House", "Falk Kosher"]
    let retail_array = ["Houston Market", "Tortas Frontera", "Gourmet Grocer", "Joe's Café", "Mark's Café", "Starbucks", "Pret a Manger", "MBA Café"]
    var final_dic = Dictionary<String,[String: String]>()
    
    @IBOutlet weak var dining_table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show()
        fetchData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.dining_table.delegate = self
            self.dining_table.dataSource = self
            self.dining_table.rowHeight = 90.0
            self.dining_table.reloadData()
            SVProgressHUD.dismiss()
        }
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {return "Dining Halls"}
        return "Retail Dining"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {return 6}
        return 8
    }
    
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        //header design
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
    
    func fetchData() {
        
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(abbreviation: "EST")
        
        //Fetch data using api
        let url = URL(string: "http://api.pennlabs.org/dining/venues")
        
        let task = URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
            let json_data = JSON(dataResponse)
            let arr = json_data["document"]["venue"].array as! [JSON]
            for json in arr {
                let name = json["name"].stringValue
                var actual_name = ""
                switch name {
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
                
                let url = json["facilityURL"].stringValue
                
                for a in (json["dateHours"].array as! [JSON]) {
                    if (a["date"].stringValue == formatter.string(from: date)) {
                        
                        let f = DateFormatter()
                        f.dateFormat = "HH:mm"
                        
                        let o = DateFormatter()
                        o.dateFormat = "HH:mm:ss"
                        
                        let meal = a["meal"]
                        
                        
                        var time_arr: [String] = []
                        for times in meal.array as! [JSON] {
                            if actual_name == "Houston Market" {
                                if(times["type"].stringValue == "Houston Market") {
                                    time_arr.append(f.string(from: o.date(from: times["open"].stringValue)!) + " - " + f.string(from: o.date(from: times["close"].stringValue)!))
                                }
                            }
                            else if actual_name == "Gourmet Grocer" {
                                if(times["type"].stringValue == "Gourmet Grocer") {
                                    time_arr.append(f.string(from: o.date(from: times["open"].stringValue)!) + " - " + f.string(from: o.date(from: times["close"].stringValue)!))
                                }
                            }
                            else {
                                time_arr.append(f.string(from: o.date(from: times["open"].stringValue)!) + " - " + f.string(from: o.date(from: times["close"].stringValue)!))
                            }
                        }
                
                        self.final_dic[actual_name] = ["url": url, "meal": time_arr.joined(separator: " | ")]
                        break
                    }
                    else{
                        self.final_dic[actual_name] = ["url": url, "meal": "CLOSED"]
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
        
        
        //set image of cell
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
        default: cell.img?.image = UIImage(named: "quad") // 다른 이미지로 교체 할것
        }
        
        //round corners to image
        cell.img?.layer.cornerRadius = 8.0
        cell.img?.clipsToBounds = true
        
        cell.hours?.text = self.final_dic[(cell.name?.text)!]?["meal"]!
        
        return cell
    }

    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if !Connectivity.isConnectedToInternet() {
            JSSAlertView().show(
                self,
                title: "No Network Connection Found",
                text: "Please Retry",
                buttonText: "OK")
            let indexPath = dining_table.indexPathForSelectedRow
            dining_table.deselectRow(at: indexPath!, animated: false)
            return false
        }
       
        return true
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue" {
            if let indexPath = self.dining_table.indexPathForSelectedRow {
                let cell = self.dining_table.cellForRow(at: indexPath) as! CustomCell
                print((self.final_dic[(cell.name?.text)!]?["url"]!)!)
                let dest = segue.destination as? MenuVC
                dest?.to_url = (self.final_dic[(cell.name?.text)!]?["url"]!)!
                self.dining_table.deselectRow(at: indexPath, animated: false)
            }
        }
    }
    
}

// taken from https://stackoverflow.com/questions/49732620/attempt-to-check-internet-connection-on-ios-device-with-alamofire
class Connectivity {
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
