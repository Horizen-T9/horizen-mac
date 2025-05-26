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
                TextField("Unique Identifier", text: $viewModel.uuid)
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

                Button {
                    viewModel.generateQRCodeImage()
                } label: {
                    Image(systemName: "qrcode")
                }
            }

//            TextField("Most significant value", value: $viewModel.major, formatter: viewModel.majorMinorFormatter)
//                .disabled(viewModel.isStarted)
            
//            TextField("Least significant value", value: $viewModel.minor, formatter: viewModel.majorMinorFormatter)
//                .disabled(viewModel.isStarted)
            
//            TextField("Power", value: $viewModel.power, formatter: viewModel.powerFormatter)
//                .disabled(viewModel.isStarted)
//            Text(viewModel.status)

            Button {
                viewModel.startStop()
            } label: {
                Spacer()
                Text(viewModel.isStarted ? "Turn iBeacon off" : "Turn iBeacon on")
                Spacer()
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
