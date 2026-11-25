import SwiftUI
import Charts
import PhotosUI
import UIKit

let neon = Color(red: 0.22, green: 1, blue: 0.53)
let gold = Color(red: 1, green: 0.84, blue: 0.25)
let panel = Color(red: 0.08, green: 0.14, blue: 0.11)
let backdrop = Color(red: 0.03, green: 0.05, blue: 0.04)

@main struct ProjectDekuApp: App {
    @StateObject private var store = Store()
    var body: some Scene { WindowGroup { Root().environmentObject(store).preferredColorScheme(.dark).tint(neon) } }
}
struct Root: View {
    @EnvironmentObject var s: Store
    var body: some View {
        TabView {
            NavigationStack { Home() }.tabItem { Label("Início", systemImage: "house.fill") }
            NavigationStack { Training() }.tabItem { Label("Treinos", systemImage: "figure.strengthtraining.traditional") }
            NavigationStack { Missions() }.tabItem { Label("Missões", systemImage: "checklist") }
            NavigationStack { ProgressPage() }.tabItem { Label("Evolução", systemImage: "chart.bar.xaxis") }
            NavigationStack { Hero() }.tabItem { Label("Herói", systemImage: "person.crop.circle") }
        }.alert("PROJECT DEKU", isPresented: Binding(get: { s.error != nil }, set: { if !$0 { s.error = nil } })) { Button("OK") { s.error = nil } } message: { Text(s.error ?? "") }
    }
}
struct Tile: View {
    var title: String; var subtitle: String; var icon: String
    var body: some View { HStack(spacing: 14) { Image(systemName: icon).font(.title2).foregroundStyle(neon).frame(width: 34); VStack(alignment: .leading, spacing: 4) { Text(title).font(.headline); Text(subtitle).font(.caption).foregroundStyle(.secondary) }; Spacer(); Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary) }.padding().background(panel, in: RoundedRectangle(cornerRadius: 16)) }
}
struct Page<Content: View>: View {
    let title: String; @ViewBuilder var content: Content
    var body: some View { ScrollView { VStack(alignment: .leading, spacing: 16) { content }.padding().frame(maxWidth: 640) }.frame(maxWidth: .infinity).background(backdrop).navigationTitle(title) }
}
struct Home: View {
    @EnvironmentObject var s: Store
    var body: some View { Page(title: "PROJECT DEKU") {
        Text("ONE FOR ALL / HERO SYSTEM 6.0").font(.caption.monospaced().bold()).foregroundStyle(neon)
        VStack(alignment: .leading, spacing: 12) {
            HStack { Text(s.data.avatar).font(.system(size: 52)); VStack(alignment: .leading) { Text(s.data.name).font(.title2.bold()); Text(s.rank).foregroundStyle(gold) }; Spacer(); Text("LV \(s.level)").font(.title2.monospaced().bold()).foregroundStyle(neon) }
            ProgressView(value: Double(s.xp % 100), total: 100).tint(neon)
            Text("\(s.xp) XP • Semana \(s.data.week)/40").font(.caption.monospaced())
        }.padding().background(panel, in: RoundedRectangle(cornerRadius: 20))
        Text("CENTRAL DE HERÓI").font(.caption.bold()).foregroundStyle(neon)
        NavigationLink { Campaign() } label: { Tile(title: "Campanha", subtitle: "40 semanas • 10 capítulos", icon: "flag.checkered") }
        NavigationLink { Quadra() } label: { Tile(title: "PROJECT QUADRA", subtitle: "Quatro arquétipos", icon: "soccerball") }
        NavigationLink { CalendarPage() } label: { Tile(title: "Agenda", subtitle: "Planejamento semanal", icon: "calendar") }
        NavigationLink { Books() } label: { Tile(title: "Cadernos", subtitle: "13 volumes digitais", icon: "books.vertical") }
        NavigationLink { Missions() } label: { Tile(title: "Missões", subtitle: "\(s.data.missions.filter(\.done).count) concluídas", icon: "checklist") }
        Text("Descanso, aprendizado e técnica também são progresso.").font(.footnote).foregroundStyle(.secondary)
    }.buttonStyle(.plain) }
}
struct Missions: View {
    @EnvironmentObject var s: Store
    @State private var search = ""; @State private var category = "Todas"; @State private var filter = "Ativas"; @State private var editing: Mission? = nil
    var body: some View { List {
        Section { Picker("Categoria", selection: $category) { ForEach(["Todas"] + Seed.topics.map { $0.0 }, id: \.self) { Text($0) } }; Picker("Mostrar", selection: $filter) { ForEach(["Ativas","Concluídas","Arquivadas","Todas"], id: \.self) { Text($0) } } }
        ForEach(s.data.missions.filter { m in (category == "Todas" || category == m.category) && (search.isEmpty || m.title.localizedCaseInsensitiveContains(search)) && (filter == "Todas" || (filter == "Ativas" && !m.archived && !m.done) || (filter == "Concluídas" && m.done && !m.archived) || (filter == "Arquivadas" && m.archived)) }) { m in
            HStack { Button { s.toggle(m.id) } label: { Image(systemName: m.done ? "checkmark.circle.fill" : "circle").foregroundStyle(neon).font(.title2) }.buttonStyle(.borderless).accessibilityLabel(m.done ? "Desmarcar" : "Concluir"); VStack(alignment: .leading) { Text(m.title); Text("\(m.category) • \(m.xp) XP").font(.caption).foregroundStyle(.secondary) }; Spacer(); Button { editing = m } label: { Image(systemName: "pencil") }.buttonStyle(.borderless) }
        }
    }.navigationTitle("Missões").searchable(text: $search).toolbar { Button { editing = Mission(title: "", category: "Herói", detail: "") } label: { Image(systemName: "plus") } }.sheet(item: $editing) { m in MissionEditor(m: m) } }
}
struct MissionEditor: View {
    @EnvironmentObject var s: Store; @Environment(\.dismiss) var dismiss; @State var m: Mission
    var body: some View { NavigationStack { Form { TextField("Título", text: $m.title); Picker("Categoria", selection: $m.category) { ForEach(Seed.topics.map { $0.0 }, id: \.self) { Text($0) } }; TextField("Descrição", text: $m.detail, axis: .vertical); Stepper("XP: \(m.xp)", value: $m.xp, in: 0...100, step: 5).disabled(m.done); Toggle("Arquivada", isOn: $m.archived); Toggle("Com data", isOn: Binding(get: { m.date != nil }, set: { m.date = $0 ? Date() : nil })); if m.date != nil { DatePicker("Data", selection: Binding(get: { m.date ?? Date() }, set: { m.date = $0 }), displayedComponents: .date) } }.navigationTitle("Missão").toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }; ToolbarItem(placement: .confirmationAction) { Button("Salvar") { if let i = s.data.missions.firstIndex(where: {$0.id == m.id}) { s.data.missions[i] = m } else { s.data.missions.append(m) }; dismiss() }.disabled(m.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) } } } }
}
struct Training: View {
    var body: some View { Page(title: "Treinos") { ForEach(Array(zip(Seed.categories, ["All Might Training", "Project Quadra", "Full Cowling", "Shoot Style", "Recovery Girl"])), id: \.0) { pair in NavigationLink { Module(category: pair.0) } label: { Tile(title: pair.0, subtitle: pair.1, icon: "figure.cooldown") } }; NavigationLink { Quadra() } label: { Tile(title: "Futebol tático", subtitle: "Posições, arquétipos e análise", icon: "soccerball") } }.buttonStyle(.plain) }
}
struct Module: View {
    @EnvironmentObject var s: Store; let category: String; @State private var adding = false; @State private var routine: Routine?; @State private var search = ""
    var library: [String] { switch category { case "Academia": return ["Remada — siga a técnica indicada pelo instrutor", "Supino — equipamento ajustado pelo instrutor", "Puxada — movimento controlado", "Exercício de pernas — somente conforme orientação profissional"]; case "Futebol": return ["Análise de passe", "Domínio orientado", "Posicionamento", "Comunicação"]; case "Corrida": return ["Planejar percurso", "Registrar caminhada ou corrida autorizada"]; case "Calistenia": return ["Movimento autorizado", "Técnica de apoio", "Respiração e controle"]; default: return ["Registrar fisioterapia", "Descanso", "Orientações profissionais"] } }
    var body: some View { List {
        Section { Button("Registrar atividade") { adding = true }; Button("Criar rotina") { routine = Routine(name: "", category: category, exercises: "") }; NavigationLink("Cronômetro") { TimerPage() }; if category == "Futebol" { NavigationLink("PROJECT QUADRA") { Quadra() } }; if category == "Recuperação" { TextField("Orientações e limites", text: $s.data.limitations, axis: .vertical) } }
        Section("Biblioteca inicial") { ForEach(library.filter { search.isEmpty || $0.localizedCaseInsensitiveContains(search) }, id: \.self) { Text($0) } }
        Section("Rotinas") { ForEach(s.data.routines.filter { $0.category == category }) { r in Button { routine = r } label: { VStack(alignment: .leading) { Text(r.name); Text(r.exercises).font(.caption).foregroundStyle(.secondary) } }.swipeActions { Button("Excluir", role: .destructive) { s.data.routines.removeAll { $0.id == r.id } } } } }
        Section("Histórico") { ForEach(s.data.sessions.filter { $0.category == category }.sorted { $0.date > $1.date }) { session in VStack(alignment: .leading) { Text(session.title).font(.headline); Text("\(session.minutes) min • \(session.date.formatted(date: .abbreviated, time: .omitted))"); Text(session.detail).font(.caption).foregroundStyle(.secondary) }.swipeActions { Button("Excluir", role: .destructive) { s.data.sessions.removeAll { $0.id == session.id } } } } }
    }.navigationTitle(category).searchable(text: $search).sheet(isPresented: $adding) { SessionEditor(category: category) }.sheet(item: $routine) { RoutineEditor(r: $0) } }
}
struct SessionEditor: View {
    @EnvironmentObject var s: Store; @Environment(\.dismiss) var dismiss; let category: String
    @State private var title = ""; @State private var duration = ""; @State private var details = ""; @State private var date = Date(); @State private var distance = ""; @State private var sets = ""; @State private var reps = ""
    var body: some View { NavigationStack { Form { TextField("Atividade", text: $title); TextField("Duração em minutos", text: $duration).keyboardType(.numberPad); DatePicker("Data", selection: $date); if category == "Corrida" { TextField("Distância em km (opcional)", text: $distance).keyboardType(.decimalPad) }; if category == "Academia" || category == "Calistenia" { TextField("Séries realizadas", text: $sets).keyboardType(.numberPad); TextField("Repetições realizadas", text: $reps).keyboardType(.numberPad) }; TextField("Observações / adaptações", text: $details, axis: .vertical); Text("Registre apenas o que foi adequado. Não há meta obrigatória de duração ou carga.").font(.footnote) }.navigationTitle("Registro").toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }; ToolbarItem(placement: .confirmationAction) { Button("Salvar") { s.data.sessions.append(Session(category: category, title: title, minutes: Int(duration) ?? 0, detail: [details, distance.isEmpty ? "" : "Distância: \(distance) km", sets.isEmpty ? "" : "Séries: \(sets)", reps.isEmpty ? "" : "Repetições: \(reps)"].filter { !$0.isEmpty }.joined(separator: "\n"), date: date)); dismiss() }.disabled(title.isEmpty || !(0...1440).contains(Int(duration) ?? -1)) } } } }
}
struct RoutineEditor: View {
    @EnvironmentObject var s: Store; @Environment(\.dismiss) var dismiss; @State var r: Routine
    var body: some View { NavigationStack { Form { TextField("Nome", text: $r.name); TextField("Exercícios e orientações", text: $r.exercises, axis: .vertical); Button("Modelo editável") { r.exercises = "Aquecimento orientado\nAtividade autorizada: \nTécnica a observar: \nPausa e recuperação: " } }.navigationTitle("Rotina").toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }; ToolbarItem(placement: .confirmationAction) { Button("Salvar") { if let i = s.data.routines.firstIndex(where: {$0.id == r.id}) { s.data.routines[i] = r } else { s.data.routines.append(r) }; dismiss() }.disabled(r.name.isEmpty) } } } }
}
struct TimerPage: View {
    @State private var start: Date?; @State private var elapsed: TimeInterval = 0
    var body: some View { Page(title: "Cronômetro") { TimelineView(.periodic(from: .now, by: 1)) { context in let total = max(0, Int(elapsed + (start.map { context.date.timeIntervalSince($0) } ?? 0))); Text(String(format: "%02d:%02d", total/60, total%60)).font(.system(size: 60, design: .monospaced)).foregroundStyle(neon) }; Button(start == nil ? "Iniciar" : "Pausar") { if let t = start { elapsed += Date().timeIntervalSince(t); start = nil } else { start = Date() } }.buttonStyle(.borderedProminent); Button("Zerar") { start = nil; elapsed = 0 } } }
}
