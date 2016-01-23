//
//  Place.swift
//  MapMyTrip
//
//  Created by Shuchi Muley on 1/2/16.
//  Copyright © 2016 Shuchi. All rights reserved.
//

import MapKit

class Place : NSObject, MKAnnotation {
    var longitude: Double
    var latitude: Double
    var countryName: String!
    var sequenceOfVisit: Int = 0
    var pinColor:UIColor = UIColor()
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(latitude: Double, longitude: Double, pinColor: UIColor) {
        self.longitude = longitude
        self.latitude = latitude
        self.countryName = ""
        self.pinColor = pinColor
    }
}
