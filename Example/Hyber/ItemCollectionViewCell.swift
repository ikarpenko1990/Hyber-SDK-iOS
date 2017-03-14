//
//  ItemCollectionViewCell.swift
//  Hyber
//
//  Created by Taras Markevych on 3/14/17.
//  Copyright © 2017 Incuube. All rights reserved.
//

import UIKit



class ItemCollectionViewCell: UICollectionViewCell, UIScrollViewDelegate {
    @IBOutlet weak var chanelLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonLabel: UIButton!
    @IBOutlet weak var bodyLabel: UITextView!
    
    var scrollView: UIScrollView?
    let shotWidth:CGFloat = 320
    let shotHeight:CGFloat = 149
    var tabAction : (() -> Void)? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.autoresizingMask = [UIViewAutoresizing.flexibleHeight]
    }
    
    override func layoutSubviews() {
        self.layoutIfNeeded()
    }
   
    @IBAction func buttonAction(_ sender: AnyObject ) {
        if let tapBlock = self.tabAction {
            tapBlock()
        }
    }

    
    
}
