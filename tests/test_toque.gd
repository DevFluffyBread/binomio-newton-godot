extends SceneTree
const Dispositivo = preload("res://scripts/dispositivo.gd")
var jogo
var falhas = 0
func _initialize():
	Dispositivo.forcar = true
	call_deferred("executar")
func verificar(valor: bool, mensagem: String):
	if not valor:
		falhas += 1
		push_error(mensagem)
func toque(indice: int, posicao: Vector2, pressionado: bool):
	var evento = InputEventScreenTouch.new()
	evento.index = indice
	evento.position = posicao
	evento.pressed = pressionado
	jogo.controles_toque._input(evento)
func layout():
	await process_frame
	await process_frame
	var r: Rect2 = jogo.ui.painel.get_global_rect()
	verificar(r.end.x <= 1280 and r.end.y <= 710, "Painel móvel cabe na tela")
func executar():
	jogo = load("res://scenes/rpg.tscn").instantiate()
	root.add_child(jogo)
	jogo.cenas_ativas = false
	jogo.iniciar("espada")
	jogo.mundo.set_physics_process(false)
	jogo.player.set_physics_process(false)
	jogo.player.position = jogo.mundo.monstros[0].position + Vector2(0, 60)
	await physics_frame
	jogo.controles_toque._process(0)
	verificar(jogo.controles_toque.habilitado, "Controles exibidos apenas durante exploração")
	toque(0, jogo.controles_toque.JOYSTICK + Vector2(95, 0), true)
	verificar(jogo.player.entrada_toque.x == 1, "Joystick move na direção do dedo")
	toque(1, jogo.controles_toque.ATAQUE, true)
	verificar(jogo.carga_critico == 1 and jogo.controles_toque.dedo_movimento == 0, "Ataque e movimento simultâneos com dois dedos")
	toque(1, jogo.controles_toque.ATAQUE, false)
	verificar(jogo.player.entrada_toque.x == 1, "Soltar ataque preserva joystick")
	toque(0, jogo.controles_toque.JOYSTICK, false)
	verificar(jogo.player.entrada_toque == Vector2.ZERO, "Soltar joystick interrompe movimento")
	jogo.recarga_ataque = 0
	var mouse = InputEventMouseButton.new()
	mouse.button_index = MOUSE_BUTTON_LEFT
	mouse.pressed = true
	mouse.device = -1
	jogo.player._unhandled_input(mouse)
	verificar(jogo.carga_critico == 1, "Mouse emulado pelo toque não duplica ataque")
	jogo.carga_critico = 3
	jogo.controles_toque._process(0)
	toque(2, jogo.controles_toque.CRITICO, true)
	verificar(jogo.estado == jogo.Estado.PERGUNTA and not jogo.controles_toque.habilitado, "Círculo crítico abre pergunta e limpa controles")
	verificar(jogo.player.entrada_toque == Vector2.ZERO, "Sem movimento residual durante perguntas")
	for p in jogo.perguntas:
		jogo.ui.pergunta(p, "GUARDIÃO", [], "DICA: " + p.dica)
		await layout()
		verificar(jogo.ui.opcoes[0].custom_minimum_size.y >= 80, "Alternativas grandes para toque")
	jogo.chefe_batalha.escala_tempo = 0.2
	jogo.carregar_fase(2, false)
	var inicio = Time.get_ticks_msec()
	while jogo.estado != jogo.Estado.PERGUNTA and Time.get_ticks_msec() - inicio < 5000: await process_frame
	verificar(jogo.estado == jogo.Estado.PERGUNTA, "Batalha do chefe funciona com interface móvel")
	await layout()
	verificar(jogo.ui.painel.position.x >= 550, "Pergunta do chefe preserva jogador à esquerda")
	for i in range(3):
		jogo.ui.pergunta_chefe(jogo.perguntas[6 + i], i, [], "DICA: " + jogo.perguntas[6 + i].dica)
		await layout()
	jogo.ui.menu()
	await layout()
	jogo.ui.menu_armas(1)
	await layout()
	jogo.ui.derrota(0)
	await layout()
	jogo.ui.vitoria(jogo.perguntas[8].explicacao)
	await layout()
	jogo.menu_inicial()
	verificar(not jogo.controles_toque.habilitado, "Menu oculta controles")
	print("TOUCH_TEST_RESULT: %d falhas" % falhas)
	quit(0 if falhas == 0 else 1)
