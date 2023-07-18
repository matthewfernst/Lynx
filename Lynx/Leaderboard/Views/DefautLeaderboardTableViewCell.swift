//
//  DefautLeaderboardTableViewCell.swift
//  Lynx
//
//  Created by Matthew Ernst on 7/17/23.
//

import UIKit

class DefautLeaderboardTableViewCell: UITableViewCell
{
    
    static let identifier = "DefaultLeaderboardTableViewCell"
    
    private var nameLabel: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        return view
    }()
    
    
    private static let profilePictureHeightWidth: CGFloat = 60.0
    private let profilePictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .systemBackground
        imageView.contentMode = .center // Change contentMode to center
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = profilePictureHeightWidth / 2
        
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 28)
        imageView.image = UIImage(systemName: "person.fill", withConfiguration: symbolConfiguration)
        
        imageView.tintColor = .secondarySystemFill
        return imageView
    }()
    
    private var statNumberLabel: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 10
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .secondarySystemBackground
        
        for view in [
            nameLabel,
            profilePictureImageView,
            statNumberLabel,
        ] {
            contentView.addSubview(view)
        }
        
        NSLayoutConstraint.activate([
            profilePictureImageView.widthAnchor.constraint(equalToConstant: Self.profilePictureHeightWidth),
            profilePictureImageView.heightAnchor.constraint(equalToConstant: Self.profilePictureHeightWidth),
            profilePictureImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            profilePictureImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: profilePictureImageView.trailingAnchor, constant: 10),
            nameLabel.heightAnchor.constraint(equalToConstant: 20),
            nameLabel.topAnchor.constraint(equalTo: profilePictureImageView.topAnchor),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: contentView.frame.height / 2),
            
            statNumberLabel.leadingAnchor.constraint(equalTo: profilePictureImageView.trailingAnchor, constant: 10),
            statNumberLabel.heightAnchor.constraint(equalToConstant: 20),
            statNumberLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: contentView.frame.height / 2),
            statNumberLabel.centerXAnchor.constraint(equalTo: nameLabel.centerXAnchor)
        ])
        
        animateRoundedRectangles()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    
    
    private func animateRoundedRectangles() {
        // Animations for the nameLabel
        let nameLabelAnimation = CAKeyframeAnimation(keyPath: "backgroundColor")
        nameLabelAnimation.values = [
            UIColor.systemGray4.cgColor,
            UIColor.systemGray3.cgColor,
            UIColor.systemGray4.cgColor
        ]
        nameLabelAnimation.keyTimes = [0, 0.5, 1]
        nameLabelAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        nameLabelAnimation.duration = 0.75
        nameLabelAnimation.repeatCount = .greatestFiniteMagnitude
        nameLabel.layer.add(nameLabelAnimation, forKey: "nameLabelBackgroundColorAnimation")
        
        // Animations for the statNumberLabel
        let statNumberLabelAnimation = CAKeyframeAnimation(keyPath: "backgroundColor")
        statNumberLabelAnimation.values = [
            UIColor.systemGray4.cgColor,
            UIColor.systemGray3.cgColor,
            UIColor.systemGray4.cgColor
        ]
        statNumberLabelAnimation.keyTimes = [0, 0.5, 1]
        statNumberLabelAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        statNumberLabelAnimation.duration = 0.75
        statNumberLabelAnimation.repeatCount = .greatestFiniteMagnitude
        statNumberLabel.layer.add(statNumberLabelAnimation, forKey: "statNumberLabelBackgroundColorAnimation")
    }
    
}
