import Foundation

class APIManager {
    static let shared = APIManager()

    let baseURL = "https://e8cd-136-53-23-56.ngrok-free.app"

    // Function to send a chat message to Yuna
    func sendMessage(_ message: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/chat") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["message": message]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let decodedResponse = try JSONDecoder().decode([String: String].self, from: data)

        let responseText = decodedResponse["response"] ?? "No response"

        // ✅ Automatically store memory after receiving a response
        await storeMemory(message)

        return responseText
    }
    
    // Function to have Yuna store memory
    func storeMemory(_ memory: String) async {
        guard let url = URL(string: "\(baseURL)/update_yuna_memory") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "new_memory": memory,
            "category": "chat_memory",
            "permanent": true
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode([String: String].self, from: data)
            print("✅ Memory stored successfully: \(response)")
        } catch {
            print("❌ Failed to store memory: \(error.localizedDescription)")
        }
    }


    struct MemoryResponse: Codable {
        let shortTerm: [[String: String]]?
        let longTerm: [[String: String]]?

        enum CodingKeys: String, CodingKey {
            case shortTerm = "short_term"
            case longTerm = "long_term"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            // Handle short_term being either an object `{}` or an array `[]`
            if let shortTermArray = try? container.decode([[String: String]].self, forKey: .shortTerm) {
                self.shortTerm = shortTermArray
            } else {
                self.shortTerm = []
            }

            // Handle long_term normally
            self.longTerm = try container.decodeIfPresent([[String: String]].self, forKey: .longTerm) ?? []
        }
    }

    
    // Function to fetch Yuna’s stored memory
    func fetchMemory() async throws -> [String] {
        print("🔍 fetchMemory() function is running...")

        guard let url = URL(string: "\(baseURL)/fetch_yuna_memory") else {
            throw URLError(.badURL)
        }

        print("🚀 Sending request to: \(url.absoluteString)")

        let (data, response) = try await URLSession.shared.data(from: url)

        if let httpResponse = response as? HTTPURLResponse {
            print("🔍 HTTP Status Code: \(httpResponse.statusCode)")
        }

        let responseString = String(data: data, encoding: .utf8) ?? "No response"
        print("📥 Raw Response: \(responseString)")

        // Decode response safely
        do {
            let decodedResponse = try JSONDecoder().decode(MemoryResponse.self, from: data)

            let shortTermMemories = decodedResponse.shortTerm?.compactMap { $0["content"] } ?? []
            let longTermMemories = decodedResponse.longTerm?.compactMap { $0["content"] } ?? []

            let allMemories = shortTermMemories + longTermMemories

            if allMemories.isEmpty {
                print("⚠️ No stored memory found, returning default message.")
                return ["No stored memory yet."]
            }

            return allMemories
        } catch {
            print("❌ JSON Decoding Error: \(error.localizedDescription)")
            return ["Error loading memory"]
        }

    }


}

