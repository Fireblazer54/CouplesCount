import SwiftUI
import SwiftData
import UIKit

struct ProfileView: View {
    @EnvironmentObject private var theme: ThemeManager
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Countdown> { $0.isShared && !$0.isArchived },
           sort: \Countdown.targetDate, order: .forward)
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
                                    .foregroundColor(.gray)
                                    .padding(4)
                            }
                        }
                        .frame(width: 80, height: 80)
                        .background(Color.gray.opacity(profileImageData == nil ? 0.2 : 0))
                        .clipShape(Circle())
                    }
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
                        let days = DateUtils.daysUntil(target: item.targetDate, in: item.timeZoneID)
                        let dateText = DateUtils.readableDate.string(from: item.targetDate)
                        CountdownCardView(
                            title: item.title,
                            daysLeft: days,
                            dateText: dateText,
                            archived: item.isArchived,
                            backgroundStyle: item.backgroundStyle,
                            colorHex: item.backgroundColorHex,
                            imageData: item.backgroundImageData,
                            shared: item.isShared,
                            shareAction: nil
                        )
                        .environmentObject(theme)
                        .contextMenu {
                            Button(role: .destructive) {
                                modelContext.delete(item)
                                try? modelContext.save()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)

                            Button {
                                item.isArchived = true
                                try? modelContext.save()
                            } label: {
                                Label("Archive", systemImage: "archivebox")
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .background(theme.theme.background.ignoresSafeArea())
    }
}
