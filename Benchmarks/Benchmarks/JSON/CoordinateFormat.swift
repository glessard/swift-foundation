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
