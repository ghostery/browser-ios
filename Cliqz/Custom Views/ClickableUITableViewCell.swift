//
//  ClickableUITableViewCell.swift
//  Client
//
//  Created by Mahmoud Adam on 11/8/17.
//  Copyright © 2017 Cliqz. All rights reserved.
//

import UIKit

// TODO: This is only for Telemetry and might be removed later on
class ClickableUITableViewCell: UITableViewCell {
    var clickedElement = ""
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
        // tab gesture recognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellPressed(_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.delegate = self
        self.addGestureRecognizer(tapGestureRecognizer)    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clickedElement = "cell"
    }
    
    func cellPressed(_ gestureRecognizer: UIGestureRecognizer) {
        
    }
}
