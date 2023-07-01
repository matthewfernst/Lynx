//
//  Pin.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 6/30/23.
//

import UIKit

class InvitationKeyDashesUIView: UIView {

    let dashes = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupUI() {
        dashes.layer.cornerRadius = 2.0
        dashes.layer.masksToBounds = true
        dashes.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dashes)
        NSLayoutConstraint.activate([
            dashes.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            dashes.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            dashes.widthAnchor.constraint(equalToConstant: 22.0),
            dashes.heightAnchor.constraint(equalToConstant: 5.0),
            ])
    }
}
