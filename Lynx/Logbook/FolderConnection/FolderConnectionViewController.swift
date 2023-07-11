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
        view.addSubview(explanationTextView)
        view.addSubview(stepsToUploadImageView)
        view.addSubview(continueButton)
        view.addSubview(uploadProgressView)
        view.addSubview(checkmarkImageView)
        
        uploadProgressView.isHidden = true
        checkmarkImageView.isHidden = true
                
        NSLayoutConstraint.activate([
            explanationTextView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            explanationTextView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            explanationTextView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            explanationTextView.bottomAnchor.constraint(equalTo: stepsToUploadImageView.topAnchor, constant: -20),
            
            stepsToUploadImageView.topAnchor.constraint(equalTo: explanationTextView.bottomAnchor),
            stepsToUploadImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stepsToUploadImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stepsToUploadImageView.heightAnchor.constraint(equalToConstant: 400),
            
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -50),
            
            uploadProgressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            uploadProgressView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            uploadProgressView.widthAnchor.constraint(equalToConstant: 250),
            
            checkmarkImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 150),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 150)
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
