extends SceneTree

var falhas = 0
var jogo

func _initialize() -> void:
	call_deferred("executar")

func verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error(mensagem)

func botoes(no: Node, encontrados: Array = []) -> Array:
	for filho in no.get_children():
		if filho is Button:
			encontrados.append(filho)
		botoes(filho, encontrados)
	return encontrados

func layout() -> void:
	await process_frame
	await process_frame
	var limites: Rect2 = jogo.ui.painel.get_global_rect()
	verificar(limites.end.x <= 1280 and limites.end.y <= 670, "Seleção cabe em 1280×720")

func executar() -> void:
	jogo = load("res://scenes/rpg.tscn").instantiate()
	root.add_child(jogo)
	jogo.duracao_ataque = 0.05
	await process_frame
	for id in range(1, 4):
		for arma in ["espada", "arco"]:
			jogo.menu()
			verificar(jogo.ui.etapa_menu == "personagem", "Personagem é a primeira etapa")
			await layout()
			var escolhas = botoes(jogo.ui.painel, [])
			verificar(escolhas.size() == 3, "Três personagens disponíveis")
			escolhas[id - 1].pressed.emit()
			verificar(jogo.personagem == id and jogo.ui.etapa_menu == "arma", "Escolha abre etapa de armas")
			await layout()
			var armas = botoes(jogo.ui.painel, [])
			verificar(armas.size() == 3, "Duas armas e botão voltar")
			armas[2].pressed.emit()
			verificar(jogo.ui.etapa_menu == "personagem", "Voltar permite trocar personagem")
			botoes(jogo.ui.painel, [])[id - 1].pressed.emit()
			botoes(jogo.ui.painel, [])[0 if arma == "espada" else 1].pressed.emit()
			verificar(jogo.estado == jogo.Estado.EXPLORACAO, "Arma inicia o jogo")
			verificar(jogo.player.personagem == id and jogo.player.arma == arma, "Combinação aplicada ao jogador")
			var sprite: AnimatedSprite2D = jogo.player.sprite
			for animacao in ["parado", "corrida", "pulo", "ataque", "dano", "morte"]:
				verificar(sprite.sprite_frames.has_animation(animacao), "Animação disponível: " + animacao)
				var textura: AtlasTexture = sprite.sprite_frames.get_frame_texture(animacao, 0)
				verificar(textura.atlas.resource_path.contains("/%s/%d/" % [arma, id]), "Textura do personagem e arma corretos")
				verificar(textura.region.size == Vector2(42, 42), "Quadro recortado sem incluir o vizinho")
			verificar(sprite.sprite_frames.get_frame_count("parado") == 4, "Quatro quadros idle")
			verificar(sprite.sprite_frames.get_frame_count("ataque") == 6, "Seis quadros de ataque")
			await create_timer(0.22).timeout
			verificar(sprite.frame > 0, "Animação parado avança")
			await create_timer(0.12).timeout
			verificar(jogo.player.is_on_floor(), "Pés apoiados no chão")
			var colisao: CollisionShape2D = jogo.player.get_node("CollisionShape2D")
			var pe = jogo.player.position.y + colisao.position.y + colisao.shape.size.y / 2
			verificar(absf(pe - 600) < 0.2, "Colisão alinhada à superfície")
			jogo.iniciar_encontro()
			jogo.responder(jogo.batalha.pergunta.correta)
			verificar(sprite.animation == "ataque", "Acerto usa o sprite de ataque")
			await create_timer(0.1).timeout
			verificar(jogo.mortos == 1, "Ataque conclui a batalha")
			jogo.continuar()
			jogo.iniciar_encontro()
			var correta: int = jogo.batalha.pergunta.correta
			var erros = 0
			for i in range(4):
				if i == correta:
					continue
				jogo.responder(i)
				erros += 1
				verificar(sprite.animation == ("morte" if erros == 3 else "dano"), "Erro anima dano ou morte")
				await create_timer(0.1).timeout
			verificar(jogo.estado == jogo.Estado.DERROTA, "Três erros levam à derrota")
			jogo.carregar_fase(jogo.fase)
			verificar(jogo.player.personagem == id and jogo.player.arma == arma, "Reinício mantém as escolhas")
			verificar(sprite.animation == "parado" and not jogo.player.acao_especial, "Reinício limpa animação de morte")
			jogo.carregar_fase(1)
			verificar(jogo.player.personagem == id and jogo.player.arma == arma, "Mudança de fase mantém as escolhas")
	print("HERO_TEST_RESULT: %d falhas" % falhas)
	quit(0 if falhas == 0 else 1)
