import SwiftUI

struct FileUploadProgressView: View {
    @Bindable var folderConnectionHandler: FolderConnectionHandler

    @Environment(\.dismiss) private var dismiss
    @State private var showSuccess = false
    @State private var showCheckmark = false
    @State private var showSparkles = false
    @State private var celebrationParticles: [CelebrationParticle] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                allSetText
                Spacer()
                ZStack {
                    circularProgress
                    successAnimation
                    celebrationView
                }
                .frame(
                    width: Constants.progressViewWidthHeight,
                    height: Constants.progressViewWidthHeight
                )
                .padding()
                uploadStatusText
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .opacity(showSuccess ? 1 : 0)
                }
            }
        }
        .padding()
        .onChange(of: folderConnectionHandler.uploadProgress) { _, newProgress in
            updateSuccessIfEnd(progress: newProgress)
        }
        .onAppear {
            updateSuccessIfEnd(progress: folderConnectionHandler.uploadProgress)
        }
    }

    private var allSetText: some View {
        VStack(spacing: 12) {
            Text("All Set!")
                .font(.largeTitle.bold())
                .opacity(showSuccess ? 1 : 0)
                .scaleEffect(showSuccess ? 1 : 0.5)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: showSuccess)

            Text("Your Slopes folder is connected. Your files will be automatically uploaded when you open the app.")
                .multilineTextAlignment(.center)
                .font(.system(size: 16))
                .opacity(showSuccess ? 1 : 0)
                .animation(.easeInOut.delay(0.5), value: showSuccess)
        }
    }

    private var circularProgress: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: Constants.CircularProgress.lineWidth)
                .opacity(showSuccess ? 0 : Constants.CircularProgress.backCircleShowOpacity)
                .foregroundStyle(.gray)

            Circle()
                .trim(from: 0.0, to: folderConnectionHandler.uploadProgress)
                .stroke(style: StrokeStyle(lineWidth: Constants.CircularProgress.lineWidth, lineCap: .round, lineJoin: .round))
                .rotationEffect(.degrees(Constants.CircularProgress.fontCircleRotationDegree))
                .opacity(showSuccess ? 0 : 1)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: folderConnectionHandler.uploadProgress)
        }
        .animation(.easeInOut(duration: 0.3), value: showSuccess)
    }

    private var successAnimation: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.green.opacity(0.2), .mint.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(showCheckmark ? 1.0 : 0.1)
                .opacity(showCheckmark ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showCheckmark)

            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green, .mint],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(showCheckmark ? 1.0 : 0.1)
                .opacity(showCheckmark ? 1 : 0)
                .rotationEffect(.degrees(showCheckmark ? 0 : -180))
                .animation(.spring(response: 0.6, dampingFraction: 0.65), value: showCheckmark)

            Image(systemName: "sparkles")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundStyle(.yellow)
                .offset(x: -50, y: -50)
                .scaleEffect(showSparkles ? 1.2 : 0.1)
                .opacity(showSparkles ? 1 : 0)
                .rotationEffect(.degrees(showSparkles ? 360 : 0))
                .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: showSparkles)

            Image(systemName: "sparkles")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(.orange)
                .offset(x: 50, y: -40)
                .scaleEffect(showSparkles ? 1.0 : 0.1)
                .opacity(showSparkles ? 1 : 0)
                .rotationEffect(.degrees(showSparkles ? -360 : 0))
                .animation(.spring(response: 0.9, dampingFraction: 0.65).delay(0.3), value: showSparkles)

            Image(systemName: "sparkles")
                .resizable()
                .frame(width: 35, height: 35)
                .foregroundStyle(.pink)
                .offset(x: 0, y: 60)
                .scaleEffect(showSparkles ? 1.1 : 0.1)
                .opacity(showSparkles ? 1 : 0)
                .rotationEffect(.degrees(showSparkles ? 180 : 0))
                .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.25), value: showSparkles)
        }
    }

    private var celebrationView: some View {
        ZStack {
            ForEach(celebrationParticles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .offset(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
                    .scaleEffect(particle.scale)
            }
        }
    }

    private var uploadStatusText: some View {
        VStack(spacing: 8) {
            Text("Uploading:")
                .font(.headline)
                .opacity(showSuccess ? 0 : 1)
                .animation(.easeInOut, value: showSuccess)

            Text(folderConnectionHandler.currentFileBeingUploaded)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
                .opacity(showSuccess ? 0 : 1)
                .animation(.easeInOut, value: showSuccess)
        }
    }

    private func updateSuccessIfEnd(progress: Double) {
        guard progress >= Constants.endProgressCheck, !showSuccess else { return }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            showSuccess = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                showCheckmark = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                showSparkles = true
            }
            createCelebrationParticles()
        }
    }

    private func createCelebrationParticles() {
        let colors: [Color] = [.blue, .green, .yellow, .orange, .pink, .purple, .cyan, .mint]

        for i in 0..<20 {
            let angle = Double(i) * (360.0 / 20.0)
            let distance: CGFloat = 80
            let x = cos(angle * .pi / 180) * distance
            let y = sin(angle * .pi / 180) * distance

            let particle = CelebrationParticle(
                id: UUID(),
                x: 0,
                y: 0,
                color: colors.randomElement() ?? .blue,
                size: CGFloat.random(in: 4...8),
                opacity: 1,
                scale: 0
            )

            celebrationParticles.append(particle)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05 * Double(i)) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    if let index = celebrationParticles.firstIndex(where: { $0.id == particle.id }) {
                        celebrationParticles[index].x = x
                        celebrationParticles[index].y = y
                        celebrationParticles[index].scale = 1
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        if let index = celebrationParticles.firstIndex(where: { $0.id == particle.id }) {
                            celebrationParticles[index].opacity = 0
                            celebrationParticles[index].y += 30
                        }
                    }
                }
            }
        }
    }

    private struct Constants {
        struct CircularProgress {
            static let lineWidth: CGFloat = 10
            static let backCircleShowOpacity: CGFloat = 0.3
            static let fontCircleRotationDegree: CGFloat = -90
        }

        static let progressViewWidthHeight: CGFloat = 150
        static let endProgressCheck: Double = 0.99
    }
}

struct CelebrationParticle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    let color: Color
    let size: CGFloat
    var opacity: Double
    var scale: CGFloat
}

#Preview {
    FileUploadProgressView(
        folderConnectionHandler: FolderConnectionHandler()
    )
}
