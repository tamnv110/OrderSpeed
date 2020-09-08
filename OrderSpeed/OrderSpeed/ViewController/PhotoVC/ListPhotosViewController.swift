//
//  ListPhotosViewController.swift
//  TestPhoto
//
//  Created by Nguyen Van Tam on 11/29/19.
//  Copyright © 2019 TamNV. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import CropViewController
import Alamofire
import SwiftyJSON

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

extension PHAsset {
    var originalFilename: String? {
        return PHAssetResource.assetResources(for: self).first?.originalFilename
    }
}

struct Album {
    var collection:PHAssetCollection?
    var imgThumb:UIImage?
    var countPhoto:Int
}

struct ItemImageSelect {
    var imageID:String
    var image:UIImage?
    var imageAsset:PHAsset
}

protocol ListPhotoDelegate {
    func eventChooseImages(_ arrImages:[ItemImageSelect])
}

class ListPhotosViewController: MainViewController {
    
    private let MAX_IMAGES = 5
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewAlbumOption: UIView!
    @IBOutlet weak var tblAlbum: UITableView!
    
    var widthCell:CGFloat = 50
    
    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
    
    var arrSelectedImage = [ItemImageSelect]() {
        didSet {
            if arrSelectedImage.count > 0 {
                if self.navigationItem.rightBarButtonItem == nil {
                    self.setupRightButton()
                }
            } else {
                self.navigationItem.rightBarButtonItem = nil
            }
        }
    }
    var delegate:ListPhotoDelegate?
    
    var arrAlbums:[Album] = []
    var indexAlbum = 0
    
    var typeUpload = 0
    var indexSelected = -1 {
        didSet {
            if self.typeUpload == 1 {
                if self.navigationItem.rightBarButtonItem == nil {
                    self.setupRightButton()
                }
            }
        }
    }
    var imageiOS: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.navigationBar.tintColor = UIColor.white
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
//        setupNavigationBar()
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
        
        print("\(TAG) - \(#function) - \(#line) - self.view.bounds : \(UIScreen.main.bounds.size)")
        var fKhoangCach:CGFloat = 24
        if UIScreen.main.bounds.size.width == 414 && UIScreen.main.bounds.size.height == 896 {
            fKhoangCach = 10
        }
        widthCell = self.view.bounds.width / 3 - fKhoangCach
        
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: widthCell * scale, height: widthCell * scale)
        
        collectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCollectionViewCell")
        
        tblAlbum.register(UINib(nibName: "AlbumOptionsCell", bundle: nil), forCellReuseIdentifier: "AlbumOptionsCell")
        tblAlbum.tableFooterView = UIView(frame: .zero)
        
        checkPermission()
        
        self.viewAlbumOption.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationPost(_:)), name: NSNotification.Name("CLOSE_LIST_PHOTO"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent && typeUpload == 0 {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = typeUpload == 0 ? "Choose Avatar" : "Choose Image"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func checkPermission() {
        let status = PHPhotoLibrary.authorizationStatus()

        switch status {
        case .authorized:
            fetchAllPhoto()
//            getAlbums()
        case .denied:
            print("\(TAG) - \(#function) - \(#line) - denied")

        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status2 in
                switch status2 {
                case .authorized:
                    print("\(self.TAG) - \(#function) - \(#line) - authorized -> lay anh")
                    self.fetchAllPhoto()
//                    self.getAlbums()
                case .denied, .restricted: break
                // as above
                case .notDetermined: break
                // won't happen but still
                @unknown default:
                    break
                }
            }

        case .restricted:
            print("\(TAG) - \(#function) - \(#line) - restricted")

        @unknown default:
            print("\(TAG) - \(#function) - \(#line) - default")
        }
    }
    
    func setupRightButton() {
        let uploadBtn = UIBarButtonItem(title: "Chọn", style: .done, target: self, action: #selector(eventChooseUploadImageCampaign(_:)))
        self.navigationItem.rightBarButtonItem = uploadBtn
    }
    
    @objc func notificationPost(_ sender:Notification) {
        print("\(TAG) - \(#function) - \(#line) - START")
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func eventChooseUploadImageCampaign(_ sender: UIBarButtonItem) {
        if typeUpload == 1 {
            delegate?.eventChooseImages(arrSelectedImage)
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func eventChooseBack(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc func eventChooseAlbum(_ sender:Any) {
        print("\(TAG) - \(#function) - \(#line) - click click")
        self.viewAlbumOption.isHidden = !self.viewAlbumOption.isHidden
        
    }
    
    @IBAction func eventChooseButtonSelect(_ sender:Any) {
        if let delegate = delegate {
            delegate.eventChooseImages(arrSelectedImage)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func fetchAllPhoto() {
        DispatchQueue.global(qos: .background).async {
            self.resetCachedAssets()
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            self.fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
            print("\(self.TAG) - \(#function) - \(#line) - self.fetchResult != nil")
            if self.arrAlbums.count == 0 {
                var imageThumb = UIImage(named: "Oval_Nomal")
                if let asset = self.fetchResult.firstObject {
                    self.imageManager.requestImage(for: asset, targetSize: self.thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { (image, info) in
                        let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                        if !isDegraded {
                            imageThumb = image
                            if var fistAlbum = self.arrAlbums.first, fistAlbum.collection == nil {
                                fistAlbum.imgThumb = imageThumb
                                self.arrAlbums[0] = fistAlbum
                                print("\(self.TAG) - \(#function) - \(#line) - thay the anh")
                                DispatchQueue.main.async {
                                    self.tblAlbum.reloadData()
                                }
                            }
                        }
                    })
                }
                self.arrAlbums.append(Album(collection: nil, imgThumb: imageThumb, countPhoto: self.fetchResult.count))
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func fetchPhotosCollection(_ collection:PHAssetCollection) {
        resetCachedAssets()
        self.fetchResult = PHAsset.fetchAssets(in: collection, options: nil)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    // MARK: UIScrollView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }

    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    // MARK: Asset Caching
    fileprivate func updateCachedAssets() {
         // Update only if the view is visible.
         guard isViewLoaded && view.window != nil else { return }

         // The preheat window is twice the height of the visible rect.
         let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
         let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)

         // Update only if the visible area is significantly different from the last preheated area.
         let delta = abs(preheatRect.midY - previousPreheatRect.midY)
         guard delta > view.bounds.height / 3 else { return }

         // Compute the assets to start caching and to stop caching.
         let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
         let addedAssets = addedRects
             .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
             .map { indexPath in fetchResult.object(at: indexPath.item) }
         let removedAssets = removedRects
             .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
             .map { indexPath in fetchResult.object(at: indexPath.item) }

         // Update the assets the PHCachingImageManager is caching.
         imageManager.startCachingImages(for: addedAssets,
             targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
         imageManager.stopCachingImages(for: removedAssets,
             targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        previousPreheatRect = preheatRect
     // Store the preheat rect to compare against in the future.
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                    width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                    width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                      width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                      width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
    func getAlbums() {
        DispatchQueue.global(qos: .background).async {
            let fetchOptions = PHFetchOptions()
            let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: fetchOptions)
            let albums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
//            var results: [Album] = []
            [smartAlbums, albums].forEach {
                $0.enumerateObjects { collection, index, stop in
                    print("\(self.TAG) - \(#function) - \(#line) - index : \(index) - \(String(describing: collection.localizedTitle))")
                    
                    let assetsFetchOptions = PHFetchOptions()
                    assetsFetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
                    let fetchedAssets = PHAsset.fetchAssets(in: collection, options: assetsFetchOptions)
                    var imageThumb = UIImage(named: "Oval_nomal")
                    if let asset = fetchedAssets.lastObject {
                        self.imageManager.requestImage(for: asset, targetSize: self.thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { (image, info) in
                            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                            if !isDegraded {
                                imageThumb = image
                                if let indexAlbum = self.arrAlbums.firstIndex(where: { (album) -> Bool in
                                    return album.collection?.localIdentifier == collection.localIdentifier
                                }) {
                                    var album = self.arrAlbums[indexAlbum]
                                    album.imgThumb = imageThumb
                                    self.arrAlbums[indexAlbum] = album
                                    DispatchQueue.main.async {
                                        self.tblAlbum.reloadData()
                                    }
                                }
                            }
                            
                        })
                    }
                    self.arrAlbums.append(Album(collection: collection, imgThumb: imageThumb, countPhoto: fetchedAssets.count))
                    DispatchQueue.main.async {
                        self.tblAlbum.reloadData()
                    }
                }
            }

        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navigationItem.title = ""
    }
}

extension ListPhotosViewController : PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        if fetchResult == nil {
            return
        }
        guard let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }

        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.
            fetchResult = changes.fetchResultAfterChanges
            if changes.hasIncrementalChanges {
                // If we have incremental diffs, animate them in the collection view.
                guard let collectionView = self.collectionView else { fatalError() }
                collectionView.performBatchUpdates({
                    // For indexes to make sense, updates must be in this order:
                    // delete, insert, reload, move
                    if let removed = changes.removedIndexes, removed.count > 0 {
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, inserted.count > 0 {
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let changed = changes.changedIndexes, changed.count > 0 {
                        collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                to: IndexPath(item: toIndex, section: 0))
                    }
                })
            } else {
                // Reload the collection view if incremental diffs are not available.
                self.collectionView.reloadData()
            }
            resetCachedAssets()
        }
    }
}

extension ListPhotosViewController : UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: widthCell, height: widthCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult != nil ? fetchResult.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? PhotoCollectionViewCell {
            let asset = fetchResult.object(at: indexPath.item)
            let idImage = asset.localIdentifier
            cell.representedAssetIdentifier = idImage
            imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                if cell.representedAssetIdentifier == idImage {
                    cell.thumbnailImage = image
                }
            })
            if let index = self.arrSelectedImage.firstIndex(where: { (item) -> Bool in
                return item.imageID == idImage
            }) {
                cell.viewSelected.isHidden = false
                cell.lblIndex.text = "\(index + 1)"
            } else {
                cell.viewSelected.isHidden = true
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        
        
        return cell
    }
    
    func updateNumSelected(_ cell:PhotoCollectionViewCell, index:Int) {
//        cell.lblNumSelected.text = index > -1 ? "\(index)" : nil
//        cell.imgvSelected.image = index > -1 ? UIImage(named: "Oval-Red") : UIImage(named: "Oval-Nomal")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = fetchResult.object(at: indexPath.item)
        DispatchQueue.global(qos: .background).async {
            let imageManager = PHCachingImageManager()
            imageManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: nil, resultHandler: { (image, info) in
                if let imageResult = image {
                    let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
                    if !isDegraded {
                        if self.typeUpload == 1 {
                            var isAdd = false
                            let idImage = asset.localIdentifier
                            if let index = self.arrSelectedImage.firstIndex(where: { (item) -> Bool in
                                return item.imageID == idImage
                            }) {
                                self.arrSelectedImage.remove(at: index)
                            } else {
                                if self.arrSelectedImage.count < self.MAX_IMAGES {
                                    isAdd = true
                                    let itemSelect = ItemImageSelect(imageID: asset.localIdentifier, image: imageResult, imageAsset: asset)
                                    self.arrSelectedImage.append(itemSelect)
                                } else {
                                    self.showErrorAlertView("Số ảnh sản phẩm tối đa là: \(self.MAX_IMAGES)")
                                    return
                                }
                            }
                            
                            DispatchQueue.main.async {
                                if isAdd {
                                    collectionView.reloadItems(at: [indexPath])
                                } else {
                                    let arrIndexPath = collectionView.indexPathsForVisibleItems
                                    collectionView.reloadItems(at: arrIndexPath)
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                let cropViewController = CropViewController(croppingStyle: .circular, image: imageResult)
                                cropViewController.delegate = self
                                self.present(cropViewController, animated: true, completion: nil)
                            }
                        }
                    }
                }
            })
        }
    }
}

extension ListPhotosViewController : CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true, completion: {
            print("\(self.TAG) - \(#function) - \(#line) - dismiss CropViewController")
//            DispatchQueue.main.async {
//                self.progressHUD.showInViewWithNavigationBar(self.navigationController!, message: "Cập nhật ảnh...")
//            }
//            self.uploadImage(image, type: "avatar") { (response) in
//                switch response.result {
//                case .success:
//                    if let data = response.data {
//                        do {
//                            let json = try JSON(data: data)
//                            print("\(self.TAG) - \(#function) - \(#line) - userInfo : \(json)")
//                            if let message = json["message"].string {
//                                self.hideProgress()
//                                self.showAlertController(message)
//                            }
//                            else if let idAvatar = json["file_id"].int, let urlAvatar = json["url"].string {
//                                self.appDelegate.userBee?.avatar = urlAvatar
//                                Tools.saveUserInfo(self.appDelegate.userBee!)
//                                self.updateAvatarProfile(idAvatar)
//                            }
//                        } catch  {
//                            print("\(self.TAG) - \(#function) - \(#line) - error : \(error.localizedDescription)")
//                            self.hideProgress()
//                        }
//                    }
//                case let .failure(error):
//                    print("\(self.TAG) - \(#function) - \(#line) - error : \(error.localizedDescription)")
//                }
//            }
        })
    }
    
    func hideProgress() {
        DispatchQueue.main.async {
            self.progessHUD.hide()
        }
    }
    
    func updateAvatarProfile(_ idAvatar: Int) {
//        guard let user = self.appDelegate.userBee else {
//            self.hideProgress()
//            return
//        }
//        let parameter = UserInfoUpdate(fullName: user.fullName, birthyear: user.birthyear, address: user.address, country: user.country, phone: user.phone, files: Avatar(avatar: idAvatar), account: user.account)
//
//        let headers: HTTPHeaders = [
//            "Api-Name": "api_update_profile",
//            "Accept": "application/json",
//            "Content-Type": "application/json",
//            "Authorization":"Bearer \(user.accessToken)",
//            "Accept-Language": Tools.language
//        ]
//
//        AF.request(Tools.HEADER_URL + "user/update_profile", method: .post, parameters: parameter, encoder: JSONParameterEncoder.default, headers: headers, interceptor: nil).responseJSON { response in
//            self.hideProgress()
//            switch response.result {
//            case .success:
//                if let data = response.data {
//                    do {
//                        let json = try JSON(data: data)
//                        print("\(self.TAG) - \(#function) - \(#line) - userInfo : \(json)")
//                        if let message = json["message"].string {
//                            self.showAlertController(message)
//                        } else {
//                            DispatchQueue.main.async {
//                                self.navigationController?.popViewController(animated: true)
//                            }
//                        }
//                    } catch let error {
//                        print("\(self.TAG) - \(#function) - \(#line) - error : \(error)")
//                        self.showAlertError()
//                    }
//                }
//            case let .failure(error):
//                print("\(self.TAG) - \(#function) - \(#line) - error : \(error)")
//                self.showAlertError()
//            }
//        }
    }
}


extension ListPhotosViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrAlbums.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumOptionsCell", for: indexPath) as! AlbumOptionsCell
        let album = arrAlbums[indexPath.row]
        if indexPath.row == 0 {
            cell.lblAlbumName.text = NSLocalizedString("All Photos", comment: "")
        } else {
            cell.lblAlbumName.text = album.collection?.localizedTitle
        }
        cell.thumbnailImage = album.imgThumb
        cell.lblPhotosCount.text = "\(album.countPhoto)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewAlbumOption.isHidden = true
        if indexAlbum == indexPath.row {
            return
        }
        indexAlbum = indexPath.row
        if indexPath.row == 0 {
            self.fetchAllPhoto()
        } else {
            let album = arrAlbums[indexPath.row]
            guard let collection = album.collection else { return }
            self.fetchPhotosCollection(collection)
        }
    }
}
