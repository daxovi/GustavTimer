import Foundation
import UIKit

protocol HapticsService {
    func intervalEnd()
    func cycleEnd()
}

final class HapticsServiceProd: HapticsService {
    func intervalEnd() {
        guard UserDefaults.standard.bool(forKey: "hapticsEnabled") else { return }
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }
    func cycleEnd() {
        guard UserDefaults.standard.bool(forKey: "hapticsEnabled") else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
