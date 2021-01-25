//
//  CodingUserInfoKeyExtension.swift
//  CoreDataCodable
//
//  Created by Preetam Jadakar on 24/01/21.
//

import Foundation

public extension CodingUserInfoKey {
    // Helper property to retrieve the Core Data managed object context
    static let managedObjectContext = CodingUserInfoKey(rawValue: "context")
}
