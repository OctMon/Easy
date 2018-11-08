//
//  FontViewController.swift
//  Easy
//
//  Created by OctMon on 2018/11/8.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class FontViewController: easy.ViewController {
    
    private struct Font: easy.Then {
        let family: String
        let name: [String]
    }
    
    private let textField: UITextField = UITextField(frame: CGRect(x: 0, y: 0, width: app.screenWidth, height: 100)).then {
        $0.text = "爆款促销"
        $0.font = UIFont.size19
        $0.textAlignment = .center
        $0.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = textField
        
        textField.addTarget(self, action: #selector(request), for: .editingChanged)
        request()
    }
    
    override func configure() {
        super.configure()
        
        listView.addTableView(style: .plain)
        listView.tableView.dataSource = self
        listView.tableView.delegate = self
        listView.tableView.registerReusableCell(UITableViewCell.self)
    }
    
    @objc override func request() {
        super.request()
        
        UIFont.familyNames.sorted().forEach({ (family) in
            listView.tableViewDataSource.append(Font(family: family, name: UIFont.fontNames(forFamilyName: family).sorted()))
        })
        
        listView.tableView.reloadData()
    }

}

extension FontViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let fonts = listView.tableViewDataSource as? [Font] ?? []
        return fonts.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let fonts = listView.tableViewDataSource as? [Font] ?? []
        return fonts[section].name.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell()
        let fonts = listView.tableViewDataSource as? [Font] ?? []
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont(name: fonts[indexPath.section].name[indexPath.row], size: 19)
        let text = (self.textField.text ?? "") + "\n" + fonts[indexPath.section].name[indexPath.row]
        cell.textLabel?.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let fonts = listView.tableViewDataSource as? [Font] ?? []
        return fonts[section].family
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let label = UILabel(frame: app.screenBounds).then {
            let fonts = listView.tableViewDataSource as? [Font] ?? []
            $0.backgroundColor = UIColor.white
            $0.numberOfLines = 0
            $0.font = UIFont(name: fonts[indexPath.section].name[indexPath.row], size: 48)
            $0.textAlignment = .center
            let text = (self.textField.text ?? "") + "\n" + fonts[indexPath.section].name[indexPath.row]
            $0.text = text
        }
        easy.PopupView(label).showWithCenter()
    }
    
}
