//
//  DateViewController.swift
//  Anco
//
//  Created by 大羽俊輔 on 2020/11/10.
//

import UIKit

private let userDefaults = UserDefaults.standard

/*
# 備忘録
swipeActionからキーボードはよくない
pickerからtextfieldへの文字入力は編集無効化はoriginalのtextfieldClassで作成するべき
# ToDo
navBarの文字色
体温編集
体温登録
今日の体温
全削除
広告
*/

class RecordViewController: UIViewController {

    @IBOutlet weak var dateTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateTableView.delegate = self
        dateTableView.dataSource = self
        dateTableView.tableFooterView = UIView()
        
    }
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
            let picker = UIPickerView()
            picker.delegate = self
            picker.dataSource = self
            let kbToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
            kbToolBar.barStyle = UIBarStyle.default // スタイルを設定
            kbToolBar.sizeToFit() // 画面幅に合わせてサイズを変更
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) // スペーサー
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.tappedDoneButton)) // 閉じるボタン
            kbToolBar.items = [spacer, doneButton]
            let cell = tableView.cellForRow(at: indexPath) as! RecordTableViewCell
            cell.tempTextField.inputView = picker
            cell.tempTextField.inputAccessoryView = kbToolBar
            cell.tempTextField.isEnabled = true
            // cellのswipeactionから実行する場合cellのanimationが終わる時にresignされる
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // 1秒後に実行したい処理
                cell.tempTextField.becomeFirstResponder()
            }
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
        cell.tempTextField.tintColor = .clear
        return cell
    }
}

extension RecordViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    //閉じるボタンが押されたらキーボードを閉じる
    @objc func tappedDoneButton (){
        self.view.endEditing(true)
    }
    
    //PickerViewのコンポーネント(縦）の数を決めるメソッド(実装必須)
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //pickerに表示する行数（横）を返すデータソースメソッド.(実装必須)
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }

    //pickerに表示する値を返すデリゲートメソッド.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let tmp = [1, 2, 3]
        return String(tmp[row])
    }

    //pickerが選択された際に呼ばれるデリゲートメソッド.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }
}


class RecordTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tempTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tempTextField.delegate = self
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.isEnabled = false
    }
}
