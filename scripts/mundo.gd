extends Node2D

const Monstro = preload("res://scripts/monstro.gd")
const PALETAS = [Color("#74d9bd"), Color("#e8b76d"), Color("#bd9cff")]
const NOMES = [["Slime de jade", "Slime rubi", "Broto faminto"], ["Slime abissal", "Mandíbula dourada", "Trepadeira sentinela"], ["Slime ancestral", "Flor sombria", "REI DO BINÔMIO"]]
const ELENCOS = [[["Slime", 1], ["Slime", 2], ["Plant", 1]], [["Slime", 3], ["Plant", 2], ["Plant", 1]], [["Slime", 2], ["Plant", 3], ["Plant", 3]]]
const ENTRADA = Vector2(130, 490)
const SAIDA = Vector2(1228, 392)
var monstros: Array[Node2D] = []
var portoes: Array[StaticBody2D] = []
var paredes: Array[Rect2] = []
var decoracoes: Array[Node2D] = []
var fase = 0
var derrotados = 0
var tempo = 0.0
var pontos = [Vector2(300, 300), Vector2(665, 480), Vector2(1085, 295)]
var efeito = ""
var progresso = 0.0
var alvo = Vector2.ZERO
var origem = Vector2.ZERO
var arma = "espada"
var porta: Sprite2D
var atores: Node2D
var heroi: Node2D

func _ready() -> void:
	atores = Node2D.new()
	atores.y_sort_enabled = true
	add_child(atores)
	porta = Sprite2D.new()
	porta.texture = load("res://assets/porta.png")
	porta.region_enabled = true
	porta.region_rect = Rect2(9, 13, 7, 9)
	porta.region_filter_clip_enabled = true
	porta.scale = Vector2(4, 4)
	porta.position = Vector2(1244, 392)
	porta.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(porta)

func corpo(retangulo: Rect2, pai: Node = null) -> StaticBody2D:
	if pai == null:
		pai = self
	var body = StaticBody2D.new()
	body.position = retangulo.get_center()
	var c = CollisionShape2D.new()
	var forma = RectangleShape2D.new()
	forma.size = retangulo.size
	c.shape = forma
	body.add_child(c)
	pai.add_child(body)
	return body

func configurar(indice: int) -> void:
	fase = indice
	derrotados = 0
	efeito = ""
	for no in monstros + decoracoes:
		atores.remove_child(no)
		no.queue_free()
	monstros.clear()
	decoracoes.clear()
	for filho in get_children():
		if filho is StaticBody2D:
			remove_child(filho)
			filho.queue_free()
	portoes.clear()
	paredes = [Rect2(24, 134, 1232, 24), Rect2(24, 630, 1232, 24), Rect2(24, 134, 24, 520), Rect2(1232, 134, 24, 210), Rect2(1232, 440, 24, 214)]
	for x in [424, 832]:
		paredes.append(Rect2(x, 142, 24, 202))
		paredes.append(Rect2(x, 440, 24, 202))
	for r in paredes:
		corpo(r)
	for x in [436, 844, 1244]:
		portoes.append(corpo(Rect2(x - 12, 344, 24, 96)))
	for p in [Vector2(220, 422), Vector2(575, 300), Vector2(990, 520)]:
		criar_pilar(p)
	for i in range(3):
		var monstro = Node2D.new()
		monstro.set_script(Monstro)
		monstro.position = pontos[i]
		atores.add_child(monstro)
		monstro.configurar(ELENCOS[fase][i][0], ELENCOS[fase][i][1], fase == 2 and i == 2)
		monstros.append(monstro)
	atualizar_portoes(0)
	queue_redraw()

func criar_pilar(p: Vector2) -> void:
	var pilar = Node2D.new()
	pilar.position = p
	atores.add_child(pilar)
	corpo(Rect2(-24, -40, 48, 40), pilar)
	pilar.draw.connect(func():
		pilar.draw_rect(Rect2(-30, -44, 60, 48), Color("#101a26"))
		pilar.draw_rect(Rect2(-24, -56, 48, 52), Color("#465467"))
		pilar.draw_rect(Rect2(-29, -65, 58, 17), Color("#657589"))
		pilar.draw_line(Vector2(-17, -43), Vector2(-17, -10), Color("#8995a2"), 3)
		pilar.draw_line(Vector2(15, -43), Vector2(15, -10), Color("#29384b"), 4)
	)
	decoracoes.append(pilar)

func atualizar_portoes(total: int) -> void:
	derrotados = total
	for i in range(portoes.size()):
		portoes[i].collision_layer = 0 if i < total else 1
	queue_redraw()

func _process(delta: float) -> void:
	tempo += delta
	for i in range(monstros.size()):
		if i < derrotados:
			monstros[i].hide()
		elif is_instance_valid(heroi):
			monstros[i].orientar(heroi.position)
	porta.modulate = Color("#a7ffe2") if derrotados == 3 else Color("#8c9aaa")
	queue_redraw()

func animar_resposta(indice: int, acertou: bool, duracao: float) -> void:
	monstros[indice].reagir(acertou, duracao)

func texto(pos: Vector2, valor: String, tamanho: int, cor: Color) -> void:
	draw_string(ThemeDB.fallback_font, pos, valor, HORIZONTAL_ALIGNMENT_LEFT, -1, tamanho, cor)

func _draw() -> void:
	var acento: Color = PALETAS[fase]
	draw_rect(Rect2(0, 0, 1280, 720), Color("#0d1522"))
	draw_rect(Rect2(48, 158, 1184, 472), Color("#222f3b"))
	for x in range(48, 1232, 40):
		for y in range(158, 630, 40):
			var cor = Color("#263541") if (x / 40 + y / 40) % 2 == 0 else Color("#23313e")
			draw_rect(Rect2(x + 1, y + 1, 38, 38), cor)
	for i in range(3):
		var x = 70 + i * 408
		texto(Vector2(x, 193), ["PÁTIO DAS RUNAS", "GALERIA DOS GUARDIÕES", "CÂMARA DO SELO"][i], 16, acento if i <= derrotados else Color("#78889a"))
		texto(Vector2(x, 216), "ÁREA %d / %s" % [i + 1, "LIBERADA" if i <= derrotados else "SELADA"], 12, Color("#9aaebf"))
		draw_arc(pontos[i], 42 if i < 2 else 55, 0, TAU, 40, Color(acento, 0.2), 2)
		if i < derrotados:
			texto(pontos[i] + Vector2(-24, 6), "LIVRE", 13, acento)
	for r in paredes:
		draw_rect(r.grow(3), Color("#111d2a"))
		draw_rect(r, Color("#455466"))
		draw_line(r.position, Vector2(r.end.x, r.position.y), Color("#6d7e90"), 3)
	for i in range(portoes.size()):
		var x = portoes[i].position.x
		if i < derrotados:
			draw_rect(Rect2(x - 12, 344, 24, 96), Color(acento, 0.15))
			draw_line(Vector2(x - 12, 345), Vector2(x + 12, 345), acento, 4)
			draw_line(Vector2(x - 12, 439), Vector2(x + 12, 439), acento, 4)
		else:
			draw_rect(Rect2(x - 12, 344, 24, 96), Color("#17212e"))
			for y in range(352, 438, 16):
				draw_line(Vector2(x - 12, y), Vector2(x + 12, y), Color("#b99b69"), 5)
			draw_line(Vector2(x, 346), Vector2(x, 439), Color("#b99b69"), 4)
			texto(Vector2(x - 38, 470), "ABERTO" if i < derrotados else "SELADO", 12, acento if i < derrotados else Color("#af986e"))
	for p in [Vector2(110, 145), Vector2(490, 145), Vector2(900, 145)]:
		draw_circle(p + Vector2(0, 12), 14 + sin(tempo * 5) * 2, Color(acento, 0.08))
		draw_rect(Rect2(p - Vector2(5, 2), Vector2(10, 18)), Color("#c7a875"))
		draw_circle(p + Vector2(0, -3), 5, acento)
	texto(Vector2(1110, 564), "SAÍDA →" if derrotados == 3 else "DERROTE O GUARDIÃO", 13, acento)
	if efeito != "":
		var centro = alvo + Vector2(0, -25)
		if efeito == "acerto":
			if arma == "arco":
				var flecha = origem.lerp(centro, minf(progresso * 2, 1))
				var direcao = (centro - origem).normalized()
				var lateral = direcao.orthogonal() * 5
				draw_line(flecha - direcao * 40, flecha, Color("#ffe3a4"), 3)
				draw_colored_polygon(PackedVector2Array([flecha, flecha - direcao * 10 + lateral, flecha - direcao * 10 - lateral]), Color.WHITE)
			else:
				draw_arc(centro, 47, -1.8 + progresso, 1.5 + progresso, 24, Color("#ffe3a4"), 6)
			for i in range(8):
				var direcao = Vector2.from_angle(i * TAU / 8)
				draw_line(centro + direcao * progresso * 25, centro + direcao * progresso * 65, Color("#ffe3a4"), 3)
			texto(centro + Vector2(-70, -45 - progresso * 20), "GOLPE CRÍTICO!", 20, Color("#ffe3a4"))
		else:
			draw_line(centro, origem, Color("#ef7884"), 4)
			draw_circle(origem, 25 + progresso * 15, Color(0.95, 0.3, 0.4, 0.3 * (1 - progresso)))
