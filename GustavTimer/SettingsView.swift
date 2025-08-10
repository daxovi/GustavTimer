import SwiftUI

struct SettingsView: View {
    @AppStorage("loopEnabled") var loopEnabled: Bool = false
    @AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true
    @AppStorage("soundsEnabled") var soundsEnabled: Bool = true
    @AppStorage("timeFormat") var timeFormat: String = "mm:ss"

    var body: some View {
        Form {
            Toggle("Loop", isOn: $loopEnabled)
            Toggle("Haptics", isOn: $hapticsEnabled)
            Toggle("Sounds", isOn: $soundsEnabled)
            Picker("Time format", selection: $timeFormat) {
                Text("ss").tag("ss")
                Text("mm:ss").tag("mm:ss")
            }
            .pickerStyle(.segmented)
        }
        .navigationTitle("Settings")
    }
}
