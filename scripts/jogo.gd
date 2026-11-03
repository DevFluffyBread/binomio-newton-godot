extends Node2D

enum Estado { MENU, EXPLORACAO, PERGUNTA, ANIMACAO, RESULTADO, DERROTA, VITORIA }
const Perguntas = preload("res://scripts/perguntas.gd")
const Mundo = preload("res://scripts/mundo.gd")
const Heroi = preload("res://scripts/heroi.gd")
const Interface = preload("res://scripts/interface.gd")
const Batalha = preload("res://scripts/batalha.gd")
const VisualHeroi = preload("res://scripts/visual_heroi.gd")
var estado = Estado.MENU
var fase = 0
var mortos = 0
var vidas = 3
var arma = "espada"
var personagem = 1
var duracao_ataque = 0.75
var geracao = 0
var mundo
var player
var ui
var batalha
var som: AudioStreamPlayer
var barreira: StaticBody2D
var perguntas = Perguntas.todas()

func _ready() -> void:
	mundo = Node2D.new()
	mundo.set_script(Mundo)
	add_child(mundo)
	player = CharacterBody2D.new()
	player.name = "Player"
	player.set_script(Heroi)
	var sprite = AnimatedSprite2D.new()
	sprite.name = "AnimatedSprite2D"
	sprite.scale = Vector2(2, 2)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	player.add_child(sprite)
	var colisao = CollisionShape2D.new()
	colisao.name = "CollisionShape2D"
	colisao.position = Vector2(0, -8)
	var forma = RectangleShape2D.new()
	forma.size = Vector2(20, 48)
	colisao.shape = forma
	player.add_child(colisao)
	add_child(player)
	batalha = Node.new()
	batalha.set_script(Batalha)
	add_child(batalha)
	batalha.respondida.connect(_resposta)
	ui = CanvasLayer.new()
	ui.set_script(Interface)
	add_child(ui)
	ui.arma_escolhida.connect(iniciar)
	ui.personagem_escolhido.connect(escolher_personagem)
	ui.trocar_personagem.connect(menu)
	ui.resposta_confirmada.connect(responder)
	ui.continuar.connect(continuar)
	ui.reiniciar.connect(func(): carregar_fase(fase))
	ui.voltar_menu.connect(menu)
	som = AudioStreamPlayer.new()
	add_child(som)
	mundo.configurar(0)
	player.position = Vector2(110, 584)
	menu()

func mudar_estado(novo: Estado) -> void:
	estado = novo
	player.pode_mover = novo == Estado.EXPLORACAO
	if not player.pode_mover:
		player.velocity = Vector2.ZERO

func menu() -> void:
	geracao += 1
	batalha.bloqueada = true
	mudar_estado(Estado.MENU)
	ui.atualizar(fase, mortos, vidas, arma, personagem)
	ui.menu()

func escolher_personagem(id: int) -> void:
	if estado != Estado.MENU or not id in VisualHeroi.NOMES:
		return
	personagem = id
	ui.menu_armas(personagem)

func iniciar(escolha: String) -> void:
	if estado != Estado.MENU or not escolha in ["espada", "arco"]:
		return
	arma = escolha
	player.configurar(personagem, arma)
	carregar_fase(0)

func carregar_fase(indice: int) -> void:
	geracao += 1
	fase = indice
	vidas = 3
	mortos = 0
	batalha.bloqueada = true
	mundo.configurar(fase)
	player.position = Vector2(110, 584)
	player.ponto_seguro = player.position
	player.velocity = Vector2.ZERO
	player.configurar(personagem, arma)
	ui.limpar()
	ui.atualizar(fase, mortos, vidas, arma, personagem)
	atualizar_barreira()
	mudar_estado(Estado.EXPLORACAO)

func atualizar_barreira() -> void:
	if is_instance_valid(barreira):
		remove_child(barreira)
		barreira.queue_free()
	barreira = null
	if mortos >= 3:
		return
	# Um guardião não pode ser pulado para evitar a pergunta.
	barreira = StaticBody2D.new()
	barreira.position = Vector2(mundo.pontos[mortos].x + 25, 350)
	var c = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(10, 700)
	c.shape = shape
	barreira.add_child(c)
	add_child(barreira)

func _physics_process(_delta: float) -> void:
	if estado != Estado.EXPLORACAO:
		return
	if mortos < 3:
		if player.position.x >= mundo.pontos[mortos].x - 85 and player.is_on_floor():
			iniciar_encontro()
	elif player.position.x >= 1160 and absf(player.position.y - 573) < 65:
		if fase < 2:
			carregar_fase(fase + 1)
		else:
			mudar_estado(Estado.VITORIA)
			ui.vitoria()

func iniciar_encontro() -> void:
	if estado != Estado.EXPLORACAO or mortos >= 3:
		return
	mudar_estado(Estado.PERGUNTA)
	batalha.iniciar(perguntas[fase * 3 + mortos])
	ui.pergunta(batalha.pergunta, mundo.NOMES[fase][mortos], batalha.erradas)

func responder(indice: int) -> void:
	if estado == Estado.PERGUNTA:
		batalha.responder(indice)

func _resposta(acertou: bool) -> void:
	if estado != Estado.PERGUNTA:
		return
	mudar_estado(Estado.ANIMACAO)
	ui.bloquear()
	var rodada = geracao
	mundo.efeito = "acerto" if acertou else "erro"
	mundo.arma = arma
	mundo.alvo = mundo.pontos[mortos]
	mundo.origem = player.position
	mundo.progresso = 0.0
	player.animar_acao("ataque" if acertou else ("morte" if vidas == 1 else "dano"), duracao_ataque)
	tocar(acertou)
	var tween = create_tween()
	tween.tween_property(mundo, "progresso", 1.0, duracao_ataque)
	await tween.finished
	if rodada != geracao:
		return
	mundo.efeito = ""
	if acertou:
		mortos += 1
		mundo.derrotados = mortos
		atualizar_barreira()
		ui.atualizar(fase, mortos, vidas, arma, personagem)
		mudar_estado(Estado.RESULTADO)
		ui.resultado(batalha.pergunta.explicacao)
	else:
		vidas -= 1
		ui.atualizar(fase, mortos, vidas, arma, personagem)
		if vidas == 0:
			mudar_estado(Estado.DERROTA)
			ui.derrota(fase)
		else:
			mudar_estado(Estado.PERGUNTA)
			batalha.bloqueada = false
			ui.pergunta(batalha.pergunta, mundo.NOMES[fase][mortos], batalha.erradas, "−1 coração. DICA: " + batalha.pergunta.dica)

func continuar() -> void:
	if estado != Estado.RESULTADO:
		return
	ui.limpar()
	mudar_estado(Estado.EXPLORACAO)

func tocar(acertou: bool) -> void:
	var dados = PackedByteArray()
	var taxa = 22050
	for i in range(6600):
		var t = float(i) / taxa
		var frequencia = (660.0 + t * 1100) if acertou else (170.0 - t * 220)
		var amostra = sin(TAU * frequencia * t) * 0.16 * (1.0 - float(i) / 6600)
		var valor = int(amostra * 32767)
		dados.append(valor & 255)
		dados.append((valor >> 8) & 255)
	var audio = AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_16_BITS
	audio.mix_rate = taxa
	audio.data = dados
	som.stream = audio
	som.play()
