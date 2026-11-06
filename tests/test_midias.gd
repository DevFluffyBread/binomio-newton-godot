extends SceneTree
var falhas = 0
var jogo
func _initialize(): call_deferred("executar")
func verificar(valor: bool, mensagem: String):
	if not valor:
		falhas += 1
		push_error(mensagem)
func executar():
	jogo = load("res://scenes/rpg.tscn").instantiate()
	root.add_child(jogo)
	jogo.introducao.tempo_legenda = 0.3
	jogo.iniciar("espada")
	verificar(jogo.ui.imagem_historia.texture.get_size() == Vector2(320, 180), "Primeira imagem nativa")
	verificar(jogo.ui.imagem_historia.scale == Vector2(4, 4), "Ampliação inteira 4x")
	await create_timer(0.34).timeout
	verificar(jogo.ui.imagem_historia.texture.resource_path.ends_with("02_despertar.png"), "Segunda imagem na legenda correta")
	await create_timer(0.3).timeout
	verificar(jogo.ui.portas_historia.visible and jogo.ui.portas_historia.is_playing(), "Portas animadas na terceira legenda")
	var frames: SpriteFrames = jogo.ui.portas_historia.sprite_frames
	verificar(frames.get_frame_count("abrir") == 48 and frames.get_animation_speed("abrir") == 12 and not frames.get_animation_loop("abrir"), "48 quadros, 12 fps, sem loop")
	var ultimo: AtlasTexture = frames.get_frame_texture("abrir", 47)
	verificar(ultimo.region == Rect2(2240, 900, 320, 180), "Último recorte das portas correto")
	jogo.ui.pular_historia.emit()
	verificar(jogo.estado == jogo.Estado.PRESSAGIO, "Pular portas leva ao presságio")
	jogo.menu_inicial()
	jogo.chefe_batalha.escala_tempo = 0.2
	jogo.carregar_fase(2)
	verificar(jogo.sons.faixa_atual == &"ruinas", "Trilha comum durante começo do fade")
	await create_timer(0.15).timeout
	verificar(jogo.ui.cortina.modulate.a == 1.0 and jogo.sons.faixa_atual == &"chefe", "Trilha do chefe começa após tela preta")
	verificar(jogo.sons.musica.stream.loop and jogo.sons.musica.playing, "Trilha do chefe em loop")
	verificar(is_equal_approx(jogo.sons.musica.stream.get_length(), jogo.sons.MUSICA_CHEFE.get_length()), "Arquivo de música correto")
	verificar(is_equal_approx(jogo.sons.musica.volume_db, -18.0 + 7.7), "Compensação do chefe aplicada")
	var trilha = jogo.sons.musica.stream
	jogo.carregar_fase(2, false)
	verificar(jogo.sons.musica.stream == trilha, "Reinício do chefe não reinicia a trilha")
	jogo.sons.volumes(0, 0.5)
	jogo.menu_inicial()
	verificar(jogo.sons.faixa_atual == &"ruinas" and jogo.sons.musica.stream_paused, "Menu restaura trilha comum e respeita silêncio")
	jogo.carregar_fase(2, false)
	verificar(jogo.sons.musica.stream_paused, "Troca de trilha preserva volume zero")
	jogo.sons.volumes(0.5, 0.5)
	verificar(not jogo.sons.musica.stream_paused, "Opções liberam música do chefe")
	verificar(is_equal_approx(jogo.sons.musica.volume_db, jogo.sons.volume_base_musica + 7.7), "Slider preserva ganho individual")
	jogo.sons.suspense(true)
	jogo.sons.volumes(0.5, 0.5)
	verificar(is_equal_approx(jogo.sons.musica.volume_db, jogo.sons.volume_base_musica + 7.7 - 10.0), "Suspense e ganho preservados nas opções")
	jogo.menu_inicial()
	jogo.carregar_fase(2)
	jogo.menu_inicial()
	await create_timer(0.2).timeout
	verificar(jogo.sons.faixa_atual == &"ruinas", "Cancelar fade não inicia música atrasada")
	print("MEDIA_TEST_RESULT: %d falhas" % falhas)
	quit(0 if falhas == 0 else 1)
