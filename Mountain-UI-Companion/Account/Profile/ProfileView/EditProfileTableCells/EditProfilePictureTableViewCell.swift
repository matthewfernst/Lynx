//
//  ProfilePictureTableViewCell.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 3/13/23.
//

import UIKit
import TOCropViewController

class EditProfilePictureTableViewCell: UITableViewCell {
    
    static let identifier = "ProfilePictureTableViewCell"
    
    private var profile: Profile!
    private var defaultProfilePicture: UIImage!
    
    var delegate: EditProfileTableViewController?
    
    private let profilePictureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person")
        imageView.backgroundColor = .secondarySystemFill
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50 // set the corner radius to half of the view's height to create a circular shape
        return imageView
    }()
    
    private lazy var changeProfilePictureButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Change Profile Picture"
        configuration.buttonSize = .mini
        configuration.cornerStyle = .medium
        
        let button = UIButton(configuration: configuration)
        button.addTarget(self.delegate, action: #selector(handleChangeProfilePicture), for: .touchUpInside)
        return button
    }()
    
    @objc func handleChangeProfilePicture() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Replace", style: .default) { [weak self] _ in
            let picker = UIImagePickerController()
            picker.delegate = self
            self?.delegate?.present(picker, animated: true)
        })
        ac.addAction(UIAlertAction(title: "Remove", style: .destructive) { [unowned self] _ in
            if let newPicture = defaultProfilePicture {
                self.profilePictureImageView.image = newPicture
                self.delegate?.handleProfilePictureChange(newProfilePicture: newPicture)
            }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.delegate!.present(ac, animated: true)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(profilePictureImageView)
        contentView.addSubview(changeProfilePictureButton)
        
        let imageViewSize = CGSize(width: 100, height: 100)
        profilePictureImageView.translatesAutoresizingMaskIntoConstraints = false
        changeProfilePictureButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profilePictureImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profilePictureImageView.widthAnchor.constraint(equalToConstant: imageViewSize.width),
            profilePictureImageView.heightAnchor.constraint(equalToConstant: imageViewSize.height),
            
            changeProfilePictureButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            changeProfilePictureButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(withProfile profileModel: Profile, delegate: EditProfileTableViewController) {
        defaultProfilePicture = profileModel.getDefaultProfilePicture(fontSize: 50, size: CGSize(width: 100, height: 100), move: CGPoint(x: 20, y: 20))
        
        profilePictureImageView.image = profileModel.profilePicture ?? defaultProfilePicture
        
        self.profile = profileModel
        self.delegate = delegate
        
        self.backgroundColor = .systemBackground
        self.selectionStyle = .none
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

extension EditProfilePictureTableViewCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            showCropViewController(with: image)
        }
        
    }
    
    func showCropViewController(with image: UIImage) {
        let cropViewController = TOCropViewController(croppingStyle: .circular, image: image)
        cropViewController.delegate = self
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.resetAspectRatioEnabled = false
        self.delegate?.present(cropViewController, animated: true, completion: nil)
    }
}

extension EditProfilePictureTableViewCell: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didCropToCircularImage image: UIImage, with cropRect: CGRect, angle: Int) {
        self.profilePictureImageView.image = image
        self.delegate?.handleProfilePictureChange(newProfilePicture: image)
        cropViewController.dismiss(animated: true)
    }
}
