import AVKit
import OSLog
import SwiftUI

struct FolderConnectionView: View {
  @Binding var showUploadProgressView: Bool
  @Bindable var folderConnectionHandler: FolderConnectionHandler

  @Environment(\.dismiss) private var dismiss
  @State private var showDocumentPicker = false
  @State var dismissForUpload: Bool = false

  @State private var player = AVPlayer(
    url: Bundle.main.url(forResource: "HowToUpload", withExtension: "mov")!)
  @State private var videoDone = false

  var body: some View {
    NavigationStack {
      initialUploadExplanation
        .navigationTitle("Uploading Slope Files")
        .navigationBarTitleDisplayMode(.inline)
        .fileImporter(
          isPresented: $showDocumentPicker,
          allowedContentTypes: [.folder]
        ) { result in
          switch result {
          case .success(let url):
            folderConnectionHandler.picker(
              didPickDocumentsAt: url,
              dismissForUpload: $dismissForUpload
            )
          case .failure(let error):
            Logger.folderConnectionView.error(
              "Failed in selecting folder with error: \(error)"
            )
          }
        }
        .alert(isPresented: $folderConnectionHandler.showError) {
          folderConnectionHandler.errorAlert!
        }
        .onChange(of: dismissForUpload) { _, newValue in
          if newValue {
            dismiss()
            // Let a small amount of time pass for this view to dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
              showUploadProgressView = true
            }
          }
        }
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
              dismiss()
            }
          }
        }
    }
  }

  private var initialUploadExplanation: some View {
    VStack {
      Text(Constants.howToUploadInformation)
        .multilineTextAlignment(.center)
        .frame(maxHeight: .infinity)
        .padding(.bottom)

      VideoPlayer(player: player)
        .aspectRatio(Constants.Video.aspectRatio, contentMode: .fit)
        .frame(height: Constants.Video.height)
        .cornerRadius(Constants.Video.cornerRadius)
        .onAppear {
          player.play()
        }
        .onDisappear {
          player.pause()
          player.seek(to: .zero)
        }
        .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)) { _ in
          withAnimation {
            videoDone = true
          }
        }

      Button("Continue") {
        showDocumentPicker = true
      }
      .buttonStyle(.borderedProminent)
      .frame(maxHeight: .infinity)
      .opacity(videoDone ? 1 : 0)

    }
    .padding()
  }

  private struct Constants {
    static let howToUploadInformation = """
      To upload, please follow the instructions illustrated below. When you are ready, click the 'Continue' button and select the correct directory
      """
    struct Video {
      static let aspectRatio: CGFloat = 9 / 16
      static let height: CGFloat = UIScreen.main.bounds.height / 2
      static let cornerRadius: CGFloat = 10
    }
  }
}

#Preview {
  FolderConnectionView(
    showUploadProgressView: .constant(false),
    folderConnectionHandler: FolderConnectionHandler()
  )
}
