//
//  DateViewController.swift
//  Anco
//
//  Created by 大羽俊輔 on 2020/11/10.
//

import UIKit

class ShareViewController: UIViewController {

    
    @IBOutlet weak var dateTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateTableView.delegate = self
        dateTableView.dataSource = self
        dateTableView.tableFooterView = UIView()
    }
    
}

extension ShareViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextCV = self.storyboard!.instantiateViewController(identifier: "MembersViewController")
        navigationController?.pushViewController(nextCV, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell", for: indexPath)
        cell.selectionStyle = .none
        return cell
    }
    
    
}
