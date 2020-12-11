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
        
//        // タップ認識するためのインスタンスを生成
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        tapGesture.cancelsTouchesInView = false
//        // Viewに追加
//        view.addGestureRecognizer(tapGesture)
    }
//    // キーボードを閉じる際の処理
//    @objc private func dismissKeyboard() {
//        view.endEditing(true)
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        dateTableView.reloadData()
//    }
}

extension RecordViewController: UITableViewDelegate, UITableViewDataSource {
    // セクション数
    func numberOfSections(in tableView: UITableView) -> Int {
        let records = userDefaults.array(forKey: "records")! as! [[[Double]]]
        return records.count
    }
    
    // sectionごとのtitle
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let records = userDefaults.array(forKey: "records")! as! [[[Double]]]
        let title = "\(Int(records[section][0][0]))年 \(Int(records[section][0][1]))月"
        return title
    }
    
    // セクションごとの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let records = userDefaults.array(forKey: "records")! as! [[[Double]]]
        let count = records[section].count - 1
        return count
    }
    
    // cellの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // タップされた時の動作
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let nextCV = self.storyboard!.instantiateViewController(identifier: "MembersViewController")
//        navigationController?.pushViewController(nextCV, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "削除") { (_, _, handler) in
            var records = userDefaults.array(forKey: "records")! as! [[[Double]]]
            records[indexPath.section].remove(at: indexPath.row + 1)
            print(records[indexPath.section])
            if records[indexPath.section].count == 1 {
                records.remove(at: indexPath.section)
                userDefaults.setValue(records, forKey: "records")
                let indexSet = NSMutableIndexSet()
                indexSet.add(indexPath.section)
                // recordsのsection要素を削除したのでrowではなくsectionを削除
                tableView.deleteSections(indexSet as IndexSet, with: .fade)
            } else {
                userDefaults.setValue(records, forKey: "records")
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            }
            handler(true)
        }
        let edit = UIContextualAction(style: .normal, title: "編集") { (_, _, handler) in
            
            handler(true)
        }
        let configuration = UISwipeActionsConfiguration(actions: [delete, edit])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell", for: indexPath) as! RecordTableViewCell
        cell.selectionStyle = .none
        let records = userDefaults.array(forKey: "records")! as! [[[Double]]]
        let date = records[indexPath.section][indexPath.row + 1][0]
        let temp = records[indexPath.section][indexPath.row + 1][1]
        cell.dateLabel.text = String(Int(date))
        cell.tempTextField.text = String(temp)
        return cell
    }
}

class RecordTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tempTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tempTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
