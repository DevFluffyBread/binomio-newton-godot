extends Node

const MUSICA = preload("res://assets/audio/musica_fundo.mp3")
const MUSICA_CHEFE = preload("res://assets/audio/musica_chefe.mp3")
const GANHO_CHEFE_DB = 7.7
var suspense_ativo = false
var nivel_transicao = 1.0
var transicao_musica: Tween
var faixa_atual = &"ruinas"
const IMPACTO = preload("res://assets/audio/impacto_arco.mp3")
const ESPADAS = [preload("res://assets/audio/espada_10.wav"), preload("res://assets/audio/espada_6.wav"), preload("res://assets/audio/espada_9.wav"), preload("res://assets/audio/espada_7.wav")]
var aguardando_interacao_web = false
var ambiencia: AudioStreamPlayer
var volume_base_musica = -18.0
var musica: AudioStreamPlayer
var espada: AudioStreamPlayer
var impacto: AudioStreamPlayer

func _ready() -> void:
	musica = AudioStreamPlayer.new()
	musica.name = "MusicaFundo"
	var faixa = MUSICA.duplicate() as AudioStreamMP3
	faixa.loop = true
	musica.stream = faixa
	musica.volume_db = -18.0
	add_child(musica)
	aguardando_interacao_web = OS.has_feature("web")
	if not aguardando_interacao_web: musica.play()
	var variacoes = AudioStreamRandomizer.new()
	variacoes.random_pitch = 1.0
	variacoes.random_volume_offset_db = 0.0
	for i in range(ESPADAS.size()):
		variacoes.add_stream(i, ESPADAS[i])
	espada = AudioStreamPlayer.new()
	espada.stream = variacoes
	espada.volume_db = -7.0
	espada.max_polyphony = 4
	add_child(espada)
	impacto = AudioStreamPlayer.new()
	ambiencia = AudioStreamPlayer.new()
	add_child(ambiencia)
	impacto.stream = IMPACTO
	impacto.volume_db = -7.0
	impacto.max_polyphony = 4
	add_child(impacto)

func golpe(arma: String) -> void:
	if arma == "espada":
		espada.play()

func acertar(arma: String) -> void:
	if arma == "arco":
		impacto.play()

func volumes(musica_nivel: float, efeitos_nivel: float) -> void:
	volume_base_musica = -18.0 + linear_to_db(maxf(musica_nivel, 0.0001))
	_aplicar_volume_musica()
	musica.stream_paused = musica_nivel <= 0
	espada.volume_db = -7.0 + linear_to_db(maxf(efeitos_nivel, 0.0001))
	impacto.volume_db = espada.volume_db
	ambiencia.volume_db = linear_to_db(maxf(efeitos_nivel, 0.0001))

func ambiente(indice: int) -> void:
	var dados = PackedByteArray()
	var taxa = 22050
	for i in range(taxa * 3):
		var t = float(i) / taxa
		var envelope = sin(PI * t / 3.0) * 0.14
		var onda = sin(TAU * (44 + indice * 12) * t) + 0.3 * sin(TAU * 71 * t + sin(t * 12))
		var valor = int(clampf(onda * envelope, -1, 1) * 32767)
		dados.append(valor & 255)
		dados.append((valor >> 8) & 255)
	var faixa = AudioStreamWAV.new()
	faixa.format = AudioStreamWAV.FORMAT_16_BITS
	faixa.mix_rate = taxa
	faixa.data = dados
	ambiencia.stream = faixa
	ambiencia.play()

func suspense(ativo: bool) -> void:
	suspense_ativo = ativo
	_aplicar_volume_musica()

func musica_chefe() -> void:
	restaurar_transicao()
	selecionar_trilha(&"chefe", MUSICA_CHEFE)

func musica_ruinas() -> void:
	restaurar_transicao()
	selecionar_trilha(&"ruinas", MUSICA)

func selecionar_trilha(nome: StringName, recurso: AudioStreamMP3) -> void:
	if faixa_atual == nome: return
	faixa_atual = nome
	var silenciosa = musica.stream_paused
	var faixa = recurso.duplicate() as AudioStreamMP3
	faixa.loop = true
	musica.stream = faixa
	_aplicar_volume_musica()
	musica.play()
	musica.stream_paused = silenciosa

func _aplicar_volume_musica() -> void:
	var ganho = GANHO_CHEFE_DB if faixa_atual == &"chefe" else 0.0
	musica.volume_db = volume_base_musica + ganho - (10.0 if suspense_ativo else 0.0) + linear_to_db(maxf(nivel_transicao, 0.0001))

func restaurar_transicao() -> void:
	if is_instance_valid(transicao_musica) and transicao_musica.is_valid(): transicao_musica.kill()
	nivel_transicao = 1.0
	_aplicar_volume_musica()

func _nivel_musica(valor: float) -> void:
	nivel_transicao = valor
	_aplicar_volume_musica()

func encerrar_batalha() -> void:
	restaurar_transicao()
	suspense_ativo = false
	transicao_musica = create_tween()
	transicao_musica.tween_method(_nivel_musica, 1.0, 0.0, 0.6)
	transicao_musica.tween_callback(func(): selecionar_trilha(&"ruinas", MUSICA))
	transicao_musica.tween_method(_nivel_musica, 0.0, 0.65, 0.9)
func _input(event: InputEvent) -> void:
	if not aguardando_interacao_web: return
	var gesto = (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed) or (event is InputEventKey and event.pressed)
	if gesto:
		aguardando_interacao_web = false
		musica.play()