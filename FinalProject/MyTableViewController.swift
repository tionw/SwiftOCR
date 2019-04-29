//
//  MyTableViewController.swift
//  FinalProject
//
//  Created by user150978 on 4/29/19.
//  Copyright © 2019 Tion. All rights reserved.
//

import UIKit

class MyTableViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var datas: Datas!
    var datas1: DataInfo!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        datas = Datas()
        if datas1 == nil{
            datas1 = DataInfo()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        datas.loadData {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue"{
            let destination = segue.destination as! UINavigationController
            let detail = destination.viewControllers.first as! TableDetailViewController
            let selectedIndex = tableView.indexPathForSelectedRow!
            detail.dataInfo = datas.dataArray[selectedIndex.row]
        }
            
    }
    
}

extension MyTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyTableViewCell
        cell.configureCell(data: datas.dataArray[indexPath.row])
        return cell
    }
}
