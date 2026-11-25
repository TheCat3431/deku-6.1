import SwiftUI
import UserNotifications
import UniformTypeIdentifiers

@MainActor final class Store: ObservableObject {
    @Published var data: State { didSet { save() } }
    @Published var error: String? = nil
    private let url: URL
    init() {
        url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("project-deku.json")
        if FileManager.default.fileExists(atPath: url.path) {
            do { data = try JSONDecoder().decode(State.self, from: Data(contentsOf: url)) }
            catch { data = State(); self.error = "Não foi possível ler o progresso anterior. Importe um backup antes de editar." }
        } else { data = State() }
    }
    func save() { do { try JSONEncoder().encode(data).write(to: url, options: .atomic) } catch { self.error = "Falha ao salvar: \(error.localizedDescription)" } }
    var xp: Int { data.missions.filter(\.done).reduce(0) { $0 + $1.xp } }
    var level: Int { 1 + xp/100 }
    var rank: String { Seed.ranks[min((level-1)/3,9)] }
    func xp(_ category: String) -> Int { data.missions.filter { $0.done && $0.category == category }.reduce(0) { $0 + $1.xp } }
    func toggle(_ id: String) { if let i = data.missions.firstIndex(where: {$0.id == id}) { data.missions[i].done.toggle() } }
    func backup() throws -> Data { try JSONEncoder().encode(data) }
    func restore(_ bytes: Data) throws {
        let candidate = try JSONDecoder().decode(State.self, from: bytes)
        guard candidate.schedule.count == 7, candidate.weeks.count == 40, (1...40).contains(candidate.week), Set(candidate.missions.map(\.id)).count == candidate.missions.count, candidate.missions.allSatisfy({ (0...100).contains($0.xp) }) else { throw CocoaError(.fileReadCorruptFile) }
        data = candidate
    }
    func notify() async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["deku.daily"])
        guard data.reminder else { return }
        do {
            guard try await center.requestAuthorization(options: [.alert,.sound]) else { error = "Notificações não autorizadas."; return }
            let content = UNMutableNotificationContent(); content.title = "PROJECT DEKU"; content.body = "Confira sua agenda, recuperação e aprendizados. Descansar também é progresso."
            var date = DateComponents(); date.hour = data.reminderHour; date.minute = 0
            try await center.add(UNNotificationRequest(identifier: "deku.daily", content: content, trigger: UNCalendarNotificationTrigger(dateMatching: date, repeats: true)))
        } catch { self.error = error.localizedDescription }
    }
}
struct BackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var bytes: Data
    init(bytes: Data = Data()) { self.bytes = bytes }
    init(configuration: ReadConfiguration) throws { guard let b = configuration.file.regularFileContents else { throw CocoaError(.fileReadCorruptFile) }; bytes = b }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper { FileWrapper(regularFileWithContents: bytes) }
}
