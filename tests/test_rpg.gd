extends SceneTree

var jogo
var falhas = 0

func _initialize() -> void:
	call_deferred("executar")

func verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error(mensagem)

func esperar() -> void:
	for i in range(120):
		await process_frame
		if jogo.estado != jogo.Estado.ANIMACAO:
			await process_frame
			return
	verificar(false, "Animação conclui dentro do limite de quadros")

func expansao(b: int, n: int) -> Array[int]:
	# Multiplicação polinomial independente do banco de alternativas.
	var coeficientes: Array[int] = [1]
	for i in range(n):
		var proxima: Array[int] = []
		proxima.resize(coeficientes.size() + 1)
		proxima.fill(0)
		for k in range(coeficientes.size()):
			proxima[k] += coeficientes[k]
			proxima[k + 1] += b * coeficientes[k]
		coeficientes = proxima
	return coeficientes

func abrir_encontro() -> void:
	jogo.player.position = jogo.mundo.monstros[jogo.mortos].position + Vector2(0, 60)
	jogo.carga_critico = 3
	jogo.iniciar_encontro()

func executar() -> void:
	jogo = load("res://scenes/rpg.tscn").instantiate()
	root.add_child(jogo)
	jogo.cenas_ativas = false
	jogo.mundo.set_physics_process(false)
	jogo.duracao_ataque = 0.01
	await process_frame
	verificar(jogo.estado == jogo.Estado.MENU, "Menu inicial")
	verificar(jogo.perguntas.size() == 9, "Nove perguntas")
	verificar(expansao(1, 2) == [1, 2, 1], "Coeficientes grau 2")
	verificar(expansao(2, 2) == [1, 4, 4], "Expansão (x+2)²")
	verificar(expansao(1, 3) == [1, 3, 3, 1], "Coeficientes grau 3")
	verificar(expansao(2, 3)[1] == 6, "Termo x² em (x+2)³")
	verificar(expansao(-1, 2) == [1, -2, 1], "Expansão (x-1)²")
	for p in jogo.perguntas:
		verificar(p.opcoes.size() == 4 and p.correta in range(4), "Formato de pergunta")
		verificar(p.dica != "" and p.explicacao != "", "Dica e explicação")
	for arma in ["espada", "arco"]:
		jogo.iniciar(arma)
		verificar(jogo.player.arma == arma, "Arma escolhida")
		abrir_encontro()
		verificar(not jogo.player.pode_mover, "Movimento bloqueado")
		var pergunta_original: Dictionary = jogo.batalha.pergunta
		var incorreta = (pergunta_original.correta + 1) % 4
		jogo.responder(incorreta)
		jogo.responder(incorreta)
		await esperar()
		verificar(jogo.vidas == 2, "Clique repetido não duplica dano")
		verificar(jogo.ui.opcoes[incorreta].disabled, "Opção errada desabilitada")
		verificar(jogo.batalha.pergunta == pergunta_original, "Mesma pergunta após erro")
		verificar(jogo.ui.feedback.text.contains("DICA"), "Dica exibida")
		jogo.responder(incorreta)
		await esperar()
		verificar(jogo.vidas == 2, "Opção já errada não tira outra vida")
		jogo.responder(pergunta_original.correta)
		jogo.responder(pergunta_original.correta)
		await esperar()
		verificar(jogo.mortos == 1, "Um acerto derrota apenas um monstro")
		verificar(jogo.estado == jogo.Estado.RESULTADO, "Explicação após acerto")
		jogo.continuar()
		verificar(jogo.player.pode_mover, "Exploração retomada")
		# Três erros diferentes encerram a fase, mantendo as vitórias anteriores.
		jogo.carregar_fase(1)
		abrir_encontro()
		for opcao in range(4):
			if opcao != jogo.batalha.pergunta.correta:
				jogo.responder(opcao)
				await esperar()
		verificar(jogo.estado == jogo.Estado.DERROTA and jogo.vidas == 0, "Terceiro erro encerra tentativa")
		jogo.carregar_fase(jogo.fase)
		verificar(jogo.fase == 1 and jogo.vidas == 3 and jogo.mortos == 0, "Reinício da mesma fase")
		verificar(jogo.arma == arma, "Reinício preserva arma")
		# Campanha completa pelas portas.
		jogo.menu()
		jogo.iniciar(arma)
		for fase in range(2):
			verificar(jogo.fase == fase and jogo.vidas == 3, "Vida cheia em cada fase")
			verificar(is_instance_valid(jogo.barreira), "Porta/progresso bloqueados por guardião")
			for monstro in range(3):
				abrir_encontro()
				jogo.responder(jogo.batalha.pergunta.correta)
				await esperar()
				jogo.continuar()
			verificar(jogo.mortos == 3 and jogo.mundo.derrotados == 3, "Três monstros derrotados")
			verificar(jogo.barreira == null, "Caminho liberado")
			jogo.player.position = jogo.mundo.SAIDA
			jogo._physics_process(0.0)
		verificar(jogo.fase == 2 and jogo.mundo.monstros.is_empty(), "Seis guardiões levam à arena exclusiva")
		jogo.menu()
		verificar(jogo.estado == jogo.Estado.MENU, "Retorno ao menu")
	# Aproximar no eixo horizontal sem estar perto no mapa não inicia batalha.
	jogo.iniciar("espada")
	jogo.player.position = Vector2(300, 560)
	await create_timer(0.12).timeout
	verificar(jogo.estado == jogo.Estado.EXPLORACAO, "Encontro usa distância nos dois eixos")
	jogo.player.position = jogo.mundo.pontos[0] + Vector2(0, 50)
	await create_timer(0.12).timeout
	verificar(jogo.estado == jogo.Estado.EXPLORACAO, "Proximidade não inicia pergunta sem crítico")
	abrir_encontro()
	var pergunta_ativa: Dictionary = jogo.batalha.pergunta
	jogo._physics_process(0.0)
	verificar(jogo.batalha.pergunta == pergunta_ativa, "Encontro não reinicia durante pergunta")
	for p in jogo.perguntas:
		jogo.ui.pergunta(p, "REI DO BINÔMIO", [], "−1 coração. DICA: " + p.dica)
		await process_frame
		await process_frame
		verificar(jogo.ui.painel.position.y + jogo.ui.painel.size.y < 670, "Pergunta cabe na altura")
		verificar(jogo.ui.painel.position.x + jogo.ui.painel.size.x <= 1280, "Pergunta cabe na largura")
		verificar(jogo.ui.confirmar.disabled, "Confirmação exige escolha")
		jogo.ui.selecionar(0)
		verificar(not jogo.ui.confirmar.disabled, "Escolha habilita confirmação")
	print("RPG_TEST_RESULT: %d falhas" % falhas)
	quit(0 if falhas == 0 else 1)
