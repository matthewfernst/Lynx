//
//  SignInWithGoogleButton.swift
//  Lynx
//
//  Created by Matthew Ernst on 3/11/23.
//
import Foundation
import UIKit

func getSignInWithGoogleButton(baseBackgroundColor: UIColor = .black) -> UIButton
{
    var config = UIButton.Configuration.filled()
    
    config.cornerStyle = .medium
    config.baseBackgroundColor = baseBackgroundColor
    
    let googleLogo = UIImage(named: "GoogleLogo.png")?.scalePreservingAspectRatio(targetSize: CGSize(width: 12, height: 12))
    config.image = googleLogo
    config.imagePadding = 4
    config.imagePlacement = .leading
    
    config.attributedTitle = AttributedString("Sign in with Google", attributes: AttributeContainer([
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .medium),
        NSAttributedString.Key.foregroundColor: baseBackgroundColor == UIColor.white ? UIColor.black : .white
    ]))
    
    config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 11, bottom: 0, trailing: 0)
    
    return UIButton(configuration: config)
}
