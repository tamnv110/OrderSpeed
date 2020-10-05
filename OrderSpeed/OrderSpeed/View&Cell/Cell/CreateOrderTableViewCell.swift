//
//  CreateOrderTableViewCell.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/5/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit
import FirebaseStorage

protocol CreateOrderCellDelegate {
    func updateInfoOrderProduct(_ item: ProductModel?) -> Void
    func eventChooseProductImages(_ cell: CreateOrderTableViewCell)
    func imageCountGreateThanMax(_ count: Int)
    func deleteImageFromServer(_ imageName: String)
}

class CreateOrderTableViewCell: UITableViewCell {
    private let TAG = "CreateOrderTableViewCell"
    @IBOutlet weak var tfLink: BottomLineTextField!
    @IBOutlet weak var tfName: BottomLineTextField!
    @IBOutlet weak var tfSize: BottomLineTextField!
    @IBOutlet weak var tfNumber: BottomLineTextField!
    @IBOutlet weak var tfPrice: BottomLineTextField!
    @IBOutlet weak var collectionImage: UICollectionView!
    @IBOutlet weak var tfNote: CustomTextViewPlaceHolder!
    var delegate: CreateOrderCellDelegate?
    
    var orderProduct: ProductModel?
    var refStorage: StorageReference?
    var arrImageShow = [(Int, String?, ItemImageSelect?)]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tfLink.delegate = self
        tfName.delegate = self
        tfSize.delegate = self
        tfNumber.delegate = self
        tfPrice.delegate = self

        tfLink.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        tfName.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        tfSize.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        tfNumber.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        tfPrice.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        
        let lblRightView = UILabel()
        lblRightView.text = "¥"
        lblRightView.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        lblRightView.textColor = Tools.hexStringToUIColor(hex: "#848383")
        tfPrice.rightView = lblRightView
        tfPrice.rightViewMode = .always
        
        collectionImage.delegate = self
        collectionImage.dataSource = self
        collectionImage.register(UINib(nibName: "ImageProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ImageProductCollectionViewCell")
        
        tfNote.customDelegate = self
    }
    
    func showInfo(_ orderProduct: ProductModel?) {
        self.orderProduct = orderProduct
        self.arrImageShow.removeAll()
        DispatchQueue.main.async {
            self.tfLink.text = self.orderProduct?.link
            self.tfName.text = self.orderProduct?.name
            self.tfSize.text = self.orderProduct?.option
            let number = self.orderProduct?.amount ?? 0
            self.tfNumber.text = (number > 0) ? "\(number)" : nil
            let price = self.orderProduct?.price ?? 0
            self.tfPrice.text = (price > 0) ? String(format: "%.2f", price) : nil
            self.tfNote.text = self.orderProduct?.note
            
            if let imagesLocal = self.orderProduct?.arrProductImages {
                let items = imagesLocal.map { (item) -> (Int, String?, ItemImageSelect?) in
                    return (0, nil, item)
                }
                self.arrImageShow.append(contentsOf: items)
            }
            
            if let imagesServer = self.orderProduct?.images {
                let items = imagesServer.map { (item) -> (Int, String?, ItemImageSelect?) in
                    return (1, item, nil)
                }
                self.arrImageShow.append(contentsOf: items)
            }
            
            DispatchQueue.main.async {
                self.collectionImage.reloadData()
            }
        }
    }
    
    func checkInput() -> Bool {
        var flag = true
        let arrInput = [tfLink!, tfPrice!, tfNumber!]
        for input in arrInput {
            if input.text?.isEmpty ?? false {
                input.isChecked = false
                flag = false
            }
        }
        return flag
    }
    
    @objc func eventChooseDeleteImage(_ sender: UIButton) {
        if let cell = sender.superview?.superview as? ImageProductCollectionViewCell, let indexPath = collectionImage.indexPath(for: cell) {
            print("\(TAG) - \(#function) - \(#line) - indexPath : \(indexPath.row)")
            let itemDelete = arrImageShow[indexPath.row]
            if itemDelete.0 == 1, let imageName = itemDelete.1 {
                delegate?.deleteImageFromServer(imageName)
            }
            arrImageShow.remove(at: indexPath.row)
            var arrImageLocal: [ItemImageSelect]?
            var arrImageServer: [String]?
            for items in arrImageShow {
                if items.0 == 0 {
                    if arrImageLocal == nil {
                        arrImageLocal = [ItemImageSelect]()
                    }
                    if let local = items.2 {
                        arrImageLocal?.append(local)
                    }
                } else {
                    if arrImageServer == nil {
                        arrImageServer = [String]()
                    }
                    if let server = items.1 {
                        arrImageServer?.append(server)
                    }
                }
            }
            orderProduct?.arrProductImages = arrImageLocal
            orderProduct?.images = arrImageServer
            delegate?.updateInfoOrderProduct(orderProduct)
            DispatchQueue.main.async {
                self.collectionImage.reloadData()
            }
        }
    }
    
    @objc func editingChanged(_ tf: BottomLineTextField) {
        print("\(TAG) - \(#function) - \(#line) - editing : \(tf.text)")
        switch tf {
        case tfLink:
            orderProduct?.link = tfLink.text ?? ""
        case tfName:
            orderProduct?.name = tfName.text ?? ""
        case tfSize:
            orderProduct?.option = tfSize.text ?? ""
        case tfNumber:
            orderProduct?.amount = Int(tfNumber.text ?? "") ?? 0
        case tfPrice:
            let temp = Double(tfPrice.text ?? "") ?? 0
            print("\(TAG) - \(#function) - \(#line) - temp : \(temp)")
            orderProduct?.price = Double(tfPrice.text ?? "") ?? 0
        default:
            print("\(TAG) - \(#function) - \(#line) - default")
        }
        delegate?.updateInfoOrderProduct(orderProduct)
    }
}

extension CreateOrderTableViewCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tfLink {
            tfName.becomeFirstResponder()
        } else if textField == tfName {
            tfSize.becomeFirstResponder()
        } else if textField == tfSize {
            tfNumber.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let tf = textField as? BottomLineTextField {
            tf.isChecked = true
        }
    }

}

extension CreateOrderTableViewCell: CustomTextViewDelegate {
    func customTextViewEndEditting(_ textView: UITextView) {
        orderProduct?.note = textView.text
        delegate?.updateInfoOrderProduct(orderProduct)
    }
    
    
}

extension CreateOrderTableViewCell: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let h = collectionView.frame.height
        return CGSize(width: h, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImageShow.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row < arrImageShow.count {
            if let cell = cell as? ImageProductCollectionViewCell {
                let item = arrImageShow[indexPath.row]
                if item.0 == 0 {
                    cell.imgvProduct.image = item.2?.image
                } else if let imageName = item.1, let ref = self.refStorage {
                    let reference = ref.child("Images/\(imageName)")
                    cell.imgvProduct.sd_setImage(with: reference, placeholderImage: nil)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageProductCollectionViewCell", for: indexPath) as! ImageProductCollectionViewCell
        if indexPath.row >= arrImageShow.count {
            cell.btnDelete.isHidden = true
            cell.imgvDefault.isHidden = false
        } else {
            cell.btnDelete.isHidden = false
            cell.imgvDefault.isHidden = true
        }

        cell.btnDelete.addTarget(self, action: #selector(eventChooseDeleteImage(_:)), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row >= arrImageShow.count {
            if arrImageShow.count == 3 {
                delegate?.imageCountGreateThanMax(arrImageShow.count)
            } else {
                delegate?.eventChooseProductImages(self)
            }
        }
    }
}

