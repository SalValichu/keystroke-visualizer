import SwiftUI

@available(macOS 12.0, *)
struct ContentView: View {
    @State private var keys: [Key] = []
    @State private var selectedKey: Key? = nil
    @State private var isEditing: Bool = false
    @State private var showPresetsMenu: Bool = false

    var body: some View {
        ZStack {
            // 背景网格
            if #available(macOS 11.0, *) {
                Color.black
                    .ignoresSafeArea()
            } else {
                Color.black
            }

            VStack(spacing: 0) {
                // 顶部工具栏 - 仅包含 Add, Undo, Redo, Load Preset
                HStack(spacing: 20) {
                    Button("+ Add Key") { /* 添加键逻辑 */ }
                        .buttonStyle(.bordered)
                        .controlSize(.small)

                    Button("Undo") { /* 撤销逻辑 */ }
                        .buttonStyle(.bordered)
                        .controlSize(.small)

                    Button("Redo") { /* 重做逻辑 */ }
                        .buttonStyle(.bordered)
                        .controlSize(.small)

                    Button("Load Preset") { /* 加载预设逻辑 */ }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .background(Color.black.opacity(0.8))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

                // 主编辑区
                if #available(macOS 11.0, *) {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(keys.indices, id: \.self) { index in
                                KeyView(key: $keys[index])
                                    .onTapGesture {
                                        selectedKey = keys[index]
                                    }
                            }
                        }
                        .padding()
                    }
                } else {
                    // Fallback for older macOS
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(keys.indices, id: \.self) { index in
                                KeyView(key: $keys[index])
                                    .onTapGesture {
                                        selectedKey = keys[index]
                                    }
                            }
                        }
                        .padding()
                    }
                }

                // 底部工具栏 - 仅包含 Edit, Export, Presets, Clear All
                HStack(spacing: 15) {
                    Button("Edit") { isEditing.toggle() }
                        .buttonStyle(.bordered)
                        .controlSize(.small)

                    Button("Export") { /* 导出逻辑 */ }
                        .buttonStyle(.bordered)
                        .controlSize(.small)

                    Button("Presets") { showPresetsMenu.toggle() }
                        .buttonStyle(.bordered)
                        .controlSize(.small)

                    Button("Clear All") { keys.removeAll() }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                .background(Color.black.opacity(0.8))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .onAppear {
            // 初始化数据
            keys.append(Key(name: "Q", position: CGPoint(x: 100, y: 100)))
        }
    }
}

// MARK: - Key Model
struct Key: Identifiable {
    let id = UUID()
    var name: String
    var position: CGPoint
}

// MARK: - KeyView
struct KeyView: View {
    @Binding var key: Key

    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .frame(width: 60, height: 60)
            .cornerRadius(8)
            .overlay(
                Text(key.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            )
            .onTapGesture {
                print("Tapped \(key.name)")
            }
    }
}
