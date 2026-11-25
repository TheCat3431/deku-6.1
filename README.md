# PROJECT DEKU 6.0 — iOS Native Edition
Projeto SwiftUI, iOS 16+, em português. Projeto de fã não oficial, sem imagens oficiais incluídas. Visual preto, verde e amarelo, com SF Symbols. Não requer servidor para uso básico.

## Windows → iPhone (caminho de teste pessoal)
1. Extraia o ZIP. Crie um repositório privado no GitHub com auxílio do responsável, se necessário. Envie o conteúdo desta pasta, incluindo `.github/workflows/ios.yml` (pastas ocultas precisam ser incluídas). Não envie backups pessoais.
2. No GitHub, abra Actions > iOS build > Run workflow. A execução usa um Mac remoto, instala XcodeGen, gera o projeto e compila com o SDK iOS. O resultado esperado é um artefato chamado ProjectDeku-unsigned, contendo um IPA **sem assinatura**. Se falhar, abra o log de build; não há IPA pré-compilado neste ZIP.
3. Para teste pessoal, o AltStore Classic é uma opção de assinatura local de IPA no Windows. Consulte as instruções oficiais em https://altstore.io/ e https://faq.altstore.io/. Instale o AltServer conforme o guia oficial e configure o iPhone. Com a ajuda de um responsável, use uma conta Apple adequada e siga o procedimento de pareamento e instalação. No AltStore, em My Apps, importe o IPA. A compatibilidade de assinatura de um IPA não assinado deve ser confirmada; se a importação falhar, use o caminho TestFlight. Contas gratuitas normalmente exigem renovação a cada sete dias. Não desative proteções do dispositivo além das permissões oficiais exigidas pelo método de desenvolvimento.

## TestFlight (caminho oficial de distribuição)
1. Um responsável que cumpra os requisitos da Apple deve configurar o Apple Developer Program e App Store Connect. O programa é pago. Consulte https://developer.apple.com/programs/ e https://developer.apple.com/testflight/.
2. Registre um Bundle ID próprio e crie o registro do app em App Store Connect. Substitua `com.projectdeku.hero` pelo identificador escolhido em project.yml e codemagic.yaml.
3. Conecte o repositório ao Codemagic (https://codemagic.io/). Crie a integração App Store Connect com o nome DEKU_ASC e configure certificados e perfis de distribuição para o identificador escolhido. Nunca coloque chaves privadas no repositório.
4. Execute o workflow ios-testflight. O arquivo codemagic.yaml é uma configuração inicial e pode exigir ajustes conforme a conta, versão de Xcode e serviço. Confira https://docs.codemagic.io/yaml-code-signing/signing-ios/ e https://docs.codemagic.io/yaml-publishing/app-store-connect/.
5. Após processamento e eventual revisão da Apple, adicione o testador no App Store Connect e instale pelo TestFlight no iPhone. Para novos uploads, incremente CURRENT_PROJECT_VERSION no project.yml.

## Implementado no código
- Cinco abas nativas; perfil, avatar emoji, XP derivado de missões, 10 patentes.
- 325 missões com IDs distintos, geradas pela combinação de 65 temas e cinco tipos de reflexão; edição, filtros, busca, data, arquivamento, conclusão reversível sem duplicação de XP.
- Cinco módulos com registros, rotinas editáveis, modelo de rotina, biblioteca inicial, cronômetro; séries, repetições e distância como campos de registro textual.
- PROJECT QUADRA: quatro arquétipos, níveis e progresso por tema, sete posições com orientação básica, análise em caderno, quadro Society arrastável com três formações e adversários, impressão via AirPrint.
- 40 semanas editáveis em dez capítulos, agenda semanal flexível, 13 cadernos com busca, tags, favoritos, imagens, compartilhamento e impressão de texto.
- Gráficos de registros e XP por arquétipo, cinco conquistas, lembrete local opcional, backup JSON e restauração.
- Persistência JSON local. Backups contêm anotações pessoais em texto legível; mantenha-os privados. Sem login, ranking online ou telemetria.

## Limites e pendências
A sintaxe Swift foi verificada e os modelos testados em Swift para Linux. SwiftUI, UIKit, Charts, PhotosUI, notificações, impressão, assinatura e execução em iPhone **não foram compilados ou testados aqui**. A primeira execução do workflow remoto é a validação real; podem surgir erros de compilação que precisem de ajustes.
A biblioteca de exercícios é inicial, não contém vídeos nem fichas clínicas. O gerador é um modelo editável, não uma IA. As semanas usam um modelo comum com objetivos temáticos, não 40 planos físicos distintos. A árvore de habilidades é uma lista de progresso, não um mapa RPG de nós conectados. Não há GPS, HealthKit, Apple Watch, animações avançadas, histórico temporal de XP, ícone de aplicativo personalizado, sistema de exploração, conta online ou imagens oficiais. As 325 missões são combinações estruturadas, não 325 textos longos escritos individualmente. A interface não reproduz a marca Liftoff nem material licenciado do anime.
Nenhuma atividade é obrigatória; intensidade não aumenta por XP. O aplicativo não substitui fisioterapia, treinador ou orientação de saúde. Ajustes e descanso não são falhas.

## Testes locais dos modelos (Swift instalado)
`swiftc Sources/Models.swift Tests/main.swift -o deku-test && ./deku-test`

## Checklist após instalar
Abra o app; conclua uma missão e desmarque-a; confira XP; feche e reabra; crie uma rotina e um registro; edite semana; mova um jogador; crie nota com foto; exporte backup e restaure; teste em modo avião; confira permissão e entrega de lembretes. Faça backup antes de reinstalar.
