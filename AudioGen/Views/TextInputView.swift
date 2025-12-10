//
//  TextInputView.swift
//  AudioGen
//
//  Created by GitHub Copilot on 09/12/25.
//

import SwiftUI

struct TextInputView: View {
    @Binding var text: String
    @Binding var instructions: String
    @Binding var isInstructionsExpanded: Bool
    
    let characterCount: Int
    let isAtCharacterLimit: Bool
    let isNearCharacterLimit: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Content GroupBox
            GroupBox(label: Label(NSLocalizedString("content.title", comment: "Content group title"), systemImage: "text.quote")) {
                VStack(alignment: .leading, spacing: 8) {
                    TextEditor(text: $text)
                        .font(.body)
                        .frame(minHeight: 200)
                        .padding(4)
                        .background(Color(nsColor: .textBackgroundColor))
                        .cornerRadius(4)
                        .overlay(alignment: .topLeading) {
                            if text.isEmpty {
                                Text(NSLocalizedString("content.placeholder", comment: "Content text editor placeholder"))
                                    .foregroundColor(.gray)
                                    .padding(8)
                                    .allowsHitTesting(false)
                            }
                        }
                    
                    HStack {
                        Spacer()
                        Text("\(characterCount) / \(AppConfig.Limits.maxInputLength)")
                            .font(.caption)
                            .foregroundColor(isAtCharacterLimit ? .red : isNearCharacterLimit ? .orange : .secondary)
                            .monospacedDigit()
                    }
                }
                .padding(8)
            }
            
            // Instructions DisclosureGroup
            GroupBox {
                DisclosureGroup(isExpanded: $isInstructionsExpanded) {
                    VStack(alignment: .leading) {
                        TextEditor(text: $instructions)
                            .font(.body)
                            .frame(minHeight: 100)
                            .padding(4)
                            .background(Color(nsColor: .textBackgroundColor))
                            .cornerRadius(4)
                            .overlay(alignment: .topLeading) {
                                if instructions.isEmpty {
                                    Text(NSLocalizedString("content.instructions.placeholder", comment: "Instructions text editor placeholder"))
                                        .foregroundColor(.gray)
                                        .padding(8)
                                        .allowsHitTesting(false)
                                }
                            }
                    }
                    .padding(.top, 8)
                } label: {
                    HStack {
                        Label(NSLocalizedString("content.advanced_instructions", comment: "Advanced instructions label"), systemImage: "slider.horizontal.3")
                            .font(.headline)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            isInstructionsExpanded.toggle()
                        }
                    }
                }
            }
            .id("instructions")
        }
    }
}

#Preview {
    @Previewable @State var text = ""
    @Previewable @State var instructions = ""
    @Previewable @State var isExpanded = false
    
    TextInputView(
        text: $text,
        instructions: $instructions,
        isInstructionsExpanded: $isExpanded,
        characterCount: 0,
        isAtCharacterLimit: false,
        isNearCharacterLimit: false
    )
    .padding()
}
