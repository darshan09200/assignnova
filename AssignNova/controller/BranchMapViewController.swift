//
//  BranchMapViewController.swift
//  AssignNova
//
//  Created by simran mehra on 2023-03-20.
//

import UIKit
import GoogleMaps
import GooglePlaces
import FloatingPanel
class BranchMapViewController: UIViewController, FloatingPanelControllerDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let camera = GMSCameraPosition(latitude: 1.285, longitude: 103.848, zoom: 12)
                let mapView = GMSMapView(frame: .zero, camera: camera)
                self.view = mapView
        
        let fpc = FloatingPanelController()
        fpc.delegate = self
        
        guard let secondVC = storyboard?.instantiateViewController(withIdentifier: "BranchList") as? SecondViewController
        else{
            return
        }
        fpc.set(contentViewController: secondVC)
        fpc.addPanel(toParent: self)
    }

       
   }
  





