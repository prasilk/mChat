//
//  MapsVC.swift
//  mChat
//
//  Created by Vitaliy Paliy on 1/8/20.
//  Copyright © 2020 PALIY. All rights reserved.
//

import UIKit
import Firebase
import Mapbox

class MapsVC: UIViewController, UIGestureRecognizerDelegate{
    
    var mapNetworking = MapsNetworking()
    var friends = [FriendInfo]()
    var isFriendSelected = false
    var selectedFriend = FriendInfo()
    var friendCoordinates = [String: CLLocationCoordinate2D]()
    
    var userInfoTab: UserInfoTab?
    var mapView = MGLMapView()
    var exitButton: MapExitButton!
    var settingsButton: MapSettingsButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkStatus()
        userMapHandler()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func checkStatus(){
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            setupMapView()
        case .denied:
            deniedAlertController()
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapNetworking.mapsVC = self
        mapNetworking.observeFriendsList()
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        if view.safeAreaInsets.top > 20 {
            exitButton = MapExitButton(mapsVC: self, topConst: 35)
            settingsButton = MapSettingsButton(mapsVC: self, topConstant: 35)
        }else{
            exitButton = MapExitButton(mapsVC: self, topConst: 20)
            settingsButton = MapSettingsButton(mapsVC: self, topConstant: 20)
        }
    }
        
    func setupMapView(){
        view.addSubview(mapView)
        mapView.frame = view.bounds
        mapView.automaticallyAdjustsContentInset = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: -8),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        mapView.styleURL = URL(string: "mapbox://styles/mapbox/streets-v11")
        mapView.delegate = self
        mapView.allowsRotating = false
        mapView.logoView.isHidden = true
        mapView.showsUserLocation = true
        
    }
    
    func userMapHandler(){
        if !ChatKit.mapTimer.isValid {
            print("Is Valid")
            ChatKit.map.showsUserLocation = true
            ChatKit.startUpdatingUserLocation()
        }
    }
    
    @objc func exitButtonPressed(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func openMapsSettings(){
        let controller = MapsSettingsVC()
        controller.isMapOpened = true
        present(UINavigationController(rootViewController: controller),animated: true, completion: nil)
    }
    
    @objc func openUserMessagesHandler(){
        let controller = ChatVC()
        controller.friend = selectedFriend
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func presentingVC() -> UIViewController {
        var topController: UIViewController = UIApplication.shared.windows[0].rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        return topController
    }
 
    func deniedAlertController(){
        let alertController = UIAlertController(title: "Error", message: "To be able to see the map you need to change your location settings. To do this, go to Settings/Privacy/Location Services/mChat/ and allow location access. ", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        present(alertController, animated: true, completion: nil)
    }
            
}