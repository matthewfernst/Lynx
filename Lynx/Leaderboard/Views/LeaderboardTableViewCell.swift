//
//  TableViewCell.swift
//  Lynx
//
//  Created by Matthew Ernst on 7/14/23.
//

import UIKit

class LeaderboardTableViewCell: UITableViewCell
{
    
    static var identifier = "LeaderboardTableViewCell"
    
    private static func getCommonLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        return label
    }
    
    private static func getCommonImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.contentMode = .scaleAspectFill
        return imageView
    }
    
    private var nameLabel: UILabel = {
        let label = getCommonLabel()
        label.font = UIFont.systemFont(ofSize: 20.0, weight: .medium)
        return label
    }()
    
    private static let profilePictureHeightWidth: CGFloat = 60.0
    private let profilePictureImageView: UIImageView = {
        let imageView = getCommonImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = profilePictureHeightWidth / 2
        return imageView
    }()
    
    private static let crownOrMedalHeightWidth: CGFloat = 15
    private let crownOrMedalImageView: UIImageView = {
        return getCommonImageView()
    }()
    
    private static let padding: CGFloat = 10
    private let circleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .tertiarySystemBackground
        view.layer.cornerRadius = (crownOrMedalHeightWidth + padding) / 2
        view.clipsToBounds = true
        return view
    }()
    
    private let statNumberLabel: UILabel = {
        let label = getCommonLabel()
        label.font = UIFont.systemFont(ofSize: 17.0, weight: .semibold)
        return label
    }()
    
    public func configure(with attributes: LeaderboardAttributes, place: Int?) {
        
        handleProfilePicture(attributes.profilePicture, fullName: attributes.fullName)

        nameLabel.text = attributes.fullName
        statNumberLabel.text = attributes.stat
        
        if let place = place {
            crownOrMedalImageView.isHidden = false
            circleView.isHidden = false
            let crownOrMedalSymbolName: String
            switch LeaderboardPlaces(rawValue: place) {
            case .firstPlace:
                crownOrMedalSymbolName = "crown.fill"
                crownOrMedalImageView.tintColor = .gold
            case .secondPlace, .thirdPlace:
                crownOrMedalSymbolName = "medal.fill"
                crownOrMedalImageView.tintColor = LeaderboardPlaces(rawValue: place) == .secondPlace ? .silver : .bronze
            default:
                crownOrMedalSymbolName = ""
            }
            crownOrMedalImageView.image = UIImage(systemName: crownOrMedalSymbolName)
        } else {
            crownOrMedalImageView.isHidden = true
            circleView.isHidden = true
        }
    }
    
    private func handleProfilePicture(_ picture: UIImage?, fullName: String) {
        profilePictureImageView.subviews.forEach { $0.removeFromSuperview() }
        
        if let profilePicture = picture {
            profilePictureImageView.image = profilePicture
        } else {
            profilePictureImageView.image = nil
            let defaultProfilePicture = ProfilePictureUtils.getDefaultProfilePicture(name: fullName, fontSize: 24)
            profilePictureImageView.addSubview(defaultProfilePicture)
            defaultProfilePicture.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                defaultProfilePicture.centerXAnchor.constraint(equalTo: profilePictureImageView.centerXAnchor),
                defaultProfilePicture.centerYAnchor.constraint(equalTo: profilePictureImageView.centerYAnchor)
            ])
            profilePictureImageView.backgroundColor = .systemBackground
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .secondarySystemBackground
        
        for view in [
            nameLabel,
            profilePictureImageView,
            statNumberLabel,
            circleView
        ] {
            contentView.addSubview(view)
        }
        
        circleView.addSubview(crownOrMedalImageView)
        
        NSLayoutConstraint.activate([
            profilePictureImageView.widthAnchor.constraint(equalToConstant: Self.profilePictureHeightWidth),
            profilePictureImageView.heightAnchor.constraint(equalToConstant: Self.profilePictureHeightWidth),
            profilePictureImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            profilePictureImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            crownOrMedalImageView.widthAnchor.constraint(equalToConstant: Self.crownOrMedalHeightWidth),
            crownOrMedalImageView.heightAnchor.constraint(equalToConstant: Self.crownOrMedalHeightWidth),
            crownOrMedalImageView.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            crownOrMedalImageView.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            
            circleView.widthAnchor.constraint(equalToConstant: Self.crownOrMedalHeightWidth + Self.padding),
            circleView.heightAnchor.constraint(equalToConstant: Self.crownOrMedalHeightWidth + Self.padding),
            circleView.bottomAnchor.constraint(equalTo: profilePictureImageView.bottomAnchor),
            circleView.centerXAnchor.constraint(equalTo: profilePictureImageView.trailingAnchor, constant: -5),
          
            
            nameLabel.topAnchor.constraint(equalTo: profilePictureImageView.topAnchor),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: contentView.frame.height / 2),
            
            statNumberLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: contentView.frame.height / 2),
            statNumberLabel.centerXAnchor.constraint(equalTo: nameLabel.centerXAnchor)
        ])
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
    
}
