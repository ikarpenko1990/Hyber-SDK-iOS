//
//  MessageCollectionViewController.swift
//  Hyber
//
//  Created by Taras Markevych on 3/14/17.
//  Copyright © 2017 Incuube. All rights reserved.
//

import UIKit
import Hyber
import RealmSwift

private let reuseIdentifier = "messageCell"

class MessageCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    let realm = try! Realm()
    var lists: Results<Message>!
    let notificationIdentifier: String = "GetNewPush"
    let defaults = UserDefaults.standard
    
    @IBOutlet var gesture: UITapGestureRecognizer!
    
    @IBAction func gestureAction(_ sender: Any) {
    }
    @IBAction func logoutAction(_ sender: Any) {
        Hyber.LogOut()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    func layoutSubviews() {
    
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        firstScreenLoader()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 310, height: 300)
        layout.minimumLineSpacing = 20
        layout.footerReferenceSize = CGSize(width: 1, height: 20)
        layout.headerReferenceSize = CGSize(width: 1, height: 20)
        collectionView?.collectionViewLayout = layout
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.allowsMultipleSelection = false
        NotificationCenter.default.addObserver(self, selector: #selector(MessageCollectionViewController.readAndUpdateUI),
                                               name:NSNotification.Name(rawValue: "GetNewPush"),
                                               object: nil)
        self.clearsSelectionOnViewWillAppear = false
        self.collectionView?.es_addPullToRefresh { [weak self] in
            self?.getMessageList()
            self?.collectionView?.es_stopPullToRefresh(completion: true, ignoreFooter: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        readAndUpdateUI()
        if lists.count > 2 {
            let sectionNumber = 0
            self.collectionView?.scrollToItem(at:NSIndexPath.init(row:(self.collectionView?.numberOfItems(inSection: sectionNumber))!-1,section: sectionNumber) as IndexPath,
                                              at: UICollectionViewScrollPosition.bottom,animated: true)
        }
    }

    
    func readAndUpdateUI() {
            lists = realm.objects(Message.self)
            collectionView?.reloadData()
    }
   
    func getMessageList() {
        Hyber.getMessageList(completionHandler: {(success) -> Void in
            if success {
                self.collectionView?.reloadData()
                self.collectionView?.es_stopPullToRefresh(completion: true)
            } else {
                self.collectionView?.es_stopPullToRefresh(completion: false)
                self.alertMessage(title: "Error", text: "Request failed. Please try later.")
            }
        })
    }
    
    func firstScreenLoader() {
        if defaults.string(forKey: "startScreen") == nil {
            if let vc3 = self.storyboard?.instantiateViewController(withIdentifier: "login") as? ViewController {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController!.present(vc3, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Navigation
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let list = lists[indexPath.row]
        if list.value(forKey: "mImageUrl") as! String? != nil {
              return CGSize(width: 310 , height: 298)
        } 
        return CGSize(width: 310 , height: 141)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let listsTasks = lists {
            return listsTasks.count
        }
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ItemCollectionViewCell
        let list = lists[indexPath.row]
        cell?.layer.cornerRadius = 15

        cell?.timeLabel.text = list.value(forKey: "mDate") as! String?
        cell?.chanelLabel.text = list.value(forKey: "mPartner") as! String?
        cell?.titleLabel.text = list.value(forKey: "mTitle") as! String?
        cell?.bodyLabel.text = list.value(forKey: "mBody") as! String?
        if list.value(forKey: "mImageUrl") as! String? != nil {
            cell?.imageView?.downloadedFrom(link: (list.value(forKey: "mImageUrl") as! String?)!)
            cell?.imageView.isHidden = false
        } else {
            cell?.imageView.isHidden = true
        }
        
        cell?.buttonLabel.setTitle(list.value(forKey: "mButtonText") as! String?, for: UIControlState.normal)
        let urlString = list.value(forKey: "mButtonUrl") as! String?
        cell?.tabAction = {
            if urlString != nil {
                if let url = URL(string: urlString! ) {
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
        return cell!
    }
    
    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let list = lists[indexPath.row]
        getActionViewReply(messageId: list.value(forKey: "messageId") as! String?)
    }
    
    func getActionViewReply(messageId: String?)  {
        let optionMenu = UIAlertController(title: "", message: "For writing message to sender press Reply", preferredStyle: .actionSheet)
        let replyAction = UIAlertAction(title: "Reply", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.sentAnswerAlert(replyMessageId: messageId)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        optionMenu.addAction(replyAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
   
    func sentAnswerAlert(replyMessageId: String?) {
        let alertController = UIAlertController(title: "Answer", message: "Please input your message", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Sent", style: .default) { [weak self] _ in
            if let field = alertController.textFields![0] as UITextField! {
                Hyber.sendMessageCallback(messageId: replyMessageId!, message: field.text, completionHandler: { (success) -> Void in
                    if success {
                        self?.collectionView?.reloadData()
                    } else {
                        self?.alertMessage(title: "Error", text: "Message was not sented. Please, try later")
                    }
                })
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        alertController.addTextField { (textField) in
            textField.placeholder = "Write something awsome for us 😊"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func alertMessage(title:String?, text: String?) {
        let alertController = UIAlertController(title: title, message: text, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel) { (_) in }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

}


