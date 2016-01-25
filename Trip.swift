//
//  Trip.swift
//  MapMyTrip
//
//  Created by Shuchi Muley on 1/25/16.
//  Copyright © 2016 Shuchi. All rights reserved.
//

import Foundation

class Trip: NSObject {
    var title:String = ""
    var places:[Place] = []
    
    init(title:String, places:[Place]) {
        self.title = title
        self.places = places
    }
}