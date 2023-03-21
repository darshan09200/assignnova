//
//  HomeScreenViewController.swift
//  AssignNova
//
//  Created by simran mehra on 2023-03-21.
//

import UIKit

class HomeScreenViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
   
    
let data =
    ["shift 1",
     "shift 1",
     "shift 1",
     "shift 1",
     "shift 1"
    ]
    @IBOutlet weak var NextShiftTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.NextShiftTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view.
        NextShiftTable.delegate = self
        NextShiftTable.dataSource = self
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    @IBAction func AddBranchBtn(_ sender: Any) {
        
    }
    
    @IBAction func AddRoleBtn(_ sender: Any) {
    }
    
    @IBAction func AddEmployeeBtn(_ sender: Any) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
