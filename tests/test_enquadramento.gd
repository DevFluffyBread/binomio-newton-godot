extends SceneTree
var jogo
var falhas = 0
func _initialize(): call_deferred("executar")
func verificar(valor: bool, mensagem: String) -> void:
	if not valor:
		falhas += 1
		push_error(mensagem)
func esperar_estado(estado: int, segundos: float = 6.0) -> void:
	var inicio = Time.get_ticks_msec()
	while jogo.estado != estado and Time.get_ticks_msec() - inicio < segundos * 1000:
		await process_frame
	verificar(jogo.estado == estado, "Estado %d alcançado, atual %d" % [estado, jogo.estado])
func executar():
	jogo = load("res://scenes/rpg.tscn").instantiate()
	root.add_child(jogo)
	jogo.introducao.tempo_legenda = 0.15
	jogo.iniciar("arco")
	verificar(jogo.estado == jogo.Estado.HISTORIA and not jogo.player.pode_mover, "Nova aventura inicia história, sem movimento")
	await process_frame
	verificar(not jogo.ui.objetivo.visible, "HUD permanece oculto durante história")
	verificar(jogo.ui.legenda_historia.text == jogo.introducao.LEGENDAS[0], "Primeira legenda exata")
	await create_timer(0.17).timeout
	verificar(jogo.introducao.legenda_atual == 1, "Segunda legenda automática")
	await create_timer(0.15).timeout
	verificar(jogo.introducao.legenda_atual == 2, "Terceira legenda automática")
	await esperar_estado(jogo.Estado.PRESSAGIO)
	verificar(jogo.camera.zoom == Vector2(2, 2), "História completa restaura câmera e mostra presságio")
	await esperar_estado(jogo.Estado.EXPLORACAO)
	jogo.carregar_fase(0)
	verificar(jogo.estado == jogo.Estado.EXPLORACAO, "Reinício não repete história nem presságio")
	jogo.menu()
	jogo.introducao.tempo_legenda = 4.0
	jogo.iniciar("espada")
	verificar(jogo.estado == jogo.Estado.HISTORIA, "Nova campanha repete história")
	jogo.ui.pular_historia.emit()
	verificar(jogo.estado == jogo.Estado.PRESSAGIO and not jogo.introducao.ativa, "Pular encerra história e inicia presságio")
	jogo.menu_inicial()
	await create_timer(0.1).timeout
	verificar(jogo.estado == jogo.Estado.MENU, "Sair cancela introdução e câmera")
	jogo.cenas_ativas = false
	jogo.chefe_batalha.escala_tempo = 0.5
	jogo.carregar_fase(2, false)
	await esperar_estado(jogo.Estado.ENQUADRAMENTO)
	jogo.ui.selecionar(jogo.batalha.pergunta.correta)
	verificar(jogo.ui.confirmar.disabled and jogo.batalha.bloqueada, "Selecionar durante zoom não libera confirmação")
	jogo.responder(jogo.batalha.pergunta.correta)
	verificar(jogo.estado == jogo.Estado.ENQUADRAMENTO, "Resposta antecipada ignorada")
	await esperar_estado(jogo.Estado.PERGUNTA)
	verificar(jogo.camera.zoom == Vector2(3, 3) and not jogo.ui.confirmar.disabled, "Close concluído libera escolha existente")
	var na_tela: Vector2 = root.get_canvas_transform() * jogo.player.global_position
	verificar(absf(na_tela.x - 320) <= 2, "Jogador enquadrado no lado esquerdo")
	var rect: Rect2 = jogo.ui.painel.get_global_rect()
	verificar(rect.position.x == 620 and rect.end.x <= 1280 and rect.end.y <= 680, "Pergunta cabe no painel direito")
	jogo.responder(jogo.batalha.pergunta.correta)
	verificar(not jogo.ui.painel.visible and jogo.estado == jogo.Estado.ANIMACAO, "Resposta esconde painel")
	await create_timer(0.05).timeout
	verificar(jogo.chefe_batalha.chefe.visual.frame == 7 and not jogo.chefe_batalha.chefe.visual.is_playing(), "Ataque aguarda afastamento da câmera")
	await esperar_estado(jogo.Estado.RESOLUCAO)
	verificar(jogo.camera.zoom == Vector2.ONE and jogo.camera.position == Vector2(640, 360), "Visão geral antes do impacto")
	await esperar_estado(jogo.Estado.RESULTADO)
	verificar(jogo.ui.painel.position.x == 620, "Explicação permanece à direita")
	jogo.continuar()
	await esperar_estado(jogo.Estado.PERGUNTA)
	for etapa in range(3):
		jogo.ui.pergunta_chefe(jogo.perguntas[6 + etapa], etapa, [3], "DICA: " + jogo.perguntas[6 + etapa].dica)
		await process_frame
		await process_frame
		verificar(jogo.ui.painel.get_global_rect().end.y <= 680, "Todas perguntas e dicas cabem")
	# Cancelar um afastamento não retoma o ataque antigo no menu.
	jogo.carregar_fase(2, false)
	await esperar_estado(jogo.Estado.PERGUNTA)
	jogo.responder(jogo.batalha.pergunta.correta)
	jogo.menu_inicial()
	await create_timer(0.5).timeout
	verificar(jogo.estado == jogo.Estado.MENU and jogo.camera.zoom == Vector2.ONE, "Cancelar zoom não altera menu")
	print("FRAMING_TEST_RESULT: %d falhas" % falhas)
	quit(0 if falhas == 0 else 1)
