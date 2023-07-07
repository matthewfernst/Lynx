//
//  NameProfileTableViewCell.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 3/12/23.
//

import UIKit

enum NameTextFieldTags: Int, CaseIterable
{
    case firstName = 0
    case lastName = 1
}

class EditNameTableViewCell: UITableViewCell
{
    
    static let identifier = "NameTableViewCell"
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var firstNameTextField: UITextField = {
        return getTextField(tag: EditProfileTextFieldTags.firstName.rawValue)
    }()
    
    private lazy var lastNameTextField: UITextField = {
        return getTextField(tag: EditProfileTextFieldTags.lastName.rawValue)
    }()
    
    private func getTextField(tag: Int) -> UITextField {
        let textField = UITextField()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.returnKeyType = .done
        textField.tag = tag
        return textField
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(firstNameTextField)
        self.contentView.addSubview(lastNameTextField)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        firstNameTextField.translatesAutoresizingMaskIntoConstraints = false
        lastNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.widthAnchor.constraint(equalToConstant: 50),
            nameLabel.heightAnchor.constraint(equalToConstant: self.contentView.frame.height),
            nameLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            nameLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            
            firstNameTextField.heightAnchor.constraint(equalToConstant: self.contentView.frame.height),
            firstNameTextField.widthAnchor.constraint(equalToConstant: 100),
            firstNameTextField.heightAnchor.constraint(equalToConstant: self.contentView.frame.height),
            firstNameTextField.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 20),
            
            lastNameTextField.heightAnchor.constraint(equalToConstant: self.contentView.frame.height),
            lastNameTextField.heightAnchor.constraint(equalToConstant: self.contentView.frame.height),
            lastNameTextField.leadingAnchor.constraint(equalTo: firstNameTextField.trailingAnchor, constant: 20),
            lastNameTextField.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(name: String, delegate: EditProfileTableViewController) {
        let fullName = name.components(separatedBy: " ")
        firstNameTextField.text = fullName[0]
        firstNameTextField.delegate = delegate
        
        lastNameTextField.text = fullName[1]
        lastNameTextField.delegate = delegate
        
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
