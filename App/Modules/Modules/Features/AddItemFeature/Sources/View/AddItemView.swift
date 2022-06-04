import UIKit
import SwiftUI
import ComposableArchitecture

struct AddItemView: View {

    let previewOptions = ["Text", "Link"]

    let store: Store<AddItemState, AddItemAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                ZStack {
                    HStack {
                        Button("Cancel") { viewStore.send(.onCancel) }
                            .buttonStyle(.borderless)
                            .controlSize(.regular)
                            .tint(.accentColor)
                        Spacer()
                        Button("Done") { viewStore.send(.onDone) }
                            .buttonStyle(.borderless)
                            .controlSize(.regular)
                            .tint(.accentColor)
                            .disabled(!viewStore.state.isFormValid)
                    }

                    Text("Add Item")
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 24)

                Form {
                    Section() {
                        TextField("Name", text: viewStore.binding(\.$title))
                    }

                    TextField("Content", text: viewStore.binding(\.$contentText))
                        .autocapitalization(.none)

                    Picker(
                        selection: viewStore.binding(\.$selectedOption),
                        label: Text("Content type")
                    ) {
                        ForEach(
                            Array(zip(viewStore.contentOptions.indices, viewStore.contentOptions)),
                            id: \.0
                        ) { index, item in
                            Text(item.rawValue).tag(index)
                        }
                    }
                    .pickerStyle(.inline)
                }
            }
            .padding(.top, 16)
            .background(Color(.secondarySystemBackground))
        }
    }
}
