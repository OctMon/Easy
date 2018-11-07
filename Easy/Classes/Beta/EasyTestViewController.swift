//
//  EasyTestViewController.swift
//  Easy
//
//  Created by OctMon on 2018/10/13.
//

import UIKit
import FLEX

class EasyTestViewController: EasyViewController {
    
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
        tableView.tableHeaderView = textView
        tableView.tableFooterView = UIView()
        
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
        
        tableViewStyle = .grouped
        setTableViewRegister([EasyTestCell.self, UITableViewCell.self], returnCell: { (indexPath) -> AnyClass? in
            if indexPath.section == 0 {
                return EasyTestCell.self
            }
            return UITableViewCell.self
        }, configureCell: { [weak self] (cell, indexPath, any) in
            if let cell = (cell as? EasyTestCell) {
                cell.do {
                    let model = any as? (String, Bool)
                    $0.selectionStyle = .none
                    $0.textLabel?.text = model?.0
                    $0.switchView.isOn = model?.1 ?? false
                    $0.switchHandler { [weak self] (isOn) in
                        if var model = model {
                            model.1 = isOn
                            self?.tableViewDataSource[indexPath.section] = model
                            switch (indexPath.section, indexPath.row) {
                            case (0, 0):
                                EasyResult.logEnabel = isOn
                            default:
                                break
                            }
                        }
                    }
                }
            } else {
                cell.do {
                    if let model = any as? (String, String) {
                        $0.accessoryType = .detailDisclosureButton
                        $0.selectionStyle = .default
                        $0.textLabel?.adjustsFontSizeToFitWidth = true
                        $0.textLabel?.text = model.0 + " -> " + model.1
                    }
                }
            }
        }) { [weak self] (indexPath, any) in
            guard indexPath.section > 0 else { return }
            sessions[indexPath.row].showChangeBaseURL({ [weak self] (url) in
                if var model = any as? (String, String) {
                    model.1 = url
                    let list = self?.tableViewDataSource[indexPath.section]
                    if var models = list as? [Any] {
                        models[indexPath.row] = model
                        self?.tableViewDataSource[indexPath.section] = models
                        self?.tableView.reloadData()
                    }
                }
            })
        }
    }
    
    override func request() {
        super.request()
        
        tableViewDataSource = [[("show EasyResult banner", EasyResult.logEnabel)]]//, (GDPerformanceMonitor.toString, omIsShowGDPerformanceMonitor)]]
        var tmp = [Any]()
        sessions.forEach({ tmp.append(($0.config.url.alias, $0.config.url.currentBaseURL)) })
        if tmp.count > 0 {
            tableViewDataSource.append(tmp)
        }
        tableView.reloadData()
    }
    
}

extension EasyTestViewController {
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
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
