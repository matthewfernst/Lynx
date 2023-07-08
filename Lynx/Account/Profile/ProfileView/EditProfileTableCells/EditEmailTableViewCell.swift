//
//  NameAndEmailTableViewCell.swift
//  Lynx
//
//  Created by Matthew Ernst on 3/12/23.
//

import UIKit

class EditEmailTableViewCell: UITableViewCell
{
    
    static let identifier = "EmailTableViewCell"
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    public let emailTextField: UITextField = {
        let textField = UITextField()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .done
        textField.tag = EditProfileTextFieldTags.email.rawValue
        return textField
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(emailLabel)
        contentView.addSubview(emailTextField)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(email: String, delegate: EditProfileTableViewController) {
        emailTextField.text = email
        emailTextField.delegate = delegate
        
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emailLabel.widthAnchor.constraint(equalToConstant: 45),
            emailLabel.heightAnchor.constraint(equalToConstant: self.contentView.frame.height),
            emailLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            emailLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            
            emailTextField.heightAnchor.constraint(equalToConstant: self.contentView.frame.height),
            emailTextField.leadingAnchor.constraint(equalTo: emailLabel.trailingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            emailTextField.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
        
        
        self.backgroundColor = .secondarySystemBackground
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
