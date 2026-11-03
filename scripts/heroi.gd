extends CharacterBody2D

const Visual = preload("res://scripts/visual_heroi.gd")
const VELOCIDADE = 240.0
const FORCA_PULO = -440.0
const GRAVIDADE = 1100.0
var pode_mover = false
var ponto_seguro = Vector2(110, 584)
var arma = "espada"
var personagem = 1
var acao_especial = false
var olhando_esquerda = false
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.animation_finished.connect(_animacao_terminou)
	configurar(personagem, arma)

func configurar(id: int, equipamento: String) -> void:
	personagem = id
	arma = equipamento
	acao_especial = false
	olhando_esquerda = false
	sprite.sprite_frames = Visual.quadros(id, equipamento)
	sprite.speed_scale = 1.0
	sprite.flip_h = false
	sprite.position = Vector2(14, -26)
	sprite.play("parado")

func animar_acao(nome: String, duracao: float) -> void:
	acao_especial = true
	olhando_esquerda = false
	sprite.flip_h = false
	sprite.position.x = 14
	var total = sprite.sprite_frames.get_frame_count(nome)
	var fps = sprite.sprite_frames.get_animation_speed(nome)
	sprite.speed_scale = float(total) / (fps * maxf(duracao, 0.01))
	sprite.stop()
	sprite.play(nome)

func _animacao_terminou() -> void:
	if sprite.animation == "morte":
		return
	acao_especial = false
	sprite.speed_scale = 1.0
	sprite.play("parado")

func _unhandled_key_input(event: InputEvent) -> void:
	if pode_mover and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_SPACE, KEY_W, KEY_UP] and is_on_floor():
			velocity.y = FORCA_PULO
			get_viewport().set_input_as_handled()

func _physics_process(delta: float) -> void:
	if not pode_mover:
		velocity = Vector2.ZERO
		if not acao_especial:
			sprite.play("parado")
		return
	if not is_on_floor():
		velocity.y += GRAVIDADE * delta
	var direcao = 0.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direcao -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direcao += 1.0
	velocity.x = direcao * VELOCIDADE
	if direcao != 0:
		olhando_esquerda = direcao < 0
	sprite.flip_h = olhando_esquerda
	sprite.position.x = -14 if olhando_esquerda else 14
	move_and_slide()
	if not acao_especial:
		sprite.play("pulo" if not is_on_floor() else ("corrida" if direcao != 0 else "parado"))
	position.x = clampf(position.x, 28, 1252)
	if is_on_floor() and position.y < 650:
		ponto_seguro = position
	if position.y > 810:
		position = ponto_seguro
		velocity = Vector2.ZERO
