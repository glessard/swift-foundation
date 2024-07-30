//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2024 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import Foundation

package enum MissingResource: Error {
  case named(String)
}

package func testData(
  named resource: String, extension ext: String, subdirectory: String? = nil
) throws -> [UInt8] {
#if FOUNDATION_FRAMEWORK
    guard let url = Bundle(for: Canary.self).url(forResource: resource, withExtension: ext, subdirectory: subdirectory) else {
        return nil
    }
    return try Array(Data(contentsOf: url))
#else
#if os(macOS)
    let subdir: String
    if let subdirectory {
        subdir = "Resources/" + subdirectory
    } else {
        subdir = "Resources"
    }

    guard let url = Bundle.module.url(forResource: resource, withExtension: ext, subdirectory: subdir) else {
        throw MissingResource.named("\(resource).\(ext)")
    }

    return try Array(Data(contentsOf: url))
#else
    // swiftpm drops the resources next to the executable, at:
    // ./FoundationPreview_FoundationEssentialsTests.resources/Resources/
    // Hard-coding the path is unfortunate, but a temporary need until we have a better way to handle this
    var path = URL(filePath: ProcessInfo.processInfo.arguments[0])
        .deletingLastPathComponent()
        .appending(component: "FoundationPreview_FoundationEssentialsTests.resources", directoryHint: .isDirectory)
        .appending(component: "Resources", directoryHint: .isDirectory)
    if let subdirectory {
        path.append(path: subdirectory, directoryHint: .isDirectory)
    }
    path.append(component: resource + "." + ext, directoryHint: .notDirectory)
    return try? Data(contentsOf: path)
#endif
#endif
}
