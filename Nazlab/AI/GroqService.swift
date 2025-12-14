import Foundation

final class GroqService: AIService {

    private let session = URLSession.shared

    func generateResponse(for messages: [Message]) async throws -> String {

        // 1️⃣ API KEY
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GROQ_API_KEY") as? String,
              !apiKey.isEmpty else {
            throw GroqError.missingAPIKey
        }

        // 2️⃣ URL
        let url = URL(string: "https://api.groq.com/openai/v1/chat/completions")!

        // 3️⃣ Messages: фильтруем пустые тексты
        let nonEmptyMessages = messages.filter { !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        guard !nonEmptyMessages.isEmpty else {
            throw GroqError.serverError(code: 400, message: "Empty messages array after trimming.")
        }

        let chatMessages: [[String: String]] = nonEmptyMessages.map {
            [
                "role": $0.role.rawValue,
                "content": $0.text
            ]
        }

        // 4️⃣ Body
        // Советуем начать с доступной модели. При необходимости вынесите в Info.plist (ключ GROQ_MODEL).
        let body: [String: Any] = [
            "model": "llama-3.1-8b-instant",
            "messages": chatMessages,
            "temperature": 0.7,
            "stream": false
        ]

        let data = try JSONSerialization.data(withJSONObject: body)

        // 5️⃣ Request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        // 6️⃣ Network
        let (responseData, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw GroqError.invalidResponse
        }

        guard 200..<300 ~= http.statusCode else {
            let serverText = String(data: responseData, encoding: .utf8) ?? ""
            #if DEBUG
            print("[GroqService] HTTP \(http.statusCode). Response body:\n\(serverText)")
            print("[GroqService] Request body:\n\(String(data: data, encoding: .utf8) ?? "")")
            #endif
            throw GroqError.serverError(code: http.statusCode, message: serverText)
        }

        // 7️⃣ Decode
        let decoded = try JSONDecoder().decode(OpenAIResponse.self, from: responseData)
        return decoded.choices.first?.message.content ?? "No response"
    }
}
enum GroqError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case serverError(code: Int, message: String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "GROQ_API_KEY табылмады."
        case .invalidResponse:
            return "Серверден қате жауап келді."
        case .serverError(let code, _):
            return "Groq сервер қатесі: \(code)"
        }
    }
}
