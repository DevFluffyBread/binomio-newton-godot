extends CanvasLayer

const Dispositivo = preload("res://scripts/dispositivo.gd")
const ICONE_CRITICO = preload("res://addons/pixel_ui/icons/star.png")
const ICONE_ESPADA = preload("res://addons/pixel_ui/icons/sword.png")
const ICONE_ARCO = preload("res://addons/pixel_ui/icons/arrow_right.png")
const Pele = preload("res://scripts/pele_pixel.gd")
const JOYSTICK = Vector2(150, 560)
const CRITICO = Vector2(340, 560)
const ATAQUE = Vector2(1130, 560)
const RAIO = 95.0
var jogo
var tela: Control
var orientacao: Control
var habilitado = false
var dedo_movimento = -1
var dedo_ataque = -1
var vetor = Vector2.ZERO
var pronto = false
var alcance = false
var pausa_orientacao = false

func _ready() -> void:
	layer = 4
	process_mode = Node.PROCESS_MODE_ALWAYS
	tela = Control.new()
	tela.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tela.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tela.draw.connect(_desenhar)
	tela.hide()
	add_child(tela)
	orientacao = Control.new()
	orientacao.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var fundo = ColorRect.new()
	fundo.size = Vector2(1280, 720)
	fundo.color = Color("#17121f")
	orientacao.add_child(fundo)
	var texto = Label.new()
	texto.text = "Vire o celular para jogar\nna horizontal"
	texto.theme = Pele.tema()
	texto.add_theme_font_size_override("font_size", 40)
	texto.position = Vector2(100, 240)
	texto.size = Vector2(1080, 240)
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	orientacao.add_child(texto)
	orientacao.hide()
	add_child(orientacao)
	get_window().focus_exited.connect(limpar)

func definir_ativo(valor: bool) -> void:
	var novo = valor and Dispositivo.ativo() and not pausa_orientacao
	if novo != habilitado:
		habilitado = novo
		tela.visible = novo
		if not novo: limpar()

func limpar() -> void:
	dedo_movimento = -1
	dedo_ataque = -1
	vetor = Vector2.ZERO
	if is_instance_valid(jogo.player): jogo.player.entrada_toque = Vector2.ZERO
	if is_instance_valid(tela): tela.queue_redraw()

func _process(_delta: float) -> void:
	var tamanho = DisplayServer.window_get_size()
	var retrato = Dispositivo.ativo() and tamanho.y > tamanho.x
	if retrato != pausa_orientacao:
		pausa_orientacao = retrato
		get_tree().paused = retrato
		orientacao.visible = retrato
		limpar()
	definir_ativo(jogo.estado == jogo.Estado.EXPLORACAO)
	if not habilitado: return
	jogo.player.entrada_toque = vetor
	pronto = jogo.carga_critico >= jogo.GOLPES_PARA_CRITICO
	alcance = jogo.alvo_ao_alcance()
	if dedo_ataque >= 0: jogo.atacar()
	tela.queue_redraw()

func _input(event: InputEvent) -> void:
	if not habilitado: return
	if event is InputEventScreenTouch:
		if not event.pressed:
			if event.index == dedo_movimento:
				dedo_movimento = -1
				vetor = Vector2.ZERO
				jogo.player.entrada_toque = vetor
				get_viewport().set_input_as_handled()
			if event.index == dedo_ataque:
				dedo_ataque = -1
				get_viewport().set_input_as_handled()
			return
		if event.position.distance_to(JOYSTICK) <= 120 and dedo_movimento < 0:
			dedo_movimento = event.index
			atualizar_vetor(event.position)
		elif event.position.distance_to(CRITICO) <= 56:
			if pronto and alcance: jogo.tentar_critico()
		elif event.position.distance_to(ATAQUE) <= 78 and dedo_ataque < 0:
			dedo_ataque = event.index
			jogo.atacar()
		else: return
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and event.index == dedo_movimento:
		atualizar_vetor(event.position)
		get_viewport().set_input_as_handled()

func atualizar_vetor(ponto: Vector2) -> void:
	vetor = ((ponto - JOYSTICK) / RAIO).limit_length(1.0)
	if vetor.length() < 0.12: vetor = Vector2.ZERO
	jogo.player.entrada_toque = vetor
	tela.queue_redraw()

func legenda(centro: Vector2, texto: String, tamanho: int = 24) -> void:
	var fonte = Pele.tema().default_font
	var largura = fonte.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamanho).x
	tela.draw_string(fonte, centro - Vector2(largura / 2, 0), texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tamanho, Color("#ffe0ab"))

func _desenhar() -> void:
	if not habilitado: return
	tela.draw_circle(JOYSTICK, RAIO, Color(0.10, 0.07, 0.06, 0.72))
	tela.draw_arc(JOYSTICK, RAIO, 0, TAU, 48, Color("#c99259"), 4)
	tela.draw_circle(JOYSTICK + vetor * 54, 37, Color("#c18d59"))
	tela.draw_arc(JOYSTICK + vetor * 54, 37, 0, TAU, 32, Color("#ffe0ab"), 3)
	legenda(Vector2(150, 698), "MOVER")
	var cor_critico = Color("#f4cb61") if pronto else Color("#765c47")
	tela.draw_circle(CRITICO, 38, Color(0.12, 0.08, 0.06, 0.86))
	tela.draw_arc(CRITICO, 38, 0, TAU, 32, cor_critico, 4)
	tela.draw_texture_rect(ICONE_CRITICO, Rect2(CRITICO - Vector2(18, 18), Vector2(36, 36)), false, cor_critico)
	legenda(CRITICO + Vector2(0, 82), "CRÍTICO")
	tela.draw_circle(ATAQUE, 62, Color("#8b5535"))
	tela.draw_arc(ATAQUE, 62, 0, TAU, 40, Color("#f3ce91"), 4)
	tela.draw_texture_rect(ICONE_ESPADA if jogo.arma == "espada" else ICONE_ARCO, Rect2(ATAQUE - Vector2(26, 26), Vector2(52, 52)), false)
	legenda(ATAQUE + Vector2(0, 105), "ATACAR")
