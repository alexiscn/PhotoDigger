//
//  PhotoMetadataViewController.swift
//  PhotoDigger
//
//  Created by xu.shuifeng on 2018/4/8.
//  Copyright © 2018 shuifeng.me. All rights reserved.
//

import UIKit

typealias MetadataInfo = (key: String, value: Any)

struct MetadataGroup {
    let title: String
    let metadatas: [MetadataInfo]
}

class PhotoMetadataViewController: UIViewController {
    
    fileprivate var dataSource: [MetadataGroup]
    
    fileprivate var tableView: UITableView!
    
    init(dataSource: [MetadataGroup]) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo Informations"
        
        let closeBarItem = UIBarButtonItem(image: UIImage(named: "navclose"), style: .done, target: self, action: #selector(onCloseBarButtonItemTapped))
        closeBarItem.tintColor = .black
        closeBarItem.imageInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        navigationItem.leftBarButtonItem = closeBarItem
        
        tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MetadataInfoCell.self, forCellReuseIdentifier: "CELL")
        tableView.reloadData()
    }
    
    @objc private func onCloseBarButtonItemTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension PhotoMetadataViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let group = dataSource[section]
        return group.metadatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL", for: indexPath)
        let group = dataSource[indexPath.section]
        let metadata = group.metadatas[indexPath.row]
        
        cell.textLabel?.text = metadata.key
        if let array = metadata.value as? [Any] {
            var str = ""
            array.forEach({ str += "\($0)," })
            cell.detailTextLabel?.text = str
        } else {
            cell.detailTextLabel?.text = "\(metadata.value)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let group = dataSource[section]
        return group.title
    }
}

class MetadataInfoCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
