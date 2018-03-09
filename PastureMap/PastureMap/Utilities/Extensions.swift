//
//  Extensions.swift
//  PastureMap
//
//  Created by Djuro Alfirevic on 3/9/18.
//  Copyright © 2018 Djuro Alfirevic. All rights reserved.
//

import UIKit
import MapKit

extension PastureCoordinate {
    
    func getCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
}

extension Pasture {
    
    func polyline() -> MKPolyline {
        var locationCoordinates = [CLLocationCoordinate2D]()
        
        if let coordinates = coordinates {
            for case let coordinate as PastureCoordinate in coordinates {
                locationCoordinates.append(coordinate.getCoordinate())
            }
        }
        
        return MKPolyline(coordinates: locationCoordinates, count: locationCoordinates.count)
    }
    
}
