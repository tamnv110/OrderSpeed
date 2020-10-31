//
//  ListProductViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 10/27/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class ListProductViewController: MainViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var idsDoc: String?
    var arrProductReal = [ProductModel]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Sản phẩm"
        collectionView.register(UINib(nibName: "ProductTMDTCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ProductTMDTCollectionCell")
        if let _ids = idsDoc {
            let arrID = _ids.components(separatedBy: ",")
            connectGetList(arrID)
        } else {
            connectGetProductOS()
        }
    }

    func connectGetProductOS() {
        self.showProgressHUD("Lấy dữ liệu...")
        self.dbFireStore.collection(OrderFolderName.rootProductReal.rawValue).getDocuments { [weak self](snapshot, error) in
            self?.hideProgressHUD()
            if let documents = snapshot?.documents {
                var arrProductOS = [ProductModel]()
                for document in documents {
                    let dict = document.data()
                    var item = ProductModel(code: "1", link: dict["link"] as! String, name: dict["name"] as! String, option: "", amount: 0, price: (dict["price"] as? Double) ?? 0, fee: 0, status: "", note: "")
                    item.images = [String]()
                    item.images?.append((dict["thumbnail"] as? String) ?? "")
                    item.code = document.documentID
                    item.option = (dict["detail"] as? String) ?? ""
                    arrProductOS.append(item)
                }
                if arrProductOS.count > 0 {
                    self?.arrProductReal.append(contentsOf: arrProductOS)
                }
            }
        }
    }
    
    func connectGetList(_ ids: [String]) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.showProgressHUD("Lấy dữ liệu")
            let dGroup = DispatchGroup()
            for idDoc in ids {
                dGroup.enter()
                self.dbFireStore.collection(OrderFolderName.rootProductReal.rawValue).document(idDoc).getDocument { (snapshot, error) in
                    if let document = snapshot, let dict = document.data() {
                        var item = ProductModel(code: "1", link: dict["link"] as! String, name: dict["name"] as! String, option: "", amount: 0, price: (dict["price"] as? Double) ?? 0, fee: 0, status: "", note: "")
                        item.images = [String]()
                        item.images?.append((dict["thumbnail"] as? String) ?? "")
                        item.code = document.documentID
                        item.option = (dict["detail"] as? String) ?? ""
                        self.arrProductReal.append(item)
                    } else {
                        print("\(self.TAG) - \(#function) - \(#line) - idDoc : \(idDoc)")
                    }
                    dGroup.leave()
                }
            }
            dGroup.notify(queue: .main) {
                self.hideProgressHUD()
                self.collectionView.reloadData()
            }
        }
    }

}

extension ListProductViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.frame.width / 2 - 16
        return CGSize(width: w, height: w * 1.54)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrProductReal.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductTMDTCollectionCell", for: indexPath) as! ProductTMDTCollectionCell
        cell.showInfor(arrProductReal[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = arrProductReal[indexPath.row]
        DispatchQueue.main.async {
            let vc = DetailProductViewController(nibName: "DetailProductViewController", bundle: nil)
            vc.itemProduct = item
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
