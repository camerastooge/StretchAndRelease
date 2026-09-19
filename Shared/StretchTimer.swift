//
//  StretchTimer.swift
//  StretchAndRelease
//
//  Shared by the iOS and watchOS targets.
//

import SwiftUI
import Observation

/// The whole stretch/rest/reps state machine, in one place.
///
/// This used to be duplicated between `TimerDisplayView` and `TimerActionViewWatch`,
/// with the two copies drifting apart. It also absorbs the old `Managers` class:
/// phase, active and paused now live alongside the countdown they belong to.
///
/// Views own no timer state. They read the published properties below and call
/// `togglePlayPause()`, `reset()`, `selectNextItem()` and `selectPreviousItem()`.
@MainActor
@Observable
final class StretchTimer {

    /// Settings are readable from views as `timer.settings`, so a view that needs the
    /// timer normally only has to pull one object out of the environment.
    @ObservationIgnored let settings: TimerSettings

    // MARK: - Published state

    private(set) var phase: StretchPhase = .stop
    private(set) var isActive = false
    private(set) var isPaused = false
    private(set) var timeRemaining = 0
    private(set) var repsCompleted = 0

    /// The arc's sweep. Kept as an angle rather than a 0...1 progress value so the
    /// existing `withAnimation` timings and `Arc.animatableData` behave exactly as before.
    private(set) var endAngle = Angle(degrees: 340)

    // MARK: - Playlist

    private(set) var playlist: [PlaylistItem] = []
    private(set) var currentItem: PlaylistItem?
    private(set) var playlistIndex: Int? = 0

    // MARK: - Platform hooks

    /// Called with `true` when a run begins and `false` when it stops. The watch app
    /// hangs `StretchSession.start()` / `.stop()` off this in `ContentView.onAppear`;
    /// iOS leaves it nil. Ignored by observation: it is a hook, not display state, and
    /// assigning it should not invalidate any view.
    @ObservationIgnored var onRunningChanged: ((Bool) -> Void)?

    // MARK: - Private

    @ObservationIgnored private var ticker: Task<Void, Never>?
    @ObservationIgnored private var pendingTransition: Task<Void, Never>?

    init(settings: TimerSettings = .shared) {
        self.settings = settings
        self.timeRemaining = settings.stretchDuration
    }

    // MARK: - Convenience passthroughs

    var totalStretch: Int {
        if isPlaylistActive, let value = currentItem?.stretchDuration { return value }
        return settings.stretchDuration
    }
    var totalRest: Int {
        if isPlaylistActive, let value = currentItem?.restDuration { return value }
        return settings.restDuration
    }
    var totalReps: Int {
        if isPlaylistActive, let value = currentItem?.repsToComplete { return value }
        return settings.repsToComplete
    }
    var isPlaylistActive: Bool { settings.isPlaylistActive }
    var audioEnabled: Bool { settings.audioEnabled }
    var hapticsEnabled: Bool { settings.hapticsEnabled }

    /// The label in the middle of the arc. The phone and the watch used to compute
    /// this slightly differently; this is the union of the two.
    var displayLabel: String {
        if isPaused { return "PAUSED" }
        if isPlaylistActive, let name = currentItem?.name, !name.isEmpty { return name }
        return phase.phaseText
    }

    var repsLabel: String { "\(repsCompleted)/\(totalReps)" }

    // MARK: - Transport

    func togglePlayPause() {
        switch (phase, isPaused) {

        // Starting from a full stop, after the spoken countdown.
        case (.stop, _):
            guard pendingTransition == nil else { return }
            if audioEnabled { SoundManager.instance.playPrompt(sound: .countdownExpanded) }
            pendingTransition = Task { [weak self] in
                guard let self else { return }
                try? await Task.sleep(for: self.audioEnabled ? .seconds(3) : .milliseconds(500))
                guard !Task.isCancelled else { return }
                withAnimation(.linear(duration: 0.25)) {
                    self.phase = .stretch
                    self.isActive = true
                    self.isPaused = false
                    self.repsCompleted = 0
                }
                self.pendingTransition = nil
                self.startTicking()
                self.onRunningChanged?(true)
            }

        // Pausing. Ticks keep arriving so the rest phase can unwind.
        case (_, false):
            isPaused = true

        // Un-pausing, after the shorter countdown.
        case (_, true):
            if audioEnabled { SoundManager.instance.playPrompt(sound: .countdown) }
            pendingTransition?.cancel()
            pendingTransition = Task { [weak self] in
                guard let self else { return }
                try? await Task.sleep(for: self.audioEnabled ? .seconds(2) : .milliseconds(500))
                guard !Task.isCancelled else { return }
                withAnimation(.linear(duration: 0.25)) {
                    self.isActive = true
                    self.isPaused = false
                }
                self.pendingTransition = nil
            }
        }
    }

    func reset() {
        pendingTransition?.cancel()
        pendingTransition = nil
        stopTicking()

        phase = .stop
        isActive = false
        isPaused = false
        repsCompleted = 0
        timeRemaining = totalStretch

        withAnimation(.linear(duration: 0.5)) {
            updateEndAngle()
        }
        onRunningChanged?(false)
    }

    /// Call after a settings screen saves. Durations only take effect immediately when
    /// the timer is idle; a run in progress finishes on the values it started with.
    func settingsDidChange() {
        SoundManager.instance.volume = settings.promptVolume
        guard phase == .stop else { return }
        timeRemaining = totalStretch
        repsCompleted = 0
        withAnimation(.easeOut(duration: 0.5)) {
            updateEndAngle()
        }
    }

    // MARK: - Playlist

    /// Hand the timer the current `@Query` results. Safe to call on every change.
    func syncPlaylist(_ items: [PlaylistItem]) {
        playlist = items

        guard settings.isPlaylistActive else {
            currentItem = nil
            return
        }

        guard !items.isEmpty else {
            currentItem = nil
            playlistIndex = nil
            settings.isPlaylistActive = false
            return
        }

        let index = min(max(playlistIndex ?? 0, 0), items.count - 1)
        playlistIndex = index
        loadItem(at: index)
    }

    func selectNextItem() {
        guard !playlist.isEmpty, let current = playlistIndex else { return }
        let next = (current + 1) % playlist.count
        playlistIndex = next
        loadItem(at: next)
        announceCurrentExercise()
    }

    func selectPreviousItem() {
        guard !playlist.isEmpty, let current = playlistIndex else { return }
        let previous = current - 1 < 0 ? playlist.count - 1 : current - 1
        playlistIndex = previous
        loadItem(at: previous)
        announceCurrentExercise()
    }

    /// Loads an exercise's durations into the settings, which is what the old
    /// `loadPlaylistItem` did by writing through `@AppStorage`.
    private func loadItem(at index: Int) {
        guard playlist.indices.contains(index) else { return }

        withAnimation(.default) {
            currentItem = playlist[index]
        }

        if phase == .stop {
            timeRemaining = totalStretch
            withAnimation(.easeOut(duration: 0.5)) {
                updateEndAngle()
            }
        }
    }

    // MARK: - The clock

    private func startTicking() {
        guard ticker == nil else { return }
        ticker = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled, let self else { return }
                self.tick()
            }
        }
    }

    private func stopTicking() {
        ticker?.cancel()
        ticker = nil
    }

    private func tick() {
        switch phase {
        case .stretch: advanceStretch()
        case .rest: advanceRest()
        case .stop: stopTicking()
        }
    }

    // MARK: - State machine

    private func advanceStretch() {
        guard !isPaused else {
            isActive = false
            return
        }

        if timeRemaining > 0 {
            timeRemaining -= 1
            withAnimation(.easeOut(duration: 1)) {
                updateEndAngle()
            }
            if audioEnabled { SoundManager.instance.playTick(sound: .tick) }
            return
        }

        repsCompleted += 1

        // More reps left on this exercise.
        if repsCompleted < totalReps {
            beginRest()
            return
        }

        guard isPlaylistActive else {
            fullStop()
            return
        }

        // More exercises left in the set list.
        if playlistIndex != playlist.count - 1 {
            beginRest()
        } else {
            fullStop()
            playlistIndex = 0
            loadItem(at: 0)
        }
    }

    private func beginRest() {
        if audioEnabled { SoundManager.instance.playPrompt(sound: .rest) }
        withAnimation(.default) {
            phase = .rest
        }
    }

    private func advanceRest() {
        // Rest counts up from 0 to totalRest.
        if isPaused {
            if timeRemaining != totalRest {
                timeRemaining += 1
                withAnimation(.easeOut(duration: 1)) {
                    updateEndAngle()
                }
                return
            }

            isActive = false

            guard isPlaylistActive else {
                timeRemaining = totalStretch
                withAnimation(.easeOut(duration: 1)) {
                    phase = .stretch
                    updateEndAngle()
                }
                return
            }

            if repsCompleted != totalReps {
                timeRemaining = totalStretch
                withAnimation(.default) { phase = .stretch }
                withAnimation(.easeOut(duration: 1)) { updateEndAngle() }
            } else {
                moveToNextExerciseInRun()
                withAnimation(.default) { phase = .stretch }
            }
            return
        }

        if timeRemaining != totalRest {
            if isActive {
                timeRemaining += 1
                withAnimation(.easeOut(duration: 1)) {
                    updateEndAngle()
                }
            }
            return
        }

        guard isPlaylistActive else {
            timeRemaining = totalStretch
            if audioEnabled { SoundManager.instance.playPrompt(sound: .stretch) }
            withAnimation(.default) { phase = .stretch }
            return
        }

        // Finished every rep of this exercise: move on, with the longer countdown.
        if repsCompleted == totalReps {
            isActive = false
            moveToNextExerciseInRun()
            if audioEnabled { SoundManager.instance.playPrompt(sound: .countdownExpanded) }

            pendingTransition?.cancel()
            pendingTransition = Task { [weak self] in
                guard let self else { return }
                try? await Task.sleep(for: self.audioEnabled ? .seconds(3) : .milliseconds(500))
                guard !Task.isCancelled else { return }
                withAnimation(.default) {
                    self.phase = .stretch
                    self.isActive = true
                }
                self.pendingTransition = nil
            }
        } else {
            timeRemaining = totalStretch
            withAnimation(.default) { phase = .stretch }
            if audioEnabled { SoundManager.instance.playPrompt(sound: .stretch) }
        }
    }

    private func moveToNextExerciseInRun() {
        if let current = playlistIndex, !playlist.isEmpty {
            let next = (current + 1) % playlist.count
            playlistIndex = next
            loadItem(at: next)
        }
        timeRemaining = totalStretch
        repsCompleted = 0
    }

    private func fullStop() {
        pendingTransition?.cancel()
        pendingTransition = nil
        stopTicking()

        if audioEnabled { SoundManager.instance.playPrompt(sound: .relax) }

        withAnimation(.easeOut(duration: 0.5)) {
            phase = .stop
            isActive = false
            isPaused = false
            updateEndAngle()
        }
        timeRemaining = totalStretch
        onRunningChanged?(false)
    }

    private func updateEndAngle() {
        switch phase {
        case .stretch:
            endAngle = arcAngle(remaining: timeRemaining, total: totalStretch)
        case .rest:
            endAngle = arcAngle(remaining: timeRemaining, total: totalRest)
        case .stop:
            endAngle = Angle(degrees: 340)
        }
    }

    private func arcAngle(remaining: Int, total: Int) -> Angle {
        guard total > 0 else { return Angle(degrees: 340) }
        let degrees = Double(remaining) / Double(total) * 320 + 20
        return Angle(degrees: min(degrees, 340))
    }

    // MARK: - Accessibility

    func announceCurrentExercise() {
        guard let name = currentItem?.name, !name.isEmpty else { return }

        var announcement = AttributedString("\(name), \(totalStretch) second stretch, \(totalReps) reps.")
        announcement.accessibilitySpeechAnnouncementPriority = .high

        // Short delay so VoiceOver finishes its button tap feedback first.
        Task {
            try? await Task.sleep(for: .milliseconds(100))
            AccessibilityNotification.Announcement(announcement).post()
        }
    }
}
