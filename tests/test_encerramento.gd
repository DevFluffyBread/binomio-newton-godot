extends SceneTree
var jogo
var falhas = 0
func _initialize(): call_deferred("executar")
func verificar(valor: bool, texto: String):
	if not valor:
		falhas += 1
		push_error(texto)
func esperar(estado: int, limite: float = 5.0):
	var inicio = Time.get_ticks_msec()
	while jogo.estado != estado and Time.get_ticks_msec() - inicio < limite * 1000:
		await process_frame
	verificar(jogo.estado == estado, "Estado esperado: %d, atual: %d" % [estado, jogo.estado])
func executar():
	jogo = load("res://scenes/rpg.tscn").instantiate()
	root.add_child(jogo)
	jogo.cenas_ativas = false
	jogo.carregar_fase(2, false)
	jogo.cenas_ativas = true
	jogo.encerramento.escala_tempo = 0.05
	jogo.batalha.pergunta = jogo.perguntas[8]
	for id in range(1, 4):
		for arma in ["espada", "arco"]:
			jogo.personagem = id
			jogo.arma = arma
			jogo.mudar_estado(jogo.Estado.MORTE_CHEFE)
			jogo.chefe_batalha._vitoria()
			verificar(jogo.estado == jogo.Estado.ENCERRAMENTO and not jogo.player.pode_mover, "Morte leva ao encerramento e bloqueia comandos")
			await esperar(jogo.Estado.VITORIA)
			verificar(jogo.encerramento.filme.frame == 143 and not jogo.encerramento.filme.is_playing(), "Último quadro mantido, sem loop")
			verificar(jogo.encerramento.saida_iniciada, "Saída do herói foi executada")
			verificar(jogo.encerramento.heroi.sprite_frames == jogo.VisualHeroi.quadros(id, arma), "Personagem e arma escolhidos preservados")
			verificar(jogo.encerramento.raiz_heroi.position.distance_to(Vector2(540, 520)) < 2, "Herói sai antes das portas fecharem")
			verificar(jogo.ui.painel.visible, "Tela de vitória visível acima do encerramento")
			verificar(jogo.encerramento.explicacao == jogo.perguntas[8].explicacao, "Explicação final preservada")
	# Pular funciona durante a transição e não duplica a vitória depois.
	jogo.encerramento.escala_tempo = 0.1
	jogo.encerramento.iniciar()
	jogo.encerramento.pular.pressed.emit()
	verificar(jogo.estado == jogo.Estado.VITORIA and jogo.encerramento.filme.frame == 143 and jogo.encerramento.filme.visible, "Pular leva ao quadro final e à vitória")
	var painel_vitoria = jogo.ui.painel
	await create_timer(0.1).timeout
	verificar(jogo.ui.painel == painel_vitoria, "Callback antigo não duplica vitória")
	jogo.encerramento.iniciar()
	jogo.menu_inicial()
	await create_timer(0.1).timeout
	verificar(jogo.estado == jogo.Estado.MENU and not jogo.encerramento.ativo and jogo.encerramento.painel == null, "Menu cancela encerramento")
	verificar(jogo.sons.nivel_transicao == 1.0, "Menu restaura volume normal")
	# Música acompanha a transição e o silêncio configurado permanece.
	jogo.sons.musica_chefe()
	jogo.sons.volumes(0, 0.5)
	jogo.sons.encerrar_batalha()
	await create_timer(1.6).timeout
	verificar(jogo.sons.faixa_atual == &"ruinas" and jogo.sons.musica.stream_paused, "Transição musical preserva silêncio")
	print("ENDING_TEST_RESULT: %d falhas" % falhas)
	quit(0 if falhas == 0 else 1)
