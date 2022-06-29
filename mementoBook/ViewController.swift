//
//  ViewController.swift
//  mementoBook
//
//  Created by Turgay Ceylan on 29.06.2022.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIApplicationDelegate{

    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var shortDescInput: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var chosenLatitude : Double = 0.0
    var chosenLongitude : Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        /*
         Varolan lokasyonumuz ne kadar doğru olsun?
         Doğruluk arttıkça pil tüketimi de artar.
         1km olarak belirledik.
         */
        
        locationManager.requestWhenInUseAuthorization()
        /* App sürekli mi yeri takip etsin yoksa kullanırken mi*/
        locationManager.startUpdatingLocation()
        
        let gestureRecoginzer = UILongPressGestureRecognizer(target: self, action: #selector(pressedLocation(gestureRecognizer:)))
        
        // 2sn. basarsa algıla
        gestureRecoginzer.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecoginzer)
        
    }
    
    // Lokasyon her güncellendiğinde çalışır
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Koordinatları aldık
        let coordinats = locations[0].coordinate
        // Enlem ve boylamı aldık
        let lat = coordinats.latitude
        let long = coordinats.longitude
        chosenLatitude = lat
        chosenLongitude = long
        // Lokasyona enlem ve boylamı parametre olarak verdik
        let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
        // Span ile haritanın yakınlığını ayarladık (0.1=yakın, 1=uzak)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        // Bölgenin konumunu ve uzaklığını belirledik
        let region = MKCoordinateRegion(center: location,span: span)
        mapView.setRegion(region, animated: true)
    }

    func getAlertToBack(title : String, description: String){
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        let alertOKButton = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(alertOKButton)
        self.present(alert, animated: true)
    }

    
    @objc func pressedLocation(gestureRecognizer: UILongPressGestureRecognizer){
        // Dokunulduysa
        if gestureRecognizer.state == .began {
            let touchedPoint = gestureRecognizer.location(in: mapView)
            let touchedCoordinates = mapView.convert(touchedPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = nameInput.text
            annotation.subtitle = shortDescInput.text
            chosenLatitude = touchedCoordinates.latitude
            chosenLongitude = touchedCoordinates.longitude
            mapView.addAnnotation(annotation)
        }
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        newPlace.setValue(nameInput.text, forKey: "title")
        newPlace.setValue(shortDescInput.text, forKey: "subtitle")
        newPlace.setValue(chosenLatitude, forKey: "latitude")
        newPlace.setValue(chosenLongitude, forKey: "longitude")
        newPlace.setValue(UUID(), forKey: "id")
        do{
            try context.save()
            print("success")
            getAlertToBack(title: "Eklendi", description: "Konum deftere eklendi")
            
        }catch{
            print("insert error")
        }
        
    }
    

}

