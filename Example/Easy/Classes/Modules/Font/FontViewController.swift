//
//  FontViewController.swift
//  Easy
//
//  Created by OctMon on 2018/11/8.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

private struct Font: easy.Then {
    let family: String
    let name: [String]
}

class FontViewController: easy.ViewController, easy.ListProtocol {
    
    typealias EasyListViewAssociatedType = FontListView
    
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
        
        addListView(in: view)
        listView.addTableView(style: .grouped)
        listView.setTableView(numberOfSections: { (listView) -> Int in
            return listView.tableViewDataSource.count
        }) { (listView, section) -> Int in
            return listView.tableViewDataSource(Font.self)[section].name.count
        }
        listView.setTableViewRegister(UITableViewCell.self, configureCell: { [weak self] (_, cell, indexPath, any) in
            guard let font = any as? Font else { return }
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont(name: font.name[indexPath.row], size: 19)
            cell.textLabel?.text = (self?.textField.text ?? "") + "\n" + font.name[indexPath.row]
        }) { [weak self] (_, indexPath, any) in
            let label = UILabel(frame: app.screenBounds).then {
                guard let font = any as? Font else { return }
                $0.backgroundColor = UIColor.white
                $0.numberOfLines = 0
                $0.font = UIFont(name: font.name[indexPath.row], size: 48)
                $0.textAlignment = .center
                let text = (self?.textField.text ?? "") + "\n" + font.name[indexPath.row]
                $0.text = text
            }
            easy.PopupView(label).showWithCenter()
        }
    }
    
    @objc override func request() {
        super.request()
        
        UIFont.familyNames.sorted().forEach({ (family) in
            listView.tableViewDataSource.append(Font(family: family, name: UIFont.fontNames(forFamilyName: family).sorted()))
        })
        listView.title = textField.text ?? "请输入"
        listView.tableView.reloadData()
    }

}

class FontListView: easy.ListView {
    
    var title = ""
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let fonts = tableViewDataSource as? [Font] ?? []
        return fonts[section].family
    }
    
}
