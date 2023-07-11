//
//  LogBookViewController.swift
//  Lynx
//
//  Created by Matthew Ernst on 1/23/23.
//


import UIKit

enum SessionSection: Int, CaseIterable {
    case lifetimeSummary = 0
    case sessionSummary = 1
}

class LogbookViewController: UIViewController {
    
    @IBOutlet var profilePictureImageView: UIImageView!
    @IBOutlet var lifetimeVerticalNumbersLabel: UILabel!
    @IBOutlet var lifetimeVerticalMeasurementSystemLabel: UILabel!
    @IBOutlet var lifetimeDaysOnMountainLabel: UILabel!
    @IBOutlet var lifetimeRunsTimeLabel: UILabel!
    @IBOutlet var lifetimeRunsLabel: UILabel!
    @IBOutlet var lifetimeSummaryTableView: UITableView!
    
    var profile: Profile!
    var logbookStats: LogbookStats = LogbookStats()
    
    private var refreshControl: UIRefreshControl!
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profile = TabViewController.profile
        
        setupNavigationBar()
        setupRefreshControl()
        setupTableView()
        setupProfilePicture()
        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        reloadProfile()
        autoUploadFiles()
        callGetLogsAndRefresh()
    }
    
    private func autoUploadFiles() {
        let uploadLabel = AutoUploadFileLabel()
        
        if FolderConnectionViewController.isConnected {
            FolderConnectionViewController.getNonUploadedSlopeFiles { [weak self] result in
                if let newUploadFiles = result {
                    self?.view.addSubview(uploadLabel)
                    uploadLabel.slideDown {
                        FolderConnectionViewController.uploadNewFilesWithLabel(label: uploadLabel, files: newUploadFiles) {
                            uploadLabel.slideUp()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                self?.refreshUI()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func updateButtonAvailability() {
        if FolderConnectionViewController.isConnected {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "link.icloud"), style: .plain, target: self, action: #selector(showConnectedFolder))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"), style: .plain, target: self, action: #selector(connectSlopesFolder))
        }
        
        if !NetworkManager().isInternetAvailable() {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "icloud.slash"), style: .plain, target: self, action: #selector(showNoInternetConnection))
            self.navigationItem.rightBarButtonItem?.tintColor = .systemGray4
        }
    }
    
    public func setupNavigationBar() {
        self.title = "Logbook"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(showMoreInfo))
        
        if FolderConnectionViewController.isConnected {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "link.icloud"), style: .plain, target: self, action: #selector(showConnectedFolder))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"), style: .plain, target: self, action: #selector(connectSlopesFolder))
        }
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        lifetimeSummaryTableView.refreshControl = refreshControl
    }
    
    private func setupTableView() {
        lifetimeSummaryTableView.delegate = self
        lifetimeSummaryTableView.dataSource = self
        lifetimeSummaryTableView.register(SessionTableViewCell.self, forCellReuseIdentifier: SessionTableViewCell.identifier)
        lifetimeSummaryTableView.rowHeight = 66.0
    }
    
    private func setupProfilePicture() {
        if let profilePicture = profile.profilePicture {
            profilePictureImageView.image = profilePicture
        } else {
            let defaultProfilePicture = ProfilePictureUtils.getDefaultProfilePicture(name: profile.name, fontSize: 60)
            profilePictureImageView.addSubview(defaultProfilePicture)
            defaultProfilePicture.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                defaultProfilePicture.centerXAnchor.constraint(equalTo: profilePictureImageView.centerXAnchor),
                defaultProfilePicture.centerYAnchor.constraint(equalTo: profilePictureImageView.centerYAnchor)
            ])
        }
        profilePictureImageView.backgroundColor = .secondarySystemBackground
        profilePictureImageView.makeRounded()
    }
    
    func reloadProfile() {
        // Update the profile picture
        profilePictureImageView.subviews.forEach { $0.removeFromSuperview() }
        
        if let profilePicture = profile.profilePicture {
            profilePictureImageView.image = profilePicture
        } else {
            let defaultProfilePicture = ProfilePictureUtils.getDefaultProfilePicture(name: profile.name, fontSize: 60)
            profilePictureImageView.addSubview(defaultProfilePicture)
            defaultProfilePicture.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                defaultProfilePicture.centerXAnchor.constraint(equalTo: profilePictureImageView.centerXAnchor),
                defaultProfilePicture.centerYAnchor.constraint(equalTo: profilePictureImageView.centerYAnchor)
            ])
        }
        
        // Update other UI elements or perform any necessary setup
        
        // Refresh the table view
        lifetimeSummaryTableView.reloadData()
    }
    
    private func setupMainStats() {
        switch profile.measurementSystem {
        case .imperial:
            lifetimeVerticalMeasurementSystemLabel.text = "lifetime vertical ft"
        case .metric:
            lifetimeVerticalMeasurementSystemLabel.text = "lifetime vertical m"
        }
        
        lifetimeVerticalNumbersLabel.text = logbookStats.lifetimeVertical
        lifetimeDaysOnMountainLabel.text  = logbookStats.lifetimeDaysOnMountain
        lifetimeRunsTimeLabel.text        = logbookStats.lifetimeRunsTime
        lifetimeRunsLabel.text            = logbookStats.lifetimeRuns
        
    }
    
    public func refreshUI() {
        updateButtonAvailability()
        callGetLogsAndRefresh()
    }
    
    private func callGetLogsAndRefresh() {
        ApolloLynxClient.clearCache()
        ApolloLynxClient.getLogs(measurementSystem: profile.measurementSystem) { [weak self] result in
            switch result {
            case .success(let logbook):
                self?.logbookStats.logbooks = logbook
                DispatchQueue.main.async {
                    self?.setupMainStats()
                    self?.lifetimeSummaryTableView.reloadData()
                    self?.refreshControl.endRefreshing()
                }
            case .failure(_):
                DispatchQueue.main.async {
                    self?.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    @objc private func refresh() {
        refreshControl.beginRefreshing()
        autoUploadFiles()
        refreshUI()
    }
    
    @objc private func showMoreInfo() {
        let message = """
                           Lynx works together with the Slopes App by Breakpoint Studios. Slopes is able to track a skier or snowboarder while they shred it down the mountain. Slopes can track things such as average speed, total vertical feet, and more. Lynx uses the data stored by Slopes and links to your Mountain-UI display.
                       """
        let ac = UIAlertController(title: "Slopes Integration", message: message, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "What is Slopes?", style: .default) { _ in
            if let url = URL(string: Constants.slopesHomepage) {
                UIApplication.shared.open(url)
            }
        })
        ac.addAction(UIAlertAction(title: "What is Mountain-UI?", style: .default) { _ in
            if let url = URL(string: Constants.mountainUIDisplayGithub) {
                UIApplication.shared.open(url)
            }
        })
        ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        
        present(ac, animated: true)
    }
    
    @objc private func connectSlopesFolder() {
        let connectVC = FolderConnectionViewController()
        let navigationController = UINavigationController(rootViewController: connectVC)
        navigationController.navigationBar.prefersLargeTitles = false
        
        navigationController.modalPresentationStyle = .pageSheet
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @objc private func showConnectedFolder() {
        let ac = UIAlertController(title: "Successfully Connected to Slopes", message: "You have already successfully connected your folder. When you open the app, it will automatically upload new files. Do you wish to connect to a different folder?", preferredStyle: .actionSheet)
        
        ac.addAction(UIAlertAction(title: "Connect to New Folder", style: .default) { [weak self] _ in
            self?.connectSlopesFolder()
        })
        
        ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        self.present(ac, animated: true)
    }
    
    @objc private func showNoInternetConnection() {
        let ac = UIAlertController(title: "No Internet Connection", message: "You are currently not connected to the internet.", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        self.present(ac, animated: true)
    }
    
}

extension LogbookViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return SessionSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sessionSection = SessionSection(rawValue: section) else {
            return 0
        }
        switch sessionSection {
        case .lifetimeSummary:
            return 1
        case .sessionSummary:
            return logbookStats.logbooks.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sessionSection = SessionSection(rawValue: indexPath.section) else {
            return
        }
        switch sessionSection {
        case .lifetimeSummary:
            if let lifetimeSummaryViewController = storyboard?.instantiateViewController(withIdentifier: LifetimeSummaryViewController.identifier) as? LifetimeSummaryViewController {
                lifetimeSummaryViewController.averageStats = logbookStats.lifetimeAverages
                lifetimeSummaryViewController.bestStats = logbookStats.lifetimeBest
                navigationController?.pushViewController(lifetimeSummaryViewController, animated: true)
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sessionSection = SessionSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        let feetOrMeters: String
        let milesPerHourOrKilometersPerHour: String
        switch profile.measurementSystem {
        case .imperial:
            feetOrMeters = "FT"
            milesPerHourOrKilometersPerHour = "MPH"
        case .metric:
            feetOrMeters = "M"
            milesPerHourOrKilometersPerHour = "KPH"
        }
        
        switch sessionSection {
        case .lifetimeSummary:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SeasonSummaryCell", for: indexPath)
            var configuration = cell.defaultContentConfiguration()
            configuration.text = "Season Summary"
            
            cell.detailTextLabel?.text = "\(lifetimeRunsLabel.text ?? "-") runs | \(lifetimeDaysOnMountainLabel.text ?? "-") days | \(lifetimeVerticalNumbersLabel.text ?? "-") \(feetOrMeters)"
            cell.backgroundColor = .secondarySystemBackground
            return cell
            
        case .sessionSummary:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SessionTableViewCell.identifier, for: indexPath) as? SessionTableViewCell else {
                return UITableViewCell()
            }
            if let configuredLogbookData = logbookStats.getConfiguredLogbookData(at: indexPath.row) {
                cell.configure(with: configuredLogbookData, measurementSystem: milesPerHourOrKilometersPerHour)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let sessionSection = SessionSection(rawValue: section) else {
            return 0
        }
        switch sessionSection {
        case .lifetimeSummary:
            return 50
        default:
            return 18
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sessionSection = SessionSection(rawValue: section) else {
            return nil
        }
        switch sessionSection {
        case .lifetimeSummary:
            let header = UILabel()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            let currentYear = dateFormatter.string(from: .now)
            let pastYear = String((Int(currentYear) ?? 0) - 1)
            header.text = "\(pastYear)/\(currentYear)"
            header.font = UIFont.systemFont(ofSize: 22, weight: .bold)
            return header
        default:
            return nil
        }
    }
}
