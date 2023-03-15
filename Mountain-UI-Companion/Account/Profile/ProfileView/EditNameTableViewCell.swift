//
//  NameProfileTableViewCell.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 3/12/23.
//

import UIKit

enum NameTextFieldTags: Int, CaseIterable {
    case firstName = 0
    case lastName = 1
}

class EditNameTableViewCell: UITableViewCell {
    
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
        contentView.addSubview(nameLabel)
        contentView.addSubview(firstNameTextField)
        contentView.addSubview(lastNameTextField)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size =  contentView.frame.size.height
        
        nameLabel.frame = CGRect(x: 20, y: 0, width: size + 3, height: size)
        
        firstNameTextField.frame = CGRect(x: nameLabel.frame.midX + 40, y: 0, width: size * 2, height: size)
        
        lastNameTextField.frame = CGRect(x: firstNameTextField.frame.midX + 60, y: 0, width: size * 2, height: size)
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
