extends Control

const BASE = "res://assets/fort_illusion/Assets/Layers/"
const CEU = preload(BASE + "back.png")
const MONTANHAS = preload(BASE + "mountains.png")
const TORRE = preload(BASE + "front.png")
const TIJOLOS = preload(BASE + "tileset.png")
const VisualHeroi = preload("res://scripts/visual_heroi.gd")
var tempo = 0.0
var heroi: AnimatedSprite2D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	heroi = AnimatedSprite2D.new()
	heroi.name = "HeroiRosa"
	heroi.sprite_frames = VisualHeroi.quadros(1, "espada")
	heroi.scale = Vector2(7, 7)
	heroi.position = Vector2(300, 464)
	heroi.play("corrida")
	add_child(heroi)

func _process(delta: float) -> void:
	tempo += delta
	queue_redraw()

func faixa(textura: Texture2D, y: float, escala: float, velocidade: float) -> void:
	var largura = textura.get_width() * escala
	var deslocamento = fposmod(tempo * velocidade, largura)
	for i in range(-1, ceili(1280 / largura) + 1):
		draw_texture_rect(textura, Rect2(i * largura - deslocamento, y, largura, textura.get_height() * escala), false)

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1280, 720), Color("#131023"))
	faixa(CEU, -180, 3, 5)
	faixa(MONTANHAS, -130, 3, 16)
	# Torres repetidas ao longe, mais rápidas que as montanhas.
	for i in range(-1, 4):
		var x = i * 640 - fposmod(tempo * 30, 640)
		draw_texture_rect(TORRE, Rect2(x, 265, 291, 336), false)
	draw_rect(Rect2(0, 0, 1280, 600), Color(0.03, 0.02, 0.08, 0.22))
	# O piso do mesmo tileset desliza mais rápido, criando profundidade.
	var offset = fposmod(tempo * 84, 96)
	for i in range(-1, 15):
		draw_texture_rect_region(TIJOLOS, Rect2(i * 96 - offset, 600, 96, 48), Rect2(48, 48, 32, 16))
		draw_texture_rect_region(TIJOLOS, Rect2(i * 96 - offset, 648, 96, 72), Rect2(48, 64, 32, 24))
