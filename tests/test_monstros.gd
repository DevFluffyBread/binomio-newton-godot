extends SceneTree

var falhas = 0

func _initialize() -> void:
	call_deferred("executar")

func verificar(condicao: bool, mensagem: String) -> void:
	if not condicao:
		falhas += 1
		push_error(mensagem)

func executar() -> void:
	var jogo = load("res://scenes/rpg.tscn").instantiate()
	root.add_child(jogo)
	jogo.duracao_ataque = 0.16
	jogo.iniciar("espada")
	var encontrados: Dictionary = {}
	for fase in range(3):
		jogo.carregar_fase(fase)
		verificar(jogo.mundo.monstros.size() == 3, "Três monstros por fase")
		for i in range(3):
			var monstro = jogo.mundo.monstros[i]
			encontrados["%s%d" % [monstro.tipo, monstro.variante]] = true
			verificar(monstro.position == jogo.mundo.pontos[i], "Monstro alinhado ao encontro")
			verificar(monstro.chefe == (fase == 2 and i == 2), "Chefe apenas no último encontro")
			for anim in ["parado", "ataque", "dano", "morte"]:
				verificar(monstro.sprite.sprite_frames.has_animation(anim), "Animação do monstro: " + anim)
				var textura: AtlasTexture = monstro.sprite.sprite_frames.get_frame_texture(anim, 0)
				verificar(textura.region == Rect2(0, 128, 64, 64), "Direção lateral esquerda correta")
				verificar(textura.atlas.resource_path.contains("%s%d_" % [monstro.tipo, monstro.variante]), "Variação correta")
			var primeiro: int = monstro.sprite.frame
			await create_timer(0.14).timeout
			verificar(monstro.sprite.frame != primeiro, "Idle do monstro anima")
			jogo.iniciar_encontro()
			var correta: int = jogo.batalha.pergunta.correta
			jogo.responder((correta + 1) % 4)
			verificar(monstro.sprite.animation == "ataque", "Erro faz o monstro atacar")
			await create_timer(0.23).timeout
			verificar(monstro.estado == "parado" and monstro.visible, "Monstro retorna ao idle após atacar")
			jogo.responder(correta)
			verificar(monstro.sprite.animation == "dano", "Acerto começa pela reação de dano")
			await create_timer(0.08).timeout
			verificar(monstro.sprite.animation == "morte", "Dano seguido de morte")
			await create_timer(0.16).timeout
			verificar(not monstro.visible and jogo.mortos == i + 1, "Derrotado desaparece após a animação")
			jogo.continuar()
			# Isolar a vida da fase para exercitar três ataques de erro sem derrota.
			jogo.vidas = 3
		jogo.carregar_fase(fase)
		await process_frame
		verificar(jogo.mundo.monstros.size() == 3, "Reinício não acumula monstros")
		for monstro in jogo.mundo.monstros:
			verificar(monstro.visible and monstro.estado == "parado", "Reinício restaura monstros vivos")
	verificar(encontrados.size() == 6, "Seis variações dos dois packs usadas")
	print("MONSTER_TEST_RESULT: %d falhas" % falhas)
	quit(0 if falhas == 0 else 1)
