# As Ruínas do Binômio

RPG educativo com visão de cima em Godot 4: escolha um dos três heróis, equipe espada ou arco e derrote nove guardiões respondendo perguntas sobre o Binômio de Newton.

## Executar

Importe `project.godot` no Godot 4.7 ou superior e pressione **F5**. A cena principal é `scenes/rpg.tscn`. A cena `fase_01.tscn` e os scripts originais continuam disponíveis como protótipo anterior.

## Como jogar

- Primeiro escolha Violeta, Prata ou Azul, com prévias animadas. Depois escolha espada ou arco. Use Voltar para trocar o personagem antes de começar. As escolhas são preservadas ao reiniciar ou mudar de fase.
- WASD ou setas movem em quatro direções. O movimento diagonal tem a mesma velocidade. Não há gravidade ou pulo na campanha.
- Explore as três salas de cada região. Ataque com Espaço ou clique; três golpes acertados carregam o crítico. Use E ou o botão do HUD, ao alcance do guardião, para abrir a pergunta.
- Acertar a pergunta causa golpe crítico e mata o guardião. Golpes comuns interrompem e afastam o inimigo, mas nunca o matam: cada área exige pelo menos uma pergunta correta. Leia a explicação e clique em Continuar.
- Errar custa um coração e revela uma dica. A alternativa errada fica desabilitada.
- Cada fase começa com três corações. Ao zerar, reinicie a mesma fase ou volte ao menu para trocar a arma.
- Cada vitória abre fisicamente o portão da próxima sala. As salas anteriores continuam acessíveis. Depois do terceiro monstro, atravesse a saída à direita para mudar de região. A última saída conclui a aventura.
- Os inimigos patrulham a própria sala e perseguem o jogador dentro dela, contornando pilares. Não atravessam para outra área, mesmo com o portão aberto. Um círculo vermelho avisa o ataque por 0,7 segundo: saia dele para evitar perder um coração. Após dano, há 1,2 segundo de invulnerabilidade.

## Campanha

| Fase | Tema | Conteúdo |
| --- | --- | --- |
| 1 | Ruínas de jade | O que é binômio, significado do expoente e identificação de A, B e n |
| 2 | Templo de bronze | Coeficiente numérico e exemplos guiados de quadrados da soma e da diferença |
| 3 | Câmara violeta | Coeficientes do cubo, completar um termo e desenvolver (x + 1)³ |

As nove perguntas são fixas. As perguntas não têm cronômetro. Não há inventário nem salvamento permanente. Durante perguntas e resultados, a perseguição e os ataques inimigos ficam pausados. Cada chefe também é derrotado com uma resposta correta.

## Estrutura

- `scripts/jogo.gd`: campanha, estados, progressão e efeitos de ataque.
- `scripts/batalha.gd`: pergunta ativa, alternativas erradas e bloqueio de respostas duplicadas.
- `scripts/perguntas.gd`: nove perguntas com resposta, dica e explicação.
- `scripts/interface.gd`: menu, HUD, alternativas e telas de resultado.
- `scripts/mundo.gd`: cenário, plataformas e distribuição dos monstros.
- `scripts/monstro.gd`: sprites laterais e animações dos seis tipos de inimigos.
- `scripts/heroi.gd`: movimento em quatro direções, animações e colisão nos pés.
- `scripts/visual_heroi.gd`: quadros e prévias dos três personagens com as duas armas.
- `scripts/piramide.gd`: lógica anterior preservada, inativa na campanha.

Jogadores animados dos packs Tiny Pixel Hero da CraftPix: parado, corrida, pulo, ataque, dano e morte, nas seis combinações de personagem e arma. Quadros de 42×42 pixels recortados no Godot; escala inteira, filtro nearest e colisão de corpo independente do alcance da arma. O personagem original continua no protótipo anterior. Porta original preservada. Monstros animados dos packs Slime Mobs e Predator Plant da CraftPix substituem os desenhos provisórios. As seis variantes acompanham a posição do herói com suas quatro direções, com idle, caminhada, ataque, dano e morte. O chefe é uma planta maior com coroa; veja `assets/monstros/CREDITOS.md`. Ruínas e efeitos continuam desenhados por código. Sons sintetizados em execução. Veja `assets/herois/CREDITOS.md` para a origem e a licença da arte.

## Validar

Execute com o Godot instalado:

```sh
godot --headless --path . --script res://tests/test_rpg.gd
godot --headless --path . --script res://tests/test_herois.gd
godot --headless --path . --script res://tests/test_monstros.gd
godot --headless --path . --script res://tests/test_exploracao.gd
godot --headless --path . --script res://tests/test_combate.gd
```

A suíte verifica armas, respostas, bloqueio de cliques repetidos, dicas, derrota, reinício, portas, campanha completa e colisões. Os resultados esperados são `RPG_TEST_RESULT: 0 falhas` e `HERO_TEST_RESULT: 0 falhas`. A suíte de monstros espera `MONSTER_TEST_RESULT: 0 falhas` e confere os nove encontros, as seis variantes, ataque, dano, morte, direção lateral e reinício. A segunda suíte cobre as seis combinações, ordem da seleção, botão Voltar, animações, colisão, morte e preservação das escolhas.

## Colaboração e créditos

Use branches próprias e versione cenas, scripts, imagens, `.import` e `.uid`. Não versione o cache `.godot/`. Os novos heróis e monstros são da CraftPix e seguem a licença do fornecedor, documentada em `assets/herois/CREDITOS.md` e `assets/monstros/CREDITOS.md`. A autoria e licença das imagens originais do protótipo ainda precisam ser confirmadas.

## Perspectiva e arte

A campanha usa salas vistas de cima, ordenação visual pela posição dos pés e janela de 1920×1080 com espaço lógico de 1280×720. Os heróis mantêm as animações laterais fornecidas pelo pack, inclusive ao caminhar verticalmente; novas folhas de frente/costas poderão substituir essa representação. Os monstros já usam frente, costas, esquerda e direita. O protótipo lateral antigo permanece em fase_01.tscn.

A suíte de exploração espera EXPLORATION_TEST_RESULT: 0 falhas e verifica quatro direções, diagonal, paredes, pilares, bloqueio das áreas, abertura e retorno pelos portões, reinício e orientação dos monstros.

## Conteúdo para o ensino médio

Nove perguntas em progressão introdutória, combinando teoria e aplicação. As primeiras trabalham vocabulário e identificação; as seguintes usam números pequenos e as fórmulas dos graus 2 e 3. Dicas explicam o próximo passo e cada acerto apresenta uma resolução curta. Os distratores abordam erros comuns, como esquecer o termo do meio ou trocar o sinal do quadrado da diferença. Não é necessário calcular combinações, fatoriais ou expansões de grau 4.

## Combate em tempo real

Espada: alcance de 76 pixels lógicos. Arco: alcance de 200 pixels, bloqueado por paredes e pilares. Ambos carregam o crítico com três acertos; a recarga do golpe comum é 0,45 segundo. Não há crítico automático por proximidade. Um erro na pergunta tira um coração e mantém a mesma pergunta disponível, com dica e alternativa errada desabilitada. O crítico é consumido ao derrotar o guardião; a próxima área começa com carga zero.

As rotas dos inimigos usam AStarGrid2D, colisão física e limites da própria sala. Perguntas pausam a simulação de combate; a animação do ataque continua visível. O teste test_combate.gd verifica perseguição, confinamento, esquiva, invulnerabilidade, recarga, alcance, paredes, carregamento e a exigência de uma pergunta em cada uma das nove áreas. Resultado esperado: COMBAT_TEST_RESULT: 0 falhas.
