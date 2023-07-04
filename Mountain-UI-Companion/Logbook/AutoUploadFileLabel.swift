//
//  WideOvalView.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 7/3/23.
//

import UIKit

class AutoUploadFileLabel: UIView {
    private let roundRectLayer = CAShapeLayer()
    public let label = UILabel()
    private let activityIndicator = UIActivityIndicatorView()
    private let checkmarkImageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Configure the round rectangle layer
        roundRectLayer.fillColor = UIColor.systemBackground.resolvedColor(with: self.traitCollection).cgColor
        roundRectLayer.shadowColor = UIColor.systemGray.resolvedColor(with: self.traitCollection).cgColor
        roundRectLayer.shadowOpacity = 0.5
        roundRectLayer.shadowOffset = CGSize(width: 0, height: 2)
        roundRectLayer.shadowRadius = 4
        layer.addSublayer(roundRectLayer)

        // Configure the label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.label // Set the desired text color
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        addSubview(label)
        
        // Configure the activity indicator
        activityIndicator.style = .medium
        activityIndicator.color = .gray
    
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activityIndicator)
        
        // Position the activity indicator to the right of the label
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            activityIndicator.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -10) // Adjust the spacing as needed
        ])
        
        // Start animating the activity indicator
        activityIndicator.startAnimating()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        roundRectLayer.fillColor = UIColor.systemBackground.resolvedColor(with: self.traitCollection).cgColor
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        
        var yOffset: CGFloat = 0
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let safeAreaInsets = windowScene.windows.first?.safeAreaInsets {
                yOffset += safeAreaInsets.top
            }
        }

        let width: CGFloat = 250
        let height: CGFloat = 44
        let x = (superview?.bounds.width ?? 0) / 2 - (width / 2)
        let y = yOffset
        
        frame = CGRect(x: x, y: y, width: width, height: height)
        
        let cornerRadius = height / 2 // Adjust the corner radius as per your preference
        roundRectLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        label.frame = bounds
    }
    
    func slideDown(completion: @escaping () -> Void) {
        checkmarkImageView.removeFromSuperview()
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            activityIndicator.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -10)
        ])
        
        transform = CGAffineTransform(translationX: 0, y: -bounds.height)
        alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.transform = .identity
            self.alpha = 1
        } completion: { _ in
            completion()
        }
    }

    func slideUp() {
        activityIndicator.removeFromSuperview()
        label.removeFromSuperview()
        
        addSubview(checkmarkImageView)
        checkmarkImageView.tintColor = UIColor.systemGreen
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            checkmarkImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        checkmarkImageView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        checkmarkImageView.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) { [weak self] in
            self?.checkmarkImageView.transform = .identity
            self?.checkmarkImageView.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 0.8, options: .curveEaseInOut) {
                self.transform = CGAffineTransform(translationX: 0, y: -self.bounds.height)
                self.alpha = 0
            }
        }
    }

}
