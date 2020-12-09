//
//  DateViewController.swift
//  Anco
//
//  Created by 大羽俊輔 on 2020/11/10.
//

import UIKit

class RecordViewController: UIViewController {

    @IBOutlet weak var dateTableView: UITableView!
    
    var data = [[2020, 12, 4, 36.2], [2020, 12, 3, 36.2], [2020, 12, 2, 36.2]]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateTableView.delegate = self
        dateTableView.dataSource = self
        dateTableView.tableFooterView = UIView()
    }
}

extension RecordViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let nextCV = self.storyboard!.instantiateViewController(identifier: "MembersViewController")
//        navigationController?.pushViewController(nextCV, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell", for: indexPath)
        cell.selectionStyle = .none
//        cell.
        return cell
    }
}

class RecordTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tempTextField: UITextField!
    let date = 0
    let temp = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dateLabel.text = String(date)
        tempTextField.text = String(temp)
    }
}
