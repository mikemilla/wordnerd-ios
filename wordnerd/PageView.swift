//
//  PageView.swift
//  wordnerd
//
//  Created by Michael Miller on 2/7/16.
//  Copyright © 2016 Michael Miller. All rights reserved.
//

import UIKit

class PageView: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    let BIT_FONT:String = "8BITWONDERNominal"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label.font = UIFont(name: BIT_FONT, size: 22)
    }

}