//
//  MenuVC.swift
//  PennMobile-Challenge
//
//  Created by brian bae on 2018. 9. 22..
//  Copyright © 2018년 brian bae. All rights reserved.
//

import UIKit
import WebKit

class MenuVC: UIViewController, WKUIDelegate {

    //default url just in case
    var to_url = "google.com"
    
    @IBOutlet weak var web: WKWebView!
    
    override func viewDidLoad() {
        //receives url from ViewController (the cell of the table) and loads it using the webview
        super.viewDidLoad()
        let url = URL(string: to_url)
        let request = URLRequest(url: url!)
        web.load(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
