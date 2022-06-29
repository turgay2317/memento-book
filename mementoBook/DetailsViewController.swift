//
//  DetailsViewController.swift
//  mementoBook
//
//  Created by Turgay Ceylan on 29.06.2022.
//

import UIKit
import CoreData
import MapKit

class DetailsViewController: UIViewController, MKMapViewDelegate{

    var chosenPlaceID : UUID?
    var chosenPlaceTitle : String = ""
    var chosenPlaceSubtitle : String = ""
    var chosenPlaceLatitude : Double = 0.0
    var chosenPlaceLongitude : Double = 0.0
    
    @IBOutlet weak var mapViewDetail: MKMapView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapViewDetail.delegate = self
        getResultbyUUID()
        showDetails()
    }
    
    func getResultbyUUID(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let specialPredicate = NSPredicate(format: "id = %@",chosenPlaceID!.uuidString)
        let fetching = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        fetching.predicate = specialPredicate
        
        fetching.returnsObjectsAsFaults = false
        do{
            let results = try context.fetch(fetching)
        
            for result in results as! [NSManagedObject] {
                chosenPlaceTitle = result.value(forKey: "title") as! String
                chosenPlaceSubtitle = result.value(forKey: "subtitle") as! String
                chosenPlaceLatitude = result.value(forKey: "latitude") as! Double
                chosenPlaceLongitude = result.value(forKey: "longitude") as! Double
            }
            
        }catch{
            print("selecting error on detail layout")
        }
        
    }
    
    func showDetails(){
        titleLabel.text = chosenPlaceTitle
        subtitleLabel.text = chosenPlaceSubtitle
        
        let location = CLLocationCoordinate2D(latitude: chosenPlaceLatitude, longitude: chosenPlaceLongitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location,span: span)
        mapViewDetail.setRegion(region, animated: true)
        
    }
    

}
