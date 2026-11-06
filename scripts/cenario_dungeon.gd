extends RefCounted

const TOCHA = preload("res://assets/dungeon_tale/Sprites/Torch.png")
const ATLAS = preload("res://assets/dungeon_tale/Atlas.png")

static func bloco(no: CanvasItem, destino: Rect2, origem: Rect2) -> void:
	no.draw_texture_rect_region(ATLAS, destino, origem)

static func preencher(no: CanvasItem, area: Rect2, origem: Rect2, passo: Vector2) -> void:
	var y = area.position.y
	while y < area.end.y:
		var x = area.position.x
		while x < area.end.x:
			var tamanho = Vector2(minf(passo.x, area.end.x - x), minf(passo.y, area.end.y - y))
			bloco(no, Rect2(Vector2(x, y), tamanho), Rect2(origem.position, origem.size * tamanho / passo))
			x += passo.x
		y += passo.y

static func chao(no: CanvasItem) -> void:
	# Lajotas intactas do atlas, com juntas escuras entre as pedras.
	no.draw_rect(Rect2(0, 0, 1280, 720), Color("#211c25"))
	no.draw_rect(Rect2(48, 158, 1184, 472), Color("#302833"))
	preencher(no, Rect2(48, 158, 1184, 472), Rect2(144, 256, 16, 16), Vector2(32, 32))
	# Sombra ambiente mantém os avisos de ataque legíveis sobre o piso.
	no.draw_rect(Rect2(48, 158, 1184, 472), Color(0.05, 0.04, 0.08, 0.50))
	# Tapetes marcam os encontros sem acrescentar obstáculos físicos.
	for ponto in [Vector2(300, 300), Vector2(665, 480), Vector2(1085, 295)]:
		bloco(no, Rect2(ponto - Vector2(48, 48), Vector2(96, 96)), Rect2(448, 224, 48, 48))

static func parede(no: CanvasItem, area: Rect2) -> void:
	no.draw_rect(area.grow(3), Color("#211925"))
	if area.size.x > area.size.y:
		preencher(no, area, Rect2(48, 448, 16, 16), Vector2(32, 24))
	else:
		preencher(no, area, Rect2(112, 368, 16, 16), Vector2(24, 32))

static func portao(no: CanvasItem, x: float, aberto: bool) -> void:
	if aberto:
		# Abertura livre, com soleira de pedra nos extremos.
		bloco(no, Rect2(x - 12, 334, 24, 10), Rect2(112, 352, 16, 5))
		bloco(no, Rect2(x - 12, 440, 24, 10), Rect2(112, 352, 16, 5))
	else:
		preencher(no, Rect2(x - 12, 344, 24, 96), Rect2(160, 128, 16, 16), Vector2(24, 32))

static func pilar(no: CanvasItem) -> void:
	bloco(no, Rect2(-24, -64, 48, 64), Rect2(144, 344, 16, 24))

static func tocha(no: CanvasItem, ponto: Vector2, tempo: float) -> void:
	var quadro = int(tempo * 7) % 7
	no.draw_texture_rect_region(TOCHA, Rect2(ponto - Vector2(16, 22), Vector2(32, 32)), Rect2(quadro * 16, 32, 16, 16))

static func detalhes(no: CanvasItem, tempo: float, arena: bool = false) -> void:
	if arena:
		for p in [Vector2(110, 166), Vector2(1165, 166), Vector2(110, 612), Vector2(1165, 612)]:
			tocha(no, p, tempo)
		for p in [Vector2(100, 260), Vector2(1130, 260), Vector2(100, 530), Vector2(1130, 530)]:
			bloco(no, Rect2(p, Vector2(40, 40)), Rect2(176, 256, 16, 16))
		return
	for sala in range(3):
		var x = 48 + sala * 408
		for p in [Vector2(x + 52, 164), Vector2(x + 310, 164)]:
			tocha(no, p, tempo)
		for p in [Vector2(x + 8, 540), Vector2(x + 320, 550)]:
			bloco(no, Rect2(p, Vector2(40, 40)), Rect2(224, 352, 16, 16))
		for p in [Vector2(x + 12, 260), Vector2(x + 320, 475)]:
			bloco(no, Rect2(p, Vector2(32, 32)), Rect2(256, 384, 16, 16))
		bloco(no, Rect2(x + 110, 580, 32, 32), Rect2(144, 256, 16, 16))
		bloco(no, Rect2(x + 320, 310, 32, 32), Rect2(176, 256, 16, 16))

static func chao_arena(no: CanvasItem) -> void:
	no.draw_rect(Rect2(0, 0, 1280, 720), Color("#211c25"))
	preencher(no, Rect2(48, 158, 1184, 472), Rect2(144, 256, 16, 16), Vector2(32, 32))
	no.draw_rect(Rect2(48, 158, 1184, 472), Color(0.05, 0.04, 0.08, 0.5))
	bloco(no, Rect2(712, 330, 216, 216), Rect2(448, 224, 48, 48))
