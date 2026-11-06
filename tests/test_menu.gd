extends SceneTree
var falhas = 0
func verificar(valor: bool, mensagem: String) -> void:
	if not valor:
		falhas += 1
		push_error(mensagem)
func buscar(no: Node, classe: String) -> Array:
	var lista = []
	if no.is_class(classe): lista.append(no)
	for filho in no.get_children(): lista.append_array(buscar(filho, classe))
	return lista
func _initialize() -> void:
	call_deferred("executar")
func executar() -> void:
	var jogo = load("res://scenes/rpg.tscn").instantiate()
	root.add_child(jogo)
	jogo.cenas_ativas = false
	await process_frame
	var ui = jogo.ui
	verificar(ui.etapa_menu == "inicio" and jogo.estado == jogo.Estado.MENU, "Abre tela inicial e bloqueia movimento")
	var botoes = buscar(ui.conteudo_inicio, "Button")
	verificar(botoes.size() == 4, "Quatro botões iniciais")
	var fundo = ui.camada.get_child(0)
	verificar(fundo.heroi.animation == "corrida" and fundo.heroi.sprite_frames.get_animation_loop("corrida"), "Herói rosa com espada animado em loop")
	var tempo = fundo.tempo
	await create_timer(0.1).timeout
	verificar(fundo.tempo > tempo, "Parallax avança continuamente")
	botoes[1].pressed.emit()
	await process_frame
	verificar(buscar(ui.conteudo_inicio, "Label")[0].text == "COMO JOGAR", "Tutorial abre")
	buscar(ui.conteudo_inicio, "Button")[0].pressed.emit()
	buscar(ui.conteudo_inicio, "Button")[2].pressed.emit()
	var sliders = buscar(ui.conteudo_inicio, "HSlider")
	sliders[0].value = 0
	verificar(ui.volume_musica == 0 and jogo.sons.musica.stream_paused, "Opção silencia música")
	sliders[1].value = 0.4
	verificar(is_equal_approx(ui.volume_efeitos, 0.4) and jogo.sons.impacto.volume_db < -7, "Opção ajusta efeitos independentemente")
	buscar(ui.conteudo_inicio, "Button").back().pressed.emit()
	buscar(ui.conteudo_inicio, "Button")[3].pressed.emit()
	verificar(buscar(ui.conteudo_inicio, "Label")[0].text == "CRÉDITOS", "Créditos abre")
	buscar(ui.conteudo_inicio, "Button")[0].pressed.emit()
	buscar(ui.conteudo_inicio, "Button")[0].pressed.emit()
	verificar(ui.etapa_menu == "personagem", "Iniciar aventura abre seleção")
	jogo.escolher_personagem(1)
	jogo.iniciar("espada")
	verificar(jogo.estado == jogo.Estado.EXPLORACAO, "Seleção inicia aventura")
	jogo.menu_inicial()
	verificar(ui.etapa_menu == "inicio" and jogo.sons.musica.stream_paused, "Retorno mantém opções")
	print("MENU_TEST_RESULT: %d falhas" % falhas)
	quit(0 if falhas == 0 else 1)
