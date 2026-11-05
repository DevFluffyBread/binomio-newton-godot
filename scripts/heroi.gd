extends CharacterBody2D

signal ataque_solicitado
signal critico_solicitado
const Visual = preload("res://scripts/visual_heroi.gd")
const VELOCIDADE = 240.0

var pode_mover = false

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
	sprite.position = Vector2(14, -42)
	sprite.play("parado")

func animar_acao(nome: String, duracao: float) -> void:
	acao_especial = true
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

func orientar(alvo: Vector2) -> void:
	if absf(alvo.x - position.x) > 1:
		olhando_esquerda = alvo.x < position.x
	sprite.flip_h = olhando_esquerda
	sprite.position.x = -14 if olhando_esquerda else 14

func vetor_entrada() -> Vector2:
	var direcao = Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direcao.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direcao.x += 1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direcao.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direcao.y += 1
	return direcao.normalized()

func _unhandled_input(event: InputEvent) -> void:
	if not pode_mover:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			ataque_solicitado.emit()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_E:
			critico_solicitado.emit()
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ataque_solicitado.emit()
		get_viewport().set_input_as_handled()

func mover(direcao: Vector2) -> void:
	velocity = direcao.limit_length(1.0) * VELOCIDADE if pode_mover else Vector2.ZERO
	if not pode_mover:
		if not acao_especial:
			sprite.play("parado")
		return
	if direcao.x != 0:
		olhando_esquerda = direcao.x < 0
	sprite.flip_h = olhando_esquerda
	sprite.position.x = -14 if olhando_esquerda else 14
	move_and_slide()
	if not acao_especial:
		sprite.play("corrida" if velocity.length() > 0 else "parado")

func _physics_process(_delta: float) -> void:
	mover(vetor_entrada())
