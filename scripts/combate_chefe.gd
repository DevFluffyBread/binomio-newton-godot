extends Node

const CENA = preload("res://scenes/chefe_tetraedro.tscn")
const ATAQUES = [&"ataque_mao_esquerda", &"ataque_mao_direita", &"ataque_olho"]
const NOME = "CHEFE DAS PROFUNDEZAS"
var jogo
var chefe
var etapa = 0
var acertou = false
var impacto_resolvido = false
var token = 0
var tweens: Array[Tween] = []
var onda: AnimatedSprite2D
var escala_tempo = 1.0
var mortes_iniciadas = 0

func esperar(segundos: float) -> void:
	await get_tree().create_timer(maxf(segundos * escala_tempo, 0.001)).timeout

func mover(no: Object, propriedade: String, destino: Variant, segundos: float) -> Tween:
	var t = create_tween()
	tweens.append(t)
	t.tween_property(no, propriedade, destino, maxf(segundos * escala_tempo, 0.001)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return t

func cancelar() -> void:
	token += 1
	if is_instance_valid(jogo.camera): jogo.camera.cancelar_transicao()
	for t in tweens:
		if is_instance_valid(t) and t.is_valid(): t.kill()
	tweens.clear()
	if is_instance_valid(onda): onda.queue_free()
	if is_instance_valid(chefe):
		chefe.hide()
		chefe.queue_free()
	chefe = null
	jogo.ui.encerrar_cinema()
	jogo.sons.ambiencia.stop()
	jogo.sons.suspense(false)

func entrar(apresentar: bool = true) -> void:
	cancelar()
	var rodada = token
	etapa = 0
	mortes_iniciadas = 0
	jogo.player.position = Vector2(440, 540)
	jogo.player.orientar(Vector2(800, 450))
	chefe = CENA.instantiate()
	chefe.position = Vector2(820, 550)
	chefe.scale = Vector2(3, 3)
	jogo.mundo.atores.add_child(chefe)
	chefe.visual.stop()
	chefe.visual.speed_scale = 1.0 / escala_tempo
	chefe.hide()
	chefe.pergunta_pronta.connect(_pergunta)
	chefe.impacto.connect(_impacto)
	chefe.morte_concluida.connect(_vitoria)
	jogo.mudar_estado(jogo.Estado.APRESENTACAO)
	if apresentar and jogo.cenas_ativas:
		jogo.ui.criar_cinema()
		jogo.ui.cortina.modulate.a = 0
		jogo.sons.suspense(true)
		mover(jogo.ui.cortina, "modulate:a", 1.0, 0.6)
		await esperar(0.6)
		if rodada != token: return
		jogo.sons.musica_chefe()
		jogo.sons.suspense(false)
		jogo.ui.frase_cinema.text = "Algo ressurgiu das profundezas."
		jogo.sons.ambiente(2)
		await esperar(2.0)
		if rodada != token: return
		mover(jogo.ui.frase_cinema, "modulate:a", 0.0, 0.4)
		await esperar(0.4)
		if rodada != token: return
		jogo.ui.titulo_chefe.text = NOME
		mover(jogo.ui.titulo_chefe, "position:y", 310.0, 1.4)
		await esperar(1.4)
		if rodada != token: return
		chefe.show()
		chefe.visual.play("surgimento")
		mover(jogo.ui.cortina, "modulate:a", 0.0, 2.0)
		mover(jogo.ui.titulo_chefe, "position:y", 50.0, 2.0)
		await esperar(2.8)
		if rodada != token: return
		mover(jogo.ui.titulo_chefe, "modulate:a", 0.0, 0.4)
		await esperar(0.4)
		if rodada != token: return
		jogo.ui.encerrar_cinema()
	else:
		jogo.sons.musica_chefe()
		chefe.show()
		chefe.visual.play("parado")
	jogo.sons.suspense(false)
	preparar()

func preparar(nova_pergunta: bool = true) -> void:
	if not is_instance_valid(chefe): return
	jogo.mudar_estado(jogo.Estado.PREPARACAO)
	jogo.ui.limpar()
	jogo.ui.atualizar_chefe(etapa, jogo.vidas)
	if nova_pergunta:
		jogo.batalha.iniciar(jogo.perguntas[6 + etapa])
		jogo.batalha.bloqueada = true
	impacto_resolvido = false
	chefe.iniciar_ataque(ATAQUES[etapa])

func _pergunta(_ataque: StringName) -> void:
	if jogo.fase != 2 or jogo.estado != jogo.Estado.PREPARACAO: return
	var rodada = token
	jogo.mudar_estado(jogo.Estado.ENQUADRAMENTO)
	jogo.batalha.bloqueada = true
	var dica = "" if jogo.batalha.erradas.is_empty() else "−1 coração. DICA: " + jogo.batalha.pergunta.dica
	jogo.ui.pergunta_chefe(jogo.batalha.pergunta, etapa, jogo.batalha.erradas, dica)
	jogo.camera.focar_pergunta(jogo.player, 0.45 * escala_tempo)
	await esperar(0.45)
	if rodada != token: return
	jogo.camera.finalizar_transicao()
	jogo.batalha.bloqueada = false
	jogo.ui.liberar_confirmacao_chefe()
	jogo.mudar_estado(jogo.Estado.PERGUNTA)

func resposta(correta: bool) -> void:
	var rodada = token
	acertou = correta
	jogo.mudar_estado(jogo.Estado.ANIMACAO)
	jogo.ui.bloquear()
	jogo.camera.visao_geral(0.45 * escala_tempo)
	await esperar(0.45)
	if rodada != token: return
	jogo.camera.finalizar_transicao()
	chefe.continuar_ataque()

func _impacto(_ataque: StringName) -> void:
	if impacto_resolvido or jogo.estado != jogo.Estado.ANIMACAO: return
	impacto_resolvido = true
	resolver()

func criar_onda(destino: Vector2) -> void:
	onda = AnimatedSprite2D.new()
	onda.sprite_frames = chefe.visual.sprite_frames
	onda.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	onda.scale = Vector2(2, 2)
	onda.position = chefe.position + Vector2(0, -85) * chefe.scale
	jogo.mundo.add_child(onda)
	onda.z_index = 5
	onda.speed_scale = 1.0 / escala_tempo
	onda.play("onda_fogo_roxo")
	onda.animation_finished.connect(onda.queue_free)
	mover(onda, "position", destino, 0.6)

func resolver() -> void:
	var rodada = token
	jogo.mudar_estado(jogo.Estado.RESOLUCAO)
	var inicio: Vector2 = jogo.player.position
	var olho: Vector2 = chefe.position + Vector2([-38, 38, 0][etapa], [-56, -56, -85][etapa]) * 3
	if etapa == 2: criar_onda(inicio + Vector2(0, -24))
	if acertou:
		mover(jogo.player, "position", inicio + Vector2(-45, 64), 0.25)
		await esperar(0.3)
		if rodada != token: return
		if jogo.arma == "espada":
			mover(jogo.player, "position", olho + Vector2(-30, 35), 0.25)
			await esperar(0.25)
			if rodada != token: return
		jogo.player.orientar(olho)
		jogo.player.animar_acao("ataque", 0.4 * escala_tempo)
		jogo.sons.golpe(jogo.arma)
		jogo.mundo.efeito = "acerto"
		jogo.mundo.arma = jogo.arma
		jogo.mundo.origem = jogo.player.position + Vector2(0, -24)
		jogo.mundo.alvo = olho + Vector2(0, 25)
		jogo.mundo.progresso = 0
		mover(jogo.mundo, "progresso", 1.0, 0.4)
		await esperar(0.4)
		if rodada != token: return
		jogo.sons.acertar(jogo.arma)
		jogo.mundo.efeito = ""
		if etapa == 2:
			jogo.mudar_estado(jogo.Estado.MORTE_CHEFE)
			mortes_iniciadas += 1
			chefe.morrer()
			return
		chefe.neutralizar_mao(&"esquerda" if etapa == 0 else &"direita")
		await esperar(1.0)
		if rodada != token: return
		mover(jogo.player, "position", inicio, 0.3)
		await esperar(0.3)
		if rodada != token: return
		etapa += 1
		jogo.ui.atualizar_chefe(etapa, jogo.vidas)
		jogo.mudar_estado(jogo.Estado.RESULTADO)
		jogo.ui.resultado_chefe(jogo.batalha.pergunta.explicacao)
	else:
		if etapa == 2:
			await esperar(0.6)
			if rodada != token: return
		jogo.vidas = 0 if etapa == 2 else jogo.vidas - 1
		jogo.tocar(false)
		jogo.player.animar_acao("morte" if jogo.vidas == 0 else "dano", 0.45 * escala_tempo)
		jogo.ui.atualizar_chefe(etapa, jogo.vidas)
		await esperar(1.0)
		if rodada != token: return
		if jogo.vidas == 0:
			jogo.mudar_estado(jogo.Estado.DERROTA)
			jogo.ui.derrota_chefe()
		else:
			preparar(false)

func _vitoria() -> void:
	if jogo.estado != jogo.Estado.MORTE_CHEFE: return
	jogo.encerramento.iniciar()
