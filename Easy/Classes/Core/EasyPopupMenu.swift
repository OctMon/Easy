//
//  EasyPopupMenu.swift
//  Easy
//
//  Created by OctMon on 2018/10/15.
//

import UIKit

public extension Easy {
    typealias PopMenu = EasyPopupMenu
}

public class EasyPopupMenu: UIView {

    private lazy var menuTableView: UITableView = {
        let tableView = UITableView(frame: EasyApp.screenBounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 2
        tableView.showsVerticalScrollIndicator = false
        tableView.bounces = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        tableView.backgroundColor = .clear
        var header = UIView()
        header.frame.size.height = 6.5
        tableView.tableHeaderView = header
        return tableView
    }()
    
    private lazy var items: [String] = {
        return []
    }()
    
    private var completion: ((Int) -> Void)?
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public convenience init() {
        self.init(frame: EasyApp.screenBounds)
        backgroundColor = .clear
        
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.addTarget(self, action: #selector(close))
        self.addGestureRecognizer(tapGestureRecognizer)
        
        addSubview(menuTableView)
        menuTableView.registerReusableCell(EasyPopupMenuCell.self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func close() {
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            guard let self = self else { return }
            self.menuTableView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        }) { (finish) in
            self.subviews.forEach({ $0.removeFromSuperview() })
            self.removeFromSuperview()
        }
    }
    
    public func show(point: CGPoint, items: [String], backgroundImage: UIImage? = UIImage(for: EasyPopupMenu.self, forResource: "EasyCore", forImage: "bg_popup_menu"), completion: @escaping (Int) -> Void) {
        menuTableView.backgroundView = UIImageView(image: backgroundImage)
        self.completion = completion
        menuTableView.layer.anchorPoint = CGPoint(x: 0.8, y: 0)
        menuTableView.frame = CGRect(x: point.x, y: point.y, width: 113.5, height: 6.5 + 44 * CGFloat(items.count))
//        menuTableView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        EasyApp.window?.addSubview(self)
        addSubview(menuTableView)
        self.items = items
        self.menuTableView.reloadData()
        self.menuTableView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else { return }
            self.menuTableView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }

}

extension EasyPopupMenu: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: EasyPopupMenuCell.self)
        cell.titleLabel.text = items[indexPath.row]
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        completion?(indexPath.row)
        close()
    }
    
}

extension EasyPopupMenu: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: menuTableView))! {
            return false
        }
        return true
    }
    
}

private class EasyPopupMenuCell: UITableViewCell {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        addSubview(label)
        
        label.textColor = .white
        label.font = .size13
        label.textAlignment = .center
        
        label.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
            make.height.equalTo(44)
        })
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
