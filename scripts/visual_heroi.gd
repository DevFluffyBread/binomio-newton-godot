extends RefCounted

const TAMANHO = 42
const NOMES = {1: "Violeta", 2: "Prata", 3: "Azul"}
static var cache: Dictionary = {}

static func quadros(personagem: int, arma: String) -> SpriteFrames:
	assert(personagem in NOMES and arma in ["espada", "arco"])
	var chave = "%s/%d" % [arma, personagem]
	if cache.has(chave):
		return cache[chave]
	var frames = SpriteFrames.new()
	frames.remove_animation("default")
	var arquivos = {"parado": "Idle", "corrida": "Run", "pulo": "Jump", "ataque": "Attack1" if arma == "espada" else "Attack", "dano": "Hurt", "morte": "Death"}
	for nome in arquivos:
		var textura: Texture2D = load("res://assets/herois/%s/%d/%s.png" % [arma, personagem, arquivos[nome]])
		frames.add_animation(nome)
		frames.set_animation_loop(nome, nome in ["parado", "corrida"])
		frames.set_animation_speed(nome, 6 if nome == "parado" else 10)
		for indice in range(textura.get_width() / TAMANHO):
			var recorte = AtlasTexture.new()
			recorte.atlas = textura
			recorte.region = Rect2(indice * TAMANHO, 0, TAMANHO, TAMANHO)
			recorte.filter_clip = true
			frames.add_frame(nome, recorte)
	cache[chave] = frames
	return frames

static func previa(personagem: int, arma: String, escala: float = 3.0) -> Control:
	var area = Control.new()
	area.custom_minimum_size = Vector2(160, 124)
	area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = quadros(personagem, arma)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2.ONE * escala
	# Centralizar o corpo, em vez de incluir a extensão da arma no centro.
	sprite.position = Vector2(80 + 7 * escala, 120 - 21 * escala)
	sprite.play("parado")
	area.add_child(sprite)
	return area
