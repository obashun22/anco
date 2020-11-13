//
//  ViewController.swift
//  Anco
//
//  Created by 大羽俊輔 on 2020/11/10.
//

import UIKit

class AddViewController: UIViewController {

    
    @IBOutlet weak var integerView: UIView!
    @IBOutlet weak var floorView: UIView!
    
    @IBOutlet weak var tensPlaceTextField: UILabel!
    @IBOutlet weak var onesPlaceTextField: UILabel!
    @IBOutlet weak var decimalTextField: UILabel!
    
    @IBAction func tappedIncreaseInt(_ sender: Any) {
    }
    @IBAction func tappedIncreaseFloor(_ sender: Any) {
    }
    @IBAction func tappedDecreaseInt(_ sender: Any) {
    }
    @IBAction func tappedDecreaseFloor(_ sender: Any) {
    }
    
    @IBOutlet weak var addButton: UIButton!
    @IBAction func tappedAddButton(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViews()
    }
    
    private func setupViews() {
        integerView.layer.cornerRadius = integerView.frame.height / 2
        floorView.layer.cornerRadius = floorView.frame.height / 2
        addButton.layer.cornerRadius = 12
        
        integerView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        integerView.layer.shadowColor = UIColor.black.cgColor
        integerView.layer.shadowOpacity = 0.4
        integerView.layer.shadowRadius = 4
        
        floorView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        floorView.layer.shadowColor = UIColor.black.cgColor
        floorView.layer.shadowOpacity = 0.4
        floorView.layer.shadowRadius = 4
        
        
    }


}

