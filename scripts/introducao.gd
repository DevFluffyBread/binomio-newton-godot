extends Node

const LEGENDAS = [
	"Por gerações, os selos do Binômio mantiveram estas ruínas em equilíbrio.",
	"Agora, as runas estão se apagando. Os guardiões despertaram, e ninguém sabe o que rompeu a ordem.",
	"Você atravessa os portões para restaurar os selos. Cada resposta correta recupera uma parte do conhecimento perdido."
]
var jogo
var token = 0
var tempo_legenda = 4.0
var legenda_atual = -1
var ativa = false
var animacao: Tween

func cancelar() -> void:
	token += 1
	ativa = false
	if is_instance_valid(jogo.ui.portas_historia): jogo.ui.portas_historia.stop()
	if is_instance_valid(animacao) and animacao.is_valid(): animacao.kill()
	if is_instance_valid(jogo.camera): jogo.camera.cancelar_transicao()

func iniciar() -> void:
	cancelar()
	ativa = true
	var rodada = token
	jogo.mudar_estado(jogo.Estado.HISTORIA)
	jogo.ui.preparar_historia()
	for i in range(LEGENDAS.size()):
		if rodada != token: return
		legenda_atual = i
		jogo.ui.mostrar_arte_historia(i, tempo_legenda)
		jogo.ui.fundo_historia.modulate.a = 0
		jogo.ui.legenda_historia.text = LEGENDAS[i]
		jogo.ui.legenda_historia.modulate.a = 0
		animacao = create_tween()
		animacao.tween_property(jogo.ui.legenda_historia, "modulate:a", 1.0, tempo_legenda * 0.1)
		animacao.parallel().tween_property(jogo.ui.fundo_historia, "modulate:a", 1.0, tempo_legenda * 0.1)
		animacao.tween_interval(tempo_legenda * 0.8)
		animacao.tween_property(jogo.ui.legenda_historia, "modulate:a", 0.0, tempo_legenda * 0.1)
		animacao.parallel().tween_property(jogo.ui.fundo_historia, "modulate:a", 0.0, tempo_legenda * 0.1)
		await get_tree().create_timer(tempo_legenda).timeout
		if rodada != token: return
	concluir()

func pular() -> void:
	if ativa: concluir()

func concluir() -> void:
	if not ativa: return
	cancelar()
	jogo.ui.encerrar_cinema()
	jogo.camera.configurar(jogo.player, false)
	jogo.ui.hud_visivel(true)
	jogo.pressagio()
