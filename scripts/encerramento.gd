extends CanvasLayer

const QUADROS = preload("res://assets/encerramento/encerramento.tres")
const VisualHeroi = preload("res://scripts/visual_heroi.gd")
var jogo
var ativo = false
var token = 0
var escala_tempo = 1.0
var painel: Control
var filme: AnimatedSprite2D
var heroi: AnimatedSprite2D
var raiz_heroi: Node2D
var legenda: Label
var titulo: Label
var pular: Button
var cortina: ColorRect
var transicao: Tween
var explicacao = ""
var saida_iniciada = false

func _ready() -> void:
	layer = 0
	set_process(false)

func cancelar() -> void:
	token += 1
	ativo = false
	set_process(false)
	if is_instance_valid(transicao) and transicao.is_valid(): transicao.kill()
	if is_instance_valid(painel):
		painel.hide()
		painel.queue_free()
	painel = null

func iniciar() -> void:
	cancelar()
	ativo = true
	saida_iniciada = false
	explicacao = jogo.batalha.pergunta.get("explicacao", "")
	jogo.mudar_estado(jogo.Estado.ENCERRAMENTO)
	jogo.ui.limpar()
	jogo.ui.encerrar_cinema()
	jogo.ui.hud_visivel(false)
	if not jogo.cenas_ativas:
		concluir()
		return
	var rodada = token
	construir()
	jogo.sons.encerrar_batalha()
	transicao = create_tween()
	transicao.tween_property(cortina, "modulate:a", 1.0, 0.4 * escala_tempo)
	await get_tree().create_timer(0.4 * escala_tempo).timeout
	if rodada != token: return
	filme.show()
	filme.play("encerramento")
	filme.speed_scale = 1.0 / escala_tempo
	legenda.show()
	set_process(true)
	transicao = create_tween()
	transicao.tween_property(cortina, "modulate:a", 0.0, 0.4 * escala_tempo)

func construir() -> void:
	painel = Control.new()
	painel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	painel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(painel)
	filme = AnimatedSprite2D.new()
	filme.sprite_frames = QUADROS
	filme.centered = false
	filme.scale = Vector2(4, 4)
	filme.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	filme.animation_finished.connect(_terminou_filme)
	filme.hide()
	painel.add_child(filme)
	raiz_heroi = Node2D.new()
	painel.add_child(raiz_heroi)
	heroi = AnimatedSprite2D.new()
	heroi.sprite_frames = VisualHeroi.quadros(jogo.personagem, jogo.arma)
	heroi.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	heroi.position = Vector2(21, -63)
	heroi.scale = Vector2(3, 3)
	heroi.flip_h = true
	raiz_heroi.add_child(heroi)
	raiz_heroi.hide()
	var fundo = ColorRect.new()
	fundo.position = Vector2(90, 540)
	fundo.size = Vector2(1100, 100)
	fundo.color = Color(0.02, 0.01, 0.04, 0.88)
	painel.add_child(fundo)
	legenda = jogo.ui.label("", 16)
	legenda.position = Vector2(114, 550)
	legenda.size = Vector2(1052, 80)
	legenda.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	legenda.hide()
	painel.add_child(legenda)
	cortina = ColorRect.new()
	cortina.size = Vector2(1280, 720)
	cortina.color = Color.BLACK
	cortina.modulate.a = 0
	cortina.mouse_filter = Control.MOUSE_FILTER_IGNORE
	painel.add_child(cortina)
	titulo = jogo.ui.label("RUÍNAS DO BINÔMIO\nAVENTURA CONCLUÍDA", 32)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.position = Vector2(80, 220)
	titulo.size = Vector2(1120, 180)
	titulo.hide()
	painel.add_child(titulo)
	pular = jogo.ui.botao("Pular encerramento", concluir)
	pular.position = Vector2(950, 34)
	pular.size = Vector2(294, 48)
	painel.add_child(pular)

func _process(_delta: float) -> void:
	if not ativo or not filme.visible: return
	var tempo = (float(filme.frame) + filme.frame_progress) / 12.0
	legenda.text = "As runas voltam a brilhar. O equilíbrio das ruínas começa a se recompor." if tempo < 6 else "Os selos foram restaurados. O conhecimento voltou a proteger as ruínas."
	if filme.frame >= 72:
		saida_iniciada = true
		raiz_heroi.show()
		var progresso = clampf((tempo - 6.0) / 2.0, 0.0, 1.0)
		raiz_heroi.position = Vector2(640, 355).lerp(Vector2(540, 520), progresso)
		var animacao = "corrida" if filme.frame < 96 else "parado"
		if heroi.animation != animacao or not heroi.is_playing():
			heroi.play(animacao)

func _terminou_filme() -> void:
	if not ativo: return
	var rodada = token
	set_process(false)
	filme.pause()
	filme.frame = 143
	heroi.play("parado")
	titulo.show()
	transicao = create_tween()
	transicao.tween_property(cortina, "modulate:a", 0.45, 0.3 * escala_tempo)
	await get_tree().create_timer(1.2 * escala_tempo).timeout
	if rodada != token: return
	concluir()

func concluir() -> void:
	if not ativo: return
	token += 1
	ativo = false
	set_process(false)
	if is_instance_valid(transicao) and transicao.is_valid(): transicao.kill()
	if is_instance_valid(painel):
		filme.pause()
		filme.frame = 143
		filme.show()
		raiz_heroi.position = Vector2(540, 520)
		raiz_heroi.show()
		heroi.play("parado")
		pular.hide()
		titulo.hide()
		legenda.hide()
		cortina.modulate.a = 0
	jogo.mudar_estado(jogo.Estado.VITORIA)
	jogo.ui.vitoria(explicacao)
