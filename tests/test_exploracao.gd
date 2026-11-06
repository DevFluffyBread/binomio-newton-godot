extends SceneTree

var jogo
var falhas = 0

func _initialize() -> void:
	call_deferred("executar")

func verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error(mensagem)

func andar(direcao: Vector2, quadros: int) -> void:
	for i in range(quadros):
		await physics_frame
		jogo.player.mover(direcao)

func executar() -> void:
	jogo = load("res://scenes/rpg.tscn").instantiate()
	root.add_child(jogo)
	jogo.cenas_ativas = false
	jogo.mundo.set_physics_process(false)
	jogo.iniciar("arco")
	jogo.set_physics_process(false)
	jogo.player.set_physics_process(false)
	await physics_frame
	verificar(jogo.player.get_parent() == jogo.mundo.atores and jogo.mundo.atores.y_sort_enabled, "Profundidade organizada pelos pés")
	for direcao in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
		jogo.player.position = Vector2(120, 500)
		await andar(direcao, 6)
		var deslocamento: Vector2 = jogo.player.position - Vector2(120, 500)
		verificar(deslocamento.dot(direcao) > 15, "Movimento na direção " + str(direcao))
		verificar(jogo.player.sprite.animation == "corrida", "Movimento usa animação de corrida")
	jogo.player.position = Vector2(120, 500)
	await andar(Vector2(1, -1), 6)
	verificar(is_equal_approx(jogo.player.velocity.length(), jogo.player.VELOCIDADE), "Diagonal não é mais rápida")
	var posicao: Vector2 = jogo.player.position
	jogo.mudar_estado(jogo.Estado.PERGUNTA)
	await andar(Vector2.RIGHT, 6)
	verificar(jogo.player.position == posicao, "Pergunta bloqueia movimento")
	jogo.mudar_estado(jogo.Estado.EXPLORACAO)
	jogo.player.position = Vector2(100, 490)
	await andar(Vector2.ZERO, 12)
	verificar(jogo.player.position == Vector2(100, 490), "Sem gravidade ou deslizamento")
	# Paredes externas, pilares e portões têm colisão real.
	jogo.player.position = Vector2(80, 500)
	await andar(Vector2.LEFT, 20)
	verificar(jogo.player.position.x >= 57, "Parede externa bloqueia saída do mapa")
	jogo.player.position = Vector2(160, 400)
	await andar(Vector2.RIGHT, 20)
	verificar(jogo.player.position.x <= 187, "Pilar bloqueia a passagem")
	for fase in range(2):
		jogo.carregar_fase(fase)
		verificar(jogo.mundo.portoes.size() == 3, "Três portões por região")
		jogo.player.position = Vector2(390, 392)
		await andar(Vector2.RIGHT, 20)
		verificar(jogo.player.position.x < 425, "Primeira área não pode ser atravessada antes da batalha")
		jogo.mortos = 1
		jogo.atualizar_barreira()
		await andar(Vector2.RIGHT, 20)
		verificar(jogo.player.position.x > 455, "Primeira vitória libera a segunda sala")
		verificar(jogo.mundo.portoes[1].collision_layer == 1 and jogo.mundo.portoes[2].collision_layer == 1, "Outras áreas continuam seladas")
		await andar(Vector2.LEFT, 20)
		verificar(jogo.player.position.x < 420, "É possível voltar à sala anterior")
		jogo.mortos = 2
		jogo.atualizar_barreira()
		jogo.player.position = Vector2(800, 392)
		await andar(Vector2.RIGHT, 20)
		verificar(jogo.player.position.x > 865, "Segunda vitória libera a terceira sala")
		verificar(jogo.mundo.portoes[2].collision_layer == 1, "Saída aguarda o chefe")
		jogo.player.position = Vector2(1200, 392)
		await andar(Vector2.RIGHT, 20)
		verificar(jogo.player.position.x < 1225, "Saída bloqueada fisicamente")
		jogo.mortos = 3
		jogo.atualizar_barreira()
		verificar(jogo.mundo.portoes[2].collision_layer == 0, "Terceira vitória abre a saída")
		jogo.carregar_fase(fase)
		verificar(jogo.player.position == jogo.mundo.ENTRADA, "Reinício retorna à entrada")
		for portao in jogo.mundo.portoes:
			verificar(portao.collision_layer == 1, "Reinício fecha os portões")
	# As quatro linhas dos monstros acompanham o jogador no mapa.
	var monstro = jogo.mundo.monstros[0]
	for par in [[Vector2.LEFT, "esquerda"], [Vector2.RIGHT, "direita"], [Vector2.UP, "costas"], [Vector2.DOWN, "frente"]]:
		monstro.orientar(monstro.position + par[0] * 100)
		verificar(monstro.direcao == par[1], "Monstro vira para " + par[1])
		var frame: AtlasTexture = monstro.sprite.sprite_frames.get_frame_texture("parado", 0)
		verificar(frame.region.position.y == monstro.LINHAS[par[1]] * 64, "Linha correta da direção")
	print("EXPLORATION_TEST_RESULT: %d falhas" % falhas)
	quit(0 if falhas == 0 else 1)
