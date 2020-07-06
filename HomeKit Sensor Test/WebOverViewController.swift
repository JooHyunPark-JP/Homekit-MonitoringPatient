//
//  WebOverViewController.swift
//  HomeKit Sensor Test
//
//  Created by Xcode User on 2018-08-09.
//  Copyright © 2018 Xcode User. All rights reserved.
//

import UIKit
import WebKit

class WebOverViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let htmlPath = "http://smarthome.fast.sheridanc.on.ca/HomeKitTest/welcomePage.html";

        let url = URL(string: htmlPath)!
       let request = URLRequest(url : url)
        webView.load (request)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
