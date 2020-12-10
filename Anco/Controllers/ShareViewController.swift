//
//  DateViewController.swift
//  Anco
//
//  Created by 大羽俊輔 on 2020/11/10.
//

import UIKit

private let userDefaults = UserDefaults.standard

class RecordViewController: UIViewController {

    @IBOutlet weak var dateTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateTableView.delegate = self
        dateTableView.dataSource = self
        dateTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dateTableView.reloadData()
    }
}

extension RecordViewController: UITableViewDelegate, UITableViewDataSource {
    // セクション数
    func numberOfSections(in tableView: UITableView) -> Int {
        // year + month文字列の集合を取ってカウント
        let data_dic = userDefaults.dictionary(forKey: "records")!
        let keys_ls = [String](data_dic.keys)
        var ym_set = Set<String>()
        for key_str in keys_ls {
            let key_ls = key_str.components(separatedBy: "/")
            let ym = key_ls[0] + key_ls[1]
            ym_set.insert(ym)
        }
        return ym_set.count
    }
    
    // sectionごとのtitle
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // year年 + " " + month月文字列で集合を取ってその文字列を返す
        let data_dic = userDefaults.dictionary(forKey: "records")!
        let keys_ls = [String](data_dic.keys).sorted { $1 < $0 }
        var ym_set = Set<String>()
        for key_str in keys_ls {
            let key_ls = key_str.components(separatedBy: "/")
            let ym = "\(key_ls[0])年 \(key_ls[1])月"
            ym_set.insert(ym)
        }
        let ym_ls = [String](ym_set).sorted { $1 < $0 }
        let title = ym_ls[section]
        return title
    }
    
    // セクションごとの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let nextCV = self.storyboard!.instantiateViewController(identifier: "MembersViewController")
//        navigationController?.pushViewController(nextCV, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell", for: indexPath) as! RecordTableViewCell
        cell.selectionStyle = .none
        
//        cell.date
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
