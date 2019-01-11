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

class FontViewController: easy.ViewController, easy.TableListProtocol {
    
    typealias EasyTableListViewAssociatedType = TableListView
    
    private let textField: UITextField = UITextField(frame: CGRect(x: 0, y: 0, width: app.screenWidth, height: 100)).then {
        $0.text = "爆款促销"
        $0.font = .size19
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
        
        addTableListView(in: view, style: .grouped)
    }
    
    @objc override func request() {
        super.request()
        
        tableListView.text = textField.text ?? ""
        UIFont.familyNames.sorted().forEach({ (family) in
            tableList.append(Font(family: family, name: UIFont.fontNames(forFamilyName: family).sorted()))
        })
        tableView.reloadData()
    }

}

extension FontViewController {
    
    class TableListView: easy.TableListView {
        
        var text = ""
        
        override func configure() {
            super.configure()
            
            tableView.estimatedRowHeight = 88
            setNumberOfSections({ (listView) -> Int in
                return listView.list.count
            }) { (listView, section) -> Int in
                return listView.listTo(Font.self)[section].name.count
            }
            register(Font.self, cellClass: UITableViewCell.self, configureCell: { (listView, cell, indexPath, font) in
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.font = UIFont(name: font.name[indexPath.row], size: 19)
                cell.textLabel?.text = (listView.view(with: TableListView.self)?.text ?? "") + "\n" + font.name[indexPath.row]
            }) { (listView, indexPath, font) in
                let label = UILabel(frame: app.screenBounds).then {
                    $0.backgroundColor = .white
                    $0.numberOfLines = 0
                    $0.font = UIFont(name: font.name[indexPath.row], size: 48)
                    $0.textAlignment = .center
                    let text = (listView.view(with: TableListView.self)?.text ?? "") + "\n" + font.name[indexPath.row]
                    $0.text = text
                }
                easy.PopupView(label, transition: .none).showWithCenter()
            }
        }
        
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 44
        }
        
        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            let fonts = list(Font.self)
            return fonts?[section].family
        }
        
    }

}
