extends Node2D
## Visual only. Root (0,0) is the bottom-center anchor; gameplay moves the root.
signal surgimento_concluido
signal pergunta_pronta(ataque: StringName)
signal impacto(ataque: StringName)
signal ataque_concluido(ataque: StringName)
signal explosao_branca
signal morte_concluida
var aguardando_resposta := false
var morrendo := false
var explosao_emitida := false
var maos_neutralizadas := 0
var ataque_atual: StringName = &""
var pausar_na_pergunta := false
var pergunta_emitida := false
var impacto_emitido := false
@onready var visual: AnimatedSprite2D = $Visual
func _ready() -> void:
    visual.animation_finished.connect(_ao_terminar)
    visual.frame_changed.connect(_ao_mudar_quadro)
    visual.play("surgimento")
func reaparecer() -> void:
    aguardando_resposta = false
    morrendo = false
    explosao_emitida = false
    visual.visible = true
    maos_neutralizadas = 0
    ataque_atual = &""
    visual.stop()
    visual.play("surgimento")
func iniciar_ataque(nome: StringName, pausar: bool = true) -> void:
    if morrendo:
        return
    if nome not in [&"ataque_mao_esquerda", &"ataque_mao_direita", &"ataque_olho"]:
        push_error("Ataque desconhecido: " + str(nome))
        return
    aguardando_resposta = false
    ataque_atual = nome
    pausar_na_pergunta = pausar
    pergunta_emitida = false
    impacto_emitido = false
    visual.stop()
    visual.play(nome)
func continuar_ataque() -> void:
    aguardando_resposta = false
    if ataque_atual != &"" and pergunta_emitida:
        visual.play()
func neutralizar_mao(lado: StringName) -> void:
    if morrendo:
        return
    if lado not in [&"esquerda", &"direita"]:
        return
    ataque_atual = &""
    maos_neutralizadas = 1 if lado == &"esquerda" else 2
    visual.stop()
    visual.play("dano_mao_" + str(lado))
func _parado() -> StringName:
    return [&"parado", &"parado_uma_mao", &"parado_sem_maos"][clampi(maos_neutralizadas,0,2)]
func _ao_mudar_quadro() -> void:
    if morrendo:
        if visual.animation == &"morte" and visual.frame == 32 and not explosao_emitida:
            explosao_emitida = true
            explosao_branca.emit()
        return
    if aguardando_resposta:
        return
    if ataque_atual == &"" or visual.animation != ataque_atual:
        return
    if visual.frame == 7 and not pergunta_emitida:
        pergunta_emitida = true
        if pausar_na_pergunta:
            aguardando_resposta = true
            visual.pause()
            call_deferred("_fixar_pergunta", ataque_atual)
        pergunta_pronta.emit(ataque_atual)
    elif visual.frame == 12 and not impacto_emitido:
        impacto_emitido = true
        impacto.emit(ataque_atual)
func _ao_terminar() -> void:
    if visual.animation == &"morte":
        visual.visible = false
        morte_concluida.emit()
    elif visual.animation == &"surgimento":
        visual.play(_parado())
        surgimento_concluido.emit()
    elif visual.animation == ataque_atual and ataque_atual != &"":
        var terminado := ataque_atual
        ataque_atual = &""
        visual.play(_parado())
        ataque_concluido.emit(terminado)
    elif visual.animation in [&"dano_mao_esquerda", &"dano_mao_direita"]:
        visual.play(_parado())
func morrer() -> void:
    if morrendo:
        return
    morrendo = true
    explosao_emitida = false
    ataque_atual = &""
    visual.visible = true
    visual.stop()
    visual.play("morte")

func _fixar_pergunta(nome: StringName) -> void:
    if aguardando_resposta and ataque_atual == nome and not morrendo:
        visual.pause()
        visual.set_frame_and_progress(7, 0.0)
