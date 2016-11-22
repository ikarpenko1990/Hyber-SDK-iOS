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
    var lists : Results<Message>!
    let defaults = UserDefaults.standard

    
    var isEditingMode = false
    //MARK: Actions 
    @IBOutlet weak var messageListsTableView: UITableView!
   
    
    @IBAction func editAction(_ sender: Any) {
            self.defaults.set("2", forKey: "startScreen")
            self.defaults.synchronize()
    }
    
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
     
        Hyber.getMessageList(completionHandler: { (success) -> Void in
            
            if success {
                self.messageListsTableView.reloadData()
            } else {
                self.getErrorAlert()
            }
        })
        self.messageListsTableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    //Mark: Main function
    func readTasksAndUpdateUI() {
        lists = realm.objects(Message.self)
        self.messageListsTableView.setEditing(false, animated: true)
        self.messageListsTableView.reloadData()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        readTasksAndUpdateUI()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
        
            let token = realm.addNotificationBlock { notification, realm in
                self.readTasksAndUpdateUI()
            }
        // later
        readTasksAndUpdateUI()
        token.stop()
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        firstScreen()
        readTasksAndUpdateUI()
        self.messageListsTableView.es_addPullToRefresh {
            [weak self] in
            Hyber.getMessageList(completionHandler: { (success) -> Void in
                
                if success {
                    self?.messageListsTableView.reloadData()
                    self?.messageListsTableView.es_stopPullToRefresh(completion: true)
                } else {
                    self?.getErrorAlert()
                     self?.messageListsTableView.es_stopPullToRefresh(completion: false)
                }
            })

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
    
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let listsTasks = lists{
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
                if let date = list.value(forKey: "mDate") as! Double? {
                    let dateformatter = DateFormatter()
                    dateformatter.dateStyle = DateFormatter.Style.short
                    dateformatter.timeStyle = DateFormatter.Style.short
                    let dateString = dateformatter.string(from: NSDate(timeIntervalSince1970: TimeInterval(date)) as Date)
                    cell?.timeLabel.text = dateString
                }
            }
        let img = list.value(forKey: "mImageUrl") as! String?
        cell?.photoLabel?.downloadedFrom(link: img!)
        let midX = self.view.bounds.width / 7
        if list.value(forKey: "mButtonText")  != nil {
            let title = list.value(forKey: "mButtonText")
            let button = UIButton()
            button.frame = CGRectMake(midX, 340 , 240, 32)
            button.layer.cornerRadius = 5
            button.backgroundColor = UIColor.darkGray
            button.setTitle(title as! String?, for: UIControlState.normal)
            cell?.addSubview(button)
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRow(at: indexPath as IndexPath)
        if cell !=  nil {
            let list = lists[indexPath.row]
            if list.value(forKey: "mButtonUrl") != nil {
                let link = list.value(forKey: "mButtonText") as! String?
                if let url = URL(string: link!) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:])
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
            print ("You selected cell number: \(indexPath.row)!")
        }
    }

 
    
    
    func linkButton(_ sender: Any) {
       print("Button pressed")
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
        let alertController = UIAlertController(title: "Network error", message: "Please turn on your internet connection", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel) { (_) in }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func goToUrlAlert(link: String? ) {
        let alertController = UIAlertController(title: "Open safari?", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel) { (_) in
            if let url = URL(string: link!) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:])
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func sentAnswerAlert(messageId: String?) {
        let alertController = UIAlertController(title: "Answer", message: "Please input your message", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Sent", style: .default) { (_) in
            if let field = alertController.textFields![0] as? UITextField {
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
            textField.placeholder = "write something awsome for us 😊 "
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)

    
    }
    
}

//MARK: Extention for downloading images
extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

extension CGRect {
    init(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) {
        self.init(x:x, y:y, width:w, height:h)
    }
}
