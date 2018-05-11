//
//  ZTCountryCodeController.swift
//  CodoonSwift
//
//  Created by SkyWalker on 2018/5/10.
//  Copyright © 2018年 SkyWalker. All rights reserved.
//

import UIKit

class ZTCountryCodeController: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    
    typealias callBack = (_ countryName:String, _ countryCode:String)->()
    public var codeSelectedCallBack:callBack?
    public weak var delegate:ZTCountryCodeControllerDelegate?
    fileprivate var searchController:UISearchController!
    fileprivate var parentNaviBarIsTranslucent:Bool = true
    fileprivate lazy var countryCodeTableView: UITableView = {
        
        let tableV = UITableView.init(frame: view.bounds, style: .plain)
        tableV.delegate = self
        tableV.dataSource = self
        view.addSubview(tableV)
        return tableV
    }()
    fileprivate lazy var sortedNameDict:Dictionary<String, Array<String>>! = {
        let pathCH = Bundle.main.path(forResource: "sortedChnames", ofType: "plist")
        let pathEN = Bundle.main.path(forResource: "sortedEnames", ofType: "plist")
        
        var dic = Dictionary<String, Array<String>>()
        let currentLauguage = Locale.preferredLanguages.first!
        if  ["en-US", "en-CA", "en-GB", "en-CN", "en"].contains(currentLauguage) {
            dic = NSDictionary.init(contentsOfFile: pathEN!) as! Dictionary<String, Array<String>>
        } else {
            dic = NSDictionary.init(contentsOfFile: pathCH!) as! Dictionary<String, Array<String>>
        }
        return dic
    }()
    fileprivate lazy var indexArr:Array<String>! = {
        var arr  = Array<String>()
        arr = self.sortedNameDict.keys.sorted(by: { (str1, str2) -> Bool in
            return str1 < str2
        })
        return arr
    }()
    
    fileprivate var searchResultValuesArray:Array<String>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultValuesArray = Array()
        //排除isTranslucent的影响
        if navigationController?.navigationBar.isTranslucent == false {
            navigationController?.navigationBar.isTranslucent = true
            parentNaviBarIsTranslucent = false
        }
        let search = UISearchController.init(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.dimsBackgroundDuringPresentation = false
        search.definesPresentationContext = true 
        search.searchBar.placeholder = "搜索"
        searchController = search
        self.countryCodeTableView.tableHeaderView = search.searchBar
        countryCodeTableView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if parentNaviBarIsTranslucent == false {
            navigationController?.navigationBar.isTranslucent = parentNaviBarIsTranslucent
        }
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive == false {
            return self.indexArr.count
        }  else {
            return 1
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive == false {
            let array = self.sortedNameDict[indexArr[section]]!
            return array.count
        }  else {
            return self.searchResultValuesArray.count
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: "cell")
        }
        var str = ""
        if searchController.isActive == false {
            str = self.sortedNameDict[indexArr[indexPath.section]]![indexPath.row]
        } else {
            str = self.searchResultValuesArray[indexPath.row]
        }
        let arr = str.components(separatedBy: "+")
        cell?.textLabel?.text = arr.first!
        cell?.detailTextLabel?.text = "+" + arr.last!
        cell?.detailTextLabel?.textColor = .lightGray
        return cell!
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if  searchController.isActive == false {
            return self.indexArr
        } else {
            return nil
        }
    }
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if searchController.isActive == false {
            return index
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive == false {
            return self.indexArr[section]
        } else {
            return nil
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.codeSelectedCallBack != nil {
            let cell = tableView.cellForRow(at: indexPath)!
            var  codeNumStr = (cell.detailTextLabel?.text!)!
            codeNumStr = codeNumStr.replacingOccurrences(of: "+", with: "")
            codeNumStr = codeNumStr.replacingOccurrences(of: " ", with: "")
            var countryName = (cell.textLabel?.text!)!
             countryName = countryName.replacingOccurrences(of: " ", with: "")
            self.codeSelectedCallBack!(countryName, codeNumStr)
            if delegate != nil {
                delegate?.ztCountryCodeDidSelect(countryName: countryName, countryCode: codeNumStr)
            }
            searchController.isActive = false
            navigationController?.modalTransitionStyle = .flipHorizontal
            navigationController?.modalPresentationStyle = .none
            navigationController?.popViewController(animated: true)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let inputStr = searchController.searchBar.text
        if searchResultValuesArray.count > 0 {
            self.searchResultValuesArray.removeAll()
        }
        for (_, valueArr) in self.sortedNameDict {
            for str in valueArr {
                if str.contains(inputStr!) {
                    searchResultValuesArray.append(str)
                }
            }
        }
        self.countryCodeTableView.reloadData()
        
    }
    
    /// 类方法，根据国家编码筛选国家名字
    ///
    /// - Parameter countryCode: 三种情况，无效，为""，有效数字
    /// - Returns: 根据上述三种情况返回地区
    class func searchCountyNameByCode(countryCode:String) -> String {
        if countryCode == "" {
            return "请从列表中选择"
        }
        let pathCH = Bundle.main.path(forResource: "sortedChnames", ofType: "plist")
        let pathEN = Bundle.main.path(forResource: "sortedEnames", ofType: "plist")
        
        var dic = Dictionary<String, Array<String>>()
        let currentLauguage = Locale.preferredLanguages.first!
        if  ["en-US", "en-CA", "en-GB", "en-CN", "en"].contains(currentLauguage) {
            dic = NSDictionary.init(contentsOfFile: pathEN!) as! Dictionary<String, Array<String>>
        } else {
            dic = NSDictionary.init(contentsOfFile: pathCH!) as! Dictionary<String, Array<String>>
        }
        //英文条件下，为了想拿到1的时候是美国，多此一步做倒序，可以删除
       let tempDic =  dic.sorted(by: { (arg0, arg1) -> Bool in
            let (key1, _) = arg0
            let (key2, _) = arg1
            return key1 > key2
        })
        for (_, valueArr) in tempDic {
            for str in valueArr {
                let code = str.components(separatedBy: "+").last?.replacingOccurrences(of: " ", with: "")
                if code == countryCode  {
                    return str.components(separatedBy: "+").first!.replacingOccurrences(of: " ", with: "")
                }
            }
        }
        return "国家编码无效"
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

protocol ZTCountryCodeControllerDelegate: class {
    func ztCountryCodeDidSelect(countryName:String, countryCode:String)
}
