//
//  ViewController.swift
//  Anco
//
//  Created by 大羽俊輔 on 2020/11/10.
//

/*
## データ構造メモ
Pickerの配列: [34(0), 35, 36, 37, 38, 39(5), 40(6), 41, 42(8)]
[
 [[2020, 12], [1, 36.2], [2, 36.5]],
 [[2020, 11], [3, 36.2], [4, 36.5]],
]
 
## 備忘録
swipeActionからキーボードはよくない
pickerからtextfieldへの文字入力は編集無効化はoriginalのtextfieldClassで作成するべき
### +, - Buttonについて
1タップに反応／長押しで連続反応／溜めあり？
tappedActionと長押しRecogでいけるかな
結局、長押し機能は保留

## ToDo
画像作成
connect設定
ID変更
リリース
*/

import UIKit
import GoogleMobileAds

private let userDefaults = UserDefaults.standard

// MARK: - AddViewController
class AddViewController: UIViewController {
    
    // 体温入力のメモリを管理するための配列とindex
    private let firstPlaceValues = Array(4...9) + Array(0...2)
    private let decimalPlaceValues = Array(0...9)
    private var tenthPlaceValue = 3
    private var firstPlaceIndex = 2
    private var decimalPlaceIndex = 6
    
    private let generatorMedium = UIImpactFeedbackGenerator(style: .medium)
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    // 今日の体温Label
    @IBOutlet weak var todayTempLabel: UILabel!
    
    // 体温入力の目盛りをまとめるView
    @IBOutlet weak var integerView: UIView!
    @IBOutlet weak var floorView: UIView!
    
    // 体温入力のLabel
    @IBOutlet weak var tensPlaceLabel: UILabel!
    @IBOutlet weak var firstPlaceLabel: UILabel!
    @IBOutlet weak var decimalLabel: UILabel!
    
    // 体温入力のボタン
    @IBOutlet weak var increaseFirstButton: UIButton!
    @IBOutlet weak var increaseDecimalButton: UIButton!
    @IBOutlet weak var decreaseFirstButton: UIButton!
    @IBOutlet weak var decreaseDecimalButton: UIButton!
    
    // +, - Buttonが押された時の処理
    @IBAction func tappedIncreaseFirst(_ sender: Any) {
        increaseFirst()
        printTemp()
        reloadTemp()
        vibe()
    }
    @IBAction func tappedIncreaseDecimal(_ sender: Any) {
        increaseDecimal()
        printTemp()
        reloadTemp()
        vibe()
    }
    @IBAction func tappedDecreaseFirst(_ sender: Any) {
        decreaseFirst()
        printTemp()
        reloadTemp()
        vibe()
    }
    @IBAction func tappedDecreaseDecimal(_ sender: Any) {
        decreaseDecimal()
        printTemp()
        reloadTemp()
        vibe()
    }
    
    @IBOutlet weak var addButton: UIButton!
    @IBAction func tappedAddButton(_ sender: Any) {
        // 今日の日付をyear, month, dateに分けてDouble型で取得
        let today = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd"
        let date_ls = format.string(from: today).components(separatedBy: "/")
        let year = Double(date_ls[0])!
        let month = Double(date_ls[1])!
        let date = Double(date_ls[2])!
        
        // 現在の体温を取得
        let temp = getTemp()
        print(year, month, date, temp)
        
        // # "records"のデータ構造
        // records = [record, record, ...]
        // record = [[year, month], data, data]
        // data = [date, temp]
        // 記録情報（UserDefaults）の更新
        var records = userDefaults.array(forKey: "records")! as! [[[Double]]]
        if records.count < 1 {
            // recordデータがない時は新しくrecordを作成
            records.insert([[year, month], [date, temp]], at: 0)
        } else {
            // 最新のrecordの年月を確認
            if records[0][0] == [year, month] {
                // 既にrecordがある場合の処理
                var found = false
                for (index, data) in records[0].enumerated() {
                    if data[0] == date {
                        // 既存のdataに今日の日付があればdataを更新（削除・追加）
                        records[0].remove(at: index)
                        records[0].insert([date, temp], at: index)
                        found = true
                        break
                    }
                }
                if !found {
                    // 既存のdataに今日の日付がない場合新しくdataを追加
                    records[0].insert([date, temp], at: 1)
                }
            } else {
                // 最新のrecordの年月が現在日時と異なる場合新しくrecordを生成
                records.insert([[year, month], [date, temp]], at: 0)
            }
        }
        // recordsデータを更新
        userDefaults.setValue(records, forKey: "records")
        print(records)
        
        // 今日の体温Labelを更新
        updateTodayTempLabel()
        
        // 記録したときに振動する
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初回起動時ならrecordsに[]を保存
        if userDefaults.array(forKey: "records") == nil {
            userDefaults.setValue([], forKey: "records")
        }
        
        setupViews()
        setupBannerView()
        generatorMedium.prepare()
        
//        userDefaults.setValue([
//            [
//                [2020, 12],
//                [2, 35.6],
//                [1, 36.5],
//            ],
//            [
//                [2020, 11],
//                [15, 37.3],
//                [14, 35.6],
//            ],
//            [
//                [2019, 3],
//                [4, 35.6],
//                [2, 35.6],
//                [1, 32.5],
//            ],
//        ], forKey: "records")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 画面読み込みとRecords画面で編集削除したとき
        updateTodayTempLabel()
    }
    
    private func setupBannerView() {
        let debugID = Bundle.main.object(forInfoDictionaryKey: "AdMob Unit ID Debug") as! String
        let releaseID = Bundle.main.object(forInfoDictionaryKey: "AdMob Unit ID Release") as! String
        // デモ広告
        bannerView.adUnitID = debugID
        // 本番広告
//        bannerView.adUnitID = releaseID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    private func setupViews() {
        // 丸角処理
        integerView.layer.cornerRadius = integerView.frame.height / 2
        floorView.layer.cornerRadius = floorView.frame.height / 2
        addButton.layer.cornerRadius = 12
        
        // 影
        let shadowOpacity = Float(0.2)
        let shadowRadius = CGFloat(4)
        integerView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        integerView.layer.shadowColor = UIColor.black.cgColor
        integerView.layer.shadowOpacity = shadowOpacity
        integerView.layer.shadowRadius = shadowRadius
        
        floorView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        floorView.layer.shadowColor = UIColor.black.cgColor
        floorView.layer.shadowOpacity = shadowOpacity
        floorView.layer.shadowRadius = shadowRadius
        
        // indexに従って体温入力Label初期化
        initTempLabel()
    }
    // indexを増減させて対応する配列の値をLabelに表示
    private func increaseFirst() {
        // 42度以上ならインクリメントしない
        if firstPlaceIndex >= 8 { return }
        if firstPlaceIndex + 1 >= 8 {
            increaseFirstButton.isEnabled = false
        }
        decreaseFirstButton.isEnabled = true
        firstPlaceIndex += 1
        if firstPlaceIndex > 5 {
            tenthPlaceValue = 4
        }
    }
    
    private func increaseDecimal() {
        if decimalPlaceIndex >= 9 { return }
        if decimalPlaceIndex + 1 >= 9 {
            increaseDecimalButton.isEnabled = false
        }
        decreaseDecimalButton.isEnabled = true
        decimalPlaceIndex += 1
    }
    
    private func decreaseFirst() {
        if firstPlaceIndex <= 0 { return }
        if firstPlaceIndex - 1 <= 0 {
            decreaseFirstButton.isEnabled = false
        }
        increaseFirstButton.isEnabled = true
        firstPlaceIndex -= 1
        if firstPlaceIndex < 6 {
            tenthPlaceValue = 3
        }
    }
    
    private func decreaseDecimal() {
        if decimalPlaceIndex <= 0 { return }
        if decimalPlaceIndex - 1 <= 0 {
            decreaseDecimalButton.isEnabled = false
        }
        increaseDecimalButton.isEnabled = true
        decimalPlaceIndex -= 1
    }
    
    // index変更処理後体温入力のLabelを更新
    private func reloadTemp() {
        let tenth = tenthPlaceValue
        let first = firstPlaceValues[firstPlaceIndex]
        let decimal = decimalPlaceValues[decimalPlaceIndex]
        tensPlaceLabel.text = String(tenth)
        firstPlaceLabel.text = String(first)
        decimalLabel.text = String(decimal)
    }
    
    // 現在の体温をデバッグ表示する
    private func printTemp() {
        print(getTemp())
    }
    
    // Double型で体温を取得する
    private func getTemp() -> Double {
        let tenthPlace = firstPlaceIndex < 6 ? 3 : 4
        let temp_s = "\(tenthPlace)\(firstPlaceValues[firstPlaceIndex]).\(decimalPlaceValues[decimalPlaceIndex])"
        let temp: Double = Double(temp_s)!
        return temp
    }
    
    // Buttonをタップした時に振動させる関数
    private func vibe() {
        generatorMedium.impactOccurred()
    }

    // 今日の体温をrecordsに従って更新する関数
    private func updateTodayTempLabel() {
        let todayTempText = "今日の体温: "
        todayTempLabel.text = todayTempText + "未記録"
        
        let records = userDefaults.array(forKey: "records")! as! [[[Double]]]
        let today = Date()
        let format = DateFormatter()
        format.dateFormat = "dd"
        let date = Double(format.string(from: today))!
        if records.count < 1 { return }
        for data in records[0] {
            if data[0] == date {
                todayTempLabel.text = todayTempText + String(data[1]) + "℃"
            }
        }
    }
    
    // indexに従って体温入力Labelを初期化する関数
    private func initTempLabel() {
        tensPlaceLabel.text = String(tenthPlaceValue)
        firstPlaceLabel.text = String(firstPlaceValues[firstPlaceIndex])
        decimalLabel.text = String(decimalPlaceValues[decimalPlaceIndex])
    }
}

