//
//  TimerViewModel.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 19.04.2023.
//

import Foundation
import Combine
import SwiftUI
import AVKit
import AVFoundation
import SwiftData
import Lottie

/// ViewModel pro správu časovače - zjednodušená verze s českými komentáři
class TimerViewModel: ObservableObject {
    // MARK: - Konfigurace
    let maxTimers = AppConfig.maxTimerCount
    let maxCountdownValue = AppConfig.maxTimerValue
    
    /// Kontrola zda je dosaženo maximálního počtu časovačů
    var isTimerFull: Bool { timers.count >= maxTimers }
    
    // MARK: - Publikované vlastnosti
    @Published var finishedRounds: Int = 0
    @Published var showingSheet = false
    @Published var showingWhatsNew: Bool = false
    @Published var timers: [IntervalData] = []
    @Published var isTimerRunning = false
    @Published var editMode = EditMode.inactive
    @Published var startedFromDeeplink: Bool = false
    @Published private var orientation = UIDeviceOrientation.unknown
    
    // MARK: - Nastavení (AppStorage)
    @AppStorage("rounds") var rounds: Int = -1 // -1 znamená nekonečno
    @AppStorage("stopCounter") var stopCounter: Int = 0
    @AppStorage("whatsNewVersion") var whatsNewVersion: Int = 0
    @AppStorage("isSoundEnabled") var isSoundEnabled: Bool = true
    @AppStorage("isVibrating") var isVibrating: Bool = false
    @AppStorage("timeDisplayFormat") var timeDisplayFormat: TimeDisplayFormat = .seconds
    
    // MARK: Lottie animation state
    @Published var appearanceIconAnimation = LottiePlaybackMode.paused(at: .frame(0))
    @Published var loopIconAnimation = LottiePlaybackMode.paused(at: .frame(0))
    
    // MARK: - Soukromé vlastnosti
    var activeTimerIndex: Int = 0  // Veřejné pro přístup z ProgressArrayView
    private var sound: SoundModel?
    private var timerTask: Task<Void, Never>?
    private var modelContext: ModelContext?
    @Published private var remainingTime: Duration = .seconds(0)
    
    // MARK: - Vypočítané vlastnosti
    /// Aktuální čas v sekundách
    var count: Int {
        min(Int(remainingTime.components.seconds), Int(timers[activeTimerIndex].duration.components.seconds))
    }
    
    /// Pokrok aktivního časovače (0.0 - 1.0)
    var progress: Double {
        guard activeTimerIndex < timers.count else { return 0.0 }
        let totalDuration = timers[activeTimerIndex].duration
        guard totalDuration > .zero else { return 0.0 }
        
        // Převod Duration na milisekundy pro přesnější výpočet
        let totalMs = Double(totalDuration.components.seconds) * 1000 +
                     Double(totalDuration.components.attoseconds) / 1e15
        let remainingMs = Double(remainingTime.components.seconds) * 1000 +
                         Double(remainingTime.components.attoseconds) / 1e15
        
        guard totalMs > 0 else { return 0.0 }
        
        // Výpočet uplynulého času a progress hodnoty
        let elapsedMs = totalMs - remainingMs
        let progressValue = elapsedMs / totalMs
        
        // Zajistit, že progress je vždy mezi 0.0 a 1.0
        return max(0.0, min(1.0, progressValue))
    }
    
    // MARK: - Inicializace
    init() {
        setupDefaultTimers()
    }
    
    /// Nastavení výchozích časovačů
    private func setupDefaultTimers() {
        timers = [
            IntervalData(value: 60, name: "Work"),
            IntervalData(value: 30, name: "Rest")
        ]
        remainingTime = timers[0].duration
    }
    
    /// Nastavení kontextu pro práci s daty
    func setModelContext(_ context: ModelContext) {
        modelContext = context
        loadTimers(resetCurrentState: true)
    }
    
    /// Znovu načte časovače z databáze s volitelným resetováním aktuálního stavu
    func reloadTimers(resetCurrentState: Bool = false) {
        loadTimers(resetCurrentState: resetCurrentState)
    }
    
    // MARK: - Logika časovače
    /// Spustí nebo zastaví časovač
    func startStopTimer() {
        isTimerRunning ? stopTimer() : startTimer()
    }
    
    /// Spuštění časovače
    private func startTimer() {
        // Pokud začínáme první kolo, nastavíme počítadlo na 1
        if finishedRounds == 0 { finishedRounds = 1 }
        
        // Pokud se časovač spouští poprvé nebo po resetu, inicializuj remainingTime
        if remainingTime <= .zero {
            remainingTime = timers[activeTimerIndex].duration
        }
        
        // Zakázat automatické uspání zařízení během běhu časovače
        UIApplication.shared.isIdleTimerDisabled = true
        isTimerRunning = true
        
        // Zrušit předchozí běžící úlohu časovače, pokud existuje
        timerTask?.cancel()
        
        // Vytvoření nové asynchronní úlohy pro časovač
        timerTask = Task { [weak self] in
            // Prevence memory leaků pomocí weak self
            guard let self = self else { return }
            
            // Nastavení intervalu tikání časovače (100ms = 10x za sekundu)
            let tickInterval: Duration = .milliseconds(10)
            // Použití kontinuálních hodin pro přesné měření času
            let clock = ContinuousClock()
            
            // Hlavní smyčka časovače - běží dokud není úloha zrušena nebo časovač zastaven
            while !Task.isCancelled && self.isTimerRunning {
                // Zaznamenání času na začátku cyklu
                let start = clock.now
                
                // Aktualizace časovače na hlavním vlákně, protože upravuje UI
                await MainActor.run {
                    self.updateTimer(tick: tickInterval)
                }
                
                // Výpočet skutečně uplynulého času pro přesné časování
                let elapsed = clock.now - start
                // Výpočet zbývajícího času do dalšího tiku
                let sleepTime = tickInterval - elapsed
                // Uspání úlohy na zbývající čas, pokud je kladný
                if sleepTime > .zero {
                    try? await Task.sleep(for: sleepTime)
                }
            }
        }
    }
    
    /// Zastavení časovače
    func stopTimer() {
        UIApplication.shared.isIdleTimerDisabled = false
        isTimerRunning = false
        timerTask?.cancel()
        timerTask = nil
        stopCounter += 1
    }
    
    /// Aktualizace časovače každý tick
    private func updateTimer(tick: Duration) {
        remainingTime -= tick
        
        // Pokud čas vyprší, přejdi na další časovač
        if remainingTime <= .zero {
            switchToNextTimer()
        }
    }
    
    /// Přechod na další časovač v sekvenci
    private func switchToNextTimer() {
        activeTimerIndex += 1
        appearanceIconAnimation = .playing(.fromProgress(0, toProgress: 1, loopMode: .playOnce))
        
        if activeTimerIndex >= timers.count {
            // Konec kola
            handleRoundCompletion()
        } else {
            // Další časovač v kole
            vibrate()
            playSound()
            remainingTime = timers[activeTimerIndex].duration
            
            // Přeskočit časovače s nulovou délkou
            if timers[activeTimerIndex].duration <= .zero {
                switchToNextTimer()
            }
        }
    }
    
    /// Dokončení aktuálního kola
    private func handleRoundCompletion() {
        activeTimerIndex = 0
        
        if rounds == -1 || finishedRounds < rounds {
            // Pokračovat v dalším kole
            vibrateRound()
            playSound()
            finishedRounds += 1
            remainingTime = timers[0].duration
            loopIconAnimation = .playing(.fromProgress(0, toProgress: 1, loopMode: .playOnce))
        } else {
            // Ukončit časovač
            vibrateEnd()
            playSound()
            resetTimer()
        }
    }
    
    /// Reset časovače do výchozího stavu
    func resetTimer() {
        stopTimer()
        finishedRounds = 0
        timerTask = nil
        activeTimerIndex = 0
        isTimerRunning = false
        remainingTime = timers[0].duration
        startedFromDeeplink = false
    }
    
    /// Přeskočit aktuální časovač
    func skipLap() {
        remainingTime = .zero
    }
    
    // MARK: - Správa časovačů
    /// Přidání nového časovače
    func addTimer() {
        guard !isTimerFull else { return }
        timers.append(IntervalData(value: 5, name: "Kolo \(timers.count + 1)"))
        saveTimers()
    }
    
    /// Odstranění časovačů podle indexu
    func removeTimer(at offsets: IndexSet) {
        timers.remove(atOffsets: offsets)
        saveTimers()
    }
    
    /// Odstranění konkrétního časovače
    func removeTimer(index: Int) {
        guard index < timers.count else { return }
        timers.remove(at: index)
        saveTimers()
    }
    
    // MARK: - Progress bar a zobrazení
    /// Výpočet šířky progress baru pro konkrétní časovač
    func getProgressBarWidth(geometry: GeometryProxy, timerIndex: Int) -> Double {
        guard timerIndex < timers.count else { return 0.0 }
        
        let totalWidth = geometry.size.width - (CGFloat(timers.count - 1) * 5)
        let ratio = getTimeRatio(for: timerIndex)
        return totalWidth * ratio
    }
    
    /// Výpočet poměru času pro jednotlivé časovače
    private func getTimeRatio(for timerIndex: Int) -> Double {
        // Převedení duration na sekundy pro spolehlivější výpočet
        let totalDuration = timers.reduce(0.0) { $0 + Double(truncating: $1.duration.components.seconds as NSNumber) }
        guard totalDuration > 0, timerIndex < timers.count else { return 0 }
        
        let timerDuration = Double(truncating: timers[timerIndex].duration.components.seconds as NSNumber)
        return timerDuration / totalDuration
    }
    
    // MARK: - Formátování času
    /// Formátování času z Duration
    func formattedTime(from duration: Duration) -> String {
        let totalSeconds = Int(duration.components.seconds)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        return minutes > 0
            ? String(format: "%d:%02d", minutes, seconds)
            : String(format: "%d", seconds)
    }
    
    /// Formátování aktuálního času podle nastaveného formátu
    func formattedCurrentTime(timeDisplayFormat: TimeDisplayFormat) -> String {
        switch timeDisplayFormat {
        case .seconds:
            return "\(count)"
        case .minutesSecondsHundredths:
            let components = remainingTime.components
            let minutes = Int(components.seconds) / 60
            let seconds = Int(components.seconds) % 60
            let tenths = Int(components.attoseconds / 10_000_000_000_000_000)
            
            if minutes > 0 {
                return String(format: "%d:%02d.%02d", minutes, seconds, tenths)
            } else {
                return String(format: "%d.%02d", seconds, tenths)
            }
        }
    }
    
    /// Zobrazení/skrytí nastavení
    func toggleSheet() {
        showingSheet.toggle()
        stopTimer()  // Zastavit časovač při otevření nastavení
        resetTimer()
    }
    
    // MARK: - Zpětná vazba (vibrace a zvuky)
    /// Lehká vibrace při přechodu mezi časovači
    private func vibrate() {
        guard isVibrating && isTimerRunning else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Vibrace při dokončení kola
    private func vibrateRound() {
        guard isVibrating && isTimerRunning else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// Vibrace při ukončení časovače
    private func vibrateEnd() {
        guard isVibrating else { return }  // Removed isTimerRunning check for end vibration
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    /// Přehrání zvuku podle situace
    private func playSound() {
        guard isSoundEnabled else { return }
        if let sound {
            SoundManager.instance.playSound(soundModel: sound)
        }
    }
    
    func setSound(sound: SoundModel?) {
        isSoundEnabled = sound != nil
        self.sound = sound
    }
    
    // MARK: - Co je nového
    /// Zobrazení okna s novinkami
    func showWhatsNew() {
        if whatsNewVersion < AppConfig.version {
            showingWhatsNew = true
            whatsNewVersion = AppConfig.version
        }
    }
    
    // MARK: - Odkazy z aplikací (Deep Links)
    /// Zpracování odkazu z jiné aplikace
    func handleDeepLink(url: URL) {
        guard url.scheme == "gustavtimerapp",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else { return }
        
        switch host {
        case "whatsnew":
            showingWhatsNew = true
        case "timer":
            handleTimerDeepLink(components: components)
        default:
            print("Neznámý deep link: \(host)")
        }
    }
    
    /// Zpracování odkazu s časovačem
    private func handleTimerDeepLink(components: URLComponents) {
        let originalTimers = timers
        var newTimers: [IntervalData] = []
        
        if let queryItems = components.queryItems {
            for item in queryItems {
                if let value = item.value, let intValue = Int(value) {
                    newTimers.append(IntervalData(value: intValue, name: item.name))
                }
            }
        }
        
        if !newTimers.isEmpty {
            timers = newTimers
            startedFromDeeplink = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.showingSheet = true
            }
        } else {
            timers = originalTimers
        }
    }
}

// MARK: - Správa dat
extension TimerViewModel {
    /// Načtení časovačů z databáze
    private func loadTimers(resetCurrentState: Bool = true) {
        guard let context = modelContext else {
            setupDefaultTimers()
            return
        }
        
        do {
            // Vždy načteme konkrétně časovač s id: 0 (výchozí časovač)
            let descriptor = FetchDescriptor<TimerData>(
                predicate: #Predicate<TimerData> { $0.order == 0 }
            )
            let timerDataArray = try context.fetch(descriptor)
            
            if let timerData = timerDataArray.first {
                timers = timerData.intervals
                // Resetuj remainingTime pouze při explicitním požadavku (např. při inicializaci)
                if resetCurrentState && !timers.isEmpty {
                    resetTimer()
                }
            } else {
                createAndSaveDefaultTimers()
            }
        } catch {
            print("Chyba při načítání časovačů: \(error)")
            setupDefaultTimers()
        }
    }
    
    /// Uložení časovačů do databáze
    private func saveTimers() {
        guard let context = modelContext else { return }
        
        do {
            // Vždy pracujeme s časovačem s id: 0 (výchozí časovač)
            let descriptor = FetchDescriptor<TimerData>(
                predicate: #Predicate<TimerData> { $0.order == 0 }
            )
            let timerDataArray = try context.fetch(descriptor)
            
            let timerData: TimerData
            if let existingData = timerDataArray.first {
                timerData = existingData
            } else {
                timerData = AppConfig.defaultTimer
                context.insert(timerData)
            }
            
            timerData.intervals = timers
            try context.save()
        } catch {
            print("Chyba při ukládání časovačů: \(error)")
        }
    }
    
    /// Vytvoření a uložení výchozích časovačů
    private func createAndSaveDefaultTimers() {
        setupDefaultTimers()
        saveTimers()
    }
}
