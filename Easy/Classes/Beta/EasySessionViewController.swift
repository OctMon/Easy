//
//  EasySessionViewController.swift
//  Easy
//
//  Created by OctMon on 2018/10/13.
//

import UIKit

class EasySessionViewController: EasyViewController, EasyTableListProtocol {
    
    typealias EasyTableListViewAssociatedType = EasyTableListView
    
    var popupView: EasyPopupView?
    var config: EasyConfig!
    var successHandler: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var list = [String]()
        var tmp = [config.url.release, config.url.test]
        if let baseURL = UserDefaults.standard.string(forKey: config.url.defaultCustomBaseURLKey) {
            tmp.append(baseURL)
        }
        tmp.append(contentsOf: config.url.list)
        tmp.forEach { (url) in
            if !url.isEmpty, !list.contains(url) {
                list.append(url)
            }
        }
        tableList = list
    }
    
    override func configure() {
        super.configure()
        
        addTableListView(in: view, style: .plain)
        
        let current = config.url.currentBaseURL
        let text = "📡 Change \(config.url.alias) BaseURL 📡"
        let height = text.getHeight(forConstrainedWidth: EasyApp.screenWidth, font: .size14)
        tableListView.tableView.tableHeaderView = UILabel(frame: CGRect(x: 0, y: 0, width: EasyApp.screenWidth, height: height)).then {
            $0.numberOfLines = 0
            $0.font = .size14
            $0.textAlignment = .center
            $0.textColor = .white
            $0.text = text
            $0.backgroundColor = .lightGray
        }
        
        tableListView.register(String.self, cellClass: UITableViewCell.self, configureCell: { [weak self] (_, cell, _, any) in
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textAlignment = .center
            if current == any {
                cell.backgroundColor = .gray
                cell.textLabel?.textColor = .white
                cell.selectionStyle = .none
                cell.accessoryType = .none
            } else {
                cell.backgroundColor = .white
                cell.textLabel?.textColor = .black
                cell.selectionStyle = .default
                cell.accessoryType = .disclosureIndicator
            }
            if let addition = self?.config.url.addition?[any]?.toPrettyPrintedString {
                cell.textLabel?.text = "\n📡baseURL : \(any)" + "\n" + addition.replacingOccurrences(of: "\\", with: "").replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "")
            } else {
                cell.textLabel?.text = "\n📡baseURL : \(any)\n"
            }
            }, didSelectRow: { [weak self] (_, _, any) in
                guard let self = self else { return }
                guard current != any else { return }
                UserDefaults.standard.set(any, forKey: self.config.url.defaultCustomBaseURLKey)
                if UserDefaults.standard.synchronize() {
                    EasyLog.debug("ChangeBaseURL Success: \(any)")
                    self.successHandler?(any)
                    self.popupView?.dismiss()
                } else {
                    EasyLog.debug("ChangeBaseURL Failure")
                }
        })
    }
    
}
