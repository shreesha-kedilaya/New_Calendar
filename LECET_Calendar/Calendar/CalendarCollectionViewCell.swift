//
//  CalendarCollectionViewCell.swift
//  LECET_Calendar
//
//  Created by Shreesha on 5/24/18.
//  Copyright © 2018 Shreesha. All rights reserved.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    
    var dateButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sharedInit()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        dateButton = UIButton(frame: bounds)
        dateButton.backgroundColor = UIColor(red: 41/255, green: 160/255, blue: 249/255, alpha: 1)
        addSubview(dateButton)
        dateButton.addTarget(self, action: #selector(CalendarCollectionViewCell.dateButtonClicked(sender:)), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dateButton.frame = bounds
    }
    
    @objc func dateButtonClicked(sender: UIButton) {
        
    }
}
