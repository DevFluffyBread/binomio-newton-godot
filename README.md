# As Ruínas do Binômio

RPG lateral educativo em Godot 4: escolha espada ou arco e derrote nove guardiões respondendo perguntas sobre o Binômio de Newton.

## Executar

Importe `project.godot` no Godot 4.7 ou superior e pressione **F5**. A cena principal é `scenes/rpg.tscn`. A cena `fase_01.tscn` e os scripts originais continuam disponíveis como protótipo anterior.

## Como jogar

- Escolha espada ou arco no menu. As armas têm as mesmas regras e efeitos visuais diferentes.
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
- `scripts/mundo.gd`: cenário, plataformas e monstros desenhados por código.
- `scripts/heroi.gd`: movimento lateral, pulo, arma e recuperação de queda.
- `scripts/piramide.gd`: lógica anterior preservada, inativa na campanha.

Sprites originais do personagem e da porta preservados. Margens transparentes recortadas com regiões do Sprite2D; escala inteira e filtro nearest. Ruínas, monstros, capa, armas e efeitos desenhados por código. Sons de ataque sintetizados em execução, sem dependências externas.

## Validar

Execute com o Godot instalado:

```sh
godot --headless --path . --script res://tests/test_rpg.gd
```

A suíte verifica armas, respostas, bloqueio de cliques repetidos, dicas, derrota, reinício, portas, campanha completa e colisões. O resultado esperado é `RPG_TEST_RESULT: 0 falhas`.

## Colaboração e créditos

Use branches próprias e versione cenas, scripts, imagens, `.import` e `.uid`. Não versione o cache `.godot/`. As imagens foram fornecidas pelo grupo; autoria e licença precisam ser confirmadas antes de distribuição pública. Nenhuma licença foi presumida.
