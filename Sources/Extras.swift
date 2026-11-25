import SwiftUI
import Charts
import PhotosUI
import UIKit
import UniformTypeIdentifiers

struct Quadra: View {
    @EnvironmentObject var s: Store
    var body: some View { Page(title: "PROJECT QUADRA") {
        ForEach(Array(zip(Seed.archetypes,["Coragem e iniciativa","Visão e leitura de jogo","Controle e técnica","Precisão e decisão"])), id: \.0) { a in NavigationLink { ArchetypePage(name: a.0) } label: { Tile(title: a.0, subtitle: "\(a.1) • Nível \(1+s.xp(a.0)/100)", icon: "bolt.shield") } }
        NavigationLink { Tactics() } label: { Tile(title: "Quadro tático", subtitle: "Society • 5 + goleiro", icon: "sportscourt") }
        NavigationLink { NotesPage(book: "Inteligência Tática") } label: { Tile(title: "Análise de partida", subtitle: "Observações e decisões", icon: "square.and.pencil") }
        Text("POSIÇÕES").font(.caption.bold()).foregroundStyle(neon)
        ForEach(Array(zip(Seed.positions,["Comunicação, ângulo e passe seguro","Cobertura e antecipação","Apoio e retorno","Equilíbrio e opção de passe","Leitura e criação","Amplitude e apoio","Movimento sem bola e escolha da finalização"])), id: \.0) { p in VStack(alignment: .leading) { Text(p.0).font(.headline); Text(p.1).foregroundStyle(.secondary) }.padding().frame(maxWidth: .infinity, alignment: .leading).background(panel, in: RoundedRectangle(cornerRadius: 12)) }
    }.buttonStyle(.plain) }
}
struct ArchetypePage: View {
    @EnvironmentObject var s: Store; let name: String
    var body: some View { Page(title: name) { Text("Nível \(1+s.xp(name)/100) • \(s.xp(name)) XP").font(.title2.bold()).foregroundStyle(neon); ProgressView(value: Double(s.xp(name)%100), total: 100); ForEach(Seed.topics.first(where: {$0.0 == name})?.1 ?? [], id: \.self) { topic in let completed = s.data.missions.filter { $0.category == name && $0.done && $0.title.localizedCaseInsensitiveContains(topic) }.count; VStack(alignment: .leading) { Label(topic, systemImage: completed > 0 ? "checkmark.seal" : "lock.open"); ProgressView(value: Double(min(completed,5)), total: 5); Text("\(completed)/5 atividades de aprendizado").font(.caption) }.padding().background(panel, in: RoundedRectangle(cornerRadius: 12)) }; NavigationLink("Abrir central de missões") { Missions() } } }
}
struct Pitch: View {
    var players: [Player]; var move: ((UUID,Double,Double)->Void)? = nil
    var body: some View { GeometryReader { geo in ZStack {
        RoundedRectangle(cornerRadius: 12).fill(Color(red: 0.08, green: 0.34, blue: 0.18))
        RoundedRectangle(cornerRadius: 2).stroke(.white.opacity(0.8), lineWidth: 2).padding(12)
        Path { p in let w=geo.size.width; let h=geo.size.height; p.move(to: CGPoint(x:12,y:h/2)); p.addLine(to: CGPoint(x:w-12,y:h/2)); p.addRect(CGRect(x:w*0.25,y:12,width:w*0.5,height:h*0.16)); p.addRect(CGRect(x:w*0.25,y:h*0.84-12,width:w*0.5,height:h*0.16)) }.stroke(.white.opacity(0.8), lineWidth: 2)
        Circle().stroke(.white.opacity(0.8), lineWidth: 2).frame(width: geo.size.width*0.25)
        ForEach(players) { player in Text("\(player.number)").font(.caption.bold()).foregroundStyle(.black).frame(width: 32,height: 32).background(player.opponent ? gold : neon, in: Circle()).position(x: geo.size.width*player.x,y:geo.size.height*player.y).gesture(DragGesture(minimumDistance: 0, coordinateSpace: .named("pitch")).onChanged { v in move?(player.id, min(0.95,max(0.05,v.location.x/geo.size.width)), min(0.95,max(0.05,v.location.y/geo.size.height))) }) }
    }.coordinateSpace(name: "pitch") }.aspectRatio(0.7, contentMode: .fit) }
}
struct Tactics: View {
    @EnvironmentObject var s: Store; @State private var formation = 0
    var body: some View { Page(title: "Quadro tático") { Picker("Formação", selection: $formation) { Text("2-2-1").tag(0); Text("3-2").tag(1); Text("1-3-1").tag(2) }.pickerStyle(.segmented).onChange(of: formation) { s.data.players = Seed.formation($0) }
        Pitch(players: s.data.players) { id,x,y in if let i = s.data.players.firstIndex(where: {$0.id == id}) { s.data.players[i].x = x; s.data.players[i].y = y } }
        Button("Adicionar adversários") { if !s.data.players.contains(where: { $0.opponent }) { s.data.players += Seed.formation(formation).map { Player(number: $0.number, x: 1-$0.x, y: 1-$0.y, opponent: true) } } }.buttonStyle(.bordered)
        Button("Restaurar formação") { s.data.players = Seed.formation(formation) }.buttonStyle(.bordered)
        Button("Imprimir quadro") { let renderer = ImageRenderer(content: Pitch(players: s.data.players).frame(width: 420,height: 600)); renderer.scale = 2; if let image = renderer.uiImage { let printer = UIPrintInteractionController.shared; printer.printingItem = image; printer.present(animated: true, completionHandler: nil) } }.buttonStyle(.borderedProminent)
        Text("Arraste os jogadores para testar posicionamento.").font(.caption)
    } }
}
struct Campaign: View {
    @EnvironmentObject var s: Store
    var body: some View { List { ForEach(0..<10, id: \.self) { chapter in Section(Seed.chapters[chapter]) { ForEach(s.data.weeks.filter { ($0.id-1)/4 == chapter }) { w in NavigationLink { WeekPage(id: w.id) } label: { HStack { Image(systemName: w.done ? "checkmark.circle.fill" : "circle").foregroundStyle(neon); VStack(alignment: .leading) { Text("Semana \(w.id)"); Text(w.goal).font(.caption) }; if s.data.week == w.id { Spacer(); Text("Atual").foregroundStyle(gold) } } } } } } }.navigationTitle("Campanha") }
}
struct WeekPage: View {
    @EnvironmentObject var s: Store; let id: Int
    var body: some View { if let i = s.data.weeks.firstIndex(where: {$0.id == id}) { Form { TextField("Objetivo", text: $s.data.weeks[i].goal); Section("Plano editável") { TextEditor(text: $s.data.weeks[i].plan).frame(minHeight: 220) }; Section("Aprendizados") { TextEditor(text: $s.data.weeks[i].notes).frame(minHeight: 100) }; Toggle("Revisão concluída", isOn: $s.data.weeks[i].done); Button("Definir como semana atual") { s.data.week = id }; NavigationLink("Missões") { Missions() } }.navigationTitle("Semana \(id)") } }
}
struct CalendarPage: View {
    @EnvironmentObject var s: Store
    var body: some View { Form { ForEach(0..<7, id: \.self) { i in Section(Seed.days[i]) { TextField("Atividade", text: $s.data.schedule[i], axis: .vertical) } }; Text("Agenda flexível. Altere quando precisar de recuperação.").font(.footnote) }.navigationTitle("Agenda semanal") }
}
struct Books: View {
    @EnvironmentObject var s: Store
    var body: some View { Page(title: "Cadernos") { ForEach(Array(Seed.books.enumerated()), id: \.offset) { i,b in NavigationLink { NotesPage(book: b) } label: { Tile(title: "\(i+1). \(b)", subtitle: "\(s.data.notes.filter {$0.book == b}.count) anotações", icon: "book.closed") } } }.buttonStyle(.plain) }
}
struct NotesPage: View {
    @EnvironmentObject var s: Store; let book: String; @State private var search = ""; @State private var favorite = false; @State private var editing: Note?
    var body: some View { List { Toggle("Somente favoritos", isOn: $favorite); ForEach(s.data.notes.filter { $0.book == book && (!favorite || $0.favorite) && (search.isEmpty || "\($0.title) \($0.body) \($0.tags)".localizedCaseInsensitiveContains(search)) }) { n in Button { editing = n } label: { VStack(alignment: .leading) { Text(n.title).font(.headline); Text(n.body).lineLimit(2).foregroundStyle(.secondary); Text(n.tags).font(.caption) } }.swipeActions { Button("Excluir", role: .destructive) { s.data.notes.removeAll {$0.id == n.id} } } } }.navigationTitle(book).searchable(text: $search).toolbar { Button { editing = Note(book: book, title: "", body: "") } label: { Image(systemName: "plus") } }.sheet(item: $editing) { NoteEditor(n: $0) } }
}
struct NoteEditor: View {
    @EnvironmentObject var s: Store; @Environment(\.dismiss) var dismiss; @State var n: Note; @State private var photo: PhotosPickerItem?
    var body: some View { NavigationStack { Form { TextField("Título", text: $n.title); TextField("Etiquetas", text: $n.tags); Toggle("Favorito", isOn: $n.favorite); TextEditor(text: $n.body).frame(minHeight: 180); PhotosPicker(selection: $photo, matching: .images) { Label("Adicionar imagem", systemImage: "photo") }; if let bytes=n.attachment, let image=UIImage(data:bytes) { Image(uiImage:image).resizable().scaledToFit(); Button("Remover imagem", role: .destructive) { n.attachment = nil } }; ShareLink(item: "\(n.title)\n\n\(n.body)"); Button("Imprimir texto") { let printer = UIPrintInteractionController.shared; printer.printFormatter = UISimpleTextPrintFormatter(text: "\(n.title)\n\n\(n.body)"); printer.present(animated:true, completionHandler:nil) } }.navigationTitle("Anotação").toolbar { ToolbarItem(placement:.cancellationAction) { Button("Cancelar") { dismiss() } }; ToolbarItem(placement:.confirmationAction) { Button("Salvar") { if let i=s.data.notes.firstIndex(where:{$0.id==n.id}) { s.data.notes[i]=n } else { s.data.notes.append(n) }; dismiss() }.disabled(n.title.isEmpty) } }.onChange(of:photo) { item in Task { if let data = try? await item?.loadTransferable(type: Data.self), let image=UIImage(data:data) { n.attachment=image.jpegData(compressionQuality:0.55) } } } } }
}
struct ProgressPage: View {
    @EnvironmentObject var s: Store; @State private var period = "Semana"
    var sessions: [Session] { let start = Calendar.current.date(byAdding: .day, value: period == "Semana" ? -7 : -30, to: Date()) ?? .distantPast; return s.data.sessions.filter {$0.date >= start} }
    var body: some View { Page(title: "Evolução") { Text("\(s.xp) XP • Nível \(s.level)").font(.title.bold()).foregroundStyle(neon); Picker("Período", selection: $period) { Text("Semana").tag("Semana"); Text("Mês").tag("Mês") }.pickerStyle(.segmented); Text("Registros por categoria").font(.headline); Chart { ForEach(Seed.categories,id:\.self) { c in BarMark(x:.value("Categoria",c),y:.value("Registros",sessions.filter{$0.category==c}.count)).foregroundStyle(neon) } }.frame(height:200); Text("Aprendizado por arquétipo").font(.headline); Chart { ForEach(Seed.archetypes,id:\.self) { a in BarMark(x:.value("Herói",a),y:.value("XP",s.xp(a))).foregroundStyle(gold) } }.frame(height:180); Text("Campanha: \(s.data.weeks.filter(\.done).count)/40 revisões"); NavigationLink("Conquistas") { Achievements() }; NavigationLink("Árvore de habilidades") { Quadra() }; Text("Os gráficos descrevem registros, não exigem metas de duração ou intensidade.").font(.caption) } }
}
struct Achievements: View {
    @EnvironmentObject var s: Store
    var body: some View { Page(title:"Conquistas") { ForEach(Array(zip(["Primeiro aprendizado","Caderno aberto","Jogo inteligente","Cuidado de herói","Primeira revisão"],[s.xp>0,!s.data.notes.isEmpty,s.xp("Isagi")>0,s.xp("Recuperação")>0,s.data.weeks.contains(where:{$0.done})])),id:\.0) { a in Tile(title:a.0,subtitle:a.1 ? "Desbloqueada" : "Ainda não desbloqueada",icon:a.1 ? "trophy.fill" : "lock") } } }
}
struct Hero: View {
    @EnvironmentObject var s: Store
    var body: some View { Form { Section("Perfil") { TextField("Nome do herói",text:$s.data.name); Picker("Avatar",selection:$s.data.avatar) { ForEach(["⚡","🛡️","🌟","🍀","🔥"],id:\.self) { Text($0) } }; Text("\(s.rank) • Nível \(s.level)") }; NavigationLink("Conquistas") { Achievements() }; NavigationLink("Habilidades") { Quadra() }; NavigationLink("Cadernos") { Books() }; NavigationLink("Configurações e backup") { Settings() } }.navigationTitle("Herói") }
}
struct Settings: View {
    @EnvironmentObject var s: Store; @State private var exporting=false; @State private var importing=false; @State private var confirm=false; @State private var document=BackupDocument()
    var body: some View { Form { Section("Lembrete opcional") { Toggle("Lembrete diário",isOn:$s.data.reminder); Stepper("Horário: \(s.data.reminderHour)h",value:$s.data.reminderHour,in:0...23); Button("Aplicar lembrete") { Task { await s.notify() } } }; Section("Dados locais") { Button("Exportar backup JSON") { do { document=BackupDocument(bytes:try s.backup()); exporting=true } catch { s.error=error.localizedDescription } }; Button("Restaurar backup") { confirm=true }; Text("A restauração substitui o progresso atual. Guarde seu backup em local privado.").font(.caption) }; Section("Sobre") { Text("PROJECT DEKU 6.0 • Projeto de fã não oficial. Sem conexão obrigatória, sem publicidade, sem competição de carga física.") } }.navigationTitle("Configurações").confirmationDialog("Substituir dados atuais?",isPresented:$confirm) { Button("Selecionar backup",role:.destructive) { importing=true }; Button("Cancelar",role:.cancel) {} }.fileExporter(isPresented:$exporting,document:document,contentType:.json,defaultFilename:"project-deku-backup") { result in if case .failure(let e)=result { s.error=e.localizedDescription } }.fileImporter(isPresented:$importing,allowedContentTypes:[.json]) { result in do { let url=try result.get(); let access=url.startAccessingSecurityScopedResource(); defer { if access { url.stopAccessingSecurityScopedResource() } }; try s.restore(Data(contentsOf:url)) } catch { s.error=error.localizedDescription } } }
}
