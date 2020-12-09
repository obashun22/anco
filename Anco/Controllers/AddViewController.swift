//
//  ViewController.swift
//  Anco
//
//  Created by 大羽俊輔 on 2020/11/10.
//

import UIKit

let userDefaults = UserDefaults.standard

class AddViewController: UIViewController {
    
    var tenthPlaceValue = 3
    let firstPlaceValues = Array(0...9) + Array(0...2)
    let decimalPlaceValues = Array(0...9)
    var firstPlaceIndex = 6
    var decimalPlaceIndex = 6
    
    private let generator = UIImpactFeedbackGenerator(style: .rigid)
    
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
        if firstPlaceIndex >= 12 { return }
        firstPlaceIndex += 1
        if firstPlaceIndex > 9 {
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
        if firstPlaceIndex < 10 {
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
    
    private func getTemp() -> Float {
        let tenthPlace = firstPlaceIndex < 10 ? 3 : 4
        let temp_s = "\(tenthPlace)\(firstPlaceValues[firstPlaceIndex]).\(decimalPlaceValues[decimalPlaceIndex])"
        let temp: Float = Float(temp_s)!
        return temp
    }
    
    private func vibe() {
        generator.impactOccurred()
    }
    
    @IBOutlet weak var addButton: UIButton!
    @IBAction func tappedAddButton(_ sender: Any) {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd"
        let date_s = format.string(from: date)
        print(date_s)
        
        let temp = getTemp()
        print(temp)
        
//        userDefaults.setValue([date_s: temp], forKey: "records")
        // ["2020/12/9": 36.6]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        userDefaults.setValue([], forKey: "records")
        generator.prepare()
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
        
    }


}

