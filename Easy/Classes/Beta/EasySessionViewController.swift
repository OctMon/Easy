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
        tableListView.list = list
    }
    
    override func configure() {
        super.configure()
        
        addTableListView(in: view, style: .plain)
        
        let current = config.url.currentBaseURL
        let text = "📡 Change \(config.url.alias) BaseURL 📡"
        let height = text.getHeight(forConstrainedWidth: EasyApp.screenWidth, font: UIFont.size14)
        tableListView.tableView.tableHeaderView = UILabel(frame: CGRect(x: 0, y: 0, width: EasyApp.screenWidth, height: height)).then {
            $0.numberOfLines = 0
            $0.font = UIFont.size14
            $0.textAlignment = .center
            $0.textColor = UIColor.white
            $0.text = text
            $0.backgroundColor = UIColor.lightGray
        }
        
        tableListView.setTableViewRegister(String.self, cellClass: UITableViewCell.self, configureCell: { [weak self] (cell, _, any) in
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textAlignment = .center
            if current == any {
                cell.backgroundColor = UIColor.gray
                cell.textLabel?.textColor = UIColor.white
                cell.selectionStyle = .none
                cell.accessoryType = .none
            } else {
                cell.backgroundColor = UIColor.white
                cell.textLabel?.textColor = UIColor.black
                cell.selectionStyle = .default
                cell.accessoryType = .disclosureIndicator
            }
            if let addition = self?.config.url.addition?[any]?.toPrettyPrintedString {
                cell.textLabel?.text = "\n📡baseURL : \(any)" + "\n" + addition.replacingOccurrences(of: "\\", with: "").replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "")
            } else {
                cell.textLabel?.text = "\n📡baseURL : \(any)\n"
            }
            }, didSelectRow: { [weak self] (_, any) in
                guard let `self` = self else { return }
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
