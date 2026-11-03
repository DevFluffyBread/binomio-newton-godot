extends Node2D

const LARGURA_CELULA = 76
const ALTURA_CELULA = 44
const ESPACO = 8

var valor_a = 0
var valor_b = 0
var quantidade_linhas = 0
var piramide = []
var posicao_piramide = Vector2.ZERO
var piramide_gerada = false
var aguardando_posicao = false
var blocos = []

func gerar(a: int, b: int) -> bool:
	# Limite provisório para evitar estouro de int64 nos termos calculados.
	if a < 0 or b < 0 or a + b < 1 or a + b > 12:
		return false
	valor_a = a
	valor_b = b
	quantidade_linhas = a + b
	piramide.clear()
	limpar_blocos()
	for n in range(quantidade_linhas):
		var linha = []
		for k in range(n + 1):
			linha.append(combinacao(n, k) * potencia(a, n - k) * potencia(b, k))
		piramide.append(linha)
	piramide_gerada = true
	aguardando_posicao = true
	queue_redraw()
	return true

func potencia(base: int, expoente: int) -> int:
	var resultado = 1
	for i in range(expoente):
		resultado *= base
	return resultado

func combinacao(n: int, k: int) -> int:
	var resultado = 1
	for i in range(1, k + 1):
		@warning_ignore("integer_division")
		resultado = resultado * (n - i + 1) / i
	return resultado

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and aguardando_posicao:
			posicionar_piramide(get_local_mouse_position())

func posicionar_piramide(posicao: Vector2) -> void:
	posicao_piramide = posicao
	aguardando_posicao = false
	criar_colisoes()
	queue_redraw()

func limpar_blocos() -> void:
	for bloco in blocos:
		remove_child(bloco)
		bloco.queue_free()
	blocos.clear()

func criar_colisoes() -> void:
	limpar_blocos()
	for n in range(piramide.size()):
		var linha = piramide[n]
		var largura = linha.size() * (LARGURA_CELULA + ESPACO) - ESPACO
		var inicio_x = posicao_piramide.x - largura / 2.0
		var y = posicao_piramide.y + n * (ALTURA_CELULA + ESPACO)
		for k in range(linha.size()):
			var bloco = StaticBody2D.new()
			bloco.position = Vector2(inicio_x + k * (LARGURA_CELULA + ESPACO) + LARGURA_CELULA / 2.0, y + ALTURA_CELULA / 2.0)
			var colisao = CollisionShape2D.new()
			var forma = RectangleShape2D.new()
			forma.size = Vector2(LARGURA_CELULA, ALTURA_CELULA)
			colisao.shape = forma
			bloco.add_child(colisao)
			add_child(bloco)
			blocos.append(bloco)

func _draw() -> void:
	if not piramide_gerada or aguardando_posicao:
		return
	var fonte = ThemeDB.fallback_font
	for n in range(piramide.size()):
		var linha = piramide[n]
		var largura = linha.size() * (LARGURA_CELULA + ESPACO) - ESPACO
		var inicio_x = posicao_piramide.x - largura / 2.0
		var y = posicao_piramide.y + n * (ALTURA_CELULA + ESPACO)
		for k in range(linha.size()):
			var x = inicio_x + k * (LARGURA_CELULA + ESPACO)
			var retangulo = Rect2(Vector2(x, y), Vector2(LARGURA_CELULA, ALTURA_CELULA))
			draw_rect(retangulo, Color("#663c27"), true)
			draw_rect(retangulo, Color("#d49a55"), false, 2)
			var texto = str(linha[k])
			var tamanho = fonte.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 18)
			draw_string(fonte, Vector2(x + (LARGURA_CELULA - tamanho.x) / 2.0, y + 28), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
