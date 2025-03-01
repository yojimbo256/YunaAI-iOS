import Foundation

class APIManager {
    static let shared = APIManager()

    let baseURL = "https://8acd-136-53-23-56.ngrok-free.app"

    // Function to send a chat message to Yuna
    func sendMessage(_ message: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/chat") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["message": message]

        do {
            let data = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = data
        } catch {
            print("❌ Failed to encode JSON: \(error.localizedDescription)")
            throw error
        }

        print("🚀 Sending request to: \(url.absoluteString)")
        print("📤 Request Body: \(body)")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("🔍 HTTP Status Code: \(httpResponse.statusCode)")
        }

        let responseString = String(data: data, encoding: .utf8) ?? "No response"
        print("📥 Raw Response: \(responseString)")

        let decodedResponse = try JSONDecoder().decode([String: String].self, from: data)

        return decodedResponse["response"] ?? "No response"
    }


    // Function to fetch Yuna’s stored memory
    func fetchMemory() async throws -> [String] {
        guard let url = URL(string: "\(baseURL)/fetch_yuna_memory") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        let response = try JSONDecoder().decode([String: [[String: String]]].self, from: data)
        let memories = response["short_term"]?.compactMap { $0["content"] } ?? []

        return memories
    }
}

