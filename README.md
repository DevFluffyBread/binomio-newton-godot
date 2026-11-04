# As Ruínas do Binômio

RPG educativo com visão de cima em Godot 4: escolha um dos três heróis, equipe espada ou arco e derrote nove guardiões respondendo perguntas sobre o Binômio de Newton.

## Executar

Importe `project.godot` no Godot 4.7 ou superior e pressione **F5**. A cena principal é `scenes/rpg.tscn`. A cena `fase_01.tscn` e os scripts originais continuam disponíveis como protótipo anterior.

## Como jogar

- Primeiro escolha Violeta, Prata ou Azul, com prévias animadas. Depois escolha espada ou arco. Use Voltar para trocar o personagem antes de começar. As escolhas são preservadas ao reiniciar ou mudar de fase.
- WASD ou setas movem em quatro direções. O movimento diagonal tem a mesma velocidade. Não há gravidade ou pulo na campanha.
- Explore as três salas de cada região. Aproxime-se do guardião da área liberada para abrir a pergunta, escolha uma das quatro alternativas e confirme.
- Acertar causa golpe crítico e derrota o monstro. Leia a explicação e clique em Continuar.
- Errar custa um coração e revela uma dica. A alternativa errada fica desabilitada.
- Cada fase começa com três corações. Ao zerar, reinicie a mesma fase ou volte ao menu para trocar a arma.
- Cada vitória abre fisicamente o portão da próxima sala. As salas anteriores continuam acessíveis. Depois do terceiro monstro, atravesse a saída à direita para mudar de região. A última saída conclui a aventura.
- Paredes e pilares bloqueiam a passagem. O combate suspende o movimento; o painel de respostas se esconde durante os ataques para mostrar as animações no mapa.

## Campanha

| Fase | Tema | Conteúdo |
| --- | --- | --- |
| 1 | Ruínas de jade | A, B, expoente, coeficientes e expansão de grau 2 |
| 2 | Templo de bronze | Coeficientes e termos de grau 3, incluindo sinal negativo |
| 3 | Câmara violeta | Grau 4, sinais e o Rei do Binômio |

As nove perguntas são fixas. Não existe cronômetro; não há dano por contato, combate manual, inventário ou salvamento permanente. Cada chefe também é derrotado com uma resposta correta.

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

Jogadores animados dos packs Tiny Pixel Hero da CraftPix: parado, corrida, pulo, ataque, dano e morte, nas seis combinações de personagem e arma. Quadros de 42×42 pixels recortados no Godot; escala inteira, filtro nearest e colisão de corpo independente do alcance da arma. O personagem original continua no protótipo anterior. Porta original preservada. Monstros animados dos packs Slime Mobs e Predator Plant da CraftPix substituem os desenhos provisórios. As seis variantes acompanham a posição do herói com suas quatro direções, com idle, ataque, dano e morte. O chefe é uma planta maior com coroa; veja `assets/monstros/CREDITOS.md`. Ruínas e efeitos continuam desenhados por código. Sons sintetizados em execução. Veja `assets/herois/CREDITOS.md` para a origem e a licença da arte.

## Validar

Execute com o Godot instalado:

```sh
godot --headless --path . --script res://tests/test_rpg.gd
godot --headless --path . --script res://tests/test_herois.gd
godot --headless --path . --script res://tests/test_monstros.gd
godot --headless --path . --script res://tests/test_exploracao.gd
```

A suíte verifica armas, respostas, bloqueio de cliques repetidos, dicas, derrota, reinício, portas, campanha completa e colisões. Os resultados esperados são `RPG_TEST_RESULT: 0 falhas` e `HERO_TEST_RESULT: 0 falhas`. A suíte de monstros espera `MONSTER_TEST_RESULT: 0 falhas` e confere os nove encontros, as seis variantes, ataque, dano, morte, direção lateral e reinício. A segunda suíte cobre as seis combinações, ordem da seleção, botão Voltar, animações, colisão, morte e preservação das escolhas.

## Colaboração e créditos

Use branches próprias e versione cenas, scripts, imagens, `.import` e `.uid`. Não versione o cache `.godot/`. Os novos heróis e monstros são da CraftPix e seguem a licença do fornecedor, documentada em `assets/herois/CREDITOS.md` e `assets/monstros/CREDITOS.md`. A autoria e licença das imagens originais do protótipo ainda precisam ser confirmadas.

## Perspectiva e arte

A campanha usa salas vistas de cima, ordenação visual pela posição dos pés e janela de 1920×1080 com espaço lógico de 1280×720. Os heróis mantêm as animações laterais fornecidas pelo pack, inclusive ao caminhar verticalmente; novas folhas de frente/costas poderão substituir essa representação. Os monstros já usam frente, costas, esquerda e direita. O protótipo lateral antigo permanece em fase_01.tscn.

A suíte de exploração espera EXPLORATION_TEST_RESULT: 0 falhas e verifica quatro direções, diagonal, paredes, pilares, bloqueio das áreas, abertura e retorno pelos portões, reinício e orientação dos monstros.
