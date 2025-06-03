//
//  BeaconEmitterViewModel.swift
//  BeaconEmitter
//
//  Created by Laurent Gaches.
//

import AppKit
import CoreBluetooth
import CoreLocation
import Foundation
import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

class BeaconEmitterViewModel: NSObject, ObservableObject {
    @AppStorage("previousUUID") private var savedUUID: String?
    @AppStorage("major") private var savedMajor: Int?
    @AppStorage("minor") private var savedMinor: Int?
    @AppStorage("power") private var savedPower: Int?

    private var advertiseBeforeSleep: Bool = false
    var majorMinorFormatter = NumberFormatter()
    var powerFormatter = NumberFormatter()
    var emitter: CBPeripheralManager?

    @Published
    var isStarted: Bool = false

    @Published
    var uuid: String = CustomUUIDGen().uuidString
    
    @Published
    var beaconLabel: String = ""
    
    @Published
    var isShowingAlert: Bool = false

    @Published
    var major: UInt16 = 0

    @Published
    var minor: UInt16 = 0

    @Published
    var status: String = ""

    @Published
    var power: Int8 = -59
    
    @Published
    var qrCodeImage: NSImage?
    @Published
    var isShowingQRCode: Bool = false
    
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    override init() {
        super.init()

        loadSavedValue()

        emitter = CBPeripheralManager(delegate: self, queue: nil)

        majorMinorFormatter.allowsFloats = false
        majorMinorFormatter.maximum = NSNumber(value: UInt16.max)
        majorMinorFormatter.minimum = NSNumber(value: UInt16.min)

        powerFormatter.allowsFloats = false
        powerFormatter.maximum = NSNumber(value: Int8.max)
        powerFormatter.minimum = NSNumber(value: Int8.min)

        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(receiveSleepNotification), name: NSWorkspace.willSleepNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(receiveAwakeNotification), name: NSWorkspace.didWakeNotification, object: nil)
    }

    func startStop() {
        guard let emitter else { return }
        
        if !checkTextFieldValidity() {
            isShowingAlert.toggle()
            return
        }

        if emitter.isAdvertising {
            emitter.stopAdvertising()
            isStarted = false
        } else {
            if let proximityUUID = NSUUID(uuidString: uuid) {
                let region = BeaconRegion(proximityUUID: proximityUUID, major: major, minor: minor)
                emitter.startAdvertising(region.peripheralDataWithMeasuredPower())
            } else {
                status = "The UUID format is invalid"
            }
        }
    }

    func refreshUUID() {
        uuid = CustomUUIDGen().uuidString
    }
    
    func checkTextFieldValidity() -> Bool {
        if beaconLabel.trimmingCharacters(in: .whitespaces).isEmpty {
            status = "The text fields cannot be empty"
            return false
        }
        
        if beaconLabel.trimmingCharacters(in: .whitespaces).contains(";") {
            status = "The text fields cannot contain ';'"
            return false
        }
        return true
    }

    func copyPaste() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(uuid, forType: .string)
    }
    
    func generateQRCodeImage() {
        let qrRawString = "\(uuid);\(beaconLabel)"
        let data = Data(qrRawString.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            let transformed = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
            if let cgimg = context.createCGImage(transformed, from: transformed.extent) {
                let nsImage = NSImage(cgImage: cgimg, size: NSSize(width: 256, height: 256))
                DispatchQueue.main.async {
                    self.qrCodeImage = nsImage
                    self.isShowingQRCode = true
                }
            }
        } else {
            qrCodeImage = nil
            isShowingQRCode = false
        }
    }
    
    func dismissQRCode() {
        isShowingQRCode = false
    }

    @objc
    func receiveSleepNotification(_: Notification) {
        if let emitter, emitter.isAdvertising {
            advertiseBeforeSleep = true
            startStop()
        }
    }

    @objc
    func receiveAwakeNotification(_: Notification) {
        if advertiseBeforeSleep {
            startStop()
        }
    }

    func save() {
        savedUUID = uuid
        savedMajor = Int(major)
        savedMinor = Int(minor)
        savedPower = Int(power)
    }

    private func loadSavedValue() {
        if let savedUUID {
            uuid = savedUUID
        }

        if let savedMajor {
            major = UInt16(savedMajor)
        }

        if let savedMinor {
            minor = UInt16(savedMinor)
        }

        if let savedPower {
            power = Int8(savedPower)
        }
    }
}

extension BeaconEmitterViewModel: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOff:
            status = "Bluetooth is currently powered off"
        case .poweredOn:
            status = "Bluetooth is currently powered on and is available to use."
        case .unauthorized:
            status = "The app is not authorized to use the Bluetooth low energy peripheral/server role."
        case .unknown:
            status = "The current state of the peripheral manager is unknown; an update is imminent."
        case .resetting:
            status = "The connection with the system service was momentarily lost; an update is imminent."
        case .unsupported:
            status = "The platform doesn't support the Bluetooth low energy peripheral/server role."
        @unknown default:
            status = "The current state of the peripheral manager is unknown; an update is imminent."
        }
    }

    func peripheralManagerDidStartAdvertising(_: CBPeripheralManager, error _: Error?) {
        if let emitter, emitter.isAdvertising {
            isStarted = true
        }
    }
}
