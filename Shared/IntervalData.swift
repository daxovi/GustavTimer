//
//  IntervalData.swift
//  GustavTimer
//
//  Created by Dalibor Janeček on 09.09.2024.
//
//  Reprezentuje jeden interval v rámci časovače.
//  Každý časovač (TimerData) obsahuje pole intervalů, např.:
//
//      [Work 20s] → [Rest 10s] → [Work 20s] → [Rest 10s] → ...
//
//  IntervalData je sdílený model používaný na iPhone i Apple Watch.
//  Závisí pouze na Foundation – žádné UIKit/WatchKit/SwiftUI importy.
//
//  Příklady vytvoření:
//
//      // Ze sekund (hlavní způsob)
//      let work = IntervalData(value: 30, name: "Work")   // 30 sekund
//      let rest = IntervalData(value: 15, name: "Rest")    // 15 sekund
//
//      // Z Duration
//      let warmup = IntervalData(duration: .seconds(120), name: "Warm Up")
//
//  Přístup k času:
//
//      work.value       // 30 (Int, sekundy) – používá se pro Codable/persistence
//      work.duration    // Duration.seconds(30) – používá se pro výpočty v TimerEngine
//
//  Codable podpora umožňuje serializaci pro SwiftData, WatchConnectivity i JSON:
//
//      let data = try JSONEncoder().encode(work)
//      let decoded = try JSONDecoder().decode(IntervalData.self, from: data)
//
//  Equatable porovnává pouze value + name (ne id), takže dva intervaly
//  se stejným nastavením jsou považovány za shodné i s různým UUID:
//
//      IntervalData(value: 30, name: "Work") == IntervalData(value: 30, name: "Work") // true
//

import Foundation

/// Jeden interval v rámci časovače (např. "Work 30s" nebo "Rest 15s").
/// Základní stavební blok celé aplikace – pole těchto intervalů tvoří jedno kolo timeru.
struct IntervalData: Identifiable, Codable, Equatable {

    /// Unikátní identifikátor pro SwiftUI ForEach a Identifiable protokol.
    /// Není zahrnut v Equatable porovnání – dva intervaly se stejným value a name
    /// jsou považovány za shodné bez ohledu na id.
    var id: UUID = UUID()

    /// Délka intervalu v celých sekundách.
    /// Toto je primární uložená hodnota – používá se pro Codable serializaci,
    /// SwiftData persistence a přenos přes WatchConnectivity.
    /// Rozsah: 0...600 (omezeno v UI, engine hodnotu nekontroluje).
    var value: Int

    /// Zobrazovaný název intervalu, např. "Work", "Rest", "Sprint".
    /// Maximální délka je omezena v UI na AppConfig.maxTimerName (12 znaků).
    var name: String

    /// Délka intervalu jako Duration – computed property nad `value`.
    /// TimerEngine interně pracuje s Duration pro sub-sekundovou přesnost.
    ///
    /// Getter:
    ///     IntervalData(value: 90, name: "Work").duration  // .seconds(90)
    ///
    /// Setter (převede Duration zpět na celé sekundy):
    ///     var interval = IntervalData(value: 0, name: "Test")
    ///     interval.duration = .seconds(45.7)
    ///     interval.value  // 45 (ořízne na celé sekundy)
    var duration: Duration {
        get {
            return .seconds(Double(value))
        }
        set {
            value = Int(newValue.components.seconds)
        }
    }

    /// Vytvoří interval se zadanou délkou v sekundách.
    ///
    ///     let work = IntervalData(value: 20, name: "Work")
    ///     let rest = IntervalData(value: 10, name: "Rest")
    init(value: Int, name: String) {
        self.value = value
        self.name = name
    }

    /// Vytvoří interval ze Swift Duration.
    /// Duration se interně převede na celé sekundy (oříznutím).
    ///
    ///     let warmup = IntervalData(duration: .seconds(120), name: "Warm Up")
    ///     warmup.value  // 120
    init(duration: Duration, name: String) {
        self.value = Int(duration.components.seconds)
        self.name = name
    }

    /// Porovnání podle value a name – id se ignoruje.
    /// Dva intervaly se stejným nastavením jsou shodné i s různým UUID.
    ///
    ///     let a = IntervalData(value: 30, name: "Work")
    ///     let b = IntervalData(value: 30, name: "Work")
    ///     a == b  // true (i když a.id != b.id)
    static func == (lhs: IntervalData, rhs: IntervalData) -> Bool {
        return lhs.value == rhs.value && lhs.name == rhs.name
    }
}
