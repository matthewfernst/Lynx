//
//  NameAndEmailTableViewCell.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 3/12/23.
//

import UIKit

class EmailTableViewCell: UITableViewCell {
    
    static let identifier = "EmailTableViewCell"
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    private let emailTextField: UITextField = {
        return UITextField()
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(emailLabel)
        contentView.addSubview(emailTextField)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(email: String) {
        emailTextField.text = email
        
        self.backgroundColor = .secondarySystemBackground
        self.selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = contentView.frame.size.height
        
        emailLabel.frame = CGRect(x: 20, y: 0, width: size, height: size)
        
        emailTextField.frame = CGRect(x: emailLabel.frame.midX + 40, y: 0, width: size * 5, height: size)
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
