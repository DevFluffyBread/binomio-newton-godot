extends Node2D

const ARQUIVOS = {"parado": "Idle", "ataque": "Attack", "dano": "Hurt", "morte": "Death"}
static var cache: Dictionary = {}
var sprite: AnimatedSprite2D
var tipo = "Slime"
var variante = 1
var chefe = false
var estado = "parado"
var revisao = 0

static func quadros(familia: String, id: int) -> SpriteFrames:
	var chave = "%s%d" % [familia, id]
	if cache.has(chave):
		return cache[chave]
	var frames = SpriteFrames.new()
	frames.remove_animation("default")
	for animacao in ARQUIVOS:
		var textura: Texture2D = load("res://assets/monstros/%s%d_%s_with_shadow.png" % [familia, id, ARQUIVOS[animacao]])
		frames.add_animation(animacao)
		frames.set_animation_loop(animacao, animacao == "parado")
		frames.set_animation_speed(animacao, 8)
		for indice in range(textura.get_width() / 64):
			var recorte = AtlasTexture.new()
			recorte.atlas = textura
			# Quatro linhas: frente, costas, esquerda e direita.
			recorte.region = Rect2(indice * 64, 128, 64, 64)
			recorte.filter_clip = true
			frames.add_frame(animacao, recorte)
	cache[chave] = frames
	return frames

func configurar(familia: String, id: int, e_chefe: bool = false) -> void:
	tipo = familia
	variante = id
	chefe = e_chefe
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = quadros(tipo, variante)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var escala = 3.0 if chefe else 2.0
	sprite.scale = Vector2.ONE * escala
	var base = 40 if tipo == "Slime" else 47
	sprite.position.y = (32 - base) * escala
	add_child(sprite)
	sprite.animation_finished.connect(_terminou)
	sprite.play("parado")
	queue_redraw()

func tocar(animacao: String, duracao: float) -> void:
	estado = animacao
	var total = sprite.sprite_frames.get_frame_count(animacao)
	sprite.speed_scale = float(total) / (8 * maxf(duracao, 0.005))
	sprite.stop()
	sprite.play(animacao)

func reagir(acertou: bool, duracao: float) -> void:
	revisao += 1
	var rodada = revisao
	if not acertou:
		tocar("ataque", duracao)
		return
	tocar("dano", duracao * 0.25)
	await get_tree().create_timer(duracao * 0.25).timeout
	if not is_inside_tree() or revisao != rodada:
		return
	tocar("morte", duracao * 0.75)

func _terminou() -> void:
	if estado == "morte":
		hide()
	elif estado == "ataque":
		estado = "parado"
		sprite.speed_scale = 1
		sprite.play("parado")

func _draw() -> void:
	if chefe:
		var p = Vector2(0, -108)
		draw_colored_polygon(PackedVector2Array([p + Vector2(-19, 12), p + Vector2(-22, -5), p + Vector2(-8, 4), p + Vector2(0, -12), p + Vector2(8, 4), p + Vector2(22, -5), p + Vector2(19, 12)]), Color("#efbc66"))
