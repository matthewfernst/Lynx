//
//  LifetimeSummaryViewController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 6/18/23.
//

import UIKit

class LifetimeSummaryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    static var identifier = "LifetimeSummaryViewController"

    var averageStats: [(Stat, Stat?)]! = nil
    var bestStats: [(Stat, Stat?)]! = nil
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Lifetime"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StatsTableViewCell.self, forCellReuseIdentifier: StatsTableViewCell.identifier)
        containerView.addSubview(tableView)
        view.addSubview(containerView)
        
        // Set up constraints for the container view
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        containerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // Set up constraints for the table view
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections in the table view
        return LiftimeSummarySections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section
        switch LiftimeSummarySections(rawValue:section) {
        case .averages:
            return averageStats.count
        case .best:
            return bestStats.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StatsTableViewCell.identifier, for: indexPath) as! StatsTableViewCell
        
        let stats: (Stat, Stat?)
        switch LiftimeSummarySections(rawValue: indexPath.section) {
        case .averages:
            stats = averageStats[indexPath.row]
        case .best:
            stats = bestStats[indexPath.row]
        default:
            stats = (Stat(label: "", information: "", icon: UIImage(systemName: "x.circle")!), nil)
        }
        
        cell.configure(leftStat: stats.0, rightStat: stats.1)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = UIColor.darkText
        switch LiftimeSummarySections(rawValue: section) {
        case .averages:
            titleLabel.text = "Averages"
        case .best:
            titleLabel.text = "Best"
        default:
            break
        }
        
        headerView.addSubview(titleLabel)
        
        // Set up constraints for the title label
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -12)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Return the desired height for the section header
        return 44.0
    }
}

enum LiftimeSummarySections: Int, CaseIterable
{
    case averages = 0
    case best = 1
}
