//
//  DateViewController.swift
//  Anco
//
//  Created by 大羽俊輔 on 2020/11/10.
//

import UIKit

private let userDefaults = UserDefaults.standard

// MARK: - RecordViewController
class RecordViewController: UIViewController {
    
    // Pickerを使用する際に使用する目盛り値の配列
    private let intPlace = Array(34...42)
    private let floatPlace = Array(0...9)
    
    // 編集を押した際にoriDataでセルのtemp(=int+float)とindex情報を一時保管して完了したら結合して保存
    struct originalData {
        var section: Int?
        var row: Int?
        var int: Int?
        var float: Int?
    }
    
    // 編集Actionをした際に編集したいCellの値を一時保管する構造体
    private var oriData = originalData()

    @IBOutlet weak var dateTableView: UITableView!
    @IBAction func tappedRemoveAllButton(_ sender: Any) {
        // 削除確認のalert
        let alert = UIAlertController(title: "すべての記録を削除", message: "すべての記録を削除しますか？", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "削除", style: .default) { (action) in
            // recordsを[]で初期化
            userDefaults.setValue([], forKey: "records")
            self.dateTableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    @IBAction func tappedCopyButton(_ sender: Any) {
        // クリップボードにコピー
        var records = userDefaults.array(forKey: "records")! as! [[[Double]]]
        records = records.reversed()
        var clipText = ""
        // recordsが空なら処理されずに実行されるらしい
        for record in records {
            for (index, data) in record.enumerated() {
                if index == 0 { continue }
                clipText += "\(Int(record[0][0])).\(Int(record[0][1])).\(Int(data[0]))\t\t\(data[1])℃\n"
            }
        }
        clipText = clipText.trimmingCharacters(in: .newlines)
        let board = UIPasteboard.general
        board.string = clipText
        
        // コピーしたことを通知
        let alert = UIAlertController(title: "記録をコピー", message: "日付と体温をクリップボードにコピーしました。", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
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


// MARK: - Extention TableView
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
        // 削除Actionの処理
        let delete = UIContextualAction(style: .destructive, title: "削除") { (_, _, handler) in
            var records = userDefaults.array(forKey: "records")! as! [[[Double]]]
            records[indexPath.section].remove(at: indexPath.row + 1)
            print(records[indexPath.section])
            if records[indexPath.section].count == 1 {
                // 削除した後にrecordにdataが入ってなかったらrecordを削除してsectionも削除
                records.remove(at: indexPath.section)
                userDefaults.setValue(records, forKey: "records")
                let indexSet = NSMutableIndexSet()
                indexSet.add(indexPath.section)
                // recordsのsection要素を削除したのでrowではなくsectionを削除
                tableView.deleteSections(indexSet as IndexSet, with: .fade)
            } else {
                // 削除後まだdataが存在する場合rowを削除
                userDefaults.setValue(records, forKey: "records")
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            }
            handler(true)
        }
        // 編集Actionの処理
        let edit = UIContextualAction(style: .normal, title: "編集") { (_, _, handler) in
            // PickerViewの作成
            let picker = UIPickerView()
            picker.delegate = self
            picker.dataSource = self
            
            // 選択したcellの日時と体温をoriDataに一時保存
            let records = userDefaults.array(forKey: "records")! as! [[[Double]]]
            let temp = records[indexPath.section][indexPath.row + 1][1]
            let temp_ls = String(temp).components(separatedBy: ".")
            let intValue = Int(temp_ls[0])!
            let floatValue = Int(temp_ls[1])!
            self.oriData.section = indexPath.section
            self.oriData.row = indexPath.row + 1
            self.oriData.int = intValue
            self.oriData.float = floatValue
            
            // 選択したcellの体温を自作の体温目盛り配列のindexとして変換してPickerでselectさせておく
            let intIndex = Array(self.intPlace.reversed()).firstIndex(of: intValue)
            let floatIndex = Array(self.floatPlace.reversed()).firstIndex(of: floatValue)
            if let intIndex = intIndex, let floatIndex = floatIndex {
                picker.selectRow(intIndex, inComponent: 0, animated: false)
                picker.selectRow(floatIndex, inComponent: 1, animated: false)
            }
            
            // inputViewの作成（キーボードを置き換えるためのView）
            let kbToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
            kbToolBar.barStyle = UIBarStyle.default // スタイルを設定
            kbToolBar.sizeToFit() // 画面幅に合わせてサイズを変更
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil) // スペーサー
            let doneButton = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(self.tappedDoneButton)) // 閉じるボタン
            let cancelButton = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(self.tappedCancelButton)) // 閉じるボタン
            kbToolBar.items = [cancelButton, spacer, doneButton]
            // 現在のcellのinputViewをpickerとして一時的に編集可能としてfirstResponder起動
            let cell = tableView.cellForRow(at: indexPath) as! RecordTableViewCell
            cell.tempTextField.inputView = picker
            cell.tempTextField.inputAccessoryView = kbToolBar
            cell.tempTextField.isEnabled = true
            // cellのswipeactionから実行する場合cellのanimationが終わる時にresignされるので1秒待つ
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // 1秒後に実行したい処理
                cell.tempTextField.becomeFirstResponder()
            }
            handler(true)
        }
        // delete, edit Actionを追加
        let configuration = UISwipeActionsConfiguration(actions: [delete, edit])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell", for: indexPath) as! RecordTableViewCell
        cell.selectionStyle = .none
        // 日付と体温をcellに渡す
        let records = userDefaults.array(forKey: "records")! as! [[[Double]]]
        let date = records[indexPath.section][indexPath.row + 1][0]
        let temp = records[indexPath.section][indexPath.row + 1][1]
        cell.dateLabel.text = String(Int(date))
        cell.tempTextField.text = String(temp)
        // 編集中にタップしてもカーソルが出ないように
        cell.tempTextField.tintColor = .clear
        return cell
    }
}

// MARK: - Extention PickerView
extension RecordViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    //閉じるボタンが押されたらキーボードを閉じる
    @objc func tappedDoneButton() {
        var records = userDefaults.array(forKey: "records")! as! [[[Double]]]
        // 選択されて変更されたoriDataの体温と保存されているsection, rowの情報からrecordsを更新
        if let section = oriData.section, let row = oriData.row, let int = oriData.int, let float = oriData.float {
            let temp = Double(int) + Double(float) / 10
            records[section][row][1] = temp
        }
        userDefaults.setValue(records, forKey: "records")
        dateTableView.reloadData()
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
    
    // component列目, row番目にセットされた時の処理
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // cellの初期体温を記録してあるoriDataの体温を書き換える
        switch component {
        case 0:
            oriData.int = intPlace.reversed()[row]
        case 1:
            oriData.float = floatPlace.reversed()[row]
        default:
            break
        }
    }
}

// MARK: - RecordTableViewCell
class RecordTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tempTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tempTextField.delegate = self
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Pickerで編集し終わったら編集不可能にする
        textField.isEnabled = false
    }
}
