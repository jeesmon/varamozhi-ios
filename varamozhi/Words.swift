//
//  Words.swift
//  MalayalamEditor
//
//  Created by jijo on 3/25/15.
//  Copyright (c) 2015 jeesmon. All rights reserved.
//

import Foundation
import CoreData

class Words: NSManagedObject {

    @NSManaged var word: String
    @NSManaged var popularity: NSNumber
    @NSManaged var count: NSNumber

}
