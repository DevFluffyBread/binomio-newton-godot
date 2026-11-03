extends Node2D

const Monstro = preload("res://scripts/monstro.gd")
const PALETAS = [Color("#74d9bd"), Color("#e8b76d"), Color("#bd9cff")]
const NOMES = [["Slime de jade", "Slime rubi", "Broto faminto"], ["Slime abissal", "Mandíbula dourada", "Trepadeira sentinela"], ["Slime ancestral", "Flor sombria", "REI DO BINÔMIO"]]
const ELENCOS = [[["Slime", 1], ["Slime", 2], ["Plant", 1]], [["Slime", 3], ["Plant", 2], ["Plant", 1]], [["Slime", 2], ["Plant", 3], ["Plant", 3]]]
var monstros: Array[Node2D] = []
var fase = 0
var derrotados = 0
var tempo = 0.0
var pontos = [Vector2(350, 600), Vector2(690, 548), Vector2(1010, 600)]
var plataformas: Array[Rect2] = []
var efeito = ""
var progresso = 0.0
var alvo = Vector2.ZERO
var origem = Vector2.ZERO
var arma = "espada"
var porta: Sprite2D

func _ready() -> void:
	porta = Sprite2D.new()
	porta.texture = load("res://assets/porta.png")
	porta.region_enabled = true
	porta.region_rect = Rect2(9, 13, 7, 9)
	porta.region_filter_clip_enabled = true
	porta.scale = Vector2(6, 6)
	porta.position = Vector2(1190, 573)
	porta.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(porta)

func configurar(indice: int) -> void:
	fase = indice
	derrotados = 0
	efeito = ""
	for monstro in monstros:
		remove_child(monstro)
		monstro.queue_free()
	monstros.clear()
	for i in range(3):
		var monstro = Node2D.new()
		monstro.set_script(Monstro)
		monstro.position = pontos[i]
		add_child(monstro)
		monstro.configurar(ELENCOS[fase][i][0], ELENCOS[fase][i][1], fase == 2 and i == 2)
		monstros.append(monstro)
	for filho in get_children():
		if filho is StaticBody2D:
			remove_child(filho)
			filho.queue_free()
	plataformas = [Rect2(0, 600, 440, 120), Rect2(500, 600, 350, 120), Rect2(910, 600, 370, 120), Rect2(580, 548, 210, 20)]
	for retangulo in plataformas:
		var corpo = StaticBody2D.new()
		corpo.position = retangulo.get_center()
		var colisao = CollisionShape2D.new()
		var forma = RectangleShape2D.new()
		forma.size = retangulo.size
		colisao.shape = forma
		corpo.add_child(colisao)
		add_child(corpo)
	queue_redraw()

func _process(delta: float) -> void:
	tempo += delta
	for i in range(monstros.size()):
		if i < derrotados:
			monstros[i].hide()
	if is_instance_valid(porta):
		porta.modulate = Color("#ffe3a4") if derrotados == 3 else Color("#8c9aaa")
	queue_redraw()

func animar_resposta(indice: int, acertou: bool, duracao: float) -> void:
	monstros[indice].reagir(acertou, duracao)

func texto(pos: Vector2, valor: String, tamanho: int, cor: Color) -> void:
	draw_string(ThemeDB.fallback_font, pos, valor, HORIZONTAL_ALIGNMENT_LEFT, -1, tamanho, cor)

func _draw() -> void:
	var acento: Color = PALETAS[fase]
	draw_rect(Rect2(0, 0, 1280, 720), Color("#101725"))
	draw_circle(Vector2(1060, 178), 64, Color(acento, 0.08))
	draw_circle(Vector2(1060, 178), 44, Color(acento, 0.08))
	# Arquitetura de ruínas: camadas, colunas, arcos e inscrições.
	for i in range(8):
		var x = float(i * 190 - 45)
		draw_rect(Rect2(x, 222, 112, 378), Color("#192234"))
		draw_arc(Vector2(x + 56, 270), 55, PI, TAU, 20, Color("#2b3548"), 12)
		draw_rect(Rect2(x + 16, 280, 80, 320), Color("#111b2b"))
		for j in range(4):
			draw_line(Vector2(x, 320 + j * 70), Vector2(x + 112, 320 + j * 70), Color("#242e42"), 2)
	for i in range(24):
		var x = fmod(i * 109.0 + sin(tempo * 0.25 + i) * 15, 1280)
		var y = 220 + fmod(i * 67.0 - tempo * 9 + 720, 300)
		draw_circle(Vector2(x, y), 1.5, Color(acento, 0.4))
	for r in plataformas:
		draw_rect(r, Color("#2d3847"))
		draw_rect(Rect2(r.position, Vector2(r.size.x, 5)), acento.darkened(0.25))
		for x in range(int(r.position.x), int(r.end.x), 48):
			draw_line(Vector2(x, r.position.y + 10), Vector2(x, r.end.y), Color("#1c2837"), 2)
		if r.size.y > 30:
			draw_line(r.position + Vector2(0, 40), Vector2(r.end.x, r.position.y + 40), Color("#1c2837"), 2)
	for i in range(3):
		var p: Vector2 = pontos[i]
		if i < derrotados:
			draw_circle(p + Vector2(0, -5), 6, acento)
			texto(p + Vector2(-22, -45), "LIVRE", 12, acento)
			continue
		texto(p + Vector2(-25, -138 if fase == 2 and i == 2 else -82), "0%d" % (i + 1), 13, acento)
	if derrotados == 3:
		draw_rect(Rect2(1162, 536, 56, 64), Color(acento, 0.25))
		texto(Vector2(1130, 515), "SAÍDA ABERTA", 14, acento)
	else:
		texto(Vector2(1150, 526), "SELADA", 14, Color("#8c9aaa"))
	if efeito != "":
		var centro = alvo + Vector2(0, -25)
		if efeito == "acerto":
			if arma == "arco":
				var flecha = origem.lerp(centro, minf(progresso * 2, 1))
				draw_line(flecha - Vector2(40, 0), flecha, Color("#ffe3a4"), 3)
				draw_colored_polygon(PackedVector2Array([flecha, flecha + Vector2(-10, -5), flecha + Vector2(-10, 5)]), Color.WHITE)
			else:
				draw_arc(centro, 47, -1.8 + progresso, 1.5 + progresso, 24, Color("#ffe3a4"), 6)
			for i in range(8):
				var direcao = Vector2.from_angle(i * TAU / 8)
				draw_line(centro + direcao * progresso * 25, centro + direcao * progresso * 65, Color("#ffe3a4"), 3)
			texto(centro + Vector2(-70, -45 - progresso * 20), "GOLPE CRÍTICO!", 20, Color("#ffe3a4"))
		else:
			draw_line(centro, origem, Color("#ef7884"), 4)
			draw_circle(origem, 25 + progresso * 15, Color(0.95, 0.3, 0.4, 0.3 * (1 - progresso)))
