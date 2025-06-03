//
//  BeaconEmitterView.swift
//  BeaconEmitter
//
//  Created by Laurent Gaches.
//

import SwiftUI

struct BeaconEmitterView: View {
    @StateObject var viewModel = BeaconEmitterViewModel()

    var body: some View {
        ZStack {
            mainForm
            
            if viewModel.isShowingQRCode, let qr = viewModel.qrCodeImage {
                            QRCodeOverlayView(qrCodeImage: qr) {
                                viewModel.dismissQRCode()
                            }
                        }
                    }
                    .animation(.easeInOut, value: viewModel.isShowingQRCode)
        }
    
    // MARK: Beacon Form
    var mainForm: some View {
        Form {
            HStack {
                TextField("Unique Identifier*", text: $viewModel.uuid)
                    .disabled(true)

                Button {
                    viewModel.refreshUUID()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(viewModel.isStarted)

                Button {
                    viewModel.copyPaste()
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .disabled(viewModel.isStarted)

            }

            TextField("Beacon Label*", text: $viewModel.beaconLabel)
                .disabled(viewModel.isStarted)
            
            HStack {
                Button {
                    viewModel.startStop()
                    NSApplication.shared.keyWindow?.makeFirstResponder(nil)
                } label: {
                    Spacer()
                    Text(viewModel.isStarted ? "Turn Beacon off" : "Turn Beacon on")
                    Spacer()
                }
                
                Button {
                    viewModel.generateQRCodeImage()
                } label: {
                    Image(systemName: "qrcode")
                }
                .disabled(!viewModel.isStarted)
                .help(!viewModel.isStarted ? "You can't generate a QR code until the beacon is turned on" : "")
            }
            
            .alert(isPresented: $viewModel.isShowingAlert){
                Alert(title: Text("Warning"), message: Text(viewModel.status), dismissButton: .default(Text("Okay")))
            }
        }
        .padding()
        .blur(radius: viewModel.isShowingQRCode ? 2 : 0)
        .onDisappear {
            viewModel.save()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BeaconEmitterView()
    }
}
