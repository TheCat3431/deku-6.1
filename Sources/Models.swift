import Foundation

struct Mission: Codable, Identifiable {
    var id: String = UUID().uuidString
    var title: String
    var category: String
    var detail: String
    var xp: Int = 20
    var done: Bool = false
    var archived: Bool = false
    var date: Date? = nil
}
struct Session: Codable, Identifiable {
    var id = UUID()
    var category: String
    var title: String
    var minutes: Int
    var detail: String
    var date = Date()
}
struct Note: Codable, Identifiable {
    var id = UUID()
    var book: String
    var title: String
    var body: String
    var tags: String = ""
    var favorite = false
    var date = Date()
    var attachment: Data? = nil
}
struct Week: Codable, Identifiable {
    var id: Int
    var goal: String
    var plan: String
    var notes = ""
    var done = false
}
struct Player: Codable, Identifiable {
    var id = UUID()
    var number: Int
    var x: Double
    var y: Double
    var opponent: Bool = false
}
struct Routine: Codable, Identifiable {
    var id = UUID()
    var name: String
    var category: String
    var exercises: String
}
struct State: Codable {
    var name = "Herói"
    var avatar = "⚡"
    var missions = Seed.missions
    var sessions: [Session] = []
    var notes: [Note] = []
    var weeks = Seed.weeks
    var week = 1
    var routines: [Routine] = []
    var players = Seed.formation(0)
    var schedule = ["Fisioterapia", "Society", "Academia ou recuperação", "Fisioterapia e Society", "Academia", "Atividade opcional", "Descanso"]
    var limitations = "Siga as orientações do fisioterapeuta."
    var reminder = false
    var reminderHour = 18
}
enum Seed {
    static let chapters = ["Origem do Herói", "Fundação do One For All", "Full Cowling", "Shoot Style", "Inteligência Tática", "Controle Técnico", "Dark Deku", "Herói Versátil", "Domínio das Habilidades", "Símbolo da Esperança"]
    static let ranks = ["Aprendiz", "Aspirante a Herói", "Estudante da U.A.", "Herói em Treinamento", "Full Cowling", "Shoot Style", "Herói Versátil", "Vigilante", "Herói Profissional", "Símbolo da Esperança"]
    static let books = ["Análise de Heróis", "Desenvolvimento Pessoal", "Academia", "Futebol", "Inteligência Tática", "Finalização", "Técnica", "Coragem", "Corrida", "Calistenia", "Recuperação", "Estudos", "One For All"]
    static let archetypes = ["Deku", "Isagi", "Fubuki", "Goenji"]
    static let positions = ["Goleiro", "Zagueiro", "Lateral", "Volante", "Meia", "Ponta", "Atacante"]
    static let categories = ["Academia", "Futebol", "Corrida", "Calistenia", "Recuperação"]
    static let days = ["Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado", "Domingo"]
    static let topics: [(String,[String])] = [
        ("Deku", ["Comunicação", "Pedir a bola", "Tomar iniciativa", "Aceitar um erro", "Ajudar um colega"]),
        ("Isagi", ["Espaço livre", "Linha de passe", "Cobertura", "Transição", "Movimento sem bola"]),
        ("Fubuki", ["Domínio", "Passe curto", "Recepção orientada", "Proteção da bola", "Condução"]),
        ("Goenji", ["Escolha do alvo", "Posicionamento", "Precisão", "Tempo de finalização", "Passe ou chute"]),
        ("Academia", ["Técnica", "Ajuste do equipamento", "Postura confortável", "Intervalos", "Rotina autorizada"]),
        ("Corrida", ["Percurso", "Conforto", "Recuperação", "Calçado", "Planejamento"]),
        ("Calistenia", ["Controle", "Respiração", "Adaptação", "Movimento autorizado", "Pausa"]),
        ("Recuperação", ["Sono", "Descanso", "Orientação profissional", "Conforto", "Limites"]),
        ("Estudos", ["Revisão", "Leitura", "Resumo", "Organização", "Dúvidas"]),
        ("Equipe", ["Respeito", "Escuta", "Cooperação", "Feedback", "Fair play"]),
        ("Organização", ["Agenda", "Materiais", "Prioridades", "Caderno", "Planejamento"]),
        ("Futebol", ["Goleiro", "Zagueiro", "Lateral", "Meio-campo", "Atacante"]),
        ("Herói", ["Paciência", "Curiosidade", "Responsabilidade", "Gentileza", "Aprendizado"])
    ]
    static var missions: [Mission] {
        let actions = ["Observar", "Registrar uma ideia sobre", "Explicar com suas palavras", "Planejar uma melhoria em", "Revisar um aprendizado sobre"]
        return topics.enumerated().flatMap { ci, group in group.1.enumerated().flatMap { ti, topic in actions.enumerated().map { ai, action in
            Mission(id: "seed-\(ci)-\(ti)-\(ai)", title: "\(action) \(topic.lowercased())", category: group.0, detail: "Faça uma breve reflexão ou análise. Atividade física é opcional e deve respeitar sua orientação profissional. Descanso não reduz XP.")
        } } }
    }
    static var weeks: [Week] {
        (1...40).map { n in Week(id: n, goal: "\(chapters[(n-1)/4]) — \(["Observar", "Aprender", "Aplicar com segurança", "Revisar"][((n-1)%4)])", plan: "Segunda: fisioterapia\nTerça: Society\nQuarta: academia ou recuperação\nQuinta: fisioterapia e Society\nSexta: academia se adequado\nSábado: prática opcional\nDomingo: descanso\nAjuste todas as atividades conforme recuperação e orientação profissional.") }
    }
    static func formation(_ index: Int) -> [Player] {
        let setups: [[(Double,Double)]] = [[(0.5,0.9),(0.25,0.7),(0.75,0.7),(0.25,0.4),(0.75,0.4),(0.5,0.18)],[(0.5,0.9),(0.2,0.7),(0.5,0.7),(0.8,0.7),(0.3,0.3),(0.7,0.3)],[(0.5,0.9),(0.5,0.7),(0.2,0.45),(0.5,0.45),(0.8,0.45),(0.5,0.18)]]
        return setups[max(0,min(index,2))].enumerated().map { Player(number: $0.offset+1, x: $0.element.0, y: $0.element.1) }
    }
}
