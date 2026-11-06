extends SceneTree
var jogo
var falhas = 0
func _initialize() -> void:
	call_deferred("executar")
func verificar(valor: bool, texto: String) -> void:
	if not valor:
		falhas += 1
		push_error(texto)
func esperar_estado(estados: Array, limite: float = 5.0) -> bool:
	var inicio = Time.get_ticks_msec()
	while not jogo.estado in estados and Time.get_ticks_msec() - inicio < limite * 1000:
		await process_frame
	var ok: bool = jogo.estado in estados
	if not ok: quit(1)
	verificar(ok, "Estado esperado: %s; atual: %s" % [estados, jogo.estado])
	return ok
func responder_certo() -> void:
	await esperar_estado([jogo.Estado.PERGUNTA])
	jogo.responder(jogo.batalha.pergunta.correta)
	jogo.responder(jogo.batalha.pergunta.correta)
func executar() -> void:
	jogo = load("res://scenes/rpg.tscn").instantiate()
	root.add_child(jogo)
	jogo.cenas_ativas = false
	jogo.chefe_batalha.escala_tempo = 0.2
	for id in range(1, 4):
		for arma in ["espada", "arco"]:
			jogo.personagem = id
			jogo.arma = arma
			jogo.carregar_fase(2, false)
			await esperar_estado([jogo.Estado.PERGUNTA])
			verificar(jogo.mundo.monstros.is_empty() and jogo.mundo.portoes.is_empty() and jogo.mundo.paredes.size() == 4, "Arena exclusiva sem guardiões ou divisórias")
			verificar(not jogo.player.pode_mover and jogo.camera.zoom == Vector2(3, 3), "Close na pergunta e movimento bloqueado")
			var chefe = jogo.chefe_batalha.chefe
			verificar(chefe.visual.frame == 7 and not chefe.visual.is_playing(), "Pergunta pausa no quadro 7")
			chefe.visual.frame = 12
			chefe._fixar_pergunta(chefe.ataque_atual)
			verificar(not chefe.impacto_emitido and chefe.visual.frame == 7, "Processamento atrasado não dispara impacto durante pergunta")
			await create_timer(0.12).timeout
			verificar(chefe.visual.frame == 7 and jogo.vidas == 3, "Sem limite de tempo ou dano enquanto responde")
			var errada: int = (jogo.batalha.pergunta.correta + 1) % 4
			jogo.responder(errada)
			jogo.responder(errada)
			await esperar_estado([jogo.Estado.PERGUNTA])
			verificar(jogo.vidas == 2 and jogo.ui.opcoes[errada].disabled, "Erro causa um dano, bloqueia alternativa e repete mão")
			verificar(jogo.ui.feedback.text.contains("DICA"), "Dica após erro")
			for etapa in range(2):
				if etapa == 1:
					await esperar_estado([jogo.Estado.PERGUNTA])
					var incorreta: int = (jogo.batalha.pergunta.correta + 1) % 4
					jogo.responder(incorreta)
					await esperar_estado([jogo.Estado.PERGUNTA])
					verificar(jogo.chefe_batalha.chefe.maos_neutralizadas == 1 and jogo.vidas == 1, "Erro na segunda mão mantém a primeira neutralizada")
				await responder_certo()
				await esperar_estado([jogo.Estado.RESULTADO])
				verificar(chefe.maos_neutralizadas == etapa + 1, "Mão correta permanece neutralizada")
				jogo.continuar()
			await esperar_estado([jogo.Estado.PERGUNTA])
			verificar(jogo.ui.feedback.text.contains("fatal"), "Aviso de ataque final fatal")
			if id == 1:
				jogo.vidas = 3
				jogo.responder((jogo.batalha.pergunta.correta + 1) % 4)
				await esperar_estado([jogo.Estado.DERROTA])
				verificar(jogo.vidas == 0, "Erro no olho é fatal com três corações")
				jogo.ui.confirmar_saida_chefe()
				verificar(jogo.estado == jogo.Estado.DERROTA, "Confirmação não sai da batalha")
				jogo.ui.derrota_chefe()
				jogo.ui.reiniciar.emit()
				await esperar_estado([jogo.Estado.PERGUNTA])
				verificar(jogo.vidas == 3 and jogo.chefe_batalha.etapa == 0 and jogo.chefe_batalha.chefe.maos_neutralizadas == 0 and jogo.batalha.erradas.is_empty(), "Reinício restaura chefe e opções")
				verificar(jogo.personagem == id and jogo.arma == arma, "Reinício mantém escolhas")
				for etapa in range(2):
					await responder_certo()
					await esperar_estado([jogo.Estado.RESULTADO])
					jogo.continuar()
			await responder_certo()
			await esperar_estado([jogo.Estado.MORTE_CHEFE])
			verificar(jogo.chefe_batalha.mortes_iniciadas == 1, "Morte única após golpe final")
			await esperar_estado([jogo.Estado.VITORIA])
			verificar(not jogo.chefe_batalha.chefe.visual.visible, "Vitória somente após desaparecimento")
	# Três erros nas mãos, em alternativas diferentes, encerram a tentativa.
	jogo.carregar_fase(2, false)
	await esperar_estado([jogo.Estado.PERGUNTA])
	var correta: int = jogo.batalha.pergunta.correta
	for i in range(4):
		if i == correta: continue
		jogo.responder(i)
		await esperar_estado([jogo.Estado.PERGUNTA, jogo.Estado.DERROTA])
	verificar(jogo.vidas == 0 and jogo.estado == jogo.Estado.DERROTA, "Terceiro erro nas mãos mata")
	# Limites da câmera incluem todos os pixels visíveis, mesmo com suavização.
	jogo.carregar_fase(0)
	for ponto in [Vector2(48, 158), Vector2(1232, 158), Vector2(48, 630), Vector2(1232, 630)]:
		jogo.player.position = ponto
		jogo.camera.configurar(jogo.player, false)
		jogo.camera._process(0.016)
		var metade: Vector2 = root.get_visible_rect().size / jogo.camera.zoom * 0.5
		var visivel = Rect2(jogo.camera.position - metade, metade * 2)
		verificar(jogo.camera.LIMITES.encloses(visivel), "Câmera não revela exterior nas bordas")
	jogo.cenas_ativas = true
	jogo.carregar_fase(0)
	verificar(jogo.estado == jogo.Estado.PRESSAGIO and not jogo.player.pode_mover, "Presságio inicial bloqueia comandos")
	await esperar_estado([jogo.Estado.EXPLORACAO])
	jogo.carregar_fase(0)
	verificar(jogo.estado == jogo.Estado.EXPLORACAO, "Reinício não repete presságio")
	jogo.carregar_fase(1)
	verificar(jogo.ui.frase_cinema.text.contains("presença"), "Segundo presságio na fase 2")
	jogo.menu_inicial()
	await create_timer(3.1).timeout
	verificar(jogo.estado == jogo.Estado.MENU, "Cancelamento do presságio não retoma exploração")
	# Cancelar uma apresentação impede callbacks de iniciar batalha no menu.
	jogo.cenas_ativas = true
	jogo.carregar_fase(2)
	jogo.menu_inicial()
	await create_timer(0.3).timeout
	verificar(jogo.estado == jogo.Estado.MENU and not is_instance_valid(jogo.chefe_batalha.chefe), "Sair cancela apresentação")
	print("BOSS_TEST_RESULT: %d falhas" % falhas)
	quit(0 if falhas == 0 else 1)
