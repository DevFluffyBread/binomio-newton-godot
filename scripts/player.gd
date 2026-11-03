extends CharacterBody2D

const VELOCIDADE = 220.0
const FORCA_PULO = -420.0
const GRAVIDADE = 1000.0

@onready var sprite = $Sprite2D

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_SPACE, KEY_W, KEY_UP] and is_on_floor():
			velocity.y = FORCA_PULO

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVIDADE * delta
	var direcao = 0.0
	# Não movimentar o personagem enquanto o usuário digita nos campos.
	if get_viewport().gui_get_focus_owner() == null:
		if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
			direcao -= 1.0
		if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
			direcao += 1.0
	velocity.x = direcao * VELOCIDADE
	if direcao != 0:
		sprite.flip_h = direcao < 0
	move_and_slide()
