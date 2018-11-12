//
//  EasyTestViewController.swift
//  Easy
//
//  Created by OctMon on 2018/10/13.
//

import UIKit
import FLEX

class EasyTestViewController: EasyViewController, EasyTableListProtocol {
    
    typealias EasyTableListViewAssociatedType = EasyTableListView
    
    private let textView: UITextView = UITextView(frame: CGRect(x: 0, y: 0, width: EasyApp.screenWidth, height: 200))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "EasyTest by OctMon"
        
        navigationItem.appendLeftBarButtonItem(title: FLEXManager.toString) {
            FLEXManager.shared().toggleExplorer()
        }
        
        navigationItem.appendRightBarButtonItem(title: "Done") {
            isShowTestTool.toggle()
        }
        
        refreshLog(EasyLog.log)
        EasyLog.logHandler = { [weak self] (log) in
            self?.refreshLog(log)
        }
        
        request()
    }
    
    private func refreshLog(_ log: String?) {
        guard let log = log else { return }
        self.textView.text = log
        self.textView.layoutManager.allowsNonContiguousLayout = false
        self.textView.scrollRangeToVisible(NSRange(location: log.count - 1, length: 1))
    }
    
    override func configure() {
        super.configure()
        
        addTableListView(in: view, style: .plain)
        tableListView.tableView.tableHeaderView = textView
        tableListView.tableView.tableFooterView = UIView()
        
        tableListView.setTableViewRegister((String, String).self, cellsClass: [EasyTestCell.self, UITableViewCell.self], returnCell: { (indexPath) -> AnyClass? in
            if indexPath.section == 0 {
                return EasyTestCell.self
            }
            return UITableViewCell.self
        }, configureCell: { [weak self] (cell, indexPath, any) in
            if let cell = (cell as? EasyTestCell) {
                cell.do {
                    $0.selectionStyle = .none
                    $0.textLabel?.text = any.0
                    $0.switchView.isOn = any.1.toBoolValue
                    $0.switchHandler { [weak self] (isOn) in
                        var model = any
                        model.1 = isOn.toStringValue
                        self?.tableListView.tableViewDataSource[indexPath.section] = model
                        switch (indexPath.section, indexPath.row) {
                        case (0, 0):
                            EasyResult.logEnabel = isOn
                        default:
                            break
                        }
                    }
                }
            } else {
                cell.do {
                    $0.accessoryType = .detailDisclosureButton
                    $0.selectionStyle = .default
                    $0.textLabel?.adjustsFontSizeToFitWidth = true
                    $0.textLabel?.text = any.0 + " -> " + any.1
                }
            }
        }) { [weak self] (indexPath, any) in
            guard indexPath.section > 0 else { return }
            sessions[indexPath.row].showChangeBaseURL({ [weak self] (url) in
                var model = any
                model.1 = url
                let list = self?.tableListView.tableViewDataSource[indexPath.section]
                if var models = list as? [Any] {
                    models[indexPath.row] = model
                    self?.tableListView.tableViewDataSource[indexPath.section] = models
                    self?.tableListView.tableView.reloadData()
                }
            })
        }
        
        tableListView.setTableViewAccessoryButtonTappedForRowWith { [weak self] (indexPath, _) in
            guard indexPath.section > 0 else { return }
            let session = sessions[indexPath.row]
            var textField = UITextField()
            textField.keyboardType = .URL
            textField.placeholder = session.config.url.currentBaseURL
            EasyAlert(message: "input custom").addTextField(&textField, required: true).addAction(title: "取消", style: .cancel).addAction(title: "确定", style: .default, preferredAction: true, handler: { [weak self] (_) in
                guard let url = textField.text, !url.isEmpty else { return }
                UserDefaults.standard.set(url, forKey: session.config.url.defaultCustomBaseURLKey)
                if UserDefaults.standard.synchronize() {
                    self?.request()
                    EasyLog.debug("ChangeBaseURL Success: \(url)")
                } else {
                    EasyLog.debug("ChangeBaseURL Failure")
                }
            }).show()
        }
    }
    
    override func request() {
        super.request()
        
        tableListView.tableViewDataSource = [[("show EasyResult banner", EasyResult.logEnabel.toStringValue)]]//, (GDPerformanceMonitor.toString, omIsShowGDPerformanceMonitor.toStringValue)]]
        var tmp = [Any]()
        sessions.forEach({ tmp.append(($0.config.url.alias, $0.config.url.currentBaseURL)) })
        if tmp.count > 0 {
            tableListView.tableViewDataSource.append(tmp)
        }
        tableListView.tableView.reloadData()
    }
    
}

class EasyTestCell: UITableViewCell {
    
    lazy var switchView: UISwitch = {
        let switchView = UISwitch()
        return switchView
    }()
    
    private var switchHandler: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryView = switchView
        
        switchView.addTarget(self, action: #selector(switchAction), for: .valueChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func switchAction(sender: UISwitch) {
        switchHandler?(sender.isOn)
    }
    
    func switchHandler(_ handler: @escaping (Bool) -> Void) {
        switchHandler = handler
    }
    
}
