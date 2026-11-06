# Ruínas do Binômio

RPG educativo em Godot 4, com visão de cima, três personagens e duas armas. A campanha tem seis guardiões comuns e um chefe com três perguntas: nove perguntas fixas, sem limite de tempo, voltadas ao ensino médio.

## Executar

Importe project.godot no Godot 4.7 ou superior e pressione F5. Cena principal: scenes/rpg.tscn. F8 interrompe uma execução anterior. Janela 1920×1080, espaço lógico fixo 1280×720, escalado proporcionalmente com barras quando necessário. O protótipo lateral anterior continua em scenes/fase_01.tscn; o script da pirâmide está preservado e inativo na campanha.

## Como jogar

- Menu inicial: Iniciar aventura, Tutorial, Opções e Créditos. Escolha Violeta, Prata ou Azul, depois espada ou arco.
- Fases 1 e 2: WASD/setas para andar; Espaço/clique para atacar; três acertos carregam o crítico. Aperte E ao alcance do guardião para responder à pergunta e derrotá-lo.
- Erros custam um coração, mostram dicas e desativam a alternativa escolhida. Golpes comuns não matam guardiões.
- Inimigos perseguem somente dentro da própria sala. O círculo vermelho avisa o ataque; fuja antes do impacto. Há três corações por fase e invulnerabilidade breve após dano.
- Cada fase comum tem três salas e três guardiões. Derrotá-los abre os portões; a saída à direita leva à próxima fase.
- A câmera acompanha o jogador com zoom 2× nas fases comuns e é limitada às bordas físicas do mapa, inclusive durante a suavização. Perguntas congelam o enquadramento; o HUD permanece fixo.
- Não há nomes, placas, textos de estado ou instruções fixas desenhadas no cenário; HUD e efeitos temporários de combate permanecem. Há oito detalhes decorativos por sala, sem novas colisões: duas tochas, duas raízes, duas ossadas, uma pedra e uma marca rúnica. Pilares continuam sólidos; rotas de navegação permanecem intactas.

## Controles em telas de toque

Joystick à esquerda para mover; botão de ataque à direita (pode manter pressionado); círculo pequeno com estrela próximo ao joystick para o crítico. Toques simultâneos são independentes. Soltar o dedo, perder foco ou abrir um painel limpa o movimento. Toques não geram ataques duplicados por emulação de mouse.

Os controles são detectados automaticamente em dispositivos com toque. No PC, é possível visualizar a interface adaptada executando `RuinasDoBinomio.exe -- --touch`. Teclado e mouse continuam disponíveis.

A interface móvel amplia textos e alvos, reorganiza alternativas, oferece rolagem nos painéis e preserva o jogador à esquerda nas perguntas do chefe. No modo retrato, uma tela pede para girar o celular e pausa o jogo. O áudio Web aguarda o primeiro gesto do usuário e usa reprodução Stream para manter os sons gerados. Volume e trilha do chefe continuam independentes.

A adaptação foi validada com eventos de toque simulados e capturas; o teste em aparelho real e a publicação Web ainda estão pendentes. GitHub Pages não foi configurado.

## Fase 3: chefe das profundezas

Arena exclusiva com visão geral nos ataques, close do jogador nas perguntas, centro livre, quatro tochas e quatro marcas periféricas. A fase começa com três corações, mantendo herói e arma.

Apresentação: fade para preto de 0,6 s, frase “Algo ressurgiu das profundezas.” por 2 s, dissolução de 0,4 s, título subindo até o centro em 1,4 s. Nesse instante começa o surgimento de 2 s e o mapa clareia. O título continua subindo, permanece 0,8 s e dissolve em 0,4 s. Nome provisório configurável em scripts/combate_chefe.gd (NOME).

A batalha começa automaticamente e tem três etapas: mão esquerda, mão direita e olho central. No quadro 7, o ataque pausa e a câmera aproxima até 3× em 0,45 s, enquadrando o jogador à esquerda. A pergunta aparece no painel direito (620,120; largura 620), com quatro opções em coluna. A confirmação exige escolha e término da aproximação. Não há cronômetro. Após confirmar, o painel some e a câmera volta à visão geral em 0,45 s antes de retomar o ataque. A resolução ocorre no impacto do quadro 12. As explicações das mãos permanecem à direita, em visão geral. Respostas duplicadas são bloqueadas.

- Acerto nas mãos: esquiva e contra-ataque automáticos, específicos da arma; olho neutralizado permanece fechado. Explicação e Continuar levam à próxima etapa.
- Erro nas mãos: perde um coração; mesma pergunta com dica e alternativa errada desativada. A outra mão já neutralizada permanece assim enquanto houver vidas.
- Após ambas as mãos: o corpo sobe e prepara fogo roxo. O aviso informa que o erro será fatal. No impacto, a onda sai do olho em direção ao alvo. Acertar provoca esquiva e golpe fatal; errar mata mesmo com três corações.
- A morte do chefe dura 4 s, com tremor, expressões matemáticas, explosão local e desaparecimento. Não há flash adicional de tela inteira. Após a morte começa o encerramento; a vitória abre depois dele, incluindo a explicação da última pergunta.
- Tentar novamente restaura três corações, as duas mãos e as alternativas, mantém arma/herói e pula a apresentação. Menu principal exige confirmação e avisa que uma nova aventura recomeça do início da ruína.

Não há carregamento manual de crítico ou combate livre na arena do chefe. As perguntas controlam a esquiva, o dano e o contra-ataque.

## Encerramento

Depois da animação completa de morte do chefe, o pacote encerramento_pixelorama toca uma vez: 144 quadros a 12 fps, 12 s, ampliação 4× e filtro nearest. Entre 6 e 8 s, um visual do personagem e arma escolhidos caminha para fora da entrada e permanece na frente das portas antes de fecharem. Textos ficam separados da arte e abaixo do personagem, na faixa reservada.

Há uma transição de entrada de 0,4 s e um título final de 1,2 s; a vitória vem em seguida, mantendo o último quadro ao fundo e a explicação da pergunta final. Pular encerramento leva diretamente a esse quadro e à vitória. Menu e nova fase cancelam callbacks e animações antigos. O controle está em scripts/encerramento.gd; cenas_ativas=false pula a cena para as suítes de regras.

A música do chefe desaparece suavemente; a trilha comum retorna em volume mais baixo durante o encerramento e a vitória. Menu ou nova fase restauram o volume habitual, respeitando as opções e o silêncio.

## História inicial

Depois de escolher personagem e arma, uma nova aventura começa com três legendas automáticas sobre a entrada da ruína. Cada uma dura 4 segundos, incluindo entrada e saída suaves. As duas primeiras legendas usam as imagens 01_selos e 02_despertar. A terceira usa a abertura das portas (48 quadros a 12 fps, sem loop, 4 s). Os PNGs nativos 320×180 são ampliados 4× com filtro nearest, sob o texto e painel escuro translúcido. Artes e legendas têm fades suaves; não há narração por voz. Pular introdução está disponível desde o início. História e combate são mutuamente exclusivos. Ao concluir ou pular, a câmera normal é restaurada e o presságio da fase 1 começa. Reinícios não repetem a história; uma nova aventura repete. Controle separado em scripts/introducao.gd.

## Presságios, áudio e opções

No início da fase 1: “Você ouve barulhos estranhos…”. Na fase 2: “Você sente uma presença desconcertante…”. Cada cena dura 3 s e ocorre uma vez por campanha; reiniciar a fase não repete o aviso.

A música comum começa no menu e repete automaticamente nas ruínas. Ao completar o fade para preto da fase 3, a gravação fornecida (musica_chefe.mp3) substitui a trilha comum e toca em loop durante apresentação e batalha. Reiniciar o chefe não reinicia a música. Voltar ao menu ou carregar uma fase comum restaura a trilha das ruínas; volume e silêncio são preservados nas trocas. Quatro variações de espada e impacto do arco têm reprodução independente. Música base -18 dB, efeitos -7 dB. A trilha do chefe recebe compensação individual de +7,7 dB, preservada pelas opções e pelo suspense. Medição dos MP3s decodificados: RMS das ruínas -16,75 dBFS e do chefe -24,47 dBFS; pico do chefe -7,78 dBFS antes do ganho. Presságios usam um som grave sintetizado e reduzem temporariamente a música. Opções ajusta música e efeitos separadamente e permite tela cheia; configurações duram pela sessão. Não há salvamento permanente.

## Estrutura e arte

Controle geral em scripts/jogo.gd; batalha do chefe em scripts/combate_chefe.gd; visual e marcadores em scripts/chefe_visual.gd; câmera limitada em scripts/camera_ruinas.gd. Interface e perguntas permanecem separadas do controle de combate.

- Heróis e monstros: CraftPix; origens e licenças em assets/herois/CREDITOS.md e assets/monstros/CREDITOS.md. As variantes não usadas na nova campanha continuam disponíveis.
- Cenário: DungeonTale / Dungeon Story de NullTale, copyright 2024, https://nulltale.itch.io/dungeon-story. Licença CC BY-ND 4.0 incluída em assets/dungeon_tale/Ds by NullTale.txt. Atlas original preservado.
- Interface: Pixel UI Free de heyheythere, https://heyheythere.itch.io/pixel-ui-free, CC BY 4.0. Recursos e licença em addons/pixel_ui/. Fonte adaptada com acentos em assets/font/; símbolos matemáticos têm fonte de reserva.
- Fundo do menu: Fort of Illusion, kit fornecido pelo usuário; licença original em assets/fort_illusion/public-license.pdf. Céu, montanhas, torres e chão se deslocam em parallax; herói Violeta corre com espada em loop à esquerda.
- Chefe: pacote completo chefe_tetraedro_morte fornecido pelo usuário; onze animações, incluindo surgimento, mãos, olho, fogo, reações, idles e morte. Quadros 128×128, 12 fps, origem inferior preservada. Ajuste de código fixa a pausa no quadro 7 mesmo em quadros de processamento longos; pixels não foram regenerados.
- Áudio: origens em assets/audio/ORIGEM.txt. Autoria/licença das imagens originais do protótipo permanece a confirmar.

## Validação

Execute cada suíte com `godot --headless --path . --script res://tests/NOME.gd`:

- test_rpg: matemática, perguntas, dicas, cliques repetidos, vida, reinício e progressão das duas fases comuns para a arena.
- test_herois: seis combinações, escolhas, animações e colisões.
- test_monstros: variantes dos seis guardiões, animações, direção e reinício.
- test_exploracao: quatro direções, diagonal, paredes, pilares e portões.
- test_combate: perseguição, confinamento, esquiva, invulnerabilidade, alcance e exigência de seis críticos comuns.
- test_menu: navegação, parallax e opções de áudio.
- test_toque: joystick, dois dedos, ataque/crítico, limpeza dos controles e painéis móveis.
- test_encerramento: seis combinações, saída do herói, último quadro, vitória, pular, cancelamento e transição musical com volume zero.
- test_midias: duas imagens, animação das portas, recortes, música sincronizada com tela preta, loop, reinício, restauração e silêncio.
- test_enquadramento: história completa e pulo, nova campanha, cancelamentos, bloqueio de resposta durante zoom, jogador à esquerda, alternativas e dicas no painel direito e visão geral antes do impacto.
- test_chefe: seis combinações; pausa no quadro 7; erros e dicas nas duas mãos; erro final fatal; três falhas; restauração; morte e vitória; câmera nos cantos; presságios e cancelamento de cenas.

Todos devem terminar com 0 falhas. As suítes comuns desativam cenas de apresentação para isolar as regras; test_chefe e a revisão renderizada exercitam as transições.

## Exportar Windows

Modelo Windows Desktop em export_presets.cfg: Windows x86_64 com pacote incorporado ao executável. Exemplo: godot --headless --path . --export-release "Windows Desktop" build/windows/RuinasDoBinomio.exe. As exportações ficam fora do versionamento; não incluir .godot ou credenciais em commits.
