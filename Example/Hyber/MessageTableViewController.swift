//
//  MessageTableViewController.swift
//  Hyber
//
//  Created by Taras on 11/16/16.
//  Copyright © 2016 Incuube. All rights reserved.
//

import UIKit
import Hyber
import RealmSwift
import SwiftyJSON

class MessageTableViewController: UITableViewController {
    let realm = try! Realm()
    var lists: Results<Message>!
    let defaults = UserDefaults.standard
    let notificationIdentifier: String = "GetNewPush"
    
    // Register to receive notification

    var isEditingMode = false
    //MARK: Actions 
    @IBOutlet weak var messageListsTableView: UITableView!
   
    @IBAction func logoutAction(_ sender: Any) {
        Hyber.LogOut()
    }
   
    @IBAction func revoke(_ sender: Any) {
    }

    func handleRefresh(_ refreshControl: UIRefreshControl) {
         Hyber.getMessageList(completionHandler: { (success) -> Void in

            if success {
                self.messageListsTableView.reloadData()
            } else {
                self.getErrorAlert()
            }
        })
        refreshControl.endRefreshing()
     }
    
  
    
    //Mark: Main function
    func readAndUpdateUI() {
        lists = realm.objects(Message.self)
        self.messageListsTableView.setEditing(false, animated: true)
        self.messageListsTableView.reloadData()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        readAndUpdateUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        //scroll down
        if lists.count > 2 {
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections-1)
            let indexPath = IndexPath(row: numberOfRows-1 , section: numberOfSections-1)
            self.tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        readAndUpdateUI()
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        firstScreen()
        readAndUpdateUI()
        NotificationCenter.default.addObserver(self, selector: #selector(MessageTableViewController.readAndUpdateUI), name:NSNotification.Name(rawValue: "GetNewPush"), object: nil)
        self.messageListsTableView.es_addPullToRefresh() {
            self.getMessageList()
            self.messageListsTableView.es_stopPullToRefresh(completion: true)
        }
    }
    
    func firstScreen() {
        if defaults.string(forKey: "startScreen") == nil {
            if let vc3 = self.storyboard?.instantiateViewController(withIdentifier: "login") as? ViewController {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController!.present(vc3, animated: true, completion: nil)
            }
        }
    }
    
    func getMessageList() {
        Hyber.getMessageList(completionHandler: { (success) -> Void in
            if success {
                self.messageListsTableView.reloadData()
                self.messageListsTableView.es_stopPullToRefresh(completion: true)
            } else {
                self.messageListsTableView.es_stopPullToRefresh(completion: false)
                self.getErrorAlert()
            }
        })
    }
    
      // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let listsTasks = lists {
            return listsTasks.count
        } 
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? MessageTableViewCell
       
        let list = lists[indexPath.row]
            cell?.titleLabel.text = list.value(forKey: "mTitle") as! String?
            cell?.textBodyLabel.text = list.value(forKey: "mBody") as! String?
            cell?.typeLabel.text = list.value(forKey: "mPartner") as! String?
            cell?.statusLabel.text = "reported"
            cell?.statusLabel.textColor = UIColor.green
                if list.value(forKey: "mDate") != nil {
                    if let date = list.value(forKey: "mDate") as! String? {
                        cell?.timeLabel.text = date
                    }
                }
            if list.value(forKey: "mImageUrl")  != nil {
                let img = list.value(forKey: "mImageUrl") as! String?
                cell?.photoLabel?.downloadedFrom(link: img!)
            } else {
               cell?.photoLabel?.image = nil
            }
    
            if list.value(forKey: "mButtonText")  != nil {
                    let midX = self.view.bounds.width / 7
                    let title = list.value(forKey: "mButtonText")
                    let button = UIButton()
                        button.frame = CGRectMake(midX, 80 , 240, 32)
                        button.layer.cornerRadius = 5
                        button.backgroundColor = UIColor.darkGray
                        button.setTitle(title as! String?, for: UIControlState.normal)
                    cell?.addSubview(button)
            }
        
        return cell!
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let list = lists[indexPath.row]
        if list.value(forKey: "mButtonUrl") != nil {

            if let url = URL(string: (list.value(forKey: "mButtonUrl") as! String?)!) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:])
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        } else {
            print("No url")
        }
        
    }
  
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let answerAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive,  title: "Answer") { (deleteAction, indexPath) -> Void in
            let listToAnswer = self.lists[indexPath.row]
            let messageId = listToAnswer.value(forKey: "messageId") as? String
            self.sentAnswerAlert(messageId: messageId)
            }
        
        return [answerAction]
    }
    
    
    // MARK: - Allerts
    
    func getErrorAlert() {
        let alertController = UIAlertController(title: "Error", message: "Somesing wrong please try later", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel) { (_) in }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func sentAnswerAlert(messageId: String?) {
        let alertController = UIAlertController(title: "Answer", message: "Please input your message", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Sent", style: .default) { (_) in
            if let field = alertController.textFields![0] as UITextField! {
                Hyber.sendMessageCallback(messageId: messageId!, message: field.text, completionHandler: { (success) -> Void in
                    if success {
                        self.messageListsTableView.reloadData()
                    } else {
                        self.getErrorAlert()
                    }
                })
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.placeholder = "write something awsome for us 😊"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let list = lists[indexPath.row]
        let img = list.value(forKey: "mImageUrl") as? String
        let caption = list.value(forKey: "mButtonText") as? String
            if img !=  nil {
                return 460.0
            }
        
            else if (caption == nil) && img == nil {
                return 140.0
            }
        
        return 180.0
    }
    
}

