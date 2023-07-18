//
//  LeaderboardViewController.swift
//  Lynx
//
//  Created by Matthew Ernst on 7/14/23.
//

import UIKit

class LeaderboardViewController: UIViewController
{
    
    @IBOutlet var leaderboardTableView: UITableView!
    
    private var categoryToLeaderAttributes = [LeaderboardSort: [LeaderboardAttributes]]()
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Leaderboard"
        navigationController?.navigationBar.prefersLargeTitles = true
        setupLeaderboardTableView()
        setupRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    @objc private func refreshData() {
        loadLeadersData()
    }
    
    private func loadLeadersData() {
        let dispatchGroup = DispatchGroup()
        var categoryToLeaderAttributes = [LeaderboardSort: [LeaderboardAttributes]]()
        
        for category in LeaderboardSort.allCases {
            dispatchGroup.enter()
            getLeaders(for: category, usingSystem: TabViewController.profile.measurementSystem) { leaders in
                if let leaders = leaders {
                    var attributesArray = [LeaderboardAttributes]()
                    
                    // Create an array of LeaderboardAttributes with profile picture URL for each leader
                    for leader in leaders {
                        dispatchGroup.enter() // Enter the dispatch group for each profile picture download
                        let attributes = LeaderboardAttributes(
                            leader: leader,
                            category: category
                        ) {
                            // This block will be executed when the profile picture is downloaded.
                            // Leave the dispatch group for this download when it's complete.
                            dispatchGroup.leave()
                        }
                        attributesArray.append(attributes)
                    }
                    
                    // Leave the dispatch group for the category when all profile pictures are scheduled for download.
                    dispatchGroup.leave()
                    categoryToLeaderAttributes[category] = attributesArray
                } else {
                    // In case there are no leaders for the category, leave the dispatch group.
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
             // Update the categoryToLeaderAttributes only when all profile pictures are downloaded.
             self?.categoryToLeaderAttributes = categoryToLeaderAttributes
             
             // Call endRefreshing on the main thread to stop the refresh control animation.
             DispatchQueue.main.async {
                 self?.leaderboardTableView.refreshControl?.endRefreshing()
                 self?.leaderboardTableView.reloadData()
             }
             
         }
    }


    private func setupLeaderboardTableView() {
        leaderboardTableView.translatesAutoresizingMaskIntoConstraints = false
       
        NSLayoutConstraint.activate([
            leaderboardTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leaderboardTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            leaderboardTableView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            leaderboardTableView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor)
        ])

        leaderboardTableView.delegate = self
        leaderboardTableView.dataSource = self
        leaderboardTableView.register(LeaderboardTableViewCell.self, forCellReuseIdentifier: LeaderboardTableViewCell.identifier)
        leaderboardTableView.register(DefautLeaderboardTableViewCell.self, forCellReuseIdentifier: DefautLeaderboardTableViewCell.identifier)
        leaderboardTableView.register(ShowAllLeadersTableViewCell.self, forCellReuseIdentifier: ShowAllLeadersTableViewCell.identifier)
    }
    
    private func setupRefreshControl() {
        refreshControl.tintColor = .systemGray
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        leaderboardTableView.refreshControl = refreshControl
    }
    
    private func getLeaders(for category: LeaderboardSort, usingSystem system: MeasurementSystem, completion: @escaping ((LeaderboardLeaders?) -> Void)) {
        ApolloLynxClient.getLeaders(for: category, limitedTo: 3, usingSytem: system) { result in
            switch result {
            case .success(let leaders):
                completion(leaders)
            default:
                completion(nil)
            }
        }
    }
}

extension LeaderboardViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LeaderboardRows.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch LeaderboardRows(rawValue: indexPath.row) {
        case .firstPlace, .secondPlace, .thirdPlace:
            guard let defaultCell = tableView.dequeueReusableCell(withIdentifier: DefautLeaderboardTableViewCell.identifier) as? DefautLeaderboardTableViewCell else {
                return UITableViewCell()
            }
            
            guard let leaderAttributes = categoryToLeaderAttributes[LeaderboardSort.allCases[indexPath.section]]?[indexPath.row] else {
                return defaultCell
            }
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LeaderboardTableViewCell.identifier) as? LeaderboardTableViewCell else {
                return defaultCell
            }
            
            cell.configure(with: leaderAttributes, place: indexPath.row)
            
            return cell
            
        case .showAll:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ShowAllLeadersTableViewCell.identifier) as? ShowAllLeadersTableViewCell else {
                return UITableViewCell()
            }
            return cell
            
        case .none:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch LeaderboardRows(rawValue: indexPath.row) {
        case .showAll:
            let (category, _) = headerTextAndSymbolName(for: indexPath.section)
            let vc = AllLeadersViewController()
            vc.category = category
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return LeaderboardSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let (headerText, symbolName) = headerTextAndSymbolName(for: section)
        
        let headerLabel = UILabel()
        headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        headerLabel.textColor = .label
        headerLabel.text = headerText
        
        let symbolConfiguration = UIImage.SymbolConfiguration(weight: .bold)
        let symbolImage = UIImage(systemName: symbolName, withConfiguration: symbolConfiguration)
        let symbolImageView = UIImageView(image: symbolImage)
        symbolImageView.tintColor = .label
        
        let symbolAttachment = NSTextAttachment()
        symbolAttachment.image = symbolImage?.withRenderingMode(.alwaysTemplate)
        symbolAttachment.bounds = CGRect(x: 0, y: -4, width: 20, height: 20)
        
        let symbolAttributedString = NSAttributedString(attachment: symbolAttachment)
        let attributedText = NSMutableAttributedString(attributedString: symbolAttributedString)
        attributedText.append(NSAttributedString(string: " \(headerText)"))
        
        headerLabel.attributedText = attributedText
        
        stackView.addArrangedSubview(headerLabel)
        stackView.spacing = 10
        
        headerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: headerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])
        
        return headerView
    }
    
    func headerTextAndSymbolName(for section: Int) -> (String, String) {
        switch LeaderboardSections(rawValue: section) {
        case .distance:
            return ("Distance", "arrow.right")
        case .runCount:
            return ("Run Count", "figure.skiing.downhill")
        case .topSpeed:
            return ("Top Speed", "flame")
        case .verticalDistance:
            return ("Vertical Distance", "arrow.down")
        case .none:
            return ("", "")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    static let leaderCellHeight: CGFloat = 80.0
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch LeaderboardRows(rawValue: indexPath.row) {
        case .showAll:
            return 40.0
        default:
            return Self.leaderCellHeight
        }
    }
}
