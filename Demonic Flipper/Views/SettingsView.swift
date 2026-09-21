//
//  SettingsView.swift
//  Demonic Flipper
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var highScoreStore: HighScoreStore
    @AppStorage(AppSettings.soundEnabledKey) private var soundEnabled = true
    @AppStorage(AppSettings.hapticsEnabledKey) private var hapticsEnabled = true
    @State private var showResetConfirmation = false

    var body: some View {
        ZStack {
            DemonicBackground()

            VStack(spacing: 24) {
                Text("EINSTELLUNGEN")
                    .font(DemonicFont.title(size: 30))
                    .foregroundStyle(DemonicPalette.neonRed)
                    .padding(.top, 40)

                VStack(spacing: 16) {
                    Toggle(isOn: $soundEnabled) {
                        Label("Höllenklänge", systemImage: "speaker.wave.2.fill")
                    }
                    Toggle(isOn: $hapticsEnabled) {
                        Label("Dämonisches Feedback", systemImage: "waveform")
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: DemonicPalette.neonRed))
                .foregroundStyle(DemonicPalette.steelSilver)
                .font(DemonicFont.body())
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(DemonicPalette.charcoal.opacity(0.85))
                )
                .padding(.horizontal, 24)

                Button {
                    showResetConfirmation = true
                } label: {
                    Text("Highscores zurücksetzen")
                        .font(DemonicFont.heading(size: 15))
                        .foregroundStyle(DemonicPalette.bloodRed)
                }
                .confirmationDialog("Alle Highscores löschen?", isPresented: $showResetConfirmation, titleVisibility: .visible) {
                    Button("Löschen", role: .destructive) {
                        highScoreStore.clear()
                    }
                    Button("Abbrechen", role: .cancel) {}
                }

                Spacer()

                MenuButton(title: "Zurück", systemImage: "arrow.uturn.left") {
                    router.route = .menu
                }
                .padding(.horizontal, 36)
                .padding(.bottom, 30)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppRouter())
        .environmentObject(HighScoreStore())
}
