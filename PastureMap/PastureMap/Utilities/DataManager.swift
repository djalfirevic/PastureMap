//
//  DataManager.swift
//  PastureMap
//
//  Created by Djuro Alfirevic on 3/9/18.
//  Copyright © 2018 Djuro Alfirevic. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import MapKit

class DataManager {
    
    // MARK: - Properties
    static let shared = DataManager()
    private init() {}
    
    // MARK: - Public API
    func savePasture(with name: String, coordinates: [CLLocationCoordinate2D]) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = delegate.persistentContainer.viewContext
        
        var array = [PastureCoordinate]()
        coordinates.forEach {
            let coordinate = NSEntityDescription.insertNewObject(forEntityName: "PastureCoordinate", into: context) as! PastureCoordinate
            coordinate.latitude = $0.latitude
            coordinate.longitude = $0.longitude
            array.append(coordinate)
        }
        
        let pasture = NSEntityDescription.insertNewObject(forEntityName: "Pasture", into: context) as! Pasture
        pasture.name = name
        pasture.coordinates = NSSet(array: array)
        
        do {
            try context.save()
        } catch {
            print("Saving error \(error.localizedDescription)")
        }
    }
    
    func getPolylines() -> [MKPolyline]? {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        let context = delegate.persistentContainer.viewContext
        
        var pastures = [Pasture]()
        let fetchRequest = NSFetchRequest<Pasture>(entityName: "Pasture")
        
        do {
            pastures = try context.fetch(fetchRequest)
        } catch {
            print("Fetching error \(error.localizedDescription)")
        }
        
        var polylines = [MKPolyline]()
        for pasture in pastures {
            polylines.append(pasture.polyline())
        }
        
        return polylines
    }
    
}
