//
//  HomeScreenViewController.swift
//  AssignNova
//
//  Created by simran mehra on 2023-04-03.
//

import UIKit

class HomeScreenViewController:  UIViewController, UITableViewDelegate ,UITableViewDataSource {
    
    let data =
        ["shift 1",
         "shift 1",
         "shift 1",
         "shift 1",
         "shift 1"
        ]
        @IBOutlet weak var NextShiftTable: UITableView!
        
    @IBOutlet weak var doYouKnow: UILabel!
    
        override func viewDidLoad() {
            super.viewDidLoad()
               self.NextShiftTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            doYouKnow.text = ActiveEmployee.instance?.factOfTheDay
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
            navigationController?.pushViewController(UIStoryboard(name: "Branch", bundle: nil).instantiateViewController(withIdentifier: "Branch"), animated: true)
        }
        
        @IBAction func AddRoleBtn(_ sender: Any) {
            navigationController?.pushViewController(UIStoryboard(name: "AddRole", bundle: nil).instantiateViewController(withIdentifier: "AddRole"), animated: true)
        }
        
        @IBAction func AddEmployeeBtn(_ sender: Any) {
            navigationController?.pushViewController(UIStoryboard(name: "AddEmployee", bundle: nil).instantiateViewController(withIdentifier: "AddEmployee"), animated: true)
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





