//
//  PopoverButtonTableViewCell.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/25/23.
//

import UIKit

class PopoverButtonTableViewCell: UITableViewCell
{
    
    var buttonTapCallback: () -> ()  = { }
        
        let button: UIButton = {
            let btn = UIButton()
            btn.setTitle("Button", for: .normal)
            btn.backgroundColor = .systemPink
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            return btn
        }()
        
        @objc func didTapButton() {
            buttonTapCallback()
        }
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            //Add button
            contentView.addSubview(button)
            button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
            
            //Set constraints as per your requirements
            button.translatesAutoresizingMaskIntoConstraints = false
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
            button.widthAnchor.constraint(equalToConstant: 100).isActive = true
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
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
