extends CharacterBody2D

signal acertou_jogador
const ARQUIVOS = {"parado": "Idle", "caminhada": "Walk", "ataque": "Attack", "dano": "Hurt", "morte": "Death"}
static var cache: Dictionary = {}
var sprite: AnimatedSprite2D
var tipo = "Slime"
var variante = 1
var chefe = false
var estado = "parado"
var revisao = 0
var direcao = "esquerda"
const LINHAS = {"frente": 0, "costas": 1, "esquerda": 2, "direita": 3}
var mundo
var area = Rect2()
var indice_area = 0
var recarga = 1.0
var aviso = -1.0
var ponto_ataque = Vector2.ZERO
var repulsao = Vector2.ZERO
var rota = PackedVector2Array()
var recalcular = 0.0
var patrulha = 0

static func quadros(familia: String, id: int, orientacao: String = "esquerda") -> SpriteFrames:
	var chave = "%s%d/%s" % [familia, id, orientacao]
	if cache.has(chave):
		return cache[chave]
	var frames = SpriteFrames.new()
	frames.remove_animation("default")
	for animacao in ARQUIVOS:
		var textura: Texture2D = load("res://assets/monstros/%s%d_%s_with_shadow.png" % [familia, id, ARQUIVOS[animacao]])
		frames.add_animation(animacao)
		frames.set_animation_loop(animacao, animacao in ["parado", "caminhada"])
		frames.set_animation_speed(animacao, 8)
		for indice in range(textura.get_width() / 64):
			var recorte = AtlasTexture.new()
			recorte.atlas = textura
			# Quatro linhas: frente, costas, esquerda e direita.
			recorte.region = Rect2(indice * 64, LINHAS[orientacao] * 64, 64, 64)
			recorte.filter_clip = true
			frames.add_frame(animacao, recorte)
	cache[chave] = frames
	return frames

func configurar(familia: String, id: int, e_chefe: bool = false) -> void:
	collision_layer = 0
	collision_mask = 1
	var colisao = CollisionShape2D.new()
	var forma = RectangleShape2D.new()
	forma.size = Vector2(22, 14)
	colisao.shape = forma
	add_child(colisao)
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

func orientar(alvo: Vector2) -> void:
	if estado not in ["parado", "caminhada"]:
		return
	var vetor = alvo - position
	var nova = ("esquerda" if vetor.x < 0 else "direita") if absf(vetor.x) >= absf(vetor.y) else ("costas" if vetor.y < 0 else "frente")
	if nova == direcao:
		return
	direcao = nova
	var quadro = sprite.frame
	var progresso_quadro = sprite.frame_progress
	sprite.sprite_frames = quadros(tipo, variante, direcao)
	sprite.play(estado)
	sprite.set_frame_and_progress(quadro, progresso_quadro)

func cancelar_aviso() -> void:
	velocity = Vector2.ZERO
	if aviso >= 0:
		aviso = -1
		estado = "parado"
		sprite.play("parado")
	recarga = maxf(recarga, 0.6)
	queue_redraw()

func golpe_comum(origem: Vector2) -> void:
	if estado == "morte":
		return
	revisao += 1
	cancelar_aviso()
	repulsao = (position - origem).normalized() * 150
	tocar("dano", 0.25)

func atualizar_ia(delta: float) -> void:
	if estado == "morte" or not visible:
		return
	recarga = maxf(0, recarga - delta)
	if repulsao.length() > 1:
		velocity = repulsao
		move_and_slide()
		repulsao = repulsao.move_toward(Vector2.ZERO, delta * 1000)
		conter_na_area()
	if estado in ["ataque", "dano"]:
		return
	if aviso >= 0:
		aviso -= delta
		if aviso <= 0:
			aviso = -1
			recarga = 1.6
			tocar("ataque", 0.35)
			if area.has_point(mundo.heroi.position) and mundo.heroi.position.distance_to(ponto_ataque) <= 36 and position.distance_to(mundo.heroi.position) < 82 and linha_livre():
				acertou_jogador.emit()
		queue_redraw()
		return
	var perseguindo = area.has_point(mundo.heroi.position)
	var destino: Vector2 = mundo.heroi.position
	if perseguindo and position.distance_to(destino) <= 54 and linha_livre():
		velocity = Vector2.ZERO
		estado = "parado"
		sprite.play("parado")
		if recarga <= 0:
			orientar(destino)
			estado = "aviso"
			aviso = 0.7
			ponto_ataque = destino
			sprite.play("parado")
			queue_redraw()
		return
	if not perseguindo:
		var destinos = [area.position + Vector2(85, 110), area.position + Vector2(280, 350)]
		destino = destinos[patrulha]
		if position.distance_to(destino) < 24:
			patrulha = 1 - patrulha
	recalcular -= delta
	if recalcular <= 0:
		rota = mundo.caminho(indice_area, position, destino)
		recalcular = 0.25
	while rota.size() > 0 and position.distance_to(rota[0]) < 10:
		rota.remove_at(0)
	if rota.size() == 0:
		velocity = Vector2.ZERO
		estado = "parado"
		sprite.play("parado")
		return
	var direcao_movimento = (rota[0] - position).normalized()
	estado = "caminhada"
	orientar(position + direcao_movimento * 100)
	sprite.speed_scale = 1
	sprite.play("caminhada")
	velocity = direcao_movimento * (85 + mundo.fase * 10)
	move_and_slide()
	conter_na_area()

func conter_na_area() -> void:
	position.x = clampf(position.x, area.position.x + 14, area.end.x - 14)
	position.y = clampf(position.y, area.position.y + 14, area.end.y - 14)

func linha_livre() -> bool:
	var consulta = PhysicsRayQueryParameters2D.create(position, mundo.heroi.position, 1)
	return get_world_2d().direct_space_state.intersect_ray(consulta).is_empty()

func tocar(animacao: String, duracao: float) -> void:
	estado = animacao
	var total = sprite.sprite_frames.get_frame_count(animacao)
	sprite.speed_scale = float(total) / (8 * maxf(duracao, 0.005))
	sprite.stop()
	sprite.play(animacao)

func reagir(acertou: bool, duracao: float) -> void:
	repulsao = Vector2.ZERO
	cancelar_aviso()
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
	elif estado in ["ataque", "dano"]:
		estado = "parado"
		sprite.speed_scale = 1
		sprite.play("parado")

func _draw() -> void:
	if aviso >= 0:
		var ponto = ponto_ataque - position
		draw_circle(ponto, 36, Color(1, 0.2, 0.25, 0.22))
		draw_arc(ponto, 36, 0, TAU, 40, Color("#ff7b86"), 3)
		draw_line(ponto + Vector2(-9, -9), ponto + Vector2(9, 9), Color("#ffb5bb"), 3)
		draw_line(ponto + Vector2(9, -9), ponto + Vector2(-9, 9), Color("#ffb5bb"), 3)
	if chefe:
		var p = Vector2(0, -108)
		draw_colored_polygon(PackedVector2Array([p + Vector2(-19, 12), p + Vector2(-22, -5), p + Vector2(-8, 4), p + Vector2(0, -12), p + Vector2(8, 4), p + Vector2(22, -5), p + Vector2(19, 12)]), Color("#efbc66"))
