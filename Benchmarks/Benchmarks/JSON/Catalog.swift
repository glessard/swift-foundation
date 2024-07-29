//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2022-2024 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

//FIXME: mit license goes here

struct Catalog : Codable, Equatable {
    let areaNames : [String:String]
    let audienceSubCategoryNames : [String:String]
    let blockNames : [String:String]
    let events : [String:Event]
    let seatCategoryNames : [String:String]
    let subTopicNames : [String:String]
    let subjectNames : [String:String]
    let topicNames : [String:String]
    let topicSubTopics : [String:[UInt64]]
    let venueNames : [String:String]

    struct Event : Codable, Equatable {
        let description : String?
        let id : UInt64
        let logo : String?
        let name : String?
        let subTopicIds : [UInt64]
        let subjecftCode : String?
        let subtitle: String?
        let topicIDs : [UInt64]?
    }

    struct Performance : Codable, Equatable {
        let eventId : UInt64
        let id : UInt64
        let logo : String?
        let name : String?
        let prices : [[String:UInt64]]
        let seatCategories : [SeatCategory]
        let seatMapImage : String?
        let start : UInt64
        let venueCode : String

        struct SeatCategory : Codable, Equatable {
            let seatCategoryId : UInt64
            let areas : [SeatArea]
        }

        struct SeatArea : Codable, Equatable {
            let areaId : UInt64
            let blockIds : [UInt64]
        }
    }
}
