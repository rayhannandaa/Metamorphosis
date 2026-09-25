import AVFAudio
import Foundation

final class GameAudioManager {
    static let shared = GameAudioManager()

    private let isAudioEnabled = false
    private let audioQueue = DispatchQueue(
        label: "com.rayhannanda.metamorphosis.audio",
        qos: .userInitiated
    )

    private var backgroundPlayer: AVAudioPlayer?
    private var thunderPlayer: AVAudioPlayer?
    private var isSessionActive = false
    private var isActivationInProgress = false
    private var pendingPlayback: [() -> Void] = []

    private init() {}

    func startBackgroundMusic() {
        guard isAudioEnabled else { return }
        performWhenSessionIsActive { [weak self] in
            self?.playBackgroundMusicIfNeeded()
        }
    }

    func playThunder() {
        guard isAudioEnabled else { return }
        performWhenSessionIsActive { [weak self] in
            self?.playThunderEffect()
        }
    }

    private func performWhenSessionIsActive(
        _ playback: @escaping () -> Void
    ) {
        audioQueue.async { [weak self] in
            guard let self else { return }

            if isSessionActive {
                playback()
                return
            }

            pendingPlayback.append(playback)
            activateAudioSessionIfNeeded()
        }
    }

    private func activateAudioSessionIfNeeded() {
        guard !isSessionActive, !isActivationInProgress else { return }
        isActivationInProgress = true

        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(.ambient, mode: .default)
        } catch {
            isActivationInProgress = false
            pendingPlayback.removeAll()
            return
        }

        if #available(iOS 27.0, *) {
            session.activate(options: []) { [weak self] activated, _ in
                guard let self else { return }

                self.audioQueue.async { [weak self] in
                    self?.finishSessionActivation(succeeded: activated)
                }
            }
        } else {
            do {
                try session.setActive(true)
                finishSessionActivation(succeeded: true)
            } catch {
                finishSessionActivation(succeeded: false)
            }
        }
    }

    private func finishSessionActivation(succeeded: Bool) {
        isActivationInProgress = false

        guard succeeded else {
            pendingPlayback.removeAll()
            return
        }

        isSessionActive = true
        let playbackRequests = pendingPlayback
        pendingPlayback.removeAll()
        playbackRequests.forEach { $0() }
    }

    private func playBackgroundMusicIfNeeded() {
        if let backgroundPlayer {
            guard !backgroundPlayer.isPlaying else { return }
            backgroundPlayer.play()
            return
        }

        guard let url = Bundle.main.url(
            forResource: "bgmusic",
            withExtension: "mp3"
        ) else { return }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = 0.35
            player.prepareToPlay()
            player.play()
            backgroundPlayer = player
        } catch {
            backgroundPlayer = nil
        }
    }

    private func playThunderEffect() {
        guard let url = Bundle.main.url(
            forResource: "IntroThunder",
            withExtension: "wav"
        ) else { return }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = 0.8
            player.prepareToPlay()
            player.play()
            thunderPlayer = player
        } catch {
            thunderPlayer = nil
        }
    }
}
