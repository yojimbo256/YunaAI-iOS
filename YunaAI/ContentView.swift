import SwiftUI

struct ContentView: View {
    @State private var userMessage: String = ""
    @State private var chatResponse: String = "Ask Yuna something..."
    @State private var memory: [String] = []
    
    var body: some View {
        VStack {
            ScrollView {
                Text(chatResponse)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                Text("Yuna’s Memory:")
                    .font(.headline)
                
                ForEach(memory, id: \.self) { memoryItem in
                    Text(memoryItem)
                        .padding()
                        .background(Color(.gray).opacity(0.2)) // ✅ Fix applied
                        .cornerRadius(8)
                }
            }
            .padding()
            
            HStack {
                TextField("Type a message...", text: $userMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .task {
            await loadMemory()
        }
    }
    
    func sendMessage() {
        guard !userMessage.isEmpty else { return }
        chatResponse = "Thinking..."
        
        Task {
            do {
                let response = try await APIManager.shared.sendMessage(userMessage)
                chatResponse = response
                userMessage = ""  // Clear input field after sending
            } catch {
                chatResponse = "Error: \(error.localizedDescription)"
            }
        }
    }
    
    func loadMemory() async {
        print("🔍 loadMemory() function triggered!")
        do {
            memory = try await APIManager.shared.fetchMemory()
            print("✅ Memory loaded successfully!")
        } catch {
            print("❌ Error loading memory: \(error.localizedDescription)")
            memory = ["Error loading memory"]
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
    
}
