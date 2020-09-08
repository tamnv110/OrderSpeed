//
//  HomeViewController.swift
//  OrderSpeed
//
//  Created by Nguyen Van Tam on 9/4/20.
//  Copyright © 2020 Nguyen Van Tam. All rights reserved.
//

import UIKit

class HomeViewController: MainViewController {

    @IBOutlet weak var tbHome: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        createTableHeader()
        
        tbHome.tableFooterView = UIView(frame: .zero)
        tbHome.register(UINib(nibName: "BankInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "BankInfoTableViewCell")
        tbHome.register(UINib(nibName: "NEWSTableViewCell", bundle: nil), forCellReuseIdentifier: "NEWSTableViewCell")
        tbHome.register(UINib(nibName: "SupportMainCell", bundle: nil), forCellReuseIdentifier: "SupportMainCell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
//        navigationController?.navigationBar.barStyle = .black
//        navigationController?.navigationBar.backgroundColor = .clear
    }
    
    func setupNavigationBar() {
        let btnLeft = UIBarButtonItem(image: UIImage(named: "logo_home"), style: .done, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = btnLeft
        
        let btnNotification = UIBarButtonItem(image: UIImage(named: "icon_notification"), style: .done, target: self, action: #selector(eventChooseNotification(_:)))
        let btnSearch = UIBarButtonItem(image: UIImage(named: "icon_search"), style: .done, target: self, action: #selector(eventChooseSearch(_:)))
        self.navigationItem.rightBarButtonItems = [btnSearch, btnNotification]
        
        
    }
    
    func createTableHeader() {
        let header = HomeHeaderView.instanceFromNib()
        header.frame = CGRect(x: 0, y: 0, width: tbHome.frame.width, height: 316)
        tbHome.tableHeaderView = header
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let headerView = tbHome.tableHeaderView as? HomeHeaderView {
            var headerFrame = headerView.frame
            let newHeight = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            if newHeight != headerFrame.height {
                headerFrame.size.height = newHeight
                headerView.frame = headerFrame
                tbHome.tableHeaderView = headerView
            }
        }
    }
    
    @objc func eventChooseSearch(_ sender: UIBarButtonItem) {
        let vc = CustomAlertViewController(nibName: "CustomAlertViewController", bundle: nil)
        vc.modalPresentationStyle = .overFullScreen
        vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func eventChooseNotification(_ sender: UIBarButtonItem) {
        let vc = CreateOrderViewController(nibName: "CreateOrderViewController", bundle: nil)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 || section == 2 {
            return 1
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 390.0
        } else if indexPath.section == 2 {
            return 270.0
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 {
            return 60
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != 0 {
            let header = HomeHeaderSectionView.instanceFromNib()
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NEWSTableViewCell", for: indexPath) as! NEWSTableViewCell
            cell.lblTitle.text = "Đi chạy nào"
            cell.lblContent.text = "Nhật Bản là một trong những thị trường mang lại nhiều doanh thu nhất cho cửa hàng ứng dụng của Apple trong năm 2019."

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SupportMainCell", for: indexPath) as! SupportMainCell
            if indexPath.section == 1 {
                cell.typeShow = 1
            } else {
                cell.typeShow = 0
            }
            return cell
        }
    }
    
    
}
