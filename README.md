# As Ruínas do Binômio

RPG lateral educativo em Godot 4: escolha um dos três heróis, equipe espada ou arco e derrote nove guardiões respondendo perguntas sobre o Binômio de Newton.

## Executar

Importe `project.godot` no Godot 4.7 ou superior e pressione **F5**. A cena principal é `scenes/rpg.tscn`. A cena `fase_01.tscn` e os scripts originais continuam disponíveis como protótipo anterior.

## Como jogar

- Primeiro escolha Violeta, Prata ou Azul, com prévias animadas. Depois escolha espada ou arco. Use Voltar para trocar o personagem antes de começar. As escolhas são preservadas ao reiniciar ou mudar de fase.
- A/D ou setas movem; Espaço, W ou seta para cima pulam.
- Aproxime-se do próximo monstro para abrir a pergunta, escolha uma das quatro alternativas e confirme.
- Acertar causa golpe crítico e derrota o monstro. Leia a explicação e clique em Continuar.
- Errar custa um coração e revela uma dica. A alternativa errada fica desabilitada.
- Cada fase começa com três corações. Ao zerar, reinicie a mesma fase ou volte ao menu para trocar a arma.
- Derrote os três monstros para abrir a porta. Ande até ela para mudar de fase. A terceira porta conclui a aventura.
- Cair em um buraco retorna ao último chão seguro, sem perder vida.

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
- `scripts/heroi.gd`: movimento lateral, pulo, animações e recuperação de queda.
- `scripts/visual_heroi.gd`: quadros e prévias dos três personagens com as duas armas.
- `scripts/piramide.gd`: lógica anterior preservada, inativa na campanha.

Jogadores animados dos packs Tiny Pixel Hero da CraftPix: parado, corrida, pulo, ataque, dano e morte, nas seis combinações de personagem e arma. Quadros de 42×42 pixels recortados no Godot; escala inteira, filtro nearest e colisão de corpo independente do alcance da arma. O personagem original continua no protótipo anterior. Porta original preservada. Monstros animados dos packs Slime Mobs e Predator Plant da CraftPix substituem os desenhos provisórios. As seis variantes usam a direção esquerda, com idle, ataque, dano e morte. O chefe é uma planta maior com coroa; veja `assets/monstros/CREDITOS.md`. Ruínas e efeitos continuam desenhados por código. Sons sintetizados em execução. Veja `assets/herois/CREDITOS.md` para a origem e a licença da arte.

## Validar

Execute com o Godot instalado:

```sh
godot --headless --path . --script res://tests/test_rpg.gd
godot --headless --path . --script res://tests/test_herois.gd
godot --headless --path . --script res://tests/test_monstros.gd
```

A suíte verifica armas, respostas, bloqueio de cliques repetidos, dicas, derrota, reinício, portas, campanha completa e colisões. Os resultados esperados são `RPG_TEST_RESULT: 0 falhas` e `HERO_TEST_RESULT: 0 falhas`. A suíte de monstros espera `MONSTER_TEST_RESULT: 0 falhas` e confere os nove encontros, as seis variantes, ataque, dano, morte, direção lateral e reinício. A segunda suíte cobre as seis combinações, ordem da seleção, botão Voltar, animações, colisão, morte e preservação das escolhas.

## Colaboração e créditos

Use branches próprias e versione cenas, scripts, imagens, `.import` e `.uid`. Não versione o cache `.godot/`. Os novos heróis e monstros são da CraftPix e seguem a licença do fornecedor, documentada em `assets/herois/CREDITOS.md` e `assets/monstros/CREDITOS.md`. A autoria e licença das imagens originais do protótipo ainda precisam ser confirmadas.
