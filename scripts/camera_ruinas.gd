extends Camera2D

const LIMITES = Rect2(24, 134, 1232, 520)
var alvo: Node2D
var seguir = true
var congelada = false
var transicao: Tween
var centro_destino = Vector2(640, 360)
var zoom_destino = Vector2.ONE

func _ready() -> void:
	position_smoothing_enabled = false
	position = Vector2(640, 360)

func cancelar_transicao() -> void:
	if is_instance_valid(transicao) and transicao.is_valid():
		transicao.kill()

func configurar(personagem: Node2D, fixa: bool, imediata: bool = true) -> void:
	cancelar_transicao()
	alvo = personagem
	seguir = not fixa
	zoom = Vector2.ONE if fixa else Vector2(2, 2)
	congelada = false
	if fixa:
		position = Vector2(640, 360)
	elif imediata:
		position = limitar(alvo.position)
	reset_smoothing()
	force_update_scroll()

func limitar_para(ponto: Vector2, aproximacao: Vector2) -> Vector2:
	var metade = get_viewport_rect().size / aproximacao * 0.5
	var limites = LIMITES
	# A visão geral da arena inclui as margens de cenário já desenhadas.
	if metade.y * 2 > limites.size.y:
		limites.position.y = 0
		limites.size.y = 720
	if metade.x * 2 > limites.size.x:
		limites.position.x = 0
		limites.size.x = 1280
	return ponto.clamp(limites.position + metade, limites.end - metade)

func limitar(ponto: Vector2) -> Vector2:
	return limitar_para(ponto, zoom)

func transicionar(centro: Vector2, aproximacao: Vector2, duracao: float) -> void:
	cancelar_transicao()
	seguir = false
	centro_destino = limitar_para(centro, aproximacao)
	zoom_destino = aproximacao
	var inicio = position
	var zoom_inicial = zoom
	transicao = create_tween()
	transicao.tween_method(func(p: float):
		zoom = zoom_inicial.lerp(aproximacao, p)
		position = limitar_para(inicio.lerp(centro_destino, p), zoom)
		force_update_scroll()
	, 0.0, 1.0, maxf(duracao, 0.001)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func finalizar_transicao() -> void:
	cancelar_transicao()
	zoom = zoom_destino
	position = limitar_para(centro_destino, zoom)
	force_update_scroll()

func focar_pergunta(personagem: Node2D, duracao: float) -> void:
	var aproximacao = Vector2(3, 3)
	var ponto_tela = Vector2(320, 500)
	var centro = personagem.position - (ponto_tela - get_viewport_rect().size * 0.5) / aproximacao
	transicionar(centro, aproximacao, duracao)

func visao_geral(duracao: float) -> void:
	transicionar(Vector2(640, 360), Vector2.ONE, duracao)

func _process(delta: float) -> void:
	if seguir and not congelada and is_instance_valid(alvo):
		position = limitar(position.lerp(limitar(alvo.position), 1.0 - exp(-8.0 * delta)))
