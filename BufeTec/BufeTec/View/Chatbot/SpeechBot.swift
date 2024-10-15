//
//  VoiceChatView.swift
//  BufeTec
//
//  Created by Felipe Alonzo on 15/10/24.
//

import SwiftUI
import Vapi
import Combine
import AVFoundation
import CoreMotion

struct AudioResponsiveCircleView: View {
    @StateObject private var audioManager = AudioManager()
    @State private var circleSize: CGFloat = 100
    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0

    var body: some View {
        ZStack {
            Circle()
                .frame(width: circleSize, height: circleSize)
                .overlay(
                    Image("mesh")  // Make sure "mesh" is added to your assets
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                       
                )
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: circleSize)
                
        }
        .onReceive(audioManager.$volumeLevel) { volume in
            updateCircleSize(volume: volume)
        }
        .onAppear {
            audioManager.startMonitoring()
        }
    }

    private func updateCircleSize(volume: Float) {
        let minSize: CGFloat = 100
        let maxSize: CGFloat = 300
        let volumeMultiplier: CGFloat = 150  // Adjust for responsiveness

        let newSize = min(max(CGFloat(volume) * volumeMultiplier + minSize, minSize), maxSize)
        circleSize = newSize
    }
}


class AudioManager: ObservableObject {
    @Published var volumeLevel: Float = 0.0
    private var audioRecorder: AVAudioRecorder!

    func startMonitoring() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try audioSession.setActive(true)

            // Setup audio recorder to monitor input levels
            let url = URL(fileURLWithPath: "/dev/null") // Dummy URL, we don't save the audio
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatAppleLossless),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder.isMeteringEnabled = true
            audioRecorder.record()

            // Start a timer to periodically update the volume level
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                self.audioRecorder.updateMeters()
                let avgPower = self.audioRecorder.averagePower(forChannel: 0)
                self.volumeLevel = self.normalizeVolume(level: avgPower)
            }
        } catch {
            print("Failed to set up audio monitoring: \(error)")
        }
    }

    private func normalizeVolume(level: Float) -> Float {
        // Normalize the audio level to a range of 0.0 - 1.0
        let minLevel: Float = -80 // AVAudioRecorder's min power level
        let maxLevel: Float = 0   // AVAudioRecorder's max power level
        let clampedLevel = max(minLevel, min(maxLevel, level))
        return (clampedLevel - minLevel) / (maxLevel - minLevel)
    }
}

class CallManager: ObservableObject {
    enum CallState {
        case started, loading, ended
    }

    @Published var callState: CallState = .ended
    var vapiEvents = [Vapi.Event]()
    private var cancellables = Set<AnyCancellable>()
    let vapi: Vapi

    init() {
        vapi = Vapi(
            publicKey: "51d3e592-becf-4d8f-b5c7-2db91aa48393"
        )
    }

    func setupVapi() {
        vapi.eventPublisher
            .sink { [weak self] event in
                self?.vapiEvents.append(event)
                switch event {
                case .callDidStart:
                    self?.callState = .started
                case .callDidEnd:
                    self?.callState = .ended
                case .speechUpdate:
                    print(event)
                case .conversationUpdate:
                    print(event)
                case .functionCall:
                    print(event)
                case .hang:
                    print(event)
                case .metadata:
                    print(event)
                case .transcript:
                    print(event)
                case .error(let error):
                    print("Error: \(error)")
                }
            }
            .store(in: &cancellables)
    }

    @MainActor
    func handleCallAction() async {
        if callState == .ended {
            await startCall()
        } else {
            endCall()
        }
    }

    @MainActor
    func startCall() async {
        callState = .loading
        let assistant = [
            "model": [
                "provider": "openai",
                "model": "gpt-3.5-turbo",
                "messages": [
                    ["role":"system", "content":"Eres un asistente"]
                ],
            ],
            
            "firstMessage": "Hola. Soy BufeBot, tu asistente para cualquier duda sobre Bufetec. ¿En qué puedo ayudarle hoy?",
            "voice": "onyx-openai"
        ] as [String : Any]
        do {
            try await vapi.start(assistantId: "55310aba-1086-4900-b7d0-bd8ae347c3cc")
        } catch {
            print("Error Empezando la llamada: \(error)")
            callState = .ended
        }
    }

    func endCall() {
        vapi.stop()
    }
}



struct SpeechBot: View {
    @StateObject private var callManager = CallManager()

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue.opacity(0.9)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Bufetec")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                AudioResponsiveCircleView()
                    .frame(width: 300, height: 300)
                    .padding()
                
                Spacer()

                Text(callManager.callStateText)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .background(callManager.callStateColor)
                    .cornerRadius(10)

                Spacer()

                Button(action: {
                    Task {
                        await callManager.handleCallAction()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(callManager.buttonColor)
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: callManager.buttonImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                    }
                }
                .disabled(callManager.callState == .loading)
                .padding(.bottom, 40)

                Spacer()
            }
        }
        .onAppear {
            callManager.setupVapi()
        }
    }
}



extension CallManager {
    var callStateText: String {
        switch callState {
        case .started: return "Call in Progress"
        case .loading: return "Connecting..."
        case .ended: return "Call Off"
        }
    }

    var callStateColor: Color {
        switch callState {
        case .started: return .green.opacity(0.8)
        case .loading: return .orange.opacity(0.8)
        case .ended: return .gray.opacity(0.8)
        }
    }

    var buttonColor: Color {
        switch callState {
        case .loading: return .gray
        case .ended: return .green
        case .started: return .red
        }
    }

    var buttonImageName: String {
        switch callState {
        case .loading: return "ellipsis"
        case .ended: return "phone.fill"
        case .started: return "phone.down.fill"
        }
    }
}
