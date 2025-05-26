//
//  QRCodeOverlay.swift
//  BeaconEmitter
//
//  Created by Haniif Ahmad C on 25/05/2025.
//

import SwiftUI

struct QRCodeOverlayView: View {
    let qrCodeImage: NSImage
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.3)
            
            VStack {
                Image(nsImage: qrCodeImage)
                    .resizable()
                    .interpolation(.none)
                    .frame(width: 256, height: 256)
                    .background(Color.white)
                    .cornerRadius(12)

                Button("Close") {
                    onDismiss()
                }
                .padding(.top, 10)
            }
            .padding()
            .transition(.opacity)
        }
        .zIndex(1)
    }
}
