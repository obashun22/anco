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
体温編集完了押したら保存更新
広告
*/

class RecordViewController: UIViewController {
    
    private let intPlace = Array(34...42)
    private let floatPlace = Array(0...9)

    @IBOutlet weak var dateTableView: UITableView!
    @IBAction func tappedRemoveAllButton(_ sender: Any) {
        let alert = UIAlertController(title: "すべての記録を削除", message: "すべての記録を削除しますか？", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "削除", style: .default) { (action) in
            userDefaults.setValue([], forKey: "records")
            self.dateTableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateTableView.delegate = self
        dateTableView.dataSource = self
        dateTableView.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dateTableView.reloadData()
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
            let records = userDefaults.array(forKey: "records")! as! [[[Double]]]
            let temp = records[indexPath.section][indexPath.row + 1][1]
            let temp_ls = String(temp).components(separatedBy: ".")
            let intValue = Int(temp_ls[0])!
            let floatValue = Int(temp_ls[1])!
            let intIndex = Array(self.intPlace.reversed()).firstIndex(of: intValue)
            let floatIndex = Array(self.floatPlace.reversed()).firstIndex(of: floatValue)
            if let intIndex = intIndex, let floatIndex = floatIndex {
                picker.selectRow(intIndex, inComponent: 0, animated: false)
                picker.selectRow(floatIndex, inComponent: 1, animated: false)
            }
            let kbToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
            kbToolBar.barStyle = UIBarStyle.default // スタイルを設定
            kbToolBar.sizeToFit() // 画面幅に合わせてサイズを変更
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) // スペーサー
            let doneButton = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(self.tappedDoneButton)) // 閉じるボタン
            let cancelButton = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(self.tappedCancelButton)) // 閉じるボタン
            kbToolBar.items = [cancelButton, spacer, doneButton]
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
        cell.tempTextField.text = String(temp) + ""
        cell.tempTextField.tintColor = .clear
        return cell
    }
}

extension RecordViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    //閉じるボタンが押されたらキーボードを閉じる
    @objc func tappedDoneButton() {
        self.view.endEditing(true)
    }
    
    @objc func tappedCancelButton() {
        self.view.endEditing(true)
    }
    
    //PickerViewのコンポーネント(縦）の数を決めるメソッド(実装必須)
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    //pickerに表示する行数（横）を返すデータソースメソッド.(実装必須)
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return intPlace.count
        case 1:
            return floatPlace.count
        default:
            return 0
        }
    }

    //pickerに表示する値を返すデリゲートメソッド.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return String(intPlace.reversed()[row])
        case 1:
            return "." + String(floatPlace.reversed()[row])
        default:
            return "0"
        }
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
