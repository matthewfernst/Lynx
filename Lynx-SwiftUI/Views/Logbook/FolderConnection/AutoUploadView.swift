//
//  AutoUploadView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/11/23.
//

import SwiftUI

struct AutoUploadView: View {
    @Bindable var folderConnectionHandler: FolderConnectionHandler
    @Binding var showAutoUpload: Bool
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var slopesFileUploading = ""
    @State private var showAllDone = false
    var body: some View {
        backgroundCapsule
            .overlay(
                HStack(alignment: .center, spacing: Constants.hstackSpacing) {
                    Spacer()
                    progress
                    slopeUploadText
                }
            )
            .onChange(of: folderConnectionHandler.uploadProgress) { _, newProgress in
                withAnimation {
                    slopesFileUploading = folderConnectionHandler.currentFileBeingUploaded
                }
                if newProgress >= 1.0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) { // wait for last timer shoot off
                        withAnimation {
                            slopesFileUploading = "All Done!"
                            showAllDone = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showAutoUpload = false
                                slopesFileUploading = ""
                            }
                        }
                    }
                }
            }
            .onDisappear {
                showAllDone = false
                folderConnectionHandler.resetUploadProgressAndFilename()
            }
    }
    
    // MARK: - Views
    private var backgroundCapsule: some View {
        RoundedRectangle(cornerRadius: Constants.BackgroundCapsule.cornerRadius)
            .frame(
                maxWidth: Constants.BackgroundCapsule.width,
                maxHeight: Constants.BackgroundCapsule.height
            )
            .foregroundStyle(
                Color(uiColor: .tertiarySystemGroupedBackground)
            )
            .shadow(radius: Constants.BackgroundCapsule.shadowRadius)
    }
    
    private var progress: some View {
        HStack {
            if showAllDone {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(.lynx)
                    .transition(.scale)
            } else {
                ZStack {
                    Circle()
                        .stroke(lineWidth: Constants.CircularProgress.lineWidth)
                        .opacity(Constants.CircularProgress.backgroundOpacity)
                        .foregroundColor(Color.secondary)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(folderConnectionHandler.uploadProgress))
                        .stroke(
                            style: StrokeStyle(lineWidth: Constants.CircularProgress.lineWidth,
                            lineCap: .round,
                            lineJoin: .round))
                        .foregroundColor(Color.lynx)
                        .rotationEffect(Constants.CircularProgress.rotationAngle)
                }
                .frame(
                    width: Constants.CircularProgress.widthHeight,
                    height: Constants.CircularProgress.widthHeight
                )
                .transition(.identity)
            }
        }
    }
    
    private var slopeUploadText: some View {
        HStack {
            Text(slopesFileUploading)
                .font(.subheadline)
                .transition(
                    folderConnectionHandler.uploadProgress < 1.0 ? .rollDownInandOut : .rollDownAndIdentity
                )
                .id(UUID().uuidString + slopesFileUploading) // id to replace this view even if the file name is the same
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    
    // MARK: - Constants For Main View
    private struct Constants {
        static let hstackSpacing: CGFloat = 10
        
        struct BackgroundCapsule {
            static let cornerRadius: CGFloat = 25.0
            static let width: CGFloat = 300
            static let height: CGFloat = 65
            static let shadowRadius: CGFloat = 5
        }
        
        struct CircularProgress {
            static let lineWidth: CGFloat = 5.0
            static let backgroundOpacity: CGFloat = 0.3
            
            static let rotationAngle: Angle = .degrees(270.0)
            static let widthHeight: CGFloat = 25.0
        }
    }
}

// MARK: - Modifiers/Transitions
struct RollDownModifier: ViewModifier {
    let yOffset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .offset(y: yOffset)
            .clipped()
    }
}


extension AnyTransition {
    static var rollDownFromTop: AnyTransition {
        .modifier(
            active: RollDownModifier(yOffset: -50),
            identity: RollDownModifier(yOffset: 0)
        )
    }
    
    static var rollDownOut: AnyTransition {
        .modifier(active: RollDownModifier(yOffset: 50),
                   identity: RollDownModifier(yOffset: 0))
        .combined(
            with: .scale
        )
    }
    
    static var rollDownInandOut: AnyTransition {
        .asymmetric(insertion: .rollDownFromTop, removal: .rollDownOut)
    }
    
    static var rollDownAndIdentity: AnyTransition {
        .asymmetric(insertion: .rollDownFromTop, removal: .identity)
    }
}

#Preview {
    AutoUploadView(
        folderConnectionHandler: FolderConnectionHandler(),
        showAutoUpload: .constant(true)
    )
}
