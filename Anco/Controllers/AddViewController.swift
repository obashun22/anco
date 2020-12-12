//
//  ViewController.swift
//  Anco
//
//  Created by 大羽俊輔 on 2020/11/10.
//

import UIKit

private let userDefaults = UserDefaults.standard

// [34(0), 35, 36, 37, 38, 39(5), 40(6), 41, 42(8)]
class AddViewController: UIViewController {
    
    var tenthPlaceValue = 3
    let firstPlaceValues = Array(4...9) + Array(0...2)
    let decimalPlaceValues = Array(0...9)
    var firstPlaceIndex = 2
    var decimalPlaceIndex = 6
    
    private let generatorMedium = UIImpactFeedbackGenerator(style: .medium)
    
    @IBOutlet weak var todayTempLabel: UILabel!
    @IBOutlet weak var integerView: UIView!
    @IBOutlet weak var floorView: UIView!
    
    @IBOutlet weak var tensPlaceLabel: UILabel!
    @IBOutlet weak var firstPlaceLabel: UILabel!
    @IBOutlet weak var decimalLabel: UILabel!
    
    @IBOutlet weak var increaseFirstButton: UIButton!
    @IBOutlet weak var increaseDecimalButton: UIButton!
    @IBOutlet weak var decreaseFirstButton: UIButton!
    @IBOutlet weak var decreaseDecimalButton: UIButton!
    
    // 1タップに反応／長押しで連続反応／溜めあり？
    // tappedActionと長押しRecogでいけるかな
    // 長押し機能はアプデ対象でいこう
    
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
    
    private func increaseFirst() {
        // 42度以上ならインクリメントしない
        if firstPlaceIndex >= 8 { return }
        firstPlaceIndex += 1
        if firstPlaceIndex > 5 {
            tenthPlaceValue = 4
        }
    }
    
    private func increaseDecimal() {
        if decimalPlaceIndex >= 9 { return }
        decimalPlaceIndex += 1
    }
    
    private func decreaseFirst() {
        if firstPlaceIndex <= 0 { return }
        firstPlaceIndex -= 1
        if firstPlaceIndex < 6 {
            tenthPlaceValue = 3
        }
    }
    
    private func decreaseDecimal() {
        if decimalPlaceIndex <= 0 { return }
        decimalPlaceIndex -= 1
    }
    
    private func reloadTemp() {
        let tenth = tenthPlaceValue
        let first = firstPlaceValues[firstPlaceIndex]
        let decimal = decimalPlaceValues[decimalPlaceIndex]
        tensPlaceLabel.text = String(tenth)
        firstPlaceLabel.text = String(first)
        decimalLabel.text = String(decimal)
    }
    
    private func printTemp() {
        print(getTemp())
    }
    
    private func getTemp() -> Double {
        let tenthPlace = firstPlaceIndex < 6 ? 3 : 4
        let temp_s = "\(tenthPlace)\(firstPlaceValues[firstPlaceIndex]).\(decimalPlaceValues[decimalPlaceIndex])"
        let temp: Double = Double(temp_s)!
        return temp
    }
    
    private func vibe() {
        generatorMedium.impactOccurred()
    }
    
    @IBOutlet weak var addButton: UIButton!
    @IBAction func tappedAddButton(_ sender: Any) {
        let today = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd"
        let date_ls = format.string(from: today).components(separatedBy: "/")
        let year = Double(date_ls[0])!
        let month = Double(date_ls[1])!
        let date = Double(date_ls[2])!
        let temp = getTemp()
        print(year, month, date, temp)
        
        var records = userDefaults.array(forKey: "records")! as! [[[Double]]]
        if records.count < 1 {
            records.insert([[year, month], [date, temp]], at: 0)
        } else {
            if records[0][0] == [year, month] {
                var found = false
                for (index, data) in records[0].enumerated() {
                    if data[0] == date {
                        records[0].remove(at: index)
                        records[0].insert([date, temp], at: index)
                        found = true
                        break
                    }
                }
                if !found {
                    records[0].insert([date, temp], at: 1)
                }
            } else {
                records.insert([[year, month], [date, temp]], at: 0)
            }
        }
        userDefaults.setValue(records, forKey: "records")
        print(records)
        updateTodayTempLabel()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        userDefaults.setValue([], forKey: "records")
        generatorMedium.prepare()
        
        userDefaults.setValue([
            [
                [2020, 12],
                [2, 35.6],
                [1, 36.5],
            ],
            [
                [2020, 11],
                [15, 37.3],
                [14, 35.6],
            ],
            [
                [2019, 3],
                [4, 35.6],
                [2, 35.6],
                [1, 32.5],
            ],
        ], forKey: "records")
    }
    
    /*
    [
     [[2020, 12], [1, 36.2], [2, 36.5]],
     [[2020, 11], [3, 36.2], [4, 36.5]],
    ]
    */
    
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 画面読み込みとRecords画面で編集削除したとき
        updateTodayTempLabel()
    }

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
}

