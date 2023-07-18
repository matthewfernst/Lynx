//
//  ShowAllLeadersTableViewCell.swift
//  Lynx
//
//  Created by Matthew Ernst on 7/17/23.
//

import UIKit

class ShowAllLeadersTableViewCell: UITableViewCell {
    
    static let identifier = "ShowAllLeadersTableViewCell"
    
    private let informationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Show All Leaders"
        label.font = UIFont.systemFont(ofSize: 17.0, weight: .medium)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .secondarySystemBackground
        self.accessoryType = .disclosureIndicator
        
        contentView.addSubview(informationLabel)
        
        NSLayoutConstraint.activate([
            informationLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            informationLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
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

}
