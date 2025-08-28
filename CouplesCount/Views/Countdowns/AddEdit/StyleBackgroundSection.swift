import SwiftUI
import PhotosUI
import AVFoundation
import UIKit

enum ColorCategory: String, CaseIterable, Identifiable {
    case pastels = "Pastels"
    case regular = "Regular"
    case gradients = "Gradients"
    var id: String { rawValue }
}

struct StyleBackgroundSection: View {
    @Binding var cardFontStyle: CardFontStyle
    @Binding var backgroundStyle: String
    @Binding var colorHex: String
    @Binding var imageData: Data?

    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var colorCategory: ColorCategory = .pastels

    private let pastelHexes = ["#FADADD", "#E0BBE4", "#FDE7D7", "#CDE7B0", "#D2E3FC"]
    private let regularHexes = ["#0A84FF","#5856D6","#FF2D55","#34C759","#FF9F0A"]
    private let gradientPairs: [[String]] = [["#0A84FF", "#5856D6"], ["#FF2D55", "#FF9F0A"], ["#34C759", "#0A84FF"]]

    var body: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Font", selection: $cardFontStyle) {
                    ForEach(CardFontStyle.allCases) { f in
                        Text(f.displayName).tag(f)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: cardFontStyle, initial: false) { _, _ in Haptics.light() }

                Picker("Style", selection: $backgroundStyle) {
                    Text("Colors").tag("color")
                    Text("Image").tag("image")
                }
                .pickerStyle(.segmented)
                .onChange(of: backgroundStyle, initial: false) { _, _ in Haptics.light() }

                if backgroundStyle == "color" {
                    Picker("", selection: $colorCategory) {
                        ForEach(ColorCategory.allCases) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: colorCategory, initial: false) { _, _ in Haptics.light() }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(currentSwatches, id: \.self) { swatch in
                                swatchView(for: swatch)
                            }
                        }
                        .padding(.vertical, 4)
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
                            .foregroundStyle(Color("Secondary"))
                    }

                    HStack(spacing: 12) {
                        Button { requestPhotos() } label: { labelButton("Choose Photo", system: "photo") }
                        Button { requestCamera() } label: { labelButton("Camera", system: "camera") }
                    }
                }
            }
        }
        .sheet(isPresented: $showPhotoPicker) { PhotoPicker(imageData: $imageData) }
        .sheet(isPresented: $showCamera) { CameraPicker(imageData: $imageData) }
    }

    private var currentSwatches: [String] {
        switch colorCategory {
        case .pastels: return pastelHexes
        case .regular: return regularHexes
        case .gradients: return gradientPairs.map { $0.joined(separator: ",") }
        }
    }

    @ViewBuilder
    private func swatchView(for hex: String) -> some View {
        let isSelected = colorHex.uppercased() == hex.uppercased()
        if hex.contains(",") {
            let parts = hex.split(separator: ",")
            let c1 = Color(hex: String(parts[0])) ?? .blue
            let c2 = Color(hex: String(parts[1])) ?? .purple
            RoundedRectangle(cornerRadius: 8)
                .fill(LinearGradient(colors: [c1, c2], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 44, height: 44)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color("Foreground").opacity(isSelected ? 0.9 : 0), lineWidth: 2))
                .onTapGesture {
                    colorHex = hex
                    Haptics.light()
                }
        } else {
            Circle()
                .fill(Color(hex: hex) ?? .blue)
                .frame(width: 44, height: 44)
                .overlay(Circle().stroke(Color("Foreground").opacity(isSelected ? 0.9 : 0), lineWidth: 2))
                .onTapGesture {
                    colorHex = hex
                    Haptics.light()
                }
        }
    }

    private func requestPhotos() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized || status == .limited {
                DispatchQueue.main.async { showPhotoPicker = true }
            }
        }
    }

    private func requestCamera() {
        AVCaptureDevice.requestAccess(for: .video) { ok in
            if ok { DispatchQueue.main.async { showCamera = true } }
        }
    }

    @ViewBuilder
    private func labelButton(_ title: String, system: String) -> some View {
        Label(title, systemImage: system)
            .foregroundStyle(Color("Foreground"))
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color("Foreground").opacity(0.1))
            )
    }
}
