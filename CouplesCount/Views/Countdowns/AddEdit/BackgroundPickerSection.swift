import SwiftUI
import PhotosUI
import AVFoundation
import UIKit

struct BackgroundPickerSection: View {
    @Environment(\.theme) private var theme
    @Binding var backgroundStyle: String
    @Binding var colorHex: String
    @Binding var imageData: Data?

    @State private var showPhotoPicker = false
    @State private var showCamera = false

    var body: some View {
        SettingsCard {
            Text("Background")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(theme.color(.MutedForeground))

            Picker("Style", selection: $backgroundStyle) {
                Text("Color").tag("color")
                Text("Image").tag("image")
            }
            .pickerStyle(.segmented)

            if backgroundStyle == "color" {
                HStack(spacing: 10) {
                    ForEach(["#0A84FF","#5856D6","#FF2D55","#34C759","#FF9F0A"], id: \.self) { hex in
                        Circle()
                            .fill(Color(hex: hex) ?? .blue)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle().stroke(theme.color(.Foreground).opacity(colorHex == hex ? 0.9 : 0), lineWidth: 2)
                            )
                            .onTapGesture { colorHex = hex }
                    }
                    Spacer()
                    ColorPicker("", selection: Binding(
                        get: { Color(hex: colorHex) ?? .blue },
                        set: { colorHex = $0.hexString }
                    ))
                    .labelsHidden()
                }
            } else {
                if let data = imageData, let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .accessibilityHidden(true)
                } else {
                    Text("No image selected")
                        .foregroundStyle(theme.color(.MutedForeground))
                }

                HStack(spacing: 12) {
                    Button {
                        PHPhotoLibrary.requestAuthorization { status in
                            if status == .authorized || status == .limited {
                                DispatchQueue.main.async { showPhotoPicker = true }
                            }
                        }
                    } label: { labelButton("Choose Photo", system: "photo") }

                    Button {
                        AVCaptureDevice.requestAccess(for: .video) { ok in
                            if ok { DispatchQueue.main.async { showCamera = true } }
                        }
                    } label: { labelButton("Camera", system: "camera") }
                }
            }
        }
        .sheet(isPresented: $showPhotoPicker) { PhotoPicker(imageData: $imageData) }
        .sheet(isPresented: $showCamera) { CameraPicker(imageData: $imageData) }
    }

    @ViewBuilder
    private func labelButton(_ title: String, system: String) -> some View {
        Label(title, systemImage: system)
            .foregroundStyle(theme.color(.Foreground))
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(theme.color(.Foreground).opacity(0.1))
            )
    }
}

