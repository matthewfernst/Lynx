//
//  LogBookViewController.swift
//  Mountain-UI-Companion
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
    @IBOutlet var lifetimeVerticalFeetLabel: UILabel!
    @IBOutlet var lifetimeDaysOnMountainLabel: UILabel!
    @IBOutlet var lifetimeRunsTimeLabel: UILabel!
    @IBOutlet var lifetimeRunsLabel: UILabel!
    @IBOutlet var lifetimeSummaryTableView: UITableView!
    
    var profile: Profile!
    var logbookStats: LogbookStats = LogbookStats()
    
    private var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBarController = self.tabBarController as! TabViewController
        self.profile = tabBarController.profile
        
        setupNavigationBar()
        setupRefreshControl()
        setupTableView()
        setupProfilePicture()
        
        refreshData()
    }
    
    private func setupNavigationBar() {
        self.title = "Logbook"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"), style: .plain, target: self, action: #selector(explainMoreWithSlopes))

    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
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
    
    func setupMainStats() {
        lifetimeVerticalFeetLabel.text   = logbookStats.lifetimeVerticalFeet
        lifetimeDaysOnMountainLabel.text = logbookStats.lifetimeDaysOnMountain
        lifetimeRunsTimeLabel.text       = logbookStats.lifetimeRunsTime
        lifetimeRunsLabel.text           = logbookStats.lifetimeRuns
    }
    
    private func refreshData() {
        refreshControl.beginRefreshing()
        ApolloMountainUIClient.clearCache()
        ApolloMountainUIClient.getLogs { [weak self] result in
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
    
    @objc private func refresh(_ sender: UIRefreshControl) {
        refreshData()
    }
    
    @objc private func explainMoreWithSlopes() {
        let message = """
                      This data comes from the Slopes app and is a way to quickly see your data being used.
                      For more detailed information, visit your Slopes app.
                      """
        let ac = UIAlertController(title: "Information From Slopes", message: message, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
        present(ac, animated: true)
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
        switch sessionSection {
        case .lifetimeSummary:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SeasonSummaryCell", for: indexPath)
            var configuration = cell.defaultContentConfiguration()
            configuration.text = "Season Summary"
            cell.detailTextLabel?.text = "\(lifetimeRunsLabel.text ?? "-") runs | \(lifetimeDaysOnMountainLabel.text ?? "-") days | \(lifetimeVerticalFeetLabel.text ?? "-") FT"
            cell.backgroundColor = .secondarySystemBackground
            return cell
        case .sessionSummary:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SessionTableViewCell.identifier, for: indexPath) as? SessionTableViewCell else {
                return UITableViewCell()
            }
            if let configuredLogbookData = logbookStats.getConfiguredLogbookData(at: indexPath.row) {
                cell.configure(with: configuredLogbookData)
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
