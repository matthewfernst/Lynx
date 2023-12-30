//
//  FileUploadProgressView.swift
//  Lynx-SwiftUI
//
//  Created by Matthew Ernst on 12/10/23.
//

import SwiftUI

struct FileUploadProgressView: View {
    @Bindable var folderConnectionHandler: FolderConnectionHandler
    
    @Environment(\.dismiss) private var dismiss
    @State private var showThumbsUp = false
    
    var body: some View {
        NavigationStack {
            VStack {
                allSetText
                Spacer()
                ZStack {
                    circularProgress
                    thumbsUp
                }
                .foregroundStyle(.blue)
                .frame(
                    width: Constants.progressViewWidthHeight,
                    height: Constants.progressViewWidthHeight
                )
                .padding()
                Text("Uploading:")
                    .opacity(showIfNotThumbsUp)
                Text(folderConnectionHandler.currentFileBeingUploaded)
                    .opacity(showIfNotThumbsUp)
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .opacity(showIfThumbsUp)
                }
            }
        }
        .padding()
        .onChange(of: folderConnectionHandler.uploadProgress) { _, newProgress in
            updateThumbsUpIfEnd(progress: newProgress)
        }
        .onAppear {
            updateThumbsUpIfEnd(progress: folderConnectionHandler.uploadProgress)
        }
    }
    
    private var allSetText: some View {
        VStack {
            Text("All Set!")
                .font(.largeTitle)
                .opacity(showIfThumbsUp)
                .padding(.bottom)
            Text("Your Slopes folder is connected. Your files will be automatically uploaded when you open the app.")
                .multilineTextAlignment(.center)
                .font(.system(size: 16))
                .opacity(showIfThumbsUp)
        }
    }
    
    private var circularProgress: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: Constants.CircularProgress.lineWidth)
                .opacity(showThumbsUp ? 0 : Constants.CircularProgress.backCircleShowOpacity)
                .foregroundColor(Color.gray)
            Circle()
                .trim(from: 0.0, to: folderConnectionHandler.uploadProgress)
                .stroke(style: StrokeStyle(lineWidth: Constants.CircularProgress.lineWidth, lineCap: .round, lineJoin: .round))
                .rotationEffect(.degrees(Constants.CircularProgress.fontCircleRotationDegree))
                .opacity(showIfNotThumbsUp)
                .animation(.easeInOut, value: folderConnectionHandler.uploadProgress)
        }
    }
    
    private var thumbsUp: some View {
        Image(systemName: "hand.thumbsup.fill")
            .resizable()
            .frame(
                width: Constants.ThumbsUp.widthHeight,
                height: Constants.ThumbsUp.widthHeight
            )
            .opacity(showIfThumbsUp)
            .rotationEffect(
                Angle.degrees(
                    showThumbsUp ? Constants.ThumbsUp.firstStartDegreeRotation : Constants.ThumbsUp.firstEndDegreeRotation
                )
            )
            .animation(
                .bouncy(duration: Constants.ThumbsUp.bouncyDuration),
                value: showThumbsUp
            )
            .rotationEffect(
                Angle.degrees(
                    showThumbsUp ? Constants.ThumbsUp.secondStartDegreeRotation : Constants.ThumbsUp.secondEndDegreeRotation
                )
            )
    }
    
    // MARK: - Helpers
    private func updateThumbsUpIfEnd(progress: Double) {
        if progress >= Constants.endProgressCheck {
            withAnimation {
                showThumbsUp = true
            }
        }
    }
    
    private var showIfNotThumbsUp: CGFloat {
        showThumbsUp ? 0 : 1
    }
    
    private var showIfThumbsUp: CGFloat {
        showThumbsUp ? 1 : 0
    }
    
    // MARK: - Constants
    private struct Constants {
        struct CircularProgress {
            static let lineWidth: CGFloat = 10
            static let backCircleShowOpacity: CGFloat = 0.3
            
            static let fontCircleRotationDegree: CGFloat = -90
        }
        
        struct ThumbsUp {
            static let widthHeight: CGFloat = 100
            
            static let firstStartDegreeRotation: CGFloat = 320
            static let firstEndDegreeRotation: CGFloat = 260
            
            static let bouncyDuration: TimeInterval = 1.5
            
            static let secondStartDegreeRotation: CGFloat = 0
            static let secondEndDegreeRotation: CGFloat = 180
        }
        
        static let progressViewWidthHeight: CGFloat = 150
        
        static let endProgressCheck: Double = 0.99
    }
}

#Preview {
    FileUploadProgressView(
        folderConnectionHandler: FolderConnectionHandler()
    )
}
