//
//  UUIDGen.swift
//  BeaconEmitter
//
//  Created by Haniif Ahmad C on 26/05/2025.
//

import Foundation

func CustomUUIDGen() -> UUID {
    // Replace non-hex characters with hex-friendly lookalikes
    let part1 = "a0b1c3d2"    // 8 characters (like H0R1Z3N2)
    let part2 = "af1c"        // 4 characters (like FR1Z)
    let part3 = "a4b6"        // 4 characters (like P4N6)
    let part4 = "d0c4"        // 4 characters (like DWk4)
    let part5 = randomHex(count: 12)

    let formatted = "\(part1)-\(part2)-\(part3)-\(part4)-\(part5)"
    return UUID(uuidString: formatted)!
}

func randomHex(count: Int) -> String {
    let hexChars = "0123456789abcdef"
    return String((0..<count).compactMap { _ in hexChars.randomElement() })
}
