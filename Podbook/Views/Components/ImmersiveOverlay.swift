import SwiftUI
import AVFoundation

// MARK: - Notification Names

extension Notification.Name {
    static let silenceDetectedAutoSubmit = Notification.Name("silenceDetectedAutoSubmit")
}

// MARK: - Warp Effect View Modifier

/// Applies the Apple Intelligence-style warp effect to content (AirDrop bump style)
struct WarpEffect: ViewModifier {
    let progress: CGFloat
    let intensity: CGFloat

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(Double(-progress * 8)),
                axis: (x: 1, y: 0, z: 0),
                anchor: .top,
                perspective: 0.4
            )
            .transformEffect(
                CGAffineTransform(a: 1 - progress * intensity * 0.5,
                                  b: 0,
                                  c: -progress * 0.03,
                                  d: 1 + progress * intensity * 1.2,
                                  tx: 0,
                                  ty: progress * 20)
            )
            .scaleEffect(1 - progress * 0.05, anchor: .top)
    }
}

extension View {
    func warpEffect(progress: CGFloat, intensity: CGFloat = 0.1) -> some View {
        modifier(WarpEffect(progress: progress, intensity: intensity))
    }
}

// MARK: - Immersive Overlay Container

struct ImmersiveOverlayContainer<Background: View, Overlay: View>: View {
    @Binding var isPresented: Bool
    let colors: [Color]
    let background: () -> Background
    let overlay: () -> Overlay

    @State private var warpProgress: CGFloat = 0
    @State private var blurAmount: CGFloat = 0
    @State private var circleScale: CGFloat = 0
    @State private var circleOpacity: CGFloat = 0
    @State private var breathingScale: CGFloat = 0.7
    @State private var overlayOpacity: CGFloat = 0
    @State private var waveScale: CGFloat = 0
    @State private var waveOpacity: CGFloat = 0

    init(
        isPresented: Binding<Bool>,
        colors: [Color] = [.orange, .red, .purple, .blue],
        @ViewBuilder background: @escaping () -> Background,
        @ViewBuilder overlay: @escaping () -> Overlay
    ) {
        self._isPresented = isPresented
        self.colors = colors
        self.background = background
        self.overlay = overlay
    }

    var body: some View {
        ZStack {
            background()
                .warpEffect(progress: warpProgress, intensity: 0.12)
                .blur(radius: blurAmount)

            if isPresented {
                waveBurstEffect
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                meshGradientBackground
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                overlay()
                    .opacity(overlayOpacity)
            }
        }
        .onChange(of: isPresented) { _, newValue in
            if newValue {
                animateIn()
            } else {
                animateOut()
            }
        }
    }

    private var waveBurstEffect: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(colors: [colors[0].opacity(0.8), colors[1].opacity(0.4)], startPoint: .top, endPoint: .bottom),
                    lineWidth: 3
                )
                .frame(width: 100, height: 100)
                .scaleEffect(waveScale * 8)
                .opacity(waveOpacity)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height * 0.5)

            Circle()
                .fill(RadialGradient(colors: [colors[0].opacity(0.4), .clear], center: .center, startRadius: 0, endRadius: 150))
                .frame(width: 200, height: 200)
                .scaleEffect(waveScale * 4)
                .opacity(waveOpacity * 0.5)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height * 0.5)
        }
    }

    private var meshGradientBackground: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(colors: [colors[0].opacity(0.8), colors[1].opacity(0.4), .clear], center: .center, startRadius: 0, endRadius: 400))
                .frame(width: 300, height: 300)
                .scaleEffect(circleScale)
                .blur(radius: 120)
                .opacity(circleOpacity)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)

            Circle()
                .fill(RadialGradient(colors: [colors[0].opacity(0.7), colors[1].opacity(0.3), .clear], center: .center, startRadius: 0, endRadius: 250))
                .frame(width: 400, height: 400)
                .scaleEffect(breathingScale)
                .blur(radius: 100)
                .opacity(circleOpacity)
                .position(x: 80, y: 200)

            Circle()
                .fill(RadialGradient(colors: [colors[2].opacity(0.6), colors[3].opacity(0.2), .clear], center: .center, startRadius: 0, endRadius: 300))
                .frame(width: 500, height: 500)
                .scaleEffect(breathingScale * 1.1)
                .blur(radius: 120)
                .opacity(circleOpacity)
                .position(x: UIScreen.main.bounds.width - 60, y: UIScreen.main.bounds.height - 350)
        }
    }

    private func animateIn() {
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred(intensity: 1.0)
        AudioServicesPlaySystemSound(1519)

        withAnimation(.easeOut(duration: 0.2)) {
            waveScale = 1.0
            waveOpacity = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeOut(duration: 0.4)) {
                waveOpacity = 0
            }
        }

        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
            warpProgress = 1.0
            blurAmount = 28
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            let secondImpact = UIImpactFeedbackGenerator(style: .medium)
            secondImpact.impactOccurred(intensity: 0.8)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                warpProgress = 0.25
            }
        }

        withAnimation(.easeOut(duration: 0.5)) {
            circleScale = 8
            circleOpacity = 1
            overlayOpacity = 1
        }

        withAnimation(.easeInOut(duration: 0.8)) {
            breathingScale = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true)) {
                breathingScale = 0.75
            }
        }
    }

    private func animateOut() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            warpProgress = 0
            blurAmount = 0
            circleScale = 0
            circleOpacity = 0
            overlayOpacity = 0
        }
    }
}

// MARK: - Simplified Ask Mode Content

struct ImmersiveQuestionContent: View {
    @Binding var isPresented: Bool
    @StateObject private var recorder = VoiceRecordingService()
    @State private var phase: AskPhase = .listening
    @State private var questionId: String?
    @State private var errorMessage: String?
    @State private var silenceTimer: Timer?
    @State private var lastTranscriptLength: Int = 0
    @State private var silenceDuration: TimeInterval = 0

    let episode: Episode
    let timestamp: TimeInterval
    let transcriptContext: String
    let onResponseReady: (String) -> Void

    // Auto-submit after 2 seconds of silence
    private let silenceThreshold: TimeInterval = 2.0

    var gradientColors: [Color] {
        let palette = ColorPalette.palette(for: episode.coverColor)
        return [
            Color(palette: palette.shade400),
            Color(palette: palette.shade600),
            Color(palette: palette.shade800),
            Color(palette: palette.shade900)
        ]
    }

    enum AskPhase {
        case listening
        case processing
        case error
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Main content based on phase
            switch phase {
            case .listening:
                listeningView
            case .processing:
                processingView
            case .error:
                errorView
            }

            Spacer()

            // Cancel tap area (subtle, at bottom)
            Button(action: cancel) {
                Text("Tap to cancel")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            await startListening()
        }
        .onReceive(NotificationCenter.default.publisher(for: .silenceDetectedAutoSubmit)) { _ in
            autoSubmit()
        }
        .onDisappear {
            silenceTimer?.invalidate()
            // Clean up UserDefaults keys used for silence detection
            UserDefaults.standard.removeObject(forKey: "silenceLastLength")
            UserDefaults.standard.removeObject(forKey: "silenceDuration")
            recorder.cleanup()
        }
    }

    // MARK: - Phase Views

    private var listeningView: some View {
        VStack(spacing: 24) {
            // Waveform visualization
            ImmersiveWaveformView(level: recorder.audioLevel, colors: gradientColors)
                .frame(height: 80)
                .padding(.horizontal, 40)

            // Transcribed text (streams in real-time)
            Text(recorder.transcribedText.isEmpty ? "Listening..." : recorder.transcribedText)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .animation(.easeOut(duration: 0.1), value: recorder.transcribedText)
        }
    }

    private var processingView: some View {
        VStack(spacing: 24) {
            ImmersiveLoader(colors: gradientColors)
                .frame(width: 60, height: 60)

            Text("Processing...")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8))

            if !recorder.transcribedText.isEmpty {
                Text("\"\(recorder.transcribedText)\"")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.5))
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineLimit(3)
            }
        }
    }

    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text(errorMessage ?? "Something went wrong")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button(action: retry) {
                Text("Try Again")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(24)
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Actions

    private func startListening() async {
        let granted = await recorder.requestPermissions()
        if !granted {
            errorMessage = "Microphone permission required"
            phase = .error
            return
        }

        do {
            try recorder.startRecording()

            // Light haptic to indicate recording started
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()

            // Start monitoring for silence
            startSilenceDetection()
        } catch {
            errorMessage = error.localizedDescription
            phase = .error
        }
    }

    private func startSilenceDetection() {
        lastTranscriptLength = 0
        silenceDuration = 0

        silenceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak recorder] timer in
            guard let recorder = recorder else {
                timer.invalidate()
                return
            }

            // Access recorder on main thread since it's a MainActor-isolated object
            DispatchQueue.main.async {
                let currentLength = recorder.transcribedText.count

                // Use a simple flag approach - the timer just monitors transcript length
                // The actual state updates happen through the recorder
                if currentLength > 0 {
                    // Store the check result in UserDefaults temporarily for cross-timer communication
                    let lastLength = UserDefaults.standard.integer(forKey: "silenceLastLength")
                    let currentSilence = UserDefaults.standard.double(forKey: "silenceDuration")

                    if currentLength == lastLength {
                        // No new text - increment silence
                        let newSilence = currentSilence + 0.5
                        UserDefaults.standard.set(newSilence, forKey: "silenceDuration")

                        if newSilence >= 2.0 {
                            // User stopped speaking - auto-submit
                            timer.invalidate()
                            UserDefaults.standard.removeObject(forKey: "silenceLastLength")
                            UserDefaults.standard.removeObject(forKey: "silenceDuration")

                            // Post notification for auto-submit
                            NotificationCenter.default.post(name: .silenceDetectedAutoSubmit, object: nil)
                        }
                    } else {
                        // New text detected - reset
                        UserDefaults.standard.set(0.0, forKey: "silenceDuration")
                        UserDefaults.standard.set(currentLength, forKey: "silenceLastLength")
                    }
                }
            }
        }
    }

    private func autoSubmit() {
        let question = recorder.stopRecording()

        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        guard !question.isEmpty else {
            errorMessage = "No question detected"
            phase = .error
            return
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            phase = .processing
        }

        Task {
            await submitQuestion(question)
        }
    }

    private func submitQuestion(_ question: String) async {
        do {
            let questionId = try await APIService.shared.submitQuestion(
                episodeId: episode.id,
                question: question,
                timestamp: timestamp,
                transcriptContext: transcriptContext
            )
            self.questionId = questionId

            let status = try await APIService.shared.waitForQuestionResponse(
                questionId: questionId,
                pollInterval: 1.0,
                maxAttempts: 180
            )

            if status.isCompleted, let audioUrl = status.audioUrl {
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.success)

                onResponseReady(audioUrl)
                isPresented = false
            } else if status.isFailed {
                errorMessage = status.message.isEmpty ? "Failed to generate response" : status.message
                phase = .error
            }
        } catch {
            errorMessage = error.localizedDescription
            phase = .error
        }
    }

    private func cancel() {
        silenceTimer?.invalidate()
        recorder.cleanup()

        if let questionId = questionId {
            Task {
                try? await APIService.shared.cancelQuestion(questionId: questionId)
            }
        }

        isPresented = false
    }

    private func retry() {
        phase = .listening
        errorMessage = nil
        recorder.transcribedText = ""

        Task {
            await startListening()
        }
    }
}

// MARK: - Immersive Waveform View

struct ImmersiveWaveformView: View {
    let level: Float
    let colors: [Color]

    @State private var barHeights: [CGFloat] = Array(repeating: 0.2, count: 40)

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<40, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [colors[0].opacity(0.9), colors[1].opacity(0.6)],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: 4, height: barHeights[index] * 60 + 4)
            }
        }
        .onChange(of: level) { _, newValue in
            updateBars(with: newValue)
        }
    }

    private func updateBars(with level: Float) {
        withAnimation(.easeInOut(duration: 0.06)) {
            for i in 0..<(barHeights.count - 1) {
                barHeights[i] = barHeights[i + 1]
            }
            let baseLevel = CGFloat(min(1.0, level * 3.0))
            let variance = CGFloat.random(in: -0.15...0.15)
            barHeights[barHeights.count - 1] = max(0.05, min(1.0, baseLevel + variance))
        }
    }
}

// MARK: - Immersive Loader

struct ImmersiveLoader: View {
    let colors: [Color]

    @State private var rotation: Double = 0

    var body: some View {
        Circle()
            .stroke(
                AngularGradient(colors: colors + [colors[0]], center: .center),
                lineWidth: 4
            )
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

// MARK: - Legacy Support

struct ImmersiveQuestionSheet: View {
    @Binding var isPresented: Bool
    let episode: Episode
    let timestamp: TimeInterval
    let transcriptContext: String
    let onResponseReady: (String) -> Void

    private var gradientColors: [Color] {
        let palette = ColorPalette.palette(for: episode.coverColor)
        return [
            Color(palette: palette.shade400),
            Color(palette: palette.shade600),
            Color(palette: palette.shade800),
            Color(palette: palette.shade900)
        ]
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            ImmersiveQuestionContent(
                isPresented: $isPresented,
                episode: episode,
                timestamp: timestamp,
                transcriptContext: transcriptContext,
                onResponseReady: onResponseReady
            )
        }
    }
}

#Preview {
    ImmersiveQuestionSheet(
        isPresented: .constant(true),
        episode: Episode.sample,
        timestamp: 45.0,
        transcriptContext: "Sample context",
        onResponseReady: { _ in }
    )
}
