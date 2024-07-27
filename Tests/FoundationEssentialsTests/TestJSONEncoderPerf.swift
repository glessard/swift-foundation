//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2022 - 2024 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import FoundationEssentials
import XCTest

#if FOUNDATION_FRAMEWORK
private typealias JSONEncoder = Foundation.JSONEncoder
private typealias Data = Foundation.Data
#else
private typealias JSONEncoder = FoundationEssentials.JSONEncoder
private typealias Data = FoundationEssentials.Data
#endif

private enum MissingResource: Error {
  case name(String)
}

class TestJSONEncoderPerf : XCTestCase {

    struct CoordinateFormat : Codable, Equatable {
        struct CoordinateDescription : Codable, Equatable {
            struct Coordinate : Codable, Equatable {
                let lat : Double
                let long : Double

                init(from decoder: Decoder) throws {
                    var container = try decoder.unkeyedContainer()
                    lat = try container.decode(Double.self)
                    long = try container.decode(Double.self)
                }
                
                func encode(to encoder: Encoder) throws {
                    var container = encoder.unkeyedContainer()
                    try container.encode(lat)
                    try container.encode(long)
                }
            }

            let coordinateLists : [[Coordinate]]

            init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()
                var result = [[Coordinate]]()
                while !container.isAtEnd {
                    try result.append(container.decode([Coordinate].self))
                }
                self.coordinateLists = result
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.unkeyedContainer()
                for list in coordinateLists {
                    try container.encode(list)
                }
            }
        }
        struct CoordinateGeometry : Codable, Equatable {
            let coordinates: CoordinateDescription
        }
        struct CoordinateFeature : Codable, Equatable {
            let geometry : CoordinateGeometry
        }

        let features : [CoordinateFeature]
    }

  func testTestBundle() throws {
    let url = Bundle.module.path(forResource: "canada", ofType: "json")
    print(url ?? "nil")

    let data = testData(forResource: "canada", withExtension: "json")
    print(data?.count ?? -1)
  }

    func test_encode_canada() throws {
        guard let data = testData(forResource: "canada", withExtension: "json") else {
            throw MissingResource.name("canada.json")
        }
        let canada = try JSONDecoder().decode(CoordinateFormat.self, from: data)
        
        measure {
            for _ in 0..<20 {
                let _ = try! JSONEncoder().encode(canada)
            }
        }
    }
    
    private let sortingEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }()
    
    private let prettyEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        return encoder
    }()
    
    func test_encode_canada_sorted() throws {
        guard let data = testData(forResource: "canada", withExtension: "json") else {
            throw MissingResource.name("canada.json")
        }
        let canada = try JSONDecoder().decode(CoordinateFormat.self, from: data)
        
        measure {
            for _ in 0..<20 {
                let _ = try! sortingEncoder.encode(canada)
            }
        }
    }
    
    func test_encode_canada_pretty() throws {
        guard let data = testData(forResource: "canada", withExtension: "json") else {
            throw MissingResource.name("canada.json")
        }
        let canada = try JSONDecoder().decode(CoordinateFormat.self, from: data)
        
        measure {
            for _ in 0..<20 {
                let _ = try! prettyEncoder.encode(canada)
            }
        }
    }

    func test_decode_canada() throws {
        guard let data = testData(forResource: "canada", withExtension: "json") else {
            throw MissingResource.name("canada.json")
        }

        measure {
            for _ in 0..<20 {
                let _ = try! JSONDecoder().decode(CoordinateFormat.self, from: data)
            }
        }
    }

    struct TwitterArchive : Codable, Equatable {
        let statuses : [Status]

        struct Status : Codable, Equatable {
            let id : UInt64
            let lang : String
            let text : String
            let source : String
            let metadata : [String:String]
            let user : User
            let place : String?
        }

        struct StatusEntities : Codable, Equatable {
            let hashtags : [Hashtag]
            let media : [MediaItem]
        }

        struct Hashtag : Codable, Equatable {
            let indices : [UInt64]
            let text : String
        }

        struct MediaItem : Codable, Equatable {
            let display_url : String
            let expanded_url : String
            let id : UInt64
            let indices : [UInt64]
            let media_url : String
            let source_status_id : UInt64
            let type : String
            let url : String

            struct Size : Codable, Equatable {
                let h : UInt64
                let w : UInt64
                let resize : String
            }
            let sizes : [String:Size]
        }

        struct User : Codable, Equatable {
            let created_at : String
            let default_profile : Bool
            let description : String
            let favourites_count : UInt64
            let followers_count : UInt64
            let friends_count : UInt64
            let id : UInt64
            let lang : String
            let name : String
            let profile_background_color : String
            let profile_background_image_url : String
            let profile_banner_url : String?
            let profile_image_url : String?
            let profile_use_background_image : Bool
            let screen_name : String
            let statuses_count : UInt64
            let url : String?
            let verified: Bool
        }
    }
    
    func test_encode_twitter() throws {
        guard let data = testData(forResource: "twitter", withExtension: "json") else {
            throw MissingResource.name("twitter.json")
        }
        let twitter = try JSONDecoder().decode(TwitterArchive.self, from: data)
        
        measure {
            for _ in 0..<100 {
                let _ = try! JSONEncoder().encode(twitter)
            }
        }
    }
    
    func test_encode_twitter_sorted() throws {
        guard let data = testData(forResource: "twitter", withExtension: "json") else {
            throw MissingResource.name("twitter.json")
        }
        let twitter = try JSONDecoder().decode(TwitterArchive.self, from: data)
        
        measure {
            for _ in 0..<25 {
                let _ = try! sortingEncoder.encode(twitter)
            }
        }
    }
    
    func test_encode_twitter_pretty() throws {
        guard let data = testData(forResource: "twitter", withExtension: "json") else {
            throw MissingResource.name("twitter.json")
        }
        let twitter = try JSONDecoder().decode(TwitterArchive.self, from: data)
        
        measure {
            for _ in 0..<100 {
                let _ = try! prettyEncoder.encode(twitter)
            }
        }
    }

    func test_decode_twitter() throws {
        guard let data = testData(forResource: "twitter", withExtension: "json") else {
            throw MissingResource.name("twitter.json")
        }

        measure {
            for _ in 0..<100 {
                let _ = try! JSONDecoder().decode(TwitterArchive.self, from: data)
            }
        }
    }

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
    
    func test_encode_catalog() throws {
        guard let data = testData(forResource: "citm_catalog", withExtension: "json") else {
            throw MissingResource.name("citm_catalog.json")
        }
        let catalog = try JSONDecoder().decode(Catalog.self, from: data)
        
        measure {
            for _ in 0..<100 {
                let _ = try! JSONEncoder().encode(catalog)
            }
        }
    }
    
    func test_encode_catalog_sorted() throws {
        guard let data = testData(forResource: "citm_catalog", withExtension: "json") else {
            throw MissingResource.name("citm_catalog.json")
        }
        let catalog = try JSONDecoder().decode(Catalog.self, from: data)
        
        measure {
            for _ in 0..<100 {
                let _ = try! sortingEncoder.encode(catalog)
            }
        }
    }
    
    func test_encode_catalog_pretty() throws {
        guard let data = testData(forResource: "citm_catalog", withExtension: "json") else {
            throw MissingResource.name("citm_catalog.json")
        }
        let catalog = try JSONDecoder().decode(Catalog.self, from: data)
        
        measure {
            for _ in 0..<100 {
                let _ = try! prettyEncoder.encode(catalog)
            }
        }
    }

    func test_decode_catalog() throws {
        guard let data = testData(forResource: "citm_catalog", withExtension: "json") else {
            throw MissingResource.name("citm_catalog.json")
        }

        measure {
            for _ in 0..<100 {
                let _ = try! JSONDecoder().decode(Catalog.self, from: data)
            }
        }
    }
    
    func test_encode_matrix() throws {
        let matrix = [
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,
            0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,
            0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,
            0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        ]
        
        measure {
            for _ in 0..<1000 {
                let _ = try! JSONEncoder().encode(matrix)
            }
        }
    }

    func test_decode_matrix() throws {
        func exampleData() -> Data {
            var json = """
    [
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,
    0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,
    0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,
    0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    ]
    """
            return json.withUTF8 { buf in
                return Data(buffer: buf)
            }
        }

        let data = exampleData()

        measure {
            for _ in 0..<1000 {
                let _ = try! JSONDecoder().decode([UInt8].self, from: data)
            }
        }
    }
    
    func test_encode_many_strings() throws {
        let strings = Array(repeating: "test", count: 1000)
        
        measure {
            for _ in 0..<1000 {
                let _ = try! JSONEncoder().encode(strings)
            }
        }
    }
    
    func test_encode_many_strings_pretty() throws {
        let strings = Array(repeating: "test", count: 1000)
        
        measure {
            for _ in 0..<1000 {
                let _ = try! prettyEncoder.encode(strings)
            }
        }
    }
    
    func test_encode_many_small_string_arrays() throws {
        let arrays = Array(repeating: ["test", "test2", "test3", "test4", "test5"], count: 1000)
        
        measure {
            for _ in 0..<1000 {
                let _ = try! JSONEncoder().encode(arrays)
            }
        }
    }
    
    func test_encode_many_small_string_arrays_pretty() throws {
        let arrays = Array(repeating: ["test", "test2", "test3", "test4", "test5"], count: 1000)
        
        measure {
            for _ in 0..<1000 {
                let _ = try! prettyEncoder.encode(arrays)
            }
        }
    }
}
