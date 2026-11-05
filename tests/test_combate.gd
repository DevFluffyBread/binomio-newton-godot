extends SceneTree

var jogo
var falhas = 0

func _initialize() -> void:
	call_deferred("executar")

func verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error(mensagem)

func esperar_animacao() -> void:
	for i in range(180):
		await process_frame
		if jogo.estado != jogo.Estado.ANIMACAO:
			await process_frame
			return
	verificar(false, "Ataque conclui dentro do limite")

func ia(monstro, quadros: int) -> void:
	for i in range(quadros):
		await physics_frame
		monstro.atualizar_ia(1.0 / 60)
		verificar(monstro.area.has_point(monstro.position), "Inimigo permanece na própria sala")

func executar() -> void:
	jogo = load("res://scenes/rpg.tscn").instantiate()
	root.add_child(jogo)
	jogo.iniciar("espada")
	jogo.set_physics_process(false)
	jogo.player.set_physics_process(false)
	jogo.mundo.set_physics_process(false)
	jogo.duracao_ataque = 0.04
	await physics_frame
	var monstro = jogo.mundo.monstros[0]
	jogo.player.position = Vector2(160, 460)
	monstro.recarga = 999
	var distancia = monstro.position.distance_to(jogo.player.position)
	await ia(monstro, 150)
	verificar(monstro.position.distance_to(jogo.player.position) < distancia - 40, "Persegue contornando o pilar")
	verificar(not jogo.mundo.PILARES[0].grow(9).has_point(monstro.position), "Não atravessa o pilar")
	var caminho_borda = jogo.mundo.caminho(0, monstro.position, Vector2(59, 500))
	verificar(caminho_borda.size() > 0, "Perseguição continua quando o jogador encosta na parede")
	jogo.mundo.portoes[0].collision_layer = 0
	jogo.player.position = Vector2(700, 392)
	await ia(monstro, 90)
	verificar(monstro.position.x < 424, "Não segue o jogador pela sala vizinha, mesmo com portão aberto")
	# Aviso dá oportunidade de esquiva.
	monstro.position = Vector2(300, 300)
	jogo.player.position = Vector2(300, 345)
	monstro.estado = "parado"
	monstro.recarga = 0
	await physics_frame
	monstro.atualizar_ia(0.01)
	verificar(monstro.aviso > 0 and jogo.vidas == 3, "Aviso não causa dano imediato")
	jogo.player.position = Vector2(390, 345)
	monstro.atualizar_ia(0.8)
	verificar(jogo.vidas == 3, "Sair do círculo evita o dano")
	await create_timer(0.42).timeout
	jogo.player.position = Vector2(300, 345)
	monstro.recarga = 0
	await physics_frame
	monstro.atualizar_ia(0.01)
	monstro.atualizar_ia(0.8)
	verificar(jogo.vidas == 2, "Permanecer no círculo perde um coração")
	jogo.receber_dano()
	verificar(jogo.vidas == 2, "Invulnerabilidade impede dano consecutivo")
	jogo._physics_process(1.3)
	jogo.receber_dano()
	verificar(jogo.vidas == 1, "Pode receber dano após invulnerabilidade")
	jogo._physics_process(1.3)
	jogo.receber_dano()
	verificar(jogo.estado == jogo.Estado.DERROTA, "Três golpes inimigos causam derrota")
	jogo.carregar_fase(0)
	verificar(jogo.vidas == 3 and jogo.carga_critico == 0 and jogo.invulneravel == 0, "Reinício restaura vida e carga")
	for arma in ["espada", "arco"]:
		jogo.menu()
		jogo.iniciar(arma)
		monstro = jogo.mundo.monstros[0]
		jogo.player.position = monstro.position + Vector2(0, 64)
		await physics_frame
		jogo._physics_process(0)
		verificar(jogo.estado == jogo.Estado.EXPLORACAO, "Proximidade não abre pergunta")
		jogo.tentar_critico()
		verificar(jogo.estado == jogo.Estado.EXPLORACAO, "Crítico exige carga")
		var tecla = InputEventKey.new()
		tecla.keycode = KEY_SPACE
		tecla.pressed = true
		jogo.player._unhandled_input(tecla)
		verificar(jogo.carga_critico == 1, "Espaço acerta e carrega")
		jogo.atacar()
		verificar(jogo.carga_critico == 1, "Recarga impede spam")
		verificar(monstro.sprite.animation == "dano", "Golpe comum mostra reação")
		verificar(monstro.repulsao.length() > 0, "Golpe comum afasta e interrompe inimigo")
		for i in range(2):
			jogo.recarga_ataque = 0
			jogo.atacar()
		verificar(jogo.carga_critico == 3 and jogo.mortos == 0 and monstro.visible, "Três comuns carregam sem matar")
		verificar(jogo.mundo.portoes[0].collision_layer == 1, "Área exige pergunta para abrir")
		jogo._physics_process(0)
		verificar(not jogo.ui.botao_critico.disabled, "Botão habilitado ao alcance com carga")
		tecla.keycode = KEY_E
		jogo.player._unhandled_input(tecla)
		verificar(jogo.estado == jogo.Estado.PERGUNTA, "E abre a pergunta do crítico")
		var antes: Vector2 = monstro.position
		jogo.mundo._physics_process(1)
		verificar(monstro.position == antes and not jogo.mundo.explorando, "Pergunta pausa perseguição")
		var correta: int = jogo.batalha.pergunta.correta
		jogo.responder((correta + 1) % 4)
		await esperar_animacao()
		verificar(jogo.vidas == 2 and jogo.mortos == 0 and jogo.carga_critico == 3, "Erro custa vida e mantém pergunta disponível")
		jogo.responder(correta)
		jogo.responder(correta)
		await esperar_animacao()
		verificar(jogo.mortos == 1 and jogo.carga_critico == 0 and jogo.mundo.portoes[0].collision_layer == 0, "Um crítico mata e libera a área uma única vez")
		jogo.continuar()
		verificar(jogo.mundo.explorando, "Continuar retoma exploração")
	# Alcance, paredes e outra área não podem carregar o crítico.
	jogo.menu()
	jogo.iniciar("arco")
	monstro = jogo.mundo.monstros[0]
	jogo.player.position = Vector2(170, 400)
	monstro.position = Vector2(260, 400)
	await physics_frame
	jogo.atacar()
	verificar(jogo.carga_critico == 0, "Flecha não atravessa pilar")
	jogo.recarga_ataque = 0
	monstro.position = Vector2(360, 300)
	jogo.player.position = Vector2(120, 300)
	await physics_frame
	jogo.atacar()
	verificar(jogo.carga_critico == 0, "Golpe fora de alcance não carrega")
	jogo.recarga_ataque = 0
	jogo.player.position = Vector2(190, 300)
	await physics_frame
	jogo.atacar()
	verificar(jogo.carga_critico == 1, "Arco alcança inimigo à distância")
	jogo.recarga_ataque = 0
	jogo.player.position = Vector2(460, 300)
	jogo.atacar()
	verificar(jogo.carga_critico == 1, "Não ataca inimigo de outra sala")
	# Nenhuma das nove áreas pode ser concluída só com golpes comuns.
	jogo.menu()
	jogo.iniciar("espada")
	var perguntas = 0
	for fase in range(3):
		for area in range(3):
			monstro = jogo.mundo.monstros[area]
			jogo.player.position = monstro.position + Vector2(0, 60)
			await physics_frame
			verificar(jogo.carga_critico == 0, "Cada área exige nova carga")
			for golpe in range(3):
				jogo.recarga_ataque = 0
				jogo.atacar()
			verificar(jogo.mortos == area, "Golpes comuns nunca liberam área")
			jogo.tentar_critico()
			verificar(jogo.estado == jogo.Estado.PERGUNTA, "Cada área abre uma pergunta para finalizar")
			perguntas += 1
			jogo.responder(jogo.batalha.pergunta.correta)
			await esperar_animacao()
			jogo.continuar()
		jogo.player.position = jogo.mundo.SAIDA
		jogo._physics_process(0.02)
	verificar(perguntas == 9 and jogo.estado == jogo.Estado.VITORIA, "Campanha exige nove críticos respondidos")
	print("COMBAT_TEST_RESULT: %d falhas" % falhas)
	quit(0 if falhas == 0 else 1)
