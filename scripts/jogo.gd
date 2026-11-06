extends Node2D

enum Estado { MENU, EXPLORACAO, PERGUNTA, ANIMACAO, RESULTADO, DERROTA, VITORIA, PRESSAGIO, APRESENTACAO, PREPARACAO, RESOLUCAO, MORTE_CHEFE, ENQUADRAMENTO, HISTORIA, ENCERRAMENTO }
const AudioJogo = preload("res://scripts/audio_jogo.gd")
const Perguntas = preload("res://scripts/perguntas.gd")
const Mundo = preload("res://scripts/mundo.gd")
const Heroi = preload("res://scripts/heroi.gd")
const Interface = preload("res://scripts/interface.gd")
const Batalha = preload("res://scripts/batalha.gd")
const VisualHeroi = preload("res://scripts/visual_heroi.gd")
var camera: Camera2D
var controles_toque
var encerramento
var introducao
var historia_pendente = false
var chefe_batalha
var cenas_ativas = true
var pressagios_vistos = [false, false]
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
var sons
var som: AudioStreamPlayer
var barreira: StaticBody2D
var perguntas = Perguntas.todas()
const GOLPES_PARA_CRITICO = 3
var carga_critico = 0
var recarga_ataque = 0.0
var invulneravel = 0.0
var tween_efeito: Tween

func _ready() -> void:
	mundo = Node2D.new()
	mundo.set_script(Mundo)
	add_child(mundo)
	player = CharacterBody2D.new()
	player.name = "Player"
	player.set_script(Heroi)
	player.collision_layer = 2
	var sprite = AnimatedSprite2D.new()
	sprite.name = "AnimatedSprite2D"
	sprite.scale = Vector2(2, 2)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	player.add_child(sprite)
	var colisao = CollisionShape2D.new()
	colisao.name = "CollisionShape2D"
	colisao.position = Vector2.ZERO
	var forma = RectangleShape2D.new()
	forma.size = Vector2(20, 12)
	colisao.shape = forma
	player.add_child(colisao)
	mundo.atores.add_child(player)
	mundo.heroi = player
	player.ataque_solicitado.connect(atacar)
	player.critico_solicitado.connect(tentar_critico)
	mundo.golpe_inimigo.connect(receber_dano)
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
	ui.critico_solicitado.connect(tentar_critico)
	ui.resposta_confirmada.connect(responder)
	ui.continuar.connect(continuar)
	ui.reiniciar.connect(func(): carregar_fase(fase, false))
	ui.voltar_menu.connect(menu_inicial)
	sons = Node.new()
	sons.set_script(AudioJogo)
	add_child(sons)
	ui.audio_alterado.connect(sons.volumes)
	ui.audio_alterado.connect(func(_musica: float, efeitos: float): som.volume_db = linear_to_db(maxf(efeitos, 0.0001)))
	som = AudioStreamPlayer.new()
	add_child(som)
	camera = Camera2D.new()
	camera.set_script(preload("res://scripts/camera_ruinas.gd"))
	add_child(camera)
	chefe_batalha = Node.new()
	chefe_batalha.set_script(preload("res://scripts/combate_chefe.gd"))
	chefe_batalha.jogo = self
	add_child(chefe_batalha)
	introducao = Node.new()
	introducao.set_script(preload("res://scripts/introducao.gd"))
	introducao.jogo = self
	add_child(introducao)
	ui.pular_historia.connect(introducao.pular)
	encerramento = CanvasLayer.new()
	encerramento.set_script(preload("res://scripts/encerramento.gd"))
	encerramento.jogo = self
	add_child(encerramento)
	controles_toque = CanvasLayer.new()
	controles_toque.set_script(preload("res://scripts/controles_toque.gd"))
	controles_toque.jogo = self
	add_child(controles_toque)
	mundo.configurar(0)
	player.position = Mundo.ENTRADA
	menu_inicial()

func menu_inicial() -> void:
	menu()
	ui.inicial()

func mudar_estado(novo: Estado) -> void:
	estado = novo
	controles_toque.definir_ativo(novo == Estado.EXPLORACAO)
	mundo.definir_exploracao(novo == Estado.EXPLORACAO)
	player.pode_mover = novo == Estado.EXPLORACAO
	if not player.pode_mover:
		player.velocity = Vector2.ZERO

func menu() -> void:
	encerramento.cancelar()
	sons.musica_ruinas()
	introducao.cancelar()
	chefe_batalha.cancelar()
	ui.hud_visivel(true)
	camera.configurar(player, true)
	if is_instance_valid(tween_efeito):
		tween_efeito.kill()
	mundo.efeito = ""
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
	pressagios_vistos = [false, false]
	historia_pendente = cenas_ativas
	arma = escolha
	player.configurar(personagem, arma)
	carregar_fase(0)

func carregar_fase(indice: int, apresentar: bool = true) -> void:
	encerramento.cancelar()
	introducao.cancelar()
	if is_instance_valid(tween_efeito):
		tween_efeito.kill()
	geracao += 1
	chefe_batalha.cancelar()
	fase = indice
	if fase < 2: sons.musica_ruinas()
	vidas = 3
	mortos = 0
	carga_critico = 0
	recarga_ataque = 0
	invulneravel = 0
	player.modulate = Color.WHITE
	batalha.bloqueada = true
	mundo.configurar(fase)
	player.position = Mundo.ENTRADA
	player.velocity = Vector2.ZERO
	player.configurar(personagem, arma)
	ui.limpar()
	ui.hud_visivel(true)
	ui.atualizar(fase, mortos, vidas, arma, personagem)
	camera.configurar(player, fase == 2)
	if fase == 2:
		barreira = null
		chefe_batalha.entrar(apresentar)
		return
	atualizar_barreira()
	if historia_pendente and fase == 0 and cenas_ativas:
		historia_pendente = false
		introducao.iniciar()
		return
	mudar_estado(Estado.EXPLORACAO)
	if cenas_ativas and not pressagios_vistos[fase]:
		pressagio()

func pressagio() -> void:
	pressagios_vistos[fase] = true
	var rodada = geracao
	mudar_estado(Estado.PRESSAGIO)
	ui.criar_cinema()
	ui.cortina.color = Color(0, 0, 0, 0.78)
	ui.frase_cinema.text = ["Você ouve barulhos estranhos…", "Você sente uma presença desconcertante…"][fase]
	ui.frase_cinema.modulate.a = 0
	sons.suspense(true)
	sons.ambiente(fase)
	var entrada = create_tween()
	entrada.tween_property(ui.frase_cinema, "modulate:a", 1.0, 0.4)
	await get_tree().create_timer(2.6).timeout
	if rodada != geracao: return
	var saida = create_tween()
	saida.tween_property(ui.frase_cinema, "modulate:a", 0.0, 0.4)
	await saida.finished
	if rodada != geracao: return
	ui.encerrar_cinema()
	ui.hud_visivel(true)
	sons.suspense(false)
	mudar_estado(Estado.EXPLORACAO)

func atualizar_barreira() -> void:
	mundo.atualizar_portoes(mortos)
	barreira = mundo.portoes[mortos] if mortos < 3 else null

func _physics_process(delta: float) -> void:
	recarga_ataque = maxf(0, recarga_ataque - delta)
	invulneravel = maxf(0, invulneravel - delta)
	player.modulate.a = 0.5 if invulneravel > 0 and fmod(invulneravel, 0.2) > 0.1 else 1.0
	camera.congelada = estado != Estado.EXPLORACAO
	if fase != 2 and estado not in [Estado.HISTORIA, Estado.PRESSAGIO, Estado.APRESENTACAO]:
		ui.combate(carga_critico, GOLPES_PARA_CRITICO, estado == Estado.EXPLORACAO and alvo_ao_alcance(), estado == Estado.EXPLORACAO)
	if estado != Estado.EXPLORACAO:
		return
	if mortos == 3 and player.position.distance_to(Mundo.SAIDA) < 30:
		if fase < 2:
			carregar_fase(fase + 1)
		else:
			mudar_estado(Estado.VITORIA)
			ui.vitoria()

func alvo_ao_alcance() -> bool:
	if fase == 2 or mortos >= 3 or not Mundo.ARENAS[mortos].has_point(player.position):
		return false
	var inimigo = mundo.monstros[mortos]
	var alcance = 200.0 if arma == "arco" else 76.0
	if not inimigo.visible or player.position.distance_to(inimigo.position) > alcance:
		return false
	var consulta = PhysicsRayQueryParameters2D.create(player.position, inimigo.position, 1)
	return get_world_2d().direct_space_state.intersect_ray(consulta).is_empty()

func atacar() -> void:
	if fase == 2 or estado != Estado.EXPLORACAO or recarga_ataque > 0:
		return
	recarga_ataque = 0.45
	player.animar_acao("ataque", 0.35)
	sons.golpe(arma)
	if not alvo_ao_alcance():
		ui.objetivo.text = "Golpe fora de alcance. Aproxime-se do guardião da área atual."
		return
	var inimigo = mundo.monstros[mortos]
	player.orientar(inimigo.position)
	inimigo.golpe_comum(player.position)
	carga_critico = mini(carga_critico + 1, GOLPES_PARA_CRITICO)
	ui.objetivo.text = "Use seu crítico ao alcance do guardião para abrir o próximo portão." if carga_critico == GOLPES_PARA_CRITICO else "Acertou! Carregue o crítico: %d/%d golpes." % [carga_critico, GOLPES_PARA_CRITICO]
	mundo.efeito = "comum"
	mundo.arma = arma
	mundo.alvo = inimigo.position
	mundo.origem = player.position + Vector2(0, -24)
	mundo.progresso = 0
	if is_instance_valid(tween_efeito):
		tween_efeito.kill()
	tween_efeito = create_tween()
	tween_efeito.tween_property(mundo, "progresso", 1.0, 0.3)
	tween_efeito.tween_callback(func():
		sons.acertar(arma)
		mundo.efeito = ""
	)

func tentar_critico() -> void:
	if fase == 2: return
	if estado != Estado.EXPLORACAO:
		return
	if carga_critico < GOLPES_PARA_CRITICO:
		ui.objetivo.text = "Acerte três golpes comuns para carregar o crítico."
		return
	if not alvo_ao_alcance():
		ui.objetivo.text = "Crítico carregado. Aproxime-se do guardião para usá-lo."
		return
	iniciar_encontro()

func receber_dano() -> void:
	if estado != Estado.EXPLORACAO or invulneravel > 0:
		return
	vidas -= 1
	invulneravel = 1.2
	ui.atualizar(fase, mortos, vidas, arma, personagem)
	player.animar_acao("morte" if vidas == 0 else "dano", 0.35)
	if vidas == 0:
		mudar_estado(Estado.DERROTA)
		ui.derrota(fase)
	else:
		ui.objetivo.text = "−1 coração. Saia do círculo vermelho antes do impacto!"

func iniciar_encontro() -> void:
	if estado != Estado.EXPLORACAO or mortos >= 3 or carga_critico < GOLPES_PARA_CRITICO or not alvo_ao_alcance():
		return
	if is_instance_valid(tween_efeito):
		tween_efeito.kill()
	mundo.efeito = ""
	mudar_estado(Estado.PERGUNTA)
	batalha.iniciar(perguntas[fase * 3 + mortos])
	ui.pergunta(batalha.pergunta, mundo.NOMES[fase][mortos], batalha.erradas)

func responder(indice: int) -> void:
	if estado == Estado.PERGUNTA:
		batalha.responder(indice)

func _resposta(acertou: bool) -> void:
	if estado != Estado.PERGUNTA:
		return
	if fase == 2:
		chefe_batalha.resposta(acertou)
		return
	mudar_estado(Estado.ANIMACAO)
	ui.bloquear()
	var rodada = geracao
	mundo.efeito = "acerto" if acertou else "erro"
	mundo.arma = arma
	mundo.alvo = mundo.monstros[mortos].position
	mundo.origem = player.position + Vector2(0, -24)
	mundo.progresso = 0.0
	player.orientar(mundo.monstros[mortos].position)
	player.animar_acao("ataque" if acertou else ("morte" if vidas == 1 else "dano"), duracao_ataque)
	mundo.animar_resposta(mortos, acertou, duracao_ataque)
	if acertou:
		sons.golpe(arma)
	else:
		tocar(false)
	var tween = create_tween()
	tween.tween_property(mundo, "progresso", 0.5, duracao_ataque * 0.5)
	tween.tween_callback(func():
		if acertou and rodada == geracao:
			sons.acertar(arma)
	)
	tween.tween_property(mundo, "progresso", 1.0, duracao_ataque * 0.5)
	await tween.finished
	if rodada != geracao:
		return
	mundo.efeito = ""
	if acertou:
		carga_critico = 0
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
	if fase == 2:
		chefe_batalha.preparar()
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
