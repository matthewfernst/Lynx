//
//  SlopesHookupViewController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/23/23.
//

import AWSClientRuntime
import AWSS3
import ClientRuntime
import UIKit
import OSLog
import UniformTypeIdentifiers

class SlopesConnectionViewController: UIViewController, UIDocumentPickerDelegate
{
    @IBOutlet var explanationTitleLabel: UILabel!
    @IBOutlet var explanationTextView: UITextView!
    @IBOutlet var slopesFolderImageView: UIImageView!
    @IBOutlet var connectSlopesButton: UIButton!
    @IBOutlet var slopeFilesUploadProgressView: UIProgressView!
    
    private var documentPicker: UIDocumentPickerViewController!
    private var bookmark: (uuid: String, url: URL)?
    
    lazy private var manualUploadSlopeFilesButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Upload Slope Files"
        configuration.cornerStyle = .medium
        configuration.buttonSize = .large
        
        let button = UIButton(configuration: configuration)
        button.addSubview(manualUploadActivityIndicator)
        
        manualUploadActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.manualUploadActivityIndicator.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            self.manualUploadActivityIndicator.centerYAnchor.constraint(equalTo: button.centerYAnchor),
        ])
        
        return button
    }()
    private let manualUploadActivityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = .white
        return activityIndicator
    }()
    
    private let thumbsUpImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "hand.thumbsup.fill")
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    private var timer: Timer!
    
    var profile: Profile!
    
    private func getAppSandboxDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBarController = self.tabBarController as! TabViewController
        self.profile = tabBarController.profile
        
        anchorSlopeFilesUploadProgressView()
        setupThumbsUpImageViewAndManualSlopeFilesButton()
        
        if !NetworkManager().isInternetAvailable() {
            showNoInternetConnectionView()
        } else {
            self.connectSlopesButton.isHidden = false
            
            loadAllBookmarks()
            
            if bookmark == nil {
                showConnectToSlopesView()
            }
            else {
                Task {
                    await self.checkForNewFilesAndUpload()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let _ = bookmark else { return }
        showAllSet()
    }
    
    // MARK: - Progress View Functions
    private func anchorSlopeFilesUploadProgressView() {
        self.slopeFilesUploadProgressView.isHidden = true
        
        self.slopeFilesUploadProgressView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.slopeFilesUploadProgressView.centerXAnchor.constraint(equalTo: self.slopesFolderImageView.centerXAnchor),
            self.slopeFilesUploadProgressView.centerYAnchor.constraint(equalTo: self.slopesFolderImageView.centerYAnchor),
            self.slopeFilesUploadProgressView.widthAnchor.constraint(equalToConstant: 250)
        ])
    }
    
    private func showNoInternetConnectionView() {
        self.explanationTitleLabel.text = "You Are Not Connected to the Internet"
        self.explanationTextView.text = "This app cannot be used currently because your device is currently offline."
        
        self.connectSlopesButton.isHidden = true
        self.slopesFolderImageView.isHidden = true
        
        let arrayOfTabBarItems = self.tabBarController?.tabBar.items

        if let barItems = arrayOfTabBarItems, barItems.count > 0 {
            barItems[0].isEnabled = false
            barItems[1].isEnabled = false
            barItems[2].isEnabled = false
        }
    }
    
    private func setupSlopeFilesUploadingView() {
        self.thumbsUpImageView.isHidden = true
        
        self.slopeFilesUploadProgressView.progress = 0
        self.slopeFilesUploadProgressView.isHidden = false
        
        self.explanationTitleLabel.text = "Uploading New Slope Files..."
        self.explanationTextView.text = nil
        self.slopesFolderImageView.image = nil
    }
    
    private func cleanUpSlopeFilesUploadView() {
        self.slopeFilesUploadProgressView.isHidden = true
        self.manualUploadSlopeFilesButton.titleLabel?.isHidden = false
        self.manualUploadActivityIndicator.stopAnimating()
        showAllSet()
    }
    
    private func updateSlopeFilesProgressView(fileBeingUploaded: String, progress: Float) {
        DispatchQueue.main.async {
            self.explanationTextView.text = "Uploading: \(fileBeingUploaded)"
            self.slopeFilesUploadProgressView.progress = progress
        }
    }
    
    private func setupThumbsUpImageViewAndManualSlopeFilesButton() {
        let manualUploadSlopeFilesButton = manualUploadSlopeFilesButton
        let thumbsUpImageView = thumbsUpImageView
        
        self.view.addSubview(manualUploadSlopeFilesButton)
        self.view.addSubview(thumbsUpImageView)
        
        self.manualUploadSlopeFilesButton.isHidden = true
        self.manualUploadSlopeFilesButton.addTarget(self, action: #selector(checkForNewFilesAndUploadWrapper), for: .touchUpInside)
        
        
        self.thumbsUpImageView.isHidden = true
        
        self.manualUploadSlopeFilesButton.translatesAutoresizingMaskIntoConstraints = false
        self.thumbsUpImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.manualUploadSlopeFilesButton.centerXAnchor.constraint(equalTo: self.connectSlopesButton.centerXAnchor),
            self.manualUploadSlopeFilesButton.centerYAnchor.constraint(equalTo: self.connectSlopesButton.centerYAnchor),
            self.manualUploadSlopeFilesButton.widthAnchor.constraint(equalToConstant: 200),
            self.manualUploadSlopeFilesButton.heightAnchor.constraint(equalToConstant: 35),
           
            self.thumbsUpImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.thumbsUpImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.thumbsUpImageView.widthAnchor.constraint(equalToConstant: 150),
            self.thumbsUpImageView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func showConnectToSlopesView() {
        self.manualUploadSlopeFilesButton.isHidden = true
        self.thumbsUpImageView.isHidden = true
        
        self.slopesFolderImageView.isHidden = false
        
        documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder], asCopy: false)
        documentPicker.delegate = self
        documentPicker.shouldShowFileExtensions = true
        documentPicker.allowsMultipleSelection = true
        
        connectSlopesButton.addTarget(self, action: #selector(selectSlopesFiles), for: .touchUpInside)
    }
    
    private func showAllSet() {
        DispatchQueue.main.async { [unowned self] in
            self.explanationTitleLabel.text = "You're All Set!"
            self.explanationTitleLabel.font = UIFont.boldSystemFont(ofSize: 28)
            self.explanationTextView.text = "Your Slopes data folder is connected. Your files will be automatically uploaded when you enter the app. If you would like to manually upload new files, tap the Upload Slope Files button below."
            self.explanationTextView.font = UIFont.systemFont(ofSize: 16)
            self.connectSlopesButton.isHidden = true
            self.slopesFolderImageView.isHidden = true
            
            self.manualUploadSlopeFilesButton.isHidden = false
            self.thumbsUpImageView.isHidden = false
            
            self.thumbsUpImageView.image = UIImage(systemName: "hand.thumbsup.fill")
            self.thumbsUpImageView.alpha = 0
            self.thumbsUpImageView.transform = .identity
            
            UIImageView.animate(withDuration: 1, delay: 0, animations: {
                self.thumbsUpImageView.alpha = 1
                self.thumbsUpImageView.transform = CGAffineTransform(rotationAngle: -.pi / 4)
            }, completion: {_ in
                UIImageView.animate(withDuration: 2, delay: 0,  usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, animations: {
                    self.thumbsUpImageView.transform = .identity
                })
            })
        }
    }
    
    @objc private func selectSlopesFiles(_ sender: UIBarButtonItem) {
        present(documentPicker, animated: true)
    }
    
    // MARK: - Error Alert Functions
    private func showErrorUploadingToS3Alert() {
        let ac = UIAlertController(title: "Error Uploading Slope Documents",
                                   message: """
                                    There was an error uploading your slope documents.
                                    Please try again.
                                    """,
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(ac, animated: true)
    }
    
    private func showFileAccessNotAllowed() {
        let ac = UIAlertController(title: "File Permission Error",
                                   message: """
                                    This app does not have permission to your files on your iPhone.
                                    Please allow this app to access your files by going to Settings.
                                    """,
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Go to Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    Logger.slopesConnection.debug("Settings opened.")
                })
            }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    private func showFileExtensionNotSupported(file: URL) {
        let ac = UIAlertController(title: "File Extension Not Supported",
                                   message: "Only 'slope' file extensions are supported, but recieved \(file.pathExtension) extension. Please try again.",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        
        present(ac, animated: true)
    }
    
    // MARK: - Document Picker
    private func isSlopesFiles(_ fileURL: URL) -> Bool {
        return !fileURL.hasDirectoryPath && fileURL.pathExtension == "slopes"
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        Task {
            let url = urls[0]
            
            guard url.startAccessingSecurityScopedResource() else {
                // Handle the failure here.
                showFileAccessNotAllowed()
                return
            }
            
            defer { url.stopAccessingSecurityScopedResource() }
            
            let keys: [URLResourceKey] = [.nameKey, .isDirectoryKey]
            
            guard var totalNumberOfFiles = FileManager.default.enumerator(at: url, includingPropertiesForKeys: keys)?.allObjects.count else {
                Logger.slopesConnection.debug("*** Unable to access the contents of \(url.path) ***\n")
                showFileAccessNotAllowed()
                return
            }
            
            guard let fileList = FileManager.default.enumerator(at: url, includingPropertiesForKeys: keys) else {
                Logger.slopesConnection.debug("*** Unable to access the contents of \(url.path) ***\n")
                showFileAccessNotAllowed()
                return
            }
            
            setupSlopeFilesUploadingView()
            var currentFileNumberBeingUploaded = 0
            
            for case let fileURL as URL in fileList {
                if self.isSlopesFiles(fileURL) {
                    Logger.slopesConnection.debug("chosen file: \(fileURL.lastPathComponent)")
                    
                    do {
                        try await S3Utils.uploadSlopesDataToS3(uuid: self.profile.uuid, file: fileURL)
                        currentFileNumberBeingUploaded += 1
                        self.updateSlopeFilesProgressView(fileBeingUploaded: fileURL.lastPathComponent.replacingOccurrences(of: "%", with: " "),
                                                          progress: Float(currentFileNumberBeingUploaded) / Float(totalNumberOfFiles))
                    } catch {
                        Logger.slopesConnection.debug("\(error)")
                        showErrorUploadingToS3Alert()
                    }
                    
                    url.stopAccessingSecurityScopedResource()
                } else if fileURL.lastPathComponent == ".DS_Store"{
                    totalNumberOfFiles -= 1
                } else {
                    showFileExtensionNotSupported(file: fileURL)
                    Logger.slopesConnection.debug("Only slope file extensions are supported, but recieved \(fileURL.pathExtension) extension.")
                }
            }
            
            saveBookmark(for: url)
            
            cleanUpSlopeFilesUploadView()
        }
    }
    
    // MARK: - Bookmarks
    private func saveBookmark(for url: URL) {
        do {
            // Start accessing a security-scoped resource.
            guard url.startAccessingSecurityScopedResource() else {
                // Handle the failure here.
                return
            }
            
            if bookmark?.url == url { return }
            
            // Make sure you release the security-scoped resource when you finish.
            defer { url.stopAccessingSecurityScopedResource() }
            
            // Generate a UUID
            let uuid = UUID().uuidString
            
            // Convert URL to bookmark
            let bookmarkData = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
            // Save the bookmark into a file (the name of the file is the UUID)
            try bookmarkData.write(to: getAppSandboxDirectory().appendingPathComponent(uuid))
            
            // Add the URL and UUID to the urls
            bookmark = (uuid, url)
        }
        catch {
            // Handle the error here.
            Logger.slopesConnection.debug("Error creating the bookmark: \(error)")
        }
    }
    
    private func getNonUploadedSlopeFiles() async -> Set<String>? {
        guard let bookmark = bookmark else { return nil }
        var nonUploadedSlopeFiles = Set<String>()
        do {
            let resourceValues = try bookmark.url.resourceValues(forKeys: [.isDirectoryKey])
            if resourceValues.isDirectory ?? false {
                let keys: [URLResourceKey] = [.nameKey, .isDirectoryKey, .creationDateKey]
                if let fileList = FileManager.default.enumerator(at: bookmark.url, includingPropertiesForKeys: keys) {
                    for case let fileURL as URL in fileList {
                        if self.isSlopesFiles(fileURL) {
                            // Check if the file was already uploaded
                            if !(await S3Utils.isFileUploadedToS3(uuid: self.profile.uuid, file: fileURL)) {
                                nonUploadedSlopeFiles.insert(fileURL.lastPathComponent)
                            }
                        }
                    }
                }
            }
        } catch {
            // Handle the error
            self.showErrorUploadingToS3Alert()
            Logger.slopesConnection.error("Error accessing bookmarked URL: \(error)")
        }
        
        return nonUploadedSlopeFiles
    }
    
    @objc private func checkForNewFilesAndUploadWrapper() {
        Task {
            await self.checkForNewFilesAndUpload()
        }
    }
    
    private func checkForNewFilesAndUpload() async {
        self.manualUploadSlopeFilesButton.titleLabel?.isHidden = true
        self.manualUploadActivityIndicator.startAnimating()
        
        guard let nonUploadedSlopeFiles = await getNonUploadedSlopeFiles() else {
            self.cleanUpSlopeFilesUploadView()
            return
        }
        if nonUploadedSlopeFiles.isEmpty {
            self.cleanUpSlopeFilesUploadView()
            return
        }
        
        guard let bookmark = bookmark else {
            self.cleanUpSlopeFilesUploadView()
            return
        }
        
        DispatchQueue.main.async {
            self.setupSlopeFilesUploadingView()
        }
        
        var currentFileNumberBeingUploaded = 0
        do {
            let resourceValues = try bookmark.url.resourceValues(forKeys: [.isDirectoryKey])
            if resourceValues.isDirectory ?? false {
                let keys: [URLResourceKey] = [.nameKey, .isDirectoryKey, .creationDateKey]
                if let fileList = FileManager.default.enumerator(at: bookmark.url, includingPropertiesForKeys: keys) {
                    for case let fileURL as URL in fileList {
                        if self.isSlopesFiles(fileURL) {
                            do {
                                if nonUploadedSlopeFiles.contains(fileURL.lastPathComponent) {
                                    try await S3Utils.uploadSlopesDataToS3(uuid: self.profile.uuid, file: fileURL)
                                    currentFileNumberBeingUploaded += 1
                                    let progress = Float(currentFileNumberBeingUploaded) / Float(nonUploadedSlopeFiles.count)
                                    self.updateSlopeFilesProgressView(fileBeingUploaded: fileURL.lastPathComponent.replacingOccurrences(of: "%", with: " "), progress: progress)
                                }
                            } catch {
                                self.showErrorUploadingToS3Alert()
                                Logger.slopesConnection.debug("\(error)")
                                self.cleanUpSlopeFilesUploadView()
                            }
                        }
                    }
                }
                
            }
        } catch {
            self.showErrorUploadingToS3Alert()
            Logger.slopesConnection.debug("Error accessing bookmarked URL: \(error)")
            self.cleanUpSlopeFilesUploadView()
        }
        
        self.cleanUpSlopeFilesUploadView()
    }
    
    
    private func loadAllBookmarks() {
        // Get all the bookmark files
        let files = try? FileManager.default.contentsOfDirectory(at: getAppSandboxDirectory(), includingPropertiesForKeys: nil)
        // Map over the bookmark files
        let bookmarks = files?.compactMap { file in
            do {
                let bookmarkData = try Data(contentsOf: file)
                var isStale = false
                // Get the URL from each bookmark
                let url = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
                
                guard !isStale else {
                    // Handle stale data here.
                    return nil
                }
                
                // Return URL
                return (file.lastPathComponent, url)
            }
            catch let error {
                // Handle the error here.
                print(error)
                return nil
            }
        } ?? []
        
        self.bookmark = bookmarks.first as? (uuid: String, url: URL)
        
    }
    
}
