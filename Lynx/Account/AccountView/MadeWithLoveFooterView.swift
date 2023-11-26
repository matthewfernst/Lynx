//
//  MadeWithLoveFooterView.swift
//  Lynx
//
//  Created by Matthew Ernst on 1/24/23.
//

import UIKit

class MadeWithLoveFooterView: UITableViewHeaderFooterView {
    static var identifier = "MadeWithLoverFooterView"
    
    let madeWithLoveLabel = UILabel()
    let appVersionLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
        
        appVersionLabel.font = UIFont.systemFont(ofSize: 11)
        appVersionLabel.textColor = .secondaryLabel
        
        
        madeWithLoveLabel.font = UIFont.systemFont(ofSize: 11)
        madeWithLoveLabel.textColor = .secondaryLabel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureContents() {
        appVersionLabel.translatesAutoresizingMaskIntoConstraints = false
        madeWithLoveLabel.translatesAutoresizingMaskIntoConstraints = false
    
        contentView.addSubview(appVersionLabel)
        contentView.addSubview(madeWithLoveLabel)
    
        NSLayoutConstraint.activate([
            appVersionLabel.heightAnchor.constraint(equalToConstant: 30),
            appVersionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 20),
            appVersionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            
            madeWithLoveLabel.heightAnchor.constraint(equalToConstant: 30),
            madeWithLoveLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            madeWithLoveLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
}
