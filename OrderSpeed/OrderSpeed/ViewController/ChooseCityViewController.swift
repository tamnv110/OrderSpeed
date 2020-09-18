//
//  ChooseCityViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/9/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit
import SwiftyJSON
import Firebase

struct CityInfo {
    var name: String
    var dictricts: [String]
}

protocol ChooseCityDelegate {
    func eventChooseCity(_ cityName: String, districtName: String)
}

class ChooseCityViewController: MainViewController {

    @IBOutlet weak var tbCity: UITableView!
    var delegate: ChooseCityDelegate?
    var arrCities = [CityInfo]() {
        didSet {
            if !itemSelected.0.isEmpty {
                if let index = arrCities.firstIndex(where: { (city) -> Bool in
                    return city.name.lowercased() == itemSelected.0.lowercased()
                }) {
                    indexSelected = index
                    sDistrict = itemSelected.1
                    DispatchQueue.main.async {
                        self.tbCity.reloadData()
                    }
                }
            }
        }
    }
    var indexSelected = -1
    var sDistrict = ""
    var itemSelected = ("", "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbCity.tableFooterView = UIView(frame: .zero)
        tbCity.register(UINib(nibName: "ShowTitleTableCell", bundle: nil), forCellReuseIdentifier: "ShowTitleTableCell")
        if let jsonData = Tools.getObjectFromDefault("LIST_CITIES") as? Data {
            do {
                let json = try JSON(data: jsonData)
                if let arrCitiesTemp = json["Cities"].array {
                    self.arrCities = arrCitiesTemp.map { (item) -> CityInfo in
                        return CityInfo(name: item["name"].stringValue, dictricts: item["dictricts"].arrayValue.map({ (dictrict) -> String in
                            return dictrict.stringValue
                        }))
                    }
                }
            } catch {
                connectGetCities()
            }
        } else {
            connectGetCities()
        }
    }
    
    func showRightButton() {
        if self.navigationItem.rightBarButtonItem == nil {
            let btnChoose = UIBarButtonItem(title: "Chọn", style: .done, target: self, action: #selector(eventChooseCity(_:)))
            self.navigationItem.rightBarButtonItem = btnChoose
        }
    }
    
    @objc func eventChooseCity(_ sender: Any) {
        if indexSelected >= 0 {
            let city = arrCities[indexSelected]
            delegate?.eventChooseCity(city.name, districtName: sDistrict)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func connectGetBank() {
        self.dbFireStore.collection("Settings").document("Bank").collection("List").getDocuments { [weak self](snapshot, error) in
            if let document = snapshot {
                for item in document.documents {
                    let dict = item.data()
                    print("\(dict)")
                }
            }
        }        
    }

    func connectGetCities() {
        self.dbFireStore.collection("Settings").document("Country").getDocument { [weak self](snapshot, error) in
            if let document = snapshot, let dict = document.data(), let cities = dict["Cities"] as? Array<[String: Any]> {
                let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: [])
                Tools.saveObjectToDefault(jsonData, key: "LIST_CITIES")
                let result = cities.compactMap { (itemDict) -> CityInfo in
                    let name = itemDict["name"] as? String
                    let dictricts = itemDict["dictricts"] as? [String]
                    return CityInfo(name: name ?? "", dictricts: dictricts ?? [String]())
                }
                self?.arrCities = result
                DispatchQueue.main.async {
                    self?.tbCity.reloadData()
                }
            } else {
                print("\(self?.TAG) - \(#function) - \(#line) - error : \(error.debugDescription)")
            }
        }
    }
    
//    func connectGetDistricts(_ idCity: Int, cityName: String) {
//        DispatchQueue.main.async {
//            self.progessHUD.showInViewWithMessage(self.view, message: "Lấy quận/huyện...")
//        }
//        let sURL = "https://khonhadat.vn/api/location/districts?cityId=\(idCity)"
//        AF.request(sURL).responseData { [weak self](response) in
//            DispatchQueue.main.async {
//                self?.progessHUD.hide()
//            }
//            switch response.result {
//            case .success:
//                if let data = response.data {
//                    do {
//                        if let result = try JSON(data: data).array {
//                            let arrDictricts = result.map { (item) -> String in
//                                return item["Name"].stringValue
//                            }
//                            if arrDictricts.count > 0{
//                                self?.uploadCity(cityName, arrDictricts: arrDictricts)
//                            }
//                        }
//                    } catch{
//                        print("\(self?.TAG ?? "") - \(#function) - \(#line) - error : \(error)")
//                    }
//                }
//            case let .failure(error):
//                print("\(self?.TAG ?? "") - \(#function) - \(#line) - error : \(error)")
//            }
//        }
//    }
    
//    func uploadCity(_ city: String, arrDictricts: [String]) {
//        DispatchQueue.main.async {
//            self.progessHUD.showInViewWithMessage(self.view, message: "Lấy quận/huyện...")
//        }
//        let dataUpload: [String: Any] = ["name": city, "dictricts": arrDictricts]
//        self.dbFireStore.collection("Settings").document("Country").updateData(["Cities" : FieldValue.arrayUnion([dataUpload])]) { [weak self](error) in
//            DispatchQueue.main.async {
//                self?.progessHUD.hide()
//            }
//            print("\(self?.TAG) - \(#function) - \(#line) - START")
//        }
//    }
    
//    func createTestBank() {
////        let batch = dbFireStore.batch()
//        let sfRef = self.dbFireStore.collection("Settings").document("Bank").collection("List")
//        for i in 0...9 {
//            let item = BankModel(id: "123\(i)", bank_name: "Bank Name \(i)", bank_number: "Bank Number \(i)", bank_brand: "Bank Brand \(i)", bank_holder: "Bank Holder \(i)")
//            do {
//                let data = try JSONEncoder().encode(item)
//                if let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
//                    print("\(TAG) - \(#function) - \(#line) - dict : \(dict)")
//                    sfRef.addDocument(data: dict)
//                }
//            } catch  {
//
//            }
//        }
//    }
}

struct BankModel: Encodable {
    var id: String
    var bank_name: String
    var bank_number: String
    var bank_brand: String
    var bank_holder: String
}

extension ChooseCityViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrCities.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (indexSelected != section) ? 0 : arrCities[indexSelected].dictricts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.white
        header.tag = section
        let lblName = UILabel()
        if indexSelected == section {
            lblName.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        } else {
            lblName.font = UIFont.systemFont(ofSize: 17)
        }
        lblName.text = arrCities[section].name
        lblName.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(lblName)
        lblName.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
        lblName.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16).isActive = true
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = UIColor(red: 217.0/255.0, green: 217.0/255.0, blue: 217.0/255.0, alpha: 1)
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(bottomLine)
        bottomLine.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16).isActive = true
        bottomLine.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16).isActive = true
        bottomLine.bottomAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        bottomLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(eventTapHeaderSection(_:))))
        
        return header
    }
    
    @objc func eventTapHeaderSection(_ tap: UIGestureRecognizer) {
        if let parentView = tap.view {
            indexSelected = (indexSelected != parentView.tag) ? parentView.tag : -1
            DispatchQueue.main.async {
                self.showRightButton()
                self.tbCity.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowTitleTableCell", for: indexPath) as! ShowTitleTableCell
        let sTemp = arrCities[indexPath.section].dictricts[indexPath.row]
        cell.lblTitle.text = "- " + sTemp
        if sDistrict == sTemp {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sDistrict = arrCities[indexPath.section].dictricts[indexPath.row]
        if let arrRows = tableView.indexPathsForVisibleRows {
            DispatchQueue.main.async {
                tableView.reloadRows(at: arrRows, with: .automatic)
            }
        }
    }
}
