//
//  ConnectionViewController.swift
//  Lynx
//
//  Created by Matthew Ernst on 7/2/23.
//

import UIKit
import ImageIO
import UniformTypeIdentifiers

class FolderConnectionViewController: UIViewController {
    
    private let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder], asCopy: false)
    
    public static let bookmarkManager = BookmarkManager()
    public static var connectedFolderNickname = "Slopes"
    
    public static var isConnected: Bool {
        bookmarkManager.loadAllBookmarks()
        return bookmarkManager.bookmark != nil
    }
    
    public let explanationTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = "To upload, please follow the instructions illustrated below. When you are ready, click the 'Continue' button and select the correct directory"
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textColor = .label
        textView.textAlignment = .center
        textView.isScrollEnabled = false
        return textView
    }()
    
    public let stepsToUploadImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "StepsToUpload")
        return imageView
    }()
    
    public let continueButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Continue", for: .normal)
        return button
    }()
    
    public let uploadProgressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()
    
    public let manualUploadActivityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .white
        return activityIndicator
    }()
    
    public let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "hand.thumbsup.fill")
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        // Do any additional setup after loading the view.
        
        self.title = "Uploading Slope Files"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        setupInitialView()
        setupDocumentPicker()
    }
    
    private func setupInitialView() {
        self.view.addSubview(explanationTextView)
        self.view.addSubview(stepsToUploadImageView)
        self.view.addSubview(continueButton)
        self.view.addSubview(uploadProgressView)
        self.view.addSubview(checkmarkImageView)
        
        uploadProgressView.isHidden = true
        checkmarkImageView.isHidden = true
        
        NSLayoutConstraint.activate([
            explanationTextView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            explanationTextView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
            explanationTextView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
            explanationTextView.bottomAnchor.constraint(equalTo: stepsToUploadImageView.topAnchor, constant: -20),
            
            stepsToUploadImageView.topAnchor.constraint(equalTo: explanationTextView.bottomAnchor),
            stepsToUploadImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            stepsToUploadImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            stepsToUploadImageView.heightAnchor.constraint(equalToConstant: 500),
            
            continueButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            continueButton.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: -50),
            
            uploadProgressView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            uploadProgressView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            uploadProgressView.widthAnchor.constraint(equalToConstant: 250),
            
            self.checkmarkImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.checkmarkImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.checkmarkImageView.widthAnchor.constraint(equalToConstant: 150),
            self.checkmarkImageView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }

    private func setupDocumentPicker() {
        documentPicker.delegate = self
        documentPicker.shouldShowFileExtensions = true
        documentPicker.allowsMultipleSelection = true
        
        continueButton.addTarget(self, action: #selector(selectSlopeFiles), for: .touchUpInside)
    }
    
    @objc public func selectSlopeFiles() {
        self.present(documentPicker, animated: true)
    }
}
