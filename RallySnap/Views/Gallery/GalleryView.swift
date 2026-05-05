import SwiftUI

struct GalleryView: View {
    @State private var selectedSegment = 0
    @State private var showCalendarView = false
    @State private var showNewAlbumAlert = false
    @State private var newAlbumName = ""
    @StateObject private var viewModel = GalleryViewModel()
    
    let segments = ["Clips", "Album", "Favorite"]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack {
                        if selectedSegment == 0 {
                            GalleryClipView(showCalendarView: $showCalendarView)
                                .environmentObject(viewModel)
                        } else if selectedSegment == 1 {
                            GalleryAlbumView()
                                .environmentObject(viewModel)
                        } else {
                            GalleryFavoriteView()
                                .environmentObject(viewModel)
                        }
                    }
                    .padding(.top, 80)
                    .padding(.bottom, 120)
                }
                
                HStack {
//                    Button(action: {}) {
//                        Image(systemName: "chevron.left")
//                            .font(.system(size: 20, weight: .semibold))
//                            .foregroundColor(Color(red: 217/255, green: 255/255, blue: 78/255))
//                            .frame(width: 44, height: 44)
//                            .background(.ultraThinMaterial)
//                            .clipShape(Circle())
//                    }
                    
//                    Spacer()
                    
                    HStack(spacing: 0) {
                        ForEach(0..<3) { index in
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedSegment = index
                                    if index != 0 {
                                        showCalendarView = false
                                    }
                                }
                            }) {
                                Text(segments[index])
                                    .font(.system(size: 14, weight: selectedSegment == index ? .semibold : .medium, design: .rounded))
                                    .foregroundColor(selectedSegment == index ? .black : .white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(
                                        selectedSegment == index
                                            ? Color(red: 217/255, green: 255/255, blue: 78/255)
                                            : Color.clear
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .frame(width: 250, height: 44)
                    
                    Spacer()
                    
                    if selectedSegment == 0 {
                        Button(action: {
                            withAnimation {
                                showCalendarView.toggle()
                            }
                        }) {
                            Image(systemName: showCalendarView ? "line.3.horizontal.decrease" : "calendar")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44)
                                .background(Color(red: 217/255, green: 255/255, blue: 78/255))
                                .clipShape(Circle())
                        }
                    } else if selectedSegment == 1 {
                        Button(action: {
                            showNewAlbumAlert = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44)
                                .background(Color(red: 217/255, green: 255/255, blue: 78/255))
                                .clipShape(Circle())
                        }
                    } else {
                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Rectangle()
                        .fill(Color.black.opacity(0.85))
                        .ignoresSafeArea(edges: .top)
                )
            }
            .alert("New Album", isPresented: $showNewAlbumAlert) {
                TextField("Album Name", text: $newAlbumName)
                Button("Cancel", role: .cancel) {
                    newAlbumName = ""
                }
                Button("Create") {
                    if !newAlbumName.isEmpty {
                        viewModel.albums.append(Album(title: newAlbumName, clips: []))
                        newAlbumName = ""
                    }
                }
            }
        }
    }
}
