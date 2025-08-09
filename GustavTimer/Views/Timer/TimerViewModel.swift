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

/// ViewModel pro správu časovače - zjednodušená verze
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
    private var currentTenths: Int = 0  // Počítadlo desetin sekund
    
    // MARK: - Vypočítané vlastnosti
    /// Aktuální čas v sekundách
    var count: Int { currentTenths / 10 }
    
    /// Pokrok aktivního časovače (0.0 - 1.0)
    var progress: Double {
        guard activeTimerIndex < timers.count else { return 0.0 }
        let totalTenths = Double(timers[activeTimerIndex].value * 10)
        let elapsed = totalTenths - Double(currentTenths)
        return totalTenths > 0 ? elapsed / totalTenths : 0.0
    }
    
    // MARK: - Inicializace
    init() {
        nastavitVychoziCasovace()
    }
    
    /// Nastavení výchozích časovačů
    private func nastavitVychoziCasovace() {
        timers = [
            IntervalData(value: 60, name: "Práce"),
            IntervalData(value: 30, name: "Odpočinek")
        ]
        currentTenths = timers[0].value * 10
    }
    
    /// Nastavení kontextu pro práci s daty
    func setModelContext(_ context: ModelContext) {
        modelContext = context
        nacistCasovace()
    }
    
    // MARK: - Logika časovače
    /// Spustí nebo zastaví časovač
    func startStopTimer() {
        isTimerRunning ? zastavitCasovac() : spustitCasovac()
    }
    
    /// Spuštění časovače
    private func spustitCasovac() {
        if round == 0 { round = 1 }
        
        // Zajistit, že máme platnou hodnotu
        currentTenths = count * 10
        
        UIApplication.shared.isIdleTimerDisabled = true
        isTimerRunning = true
        
        timer = Timer
            .publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.aktualizovatCasovac()
            }
    }
    
    /// Zastavení časovače
    private func zastavitCasovac() {
        UIApplication.shared.isIdleTimerDisabled = false
        isTimerRunning = false
        timer = nil
        stopCounter += 1
    }
    
    
    /// Aktualizace časovače každých 0.1 sekundy
    private func aktualizovatCasovac() {
        currentTenths -= 1
        
        // Pokud čas vyprší, přejdi na další časovač
        if currentTenths <= 0 {
            prejitNaDalsiCasovac()
        }
    }
    
    /// Přechod na další časovač v sekvenci
    private func prejitNaDalsiCasovac() {
        activeTimerIndex += 1
        
        if activeTimerIndex >= timers.count {
            // Konec kola
            dokoncitKolo()
        } else {
            // Další časovač v kole
            vibrace()
            prehratZvuk()
            currentTenths = timers[activeTimerIndex].value * 10
            
            // Přeskočit časovače s nulovou délkou
            if timers[activeTimerIndex].value <= 0 {
                prejitNaDalsiCasovac()
            }
        }
    }
    
    
    /// Dokončení aktuálního kola
    private func dokoncitKolo() {
        activeTimerIndex = 0
        
        if isLooping {
            // Pokračovat v dalším kole
            vibraceKolo()
            prehratZvuk()
            round += 1
            currentTenths = timers[0].value * 10
        } else {
            // Ukončit časovač
            vibraceKonec()
            prehratZvuk()
            resetovatCasovac()
        }
    }
    
    /// Reset časovače do výchozího stavu
    func resetovatCasovac() {
        zastavitCasovac()
        round = 0
        timer = nil
        activeTimerIndex = 0
        isTimerRunning = false
        currentTenths = timers[0].value * 10
        startedFromDeeplink = false
        nacistCasovace()
    }
    
    /// Přeskočit aktuální časovač
    func preskocitCasovac() {
        currentTenths = 0
    }
    
    // MARK: - Správa časovačů
    /// Přidání nového časovače
    func pridatCasovac() {
        guard !isTimerFull else { return }
        timers.append(IntervalData(value: 5, name: "Kolo \(timers.count + 1)"))
        ulozitCasovace()
    }
    
    /// Odstranění časovačů podle indexu
    func odstranit(at offsets: IndexSet) {
        timers.remove(atOffsets: offsets)
        ulozitCasovace()
    }
    
    /// Odstranění konkrétního časovače
    func odstranit(index: Int) {
        guard index < timers.count else { return }
        timers.remove(at: index)
        ulozitCasovace()
    }
    
    // MARK: - Progress bar a zobrazení
    /// Výpočet šířky progress baru pro konkrétní časovač
    func sirkaProgressBaru(geometry: GeometryProxy, timerIndex: Int) -> Double {
        guard timerIndex < timers.count else { return 0.0 }
        
        let totalWidth = geometry.size.width - (CGFloat(timers.count - 1) * 5)
        let ratio = pomerCasu(for: timerIndex)
        return totalWidth * ratio
    }
    
    /// Výpočet poměru času pro jednotlivé časovače
    private func pomerCasu(for timerIndex: Int) -> Double {
        let celkovyCas = Double(timers.reduce(0) { $0 + $1.value })
        guard celkovyCas > 0, timerIndex < timers.count else { return 0 }
        return Double(timers[timerIndex].value) / celkovyCas
    }
    
    // MARK: - Formátování času
    /// Formátování času z celkových sekund
    func formatovatCas(from totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        return minutes > 0
            ? String(format: "%d:%02d", minutes, seconds)
            : String(format: "%d", seconds)
    }
    
    /// Formátování aktuálního času podle nastaveného formátu
    func formatovatAktualniCas() -> String {
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
    func prepnoutNastaveni() {
        showingSheet.toggle()
        resetovatCasovac()
    }
    
    // MARK: - Zpětná vazba (vibrace a zvuky)
    /// Lehká vibrace při přechodu mezi časovači
    private func vibrace() {
        guard isVibrating && isTimerRunning else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    /// Vibrace při dokončení kola
    private func vibraceKolo() {
        guard isVibrating && isTimerRunning else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// Vibrace při ukončení časovače
    private func vibraceKonec() {
        guard isVibrating && isTimerRunning else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    /// Přehrání zvuku podle situace
    private func prehratZvuk() {
        guard isSoundEnabled && isTimerRunning else { return }
        
        if count == 0 && timers[activeTimerIndex].value > 1 {
            SoundManager.instance.playSound(sound: .final, theme: selectedSound)
        } else if count == 3 && count > 0 && timers[activeTimerIndex].value > 9 {
            SoundManager.instance.playSound(sound: .countdown, theme: selectedSound)
        }
    }
    
    // MARK: - Co je nového
    /// Zobrazení okna s novinkami
    func zobrazitCoJeNoveho() {
        if whatsNewVersion < AppConfig.version {
            showingWhatsNew = true
            whatsNewVersion = AppConfig.version
        }
    }
    
    // MARK: - Odkazy z aplikací (Deep Links)  
    /// Zpracování odkazu z jiné aplikace
    func zpracovatOdkaz(url: URL) {
        guard url.scheme == "gustavtimerapp",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else { return }
        
        switch host {
        case "whatsnew":
            showingWhatsNew = true
        case "timer":
            zpracovatTimerOdkaz(components: components)
        default:
            print("Neznámý deep link: \(host)")
        }
    }
    
    /// Zpracování odkazu s časovačem
    private func zpracovatTimerOdkaz(components: URLComponents) {
        let puvodnyCasovace = timers
        var noveCasovace: [IntervalData] = []
        
        if let queryItems = components.queryItems {
            for item in queryItems {
                if let value = item.value, let intValue = Int(value) {
                    noveCasovace.append(IntervalData(value: intValue, name: item.name))
                }
            }
        }
        
        if !noveCasovace.isEmpty {
            timers = noveCasovace
            startedFromDeeplink = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.showingSheet = true
            }
        } else {
            timers = puvodnyCasovace
        }
    }
}

// MARK: - Správa dat
extension TimerViewModel {
    /// Načtení časovačů z databáze
    private func nacistCasovace() {
        guard let context = modelContext else {
            nastavitVychoziCasovace()
            return
        }
        
        do {
            let descriptor = FetchDescriptor<TimerData>()
            let timerDataArray = try context.fetch(descriptor)
            
            if let timerData = timerDataArray.first {
                timers = timerData.intervals
                if !timers.isEmpty {
                    currentTenths = timers[0].value * 10
                }
            } else {
                vytvoriaUlozitVychoziCasovace()
            }
        } catch {
            print("Chyba při načítání časovačů: \(error)")
            nastavitVychoziCasovace()
        }
    }
    
    /// Uložení časovačů do databáze
    private func ulozitCasovace() {
        guard let context = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<TimerData>()
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
    private func vytvoriaUlozitVychoziCasovace() {
        nastavitVychoziCasovace()
        ulozitCasovace()
    }
}

// MARK: - Kompatibilita se starými názvy metod (pro Views)
extension TimerViewModel {
    /// Kompatibilita pro resetTimer 
    func resetTimer() { resetovatCasovac() }
    
    /// Kompatibilita pro addTimer
    func addTimer() { pridatCasovac() }
    
    /// Kompatibilita pro removeTimer
    func removeTimer(at offsets: IndexSet) { odstranit(at: offsets) }
    
    /// Kompatibilita pro removeTimer s indexem
    func removeTimer(index: Int) { odstranit(index: index) }
    
    /// Kompatibilita pro skipLap
    func skipLap() { preskocitCasovac() }
    
    /// Kompatibilita pro formattedTime
    func formattedTime(from totalSeconds: Int) -> String { formatovatCas(from: totalSeconds) }
    
    /// Kompatibilita pro formattedCurrentTime
    func formattedCurrentTime() -> String { formatovatAktualniCas() }
    
    /// Kompatibilita pro toggleSheet
    func toggleSheet() { prepnoutNastaveni() }
    
    /// Kompatibilita pro getProgressBarWidth
    func getProgressBarWidth(geometry: GeometryProxy, timerIndex: Int) -> Double {
        sirkaProgressBaru(geometry: geometry, timerIndex: timerIndex)
    }
    
    /// Kompatibilita pro showWhatsNew
    func showWhatsNew() { zobrazitCoJeNoveho() }
    
    /// Kompatibilita pro handleDeepLink
    func handleDeepLink(url: URL) { zpracovatOdkaz(url: url) }
}
