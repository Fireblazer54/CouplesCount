import SwiftUI
import SwiftData
import UIKit

struct ProfileView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.theme) private var theme
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Countdown> { $0.isShared && !$0.isArchived },
           sort: \Countdown.targetUTC, order: .forward)
    private var shared: [Countdown]

    @AppStorage("profileImageData") private var profileImageData: Data?
    @State private var showPhotoPicker = false
    @State private var showCameraPicker = false
    @State private var showPhotoOptions = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Header similar to Instagram
                HStack {
                    Button {
                        showPhotoOptions = true
                    } label: {
                        Group {
                            if let data = profileImageData,
                               let img = UIImage(data: data) {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(theme.color(.MutedForeground))
                                    .padding(4)
                            }
                        }
                        .frame(width: 80, height: 80)
                        .background(theme.color(.Muted).opacity(profileImageData == nil ? 0.2 : 0))
                        .clipShape(Circle())
                    }
                    .accessibilityLabel("Profile photo")
                    .accessibilityHint("Change your profile picture")
                    .buttonStyle(.plain)
                    .confirmationDialog("Profile Photo", isPresented: $showPhotoOptions) {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            Button("Take Photo") { showCameraPicker = true }
                        }
                        Button("Choose Photo") { showPhotoPicker = true }
                        if profileImageData != nil {
                            Button("Remove Photo", role: .destructive) { profileImageData = nil }
                        }
                    }
                    .sheet(isPresented: $showPhotoPicker) {
                        PhotoPicker(imageData: $profileImageData)
                    }
                    .sheet(isPresented: $showCameraPicker) {
                        CameraPicker(imageData: $profileImageData)
                    }
                    Spacer()
                    VStack {
                        Text("\(shared.count)")
                            .font(.headline)
                        Text("Posts")
                            .font(.subheadline)
                    }
                    Spacer()
                    VStack {
                        Text("0")
                            .font(.headline)
                        Text("Followers")
                            .font(.subheadline)
                    }
                    Spacer()
                    VStack {
                        Text("0")
                            .font(.headline)
                        Text("Following")
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)
                .safeAreaPadding(.top, 12)

                Text("Username")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                    .padding(.top, 4)

                Button("Add Friend") {
                    // Placeholder for friend adding flow
                }
                .padding(.horizontal)
                .padding(.bottom, 4)

                // Grid of shared countdowns
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                    ForEach(shared) { item in
                        let dateText = DateUtils.readableDate.string(from: item.targetDate)
                        CountdownCardView(
                            title: item.title,
                            targetDate: item.targetDate,
                            timeZoneID: item.timeZoneID,
                            dateText: dateText,
                            archived: item.isArchived,
                            backgroundStyle: item.backgroundStyle,
                            colorHex: item.backgroundColorHex,
                            imageData: item.backgroundImageData,
                            fontStyle: item.cardFontStyle,
                            shared: item.isShared,
                            shareAction: nil
                        )
                        .environmentObject(themeManager)
                        .contextMenu {
                            DeleteSwipeButton({
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                    modelContext.delete(item)
                                    try? modelContext.save()
                                    let all = (try? modelContext.fetch(FetchDescriptor<Countdown>())) ?? []
                                    updateWidgetSnapshot(afterSaving: all)
                                }
                                Haptics.warning()
                            }, iconOnly: false)

                            ArchiveSwipeButton({
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                    item.isArchived = true
                                    try? modelContext.save()
                                    let all = (try? modelContext.fetch(FetchDescriptor<Countdown>())) ?? []
                                    updateWidgetSnapshot(afterSaving: all)
                                }
                                Haptics.light()
                            }, iconOnly: false)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .animation(.spring(response: 0.4, dampingFraction: 0.85), value: shared)
            }
        }
        .background(theme.color(.Background).ignoresSafeArea())
    }
}
