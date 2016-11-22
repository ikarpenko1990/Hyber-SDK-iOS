//
//  MessageTableViewController.swift
//  Hyber
//
//  Created by Taras on 11/16/16.
//  Copyright © 2016 Incuube. All rights reserved.
//

import UIKit
import Hyber
import Realm
import RealmSwift
import SwiftyJSON

class MessageTableViewController: UITableViewController {
    let realm = try! Realm()
    var lists : Results<Message>!

    
    var isEditingMode = false
    //MARK: Actions 
    @IBOutlet weak var messageListsTableView: UITableView!
   
    
    @IBAction func editAction(_ sender: Any) {

    }
    
    @IBAction func refreshAction(_ sender: Any) {
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
        readTasksAndUpdateUI()
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
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
        _ = realm.objects(Message.self).sorted(byProperty: "mDate",  ascending: false)

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
            //incomplete
//            if let img = list.value(forKey: "mImageUrl") as! String? {
//                let url = NSURL(string: img)
//                let imageView = UIImageView()
//                imageView.downloadedFrom(link: img)
//                
//                cell?.addSubview(imageView)
//            }
        
        
        return cell!
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
