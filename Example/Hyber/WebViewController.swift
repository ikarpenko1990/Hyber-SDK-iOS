//
//  WebViewController.swift
//  Hyber
//
//  Created by Taras on 11/24/16.
//  Copyright © 2016 Incuube. All rights reserved.
//

import UIKit
import Hyber
import RealmSwift


class WebViewController: UIViewController {
    var selectedUrl: Message!
    @IBOutlet weak var webViewContainer: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//            let link = selectedUrl.value(forKey: "mButtonUrl")
//            print(link as! String)
            if let url = URL(string: "http://google.com") {
//                if #available(iOS 10.0, *) {
//                    UIApplication.shared.open(url, options: [:])
//                } else {
//                    UIApplication.shared.openURL(url)
//                }
                 let requestObj = NSURLRequest(url: url);
                webViewContainer.loadRequest(requestObj as URLRequest)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
