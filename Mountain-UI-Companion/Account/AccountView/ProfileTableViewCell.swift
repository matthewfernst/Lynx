//
//  ProfileTableViewCell.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/25/23.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    static let identifier = "ProfileTableViewCell"
    
    private let profilePictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        return label
    }()
    
    private let editProfileAndAccountLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.text = "Edit Account & Profile"
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameLabel)
        contentView.addSubview(editProfileAndAccountLabel)
        contentView.addSubview(profilePictureImageView)
        accessoryType = .disclosureIndicator
        
        
        profilePictureImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        editProfileAndAccountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profilePictureImageView.widthAnchor.constraint(equalToConstant: 70),
            profilePictureImageView.heightAnchor.constraint(equalToConstant: 70),
            profilePictureImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15),
            profilePictureImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: profilePictureImageView.trailingAnchor, constant: 15),
            nameLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: -10),
            
            editProfileAndAccountLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            editProfileAndAccountLabel.leadingAnchor.constraint(equalTo: profilePictureImageView.trailingAnchor, constant: 15)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(withProfile profile: Profile) {
        profilePictureImageView.image = profile.profilePicture ?? profile.getDefaultProfilePicture(fontSize: 50,
                                                                                            size: CGSize(width: 100, height: 100),
                                                                                            move: CGPoint(x: 20, y: 20))
        profilePictureImageView.backgroundColor = .systemBackground
        nameLabel.text = profile.name
        self.backgroundColor = .secondarySystemBackground
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
