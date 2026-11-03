extends CharacterBody2D

const VELOCIDADE = 240.0
const FORCA_PULO = -440.0
const GRAVIDADE = 1100.0
var pode_mover = false
var ponto_seguro = Vector2(110, 584)
var arma = "espada"
@onready var sprite = $Sprite2D

func _unhandled_key_input(event: InputEvent) -> void:
	if pode_mover and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_SPACE, KEY_W, KEY_UP] and is_on_floor():
			velocity.y = FORCA_PULO
			get_viewport().set_input_as_handled()

func _physics_process(delta: float) -> void:
	queue_redraw()
	if not pode_mover:
		velocity = Vector2.ZERO
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
		sprite.flip_h = direcao < 0
	move_and_slide()
	position.x = clampf(position.x, 28, 1252)
	if is_on_floor() and position.y < 650:
		ponto_seguro = position
	if position.y > 810:
		position = ponto_seguro
		velocity = Vector2.ZERO

func _draw() -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(-8, -7), Vector2(-14, 15), Vector2(5, 13)]), Color("#55d9cc"))
	var lado = -1.0 if is_instance_valid(sprite) and sprite.flip_h else 1.0
	if arma == "espada":
		draw_line(Vector2(11 * lado, 9), Vector2(20 * lado, -14), Color("#e9f2ff"), 4)
		draw_line(Vector2(9 * lado, 1), Vector2(20 * lado, 5), Color("#efbc66"), 3)
	else:
		draw_arc(Vector2(14 * lado, 0), 13, -PI / 2, PI / 2, 12, Color("#efbc66"), 3)
		draw_line(Vector2(14 * lado, -13), Vector2(14 * lado, 13), Color("#e9f2ff"), 1)
