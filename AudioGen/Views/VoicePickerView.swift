//
//  VoicePickerView.swift
//  AudioGen
//
//  Created by Guillermo Vertel on 19/11/25.
//

import SwiftUI

/// A dedicated view for selecting voice profiles
struct VoicePickerView: View {
    let voices: [Voice]
    @Binding var selectedVoice: Voice
    let isLoading: Bool
    
    var body: some View {
        GroupBox(label: Label(NSLocalizedString("voice_settings.title", comment: "Voice settings group title"), systemImage: "person.wave.2")) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.6)
                    } else {
                        Picker(NSLocalizedString("voice_settings.select_voice", comment: "Select voice picker label"), selection: $selectedVoice) {
                            ForEach(voices) { voice in
                                Text(voice.name).tag(voice)
                            }
                        }
                        .labelsHidden()
                        .frame(maxWidth: 200, alignment: .leading)
                    }
                    Spacer()
                }

                Text(selectedVoice.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(8)
        }
    }
}

#Preview {
    @Previewable @State var selectedVoice = Voice.default
    
    VoicePickerView(
        voices: Voice.availableVoices,
        selectedVoice: $selectedVoice,
        isLoading: false
    )
    .padding()
}
