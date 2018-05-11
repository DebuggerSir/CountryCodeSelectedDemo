//
//  ViewController.swift
//  CountryCodeSelectedDemo
//
//  Created by SkyWalker on 2018/5/11.
//  Copyright © 2018年 SkyWalker. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var codeTextF: UITextField!
    @IBOutlet weak var countryButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        codeTextF.delegate = self
    }
    @IBAction func contryClick(_ sender: UIButton) {
        let vc = ZTCountryCodeController()
        vc.codeSelectedCallBack = { (countryName, code) in
            sender.setTitle(countryName, for: .normal)
            self.codeTextF.text = code
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(string, textField.text!)
        var  code = textField.text!
        if string == "" {
            code.removeLast()
        } else {
            code = textField.text! + string
        }
        
        countryButton.setTitle(ZTCountryCodeController.searchCountyNameByCode(countryCode: code), for: .normal)
        return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

