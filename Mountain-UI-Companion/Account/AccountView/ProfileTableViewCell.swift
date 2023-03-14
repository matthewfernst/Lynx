//
//  ProfileTableViewCell.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/25/23.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    static let identifier = "ProfileTableViewCell"
    
    private let profileImageContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let usersNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        return label
    }()
    
    private let editProfileAndAccountLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(usersNameLabel)
        contentView.addSubview(editProfileAndAccountLabel)
        contentView.addSubview(profileImageContainer)
        contentView.addSubview(profileImageView)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        profileImageContainer.backgroundColor = nil
        profileImageView.image = nil
        usersNameLabel.text = nil
        editProfileAndAccountLabel.text = nil
    }
    
    public func configure(withProfile profile: Profile) {
        profileImageContainer.backgroundColor = .systemBackground
        
        profileImageView.image = profile.profilePicture ?? profile.defaultAccountSettingsProfilePicture
        
        usersNameLabel.text = profile.name
        editProfileAndAccountLabel.text = "Edit Account & Profile"
        self.backgroundColor = .secondarySystemBackground
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = contentView.frame.size.height - 12
        profileImageContainer.frame = CGRect(x: 10, y: 6, width: size, height: size)
        profileImageContainer.layer.cornerRadius = profileImageContainer.frame.size.width / 2.0
        
        let imageSize = size
        profileImageView.frame = CGRect(x: (size - imageSize) / 2, y: (size - imageSize) / 2, width: imageSize, height: imageSize)
        profileImageView.center = profileImageContainer.center
        profileImageView.makeRounded()
        
        usersNameLabel.frame = CGRect(x: contentView.center.x - 60,
                                      y: contentView.center.y - 55,
                                      width: contentView.frame.size.width - 15 - profileImageContainer.frame.size.width,
                                      height: contentView.frame.size.height)
        
        editProfileAndAccountLabel.frame = CGRect(x: contentView.center.x - 60,
                                                  y: contentView.center.y - 35,
                                                  width: contentView.frame.size.width - 15 - profileImageContainer.frame.size.width,
                                                  height: contentView.frame.size.height)
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
