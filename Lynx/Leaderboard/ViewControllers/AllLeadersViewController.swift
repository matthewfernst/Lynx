//
//  AllLeadersViewController.swift
//  Lynx
//
//  Created by Matthew Ernst on 7/17/23.
//

import UIKit

class AllLeadersViewController: UIViewController
{
    
    var allLeadersTableView: UITableView!
    static let identifier = "AllLeadersViewController"
    
    var category: String!
    private var leadersForCategory = [LeaderboardAttributes]()
    private var isLoadingData = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = category
        view.backgroundColor = .systemBackground
        
        setupLeaderboardTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isLoadingData = false
    }
    
    private func setupLeaderboardTableView() {
        allLeadersTableView = UITableView(frame: .zero, style: .insetGrouped)
        
        allLeadersTableView.translatesAutoresizingMaskIntoConstraints = false
        allLeadersTableView.delegate = self
        allLeadersTableView.dataSource = self
        
        allLeadersTableView.register(LeaderboardTableViewCell.self, forCellReuseIdentifier: LeaderboardTableViewCell.identifier)
        allLeadersTableView.register(DefautLeaderboardTableViewCell.self, forCellReuseIdentifier: DefautLeaderboardTableViewCell.identifier)
        
        view.addSubview(allLeadersTableView)
        
        allLeadersTableView.backgroundColor = .systemBackground
        NSLayoutConstraint.activate([
            allLeadersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            allLeadersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            allLeadersTableView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            allLeadersTableView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllLeadersForCategory()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    private func getAllLeadersForCategory() {
        guard let leaderCategory = ApolloGeneratedGraphQL.LeaderboardSort(rawValue: category.uppercased().replacingOccurrences(of: " ", with: "_")) else {
            return
        }

        ApolloLynxClient.getSelectedLeaderboard(leaderCategory, limit: nil, inMeasurementSystem: TabViewController.profile.measurementSystem) { result in
            switch result {
            case .success(let leaders):
                self.leadersForCategory = leaders
                
                DispatchQueue.main.async { [weak self] in
                    self?.isLoadingData = false
                    self?.allLeadersTableView.reloadData()
                }
            case .failure(_):
                break
            }
        }
    }
    
}

extension AllLeadersViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return LeaderboardViewController.leaderCellHeight
    }
    
}

extension AllLeadersViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoadingData {
            return Int((view.frame.height / LeaderboardViewController.leaderCellHeight) / 2)
        } else {
            return leadersForCategory.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // No need for the guard statement. Dequeue the appropriate cell.
        let cell: UITableViewCell
        
        if isLoadingData {
            // Show the default cell while data is loading
            if let defaultCell = tableView.dequeueReusableCell(withIdentifier: DefautLeaderboardTableViewCell.identifier) as? DefautLeaderboardTableViewCell {
                cell = defaultCell
            } else {
                cell = UITableViewCell()
            }
        } else {
            // Show the actual data cells after data is fetched
            let leaderAttributes = leadersForCategory[indexPath.row]
            
            if let customCell = tableView.dequeueReusableCell(withIdentifier: LeaderboardTableViewCell.identifier) as? LeaderboardTableViewCell {
                // Configure the custom cell with data
                switch LeaderboardRows(rawValue: indexPath.row) {
                case .firstPlace, .secondPlace, .thirdPlace:
                    customCell.configure(with: leaderAttributes, place: indexPath.row)
                default:
                    customCell.configure(with: leaderAttributes, place: nil)
                }
                cell = customCell
            } else {
                cell = UITableViewCell()
            }
        }
        
        return cell
    }
}
