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

/// ViewModel pro správu časovače - zjednodušená verze s českými komentáři
class TimerViewModel: ObservableObject {
    // MARK: - Konfigurace
    let maxTimers = AppConfig.maxTimerCount
    let maxCountdownValue = AppConfig.maxTimerValue
    
    /// Kontrola zda je dosaženo maximálního počtu časovačů
    var isTimerFull: Bool { timers.count >= maxTimers }
    
    // MARK: - Publikované vlastnosti
    @Published var round: Int = 0
    @Published var showingSheet = false
    @Published var showingWhatsNew: Bool = false
    @Published var timers: [IntervalData] = []
    @Published var isTimerRunning = false
    @Published var editMode = EditMode.inactive
    @Published var startedFromDeeplink: Bool = false
    
    // MARK: - Nastavení (AppStorage)
    @AppStorage("isLooping") var isLooping: Bool = true
    @AppStorage("stopCounter") var stopCounter: Int = 0
    @AppStorage("whatsNewVersion") var whatsNewVersion: Int = 0
    @AppStorage("selectedSound") var selectedSound: String = "beep"
    @AppStorage("isSoundEnabled") var isSoundEnabled: Bool = true
    @AppStorage("isVibrating") var isVibrating: Bool = false
    @AppStorage("timeDisplayFormat") var timeDisplayFormat: TimeDisplayFormat = .seconds
    
    // MARK: - Soukromé vlastnosti
    var activeTimerIndex: Int = 0  // Veřejné pro přístup z ProgressArrayView
    private var timer: AnyCancellable?
    private var modelContext: ModelContext?
    @Published private var currentTenths: Int = 0  // Počítadlo desetin sekund - sjednocená verze
    
    // MARK: - Vypočítané vlastnosti
    /// Aktuální čas v sekundách (počítaný z desetin)
    var count: Int { currentTenths / 10 }
    
    /// Pokrok aktivního časovače (0.0 - 1.0)
    var progress: Double {
        guard activeTimerIndex < timers.count else { return 0.0 }
        let totalTenths = Double(timers[activeTimerIndex].value * 10)
        let elapsed = totalTenths - Double(currentTenths)
        guard totalTenths > 0 else { return 0.0 }
        let progressValue = elapsed / totalTenths
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
            IntervalData(value: 60, name: "Práce"),
            IntervalData(value: 30, name: "Odpočinek")
        ]
        currentTenths = timers[0].value * 10
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
        if round == 0 { round = 1 }
        
        // Pokud se časovač spouští poprvé nebo po resetu, inicializuj currentTenths
        if currentTenths <= 0 {
            currentTenths = timers[activeTimerIndex].value * 10
        }
        
        UIApplication.shared.isIdleTimerDisabled = true
        isTimerRunning = true
        
        timer = Timer
            .publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimer()
            }
    }
    
    /// Zastavení časovače
    func stopTimer() {
        UIApplication.shared.isIdleTimerDisabled = false
        isTimerRunning = false
        timer = nil
        stopCounter += 1
    }
    
    /// Aktualizace časovače každých 0.1 sekundy
    private func updateTimer() {
        currentTenths -= 1
        
        // Pokud čas vyprší, přejdi na další časovač
        if currentTenths <= 0 {
            switchToNextTimer()
        }
    }
    
    /// Přechod na další časovač v sekvenci
    private func switchToNextTimer() {
        activeTimerIndex += 1
        
        if activeTimerIndex >= timers.count {
            // Konec kola
            handleRoundCompletion()
        } else {
            // Další časovač v kole
            vibrate()
            playSound()
            currentTenths = timers[activeTimerIndex].value * 10
            
            // Přeskočit časovače s nulovou délkou
            if timers[activeTimerIndex].value <= 0 {
                switchToNextTimer()
            }
        }
    }
    
    /// Dokončení aktuálního kola
    private func handleRoundCompletion() {
        activeTimerIndex = 0
        
        if isLooping {
            // Pokračovat v dalším kole
            vibrateRound()
            playSound()
            round += 1
            currentTenths = timers[0].value * 10
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
        round = 0
        timer = nil
        activeTimerIndex = 0
        isTimerRunning = false
        currentTenths = timers[0].value * 10
        startedFromDeeplink = false
    }
    
    /// Přeskočit aktuální časovač
    func skipLap() {
        currentTenths = 0
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
        let totalTime = Double(timers.reduce(0) { $0 + $1.value })
        guard totalTime > 0, timerIndex < timers.count else { return 0 }
        return Double(timers[timerIndex].value) / totalTime
    }
    
    // MARK: - Formátování času
    /// Formátování času z celkových sekund
    func formattedTime(from totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        return minutes > 0
            ? String(format: "%d:%02d", minutes, seconds)
            : String(format: "%d", seconds)
    }
    
    /// Formátování aktuálního času podle nastaveného formátu
    func formattedCurrentTime() -> String {
        switch timeDisplayFormat {
        case .seconds:
            return "\(count)"
        case .minutesSecondsHundredths:
            let minutes = currentTenths / 600  // 600 desetin = 1 minuta
            let remainingTenths = currentTenths % 600
            let seconds = remainingTenths / 10
            let tenths = remainingTenths % 10
            
            if minutes > 0 {
                return String(format: "%d:%02d.%01d", minutes, seconds, tenths)
            } else {
                return String(format: "%d.%01d", seconds, tenths)
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
        
        if count == 0 && timers[activeTimerIndex].value > 1 {
            SoundManager.instance.playSound(sound: .final, theme: selectedSound)
        } else if count == 3 && count > 0 && timers[activeTimerIndex].value > 9 && isTimerRunning {
            SoundManager.instance.playSound(sound: .countdown, theme: selectedSound)
        }
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
                predicate: #Predicate<TimerData> { $0.id == 0 }
            )
            let timerDataArray = try context.fetch(descriptor)
            
            if let timerData = timerDataArray.first {
                timers = timerData.intervals
                // Resetuj currentTenths pouze při explicitním požadavku (např. při inicializaci)
                if resetCurrentState && !timers.isEmpty {
                    currentTenths = timers[0].value * 10
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
                predicate: #Predicate<TimerData> { $0.id == 0 }
            )
            let timerDataArray = try context.fetch(descriptor)
            
            let timerData: TimerData
            if let existingData = timerDataArray.first {
                timerData = existingData
            } else {
                timerData = TimerData(id: 0, name: "Výchozí časovač")
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