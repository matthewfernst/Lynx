//
//  NameAndEmailTableViewCell.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 3/12/23.
//

import UIKit

class EditEmailTableViewCell: UITableViewCell {
    
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
        
        self.backgroundColor = .secondarySystemBackground
        self.selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let contentHeight = contentView.frame.size.height
        let contentWidth = contentView.frame.size.width
        
        emailLabel.frame = CGRect(x: 20, y: 0, width: contentHeight, height: contentHeight)
        
        emailTextField.frame = CGRect(x: emailLabel.frame.midX + 40,
                                      y: 0,
                                      width: contentWidth,
                                      height: contentHeight)
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
