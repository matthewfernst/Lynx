//
//  StatsTableViewCell.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 6/18/23.
//

import UIKit

class StatsTableViewCell: UITableViewCell {
    static var identifier = "StatsTableViewCell"
    
    private static let labelFontSize: CGFloat = 14
    private let leftStatInformationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        return label
    }()
    
    private let leftStatIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        return imageView
    }()
    
    private let leftStatLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: labelFontSize)
        return label
    }()
    
    private let rightStatInformationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        return label
    }()
    
    private let rightStatIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        return imageView
    }()
    
    private let rightStatLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: labelFontSize)
        return label
    }()
    
    override func layoutSubviews() {
         super.layoutSubviews()
         
         // Update the separator inset to hide the separators
         separatorInset = UIEdgeInsets(top: 0, left: bounds.size.width, bottom: 0, right: 0)
     }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(leftStatInformationLabel)
        contentView.addSubview(leftStatIconImageView)
        contentView.addSubview(leftStatLabel)
        
        contentView.addSubview(rightStatInformationLabel)
        contentView.addSubview(rightStatIconImageView)
        contentView.addSubview(rightStatLabel)
        
        // Set up constraints for the labels
        let padding: CGFloat = 16.0
        let iconPadding: CGFloat = 2.0
        let iconHeightWidth: CGFloat = 15.0
        NSLayoutConstraint.activate([
            leftStatInformationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            leftStatInformationLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            leftStatIconImageView.leadingAnchor.constraint(equalTo: leftStatInformationLabel.leadingAnchor),
            leftStatIconImageView.centerYAnchor.constraint(equalTo: leftStatLabel.centerYAnchor),
            leftStatIconImageView.heightAnchor.constraint(equalToConstant: iconHeightWidth),
            leftStatIconImageView.widthAnchor.constraint(equalToConstant: iconHeightWidth),
            leftStatLabel.leadingAnchor.constraint(equalTo: leftStatIconImageView.trailingAnchor, constant: iconPadding),
            leftStatLabel.topAnchor.constraint(equalTo: leftStatInformationLabel.bottomAnchor),
            
            
            rightStatInformationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding * 4),
            rightStatInformationLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rightStatIconImageView.leadingAnchor.constraint(equalTo: rightStatInformationLabel.leadingAnchor),
            rightStatIconImageView.centerYAnchor.constraint(equalTo: rightStatLabel.centerYAnchor),
            rightStatIconImageView.heightAnchor.constraint(equalToConstant: iconHeightWidth),
            rightStatIconImageView.widthAnchor.constraint(equalToConstant: iconHeightWidth),
            rightStatLabel.leadingAnchor.constraint(equalTo: rightStatIconImageView.trailingAnchor, constant: iconPadding),
            rightStatLabel.topAnchor.constraint(equalTo: rightStatInformationLabel.bottomAnchor),
        ])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(leftStat: Stat, rightStat: Stat?) {
        leftStatInformationLabel.text = leftStat.information
        leftStatIconImageView.image = leftStat.icon
        leftStatLabel.text = leftStat.label
        
        if let rightStat = rightStat {
            rightStatInformationLabel.text = rightStat.information
            rightStatIconImageView.image = rightStat.icon
            rightStatLabel.text = rightStat.label
        } else {
            rightStatInformationLabel.removeFromSuperview()
            rightStatIconImageView.removeFromSuperview()
            rightStatLabel.removeFromSuperview()
        }
    }
}

struct Stat
{
    let label: String
    var information: String
    let icon: UIImage
}
