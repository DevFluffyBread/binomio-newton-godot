extends CanvasLayer

const VisualHeroi = preload("res://scripts/visual_heroi.gd")
const Dispositivo = preload("res://scripts/dispositivo.gd")
const Pele = preload("res://scripts/pele_pixel.gd")
signal pular_historia
var confirmacao_bloqueada = false
var layout_chefe = false
signal audio_alterado(musica: float, efeitos: float)
var volume_musica = 1.0
var volume_efeitos = 1.0
var conteudo_inicio: Control
var fundo_historia: Control
var imagem_historia: Sprite2D
var portas_historia: AnimatedSprite2D
var legenda_historia: Label
var cinema: Control
var cortina: ColorRect
var frase_cinema: Label
var titulo_chefe: Label
var tema_pixel: Theme
var coracoes: Array[TextureRect] = []
var barra_critico: ProgressBar
signal personagem_escolhido(personagem: int)
signal trocar_personagem
signal critico_solicitado
signal arma_escolhida(arma: String)
signal resposta_confirmada(indice: int)
signal continuar
signal reiniciar
signal voltar_menu
var topo: Label
var vidas_label: Label
var objetivo: Label
var camada: Control
var painel: PanelContainer
var opcoes: Array[Button] = []
var confirmar: Button
var feedback: Label
var selecionada = -1
var cor = Color("#74d9bd")
var etapa_menu = "personagem"
var botao_critico: Button
var carga_label: Label
var popup_critico: PanelContainer
var aviso_titulo: Label
var aviso_instrucao: Label
var animacao_aviso: Tween
var aviso_ativo = false
const POSICAO_POPUP = Vector2(400, 110)

func label(texto: String, tamanho: int = 22, tinta: Color = Color("#f1d6a8")) -> Label:
	var l = Label.new()
	l.theme = Pele.tema()
	l.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	l.text = texto
	l.add_theme_font_size_override("font_size", Pele.tamanho(tamanho))
	l.add_theme_color_override("font_color", tinta)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

func botao(texto: String, acao: Callable) -> Button:
	var b = Button.new()
	b.theme = Pele.tema()
	b.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	b.text = texto
	b.custom_minimum_size.y = 80 if Dispositivo.ativo() else 48
	b.add_theme_font_size_override("font_size", 24 if Dispositivo.ativo() else 16)
	if Dispositivo.ativo(): b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.add_theme_constant_override("icon_max_width", 24)
	b.expand_icon = true
	b.icon = Pele.icone("star" if "crítico" in texto.to_lower() else ("sword" if "ESPADA" in texto or "ataque" in texto.to_lower() else ("arrow_left" if "Voltar" in texto or "Menu" in texto else ("arrow_right" if "Continuar" in texto or "ARCO" in texto else ("user" if texto == "Escolher" else "play")))))
	if texto.length() > 0 and texto.left(1) in ["A", "B", "C", "D"] and texto.substr(1, 3) == "   ":
		b.icon = null
	b.pressed.connect(acao)
	return b

func _ready() -> void:
	tema_pixel = Pele.tema()
	if not Dispositivo.ativo(): Input.set_custom_mouse_cursor(load(Pele.RAIZ + "cursor_3x.png"))
	var barra = Panel.new()
	barra.position = Vector2(24, 20)
	barra.size = Vector2(1232, 82)
	barra.theme = tema_pixel
	barra.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	barra.add_theme_stylebox_override("panel", Pele.painel())
	add_child(barra)
	topo = label("", 22)
	topo.position = Vector2(44, 33)
	topo.size = Vector2(830, 30)
	add_child(topo)
	vidas_label = label("VIDA 3/3", 16)
	vidas_label.position = Vector2(1030, 71)
	vidas_label.size = Vector2(210, 24)
	add_child(vidas_label)
	for i in range(3):
		var coracao = TextureRect.new()
		coracao.texture = Pele.icone("heart")
		coracao.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		coracao.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		coracao.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		coracao.position = Vector2(1030 + i * 48, 30)
		coracao.size = Vector2(32, 32)
		coracao.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(coracao)
		coracoes.append(coracao)
	objetivo = label("", 15, Color("#d2b28c"))
	objetivo.position = Vector2(44, 69)
	objetivo.size = Vector2(1100, 26)
	add_child(objetivo)
	var controles = label("WASD / SETAS: mover   •   ESPAÇO / CLIQUE: atacar   •   E: crítico   •   Fuja do círculo vermelho!", 16, Color("#dcc59f"))
	controles.position = Vector2(30, 694)
	controles.size = Vector2(1220, 26)
	add_child(controles)
	var rodape = Panel.new()
	rodape.theme = tema_pixel
	rodape.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rodape.position = Vector2(24, 642)
	rodape.size = Vector2(1232, 50)
	rodape.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rodape)
	var estrela = TextureRect.new()
	estrela.texture = Pele.icone("star")
	estrela.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	estrela.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	estrela.position = Vector2(40, 654)
	estrela.size = Vector2(24, 24)
	estrela.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(estrela)
	carga_label = label("CRÍTICO  0/3 golpes", 18, Color("#f7d993"))
	carga_label.position = Vector2(80, 657)
	carga_label.size = Vector2(335, 30)
	add_child(carga_label)
	barra_critico = ProgressBar.new()
	barra_critico.theme = tema_pixel
	barra_critico.theme_type_variation = "GoldBar"
	barra_critico.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	barra_critico.position = Vector2(440, 655)
	barra_critico.size = Vector2(270, 24)
	barra_critico.show_percentage = false
	barra_critico.max_value = 3
	barra_critico.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(barra_critico)
	botao_critico = botao("E / Golpe crítico", func(): critico_solicitado.emit())
	botao_critico.position = Vector2(940, 646)
	botao_critico.custom_minimum_size.y = 40
	botao_critico.size = Vector2(300, 40)
	botao_critico.focus_mode = Control.FOCUS_NONE
	add_child(botao_critico)
	criar_popup_critico()
	if Dispositivo.ativo():
		barra.size.y = 110
		topo.position = Vector2(40, 25)
		topo.size = Vector2(940, 40)
		objetivo.position = Vector2(40, 76)
		objetivo.size = Vector2(940, 42)
		objetivo.max_lines_visible = 1
		objetivo.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		vidas_label.position = Vector2(1030, 78)
		vidas_label.size = Vector2(210, 40)
		controles.hide()
		rodape.hide()
		estrela.hide()
		botao_critico.hide()
		carga_label.position = Vector2(438, 646)
		carga_label.size = Vector2(450, 40)
		barra_critico.position = Vector2(438, 690)
		barra_critico.size = Vector2(400, 16)

func criar_popup_critico() -> void:
	popup_critico = PanelContainer.new()
	popup_critico.position = POSICAO_POPUP
	popup_critico.custom_minimum_size = Vector2(480, 120 if Dispositivo.ativo() else 104)
	popup_critico.size = Vector2(480, 104)
	popup_critico.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup_critico.theme = tema_pixel
	popup_critico.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var fundo = Pele.painel()
	fundo.content_margin_top = 12
	fundo.content_margin_bottom = 12
	popup_critico.add_theme_stylebox_override("panel", fundo)
	add_child(popup_critico)
	var coluna = VBoxContainer.new()
	coluna.mouse_filter = Control.MOUSE_FILTER_IGNORE
	coluna.add_theme_constant_override("separation", 4)
	popup_critico.add_child(coluna)
	aviso_titulo = label("Golpe crítico pronto!", 27, Color("#ffe0a0"))
	aviso_instrucao = label("Toque no botão crítico" if Dispositivo.ativo() else "Aperte E para realizá-lo", 19, Color("#f1d6a8"))
	for linha in [aviso_titulo, aviso_instrucao]:
		linha.autowrap_mode = TextServer.AUTOWRAP_OFF
		linha.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		linha.mouse_filter = Control.MOUSE_FILTER_IGNORE
		coluna.add_child(linha)
	popup_critico.hide()

func mostrar_popup_critico() -> void:
	aviso_ativo = true
	if is_instance_valid(animacao_aviso):
		animacao_aviso.kill()
	popup_critico.pivot_offset = popup_critico.size / 2
	popup_critico.position = POSICAO_POPUP + Vector2(0, -14)
	popup_critico.scale = Vector2.ONE * 0.88
	popup_critico.rotation = -0.012
	popup_critico.modulate.a = 0
	popup_critico.show()
	animacao_aviso = create_tween().set_parallel(true)
	animacao_aviso.tween_property(popup_critico, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	animacao_aviso.tween_property(popup_critico, "scale", Vector2.ONE * 1.035, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	animacao_aviso.tween_property(popup_critico, "position", POSICAO_POPUP, 0.30).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	animacao_aviso.tween_property(popup_critico, "rotation", 0.0, 0.30).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	animacao_aviso.chain().tween_property(popup_critico, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	animacao_aviso.chain().tween_method(shake_popup, 0.0, 1.0, 0.72)
	animacao_aviso.chain().tween_callback(assentar_popup)

func shake_popup(progresso: float) -> void:
	var intensidade = pow(1.0 - progresso, 2)
	var onda = sin(progresso * TAU * 2.5)
	popup_critico.position = POSICAO_POPUP + Vector2(onda * 2.0, sin(progresso * TAU * 2) * 0.6) * intensidade
	popup_critico.rotation = onda * 0.007 * intensidade

func assentar_popup() -> void:
	popup_critico.position = POSICAO_POPUP
	popup_critico.rotation = 0
	popup_critico.scale = Vector2.ONE
	popup_critico.modulate.a = 1

func ocultar_popup_critico() -> void:
	aviso_ativo = false
	if is_instance_valid(animacao_aviso):
		animacao_aviso.kill()
	if is_instance_valid(popup_critico):
		popup_critico.hide()

func combate(carga: int, total: int, ao_alcance: bool, exibir_aviso: bool = true) -> void:
	var pronto = carga >= total
	objetivo.show()
	carga_label.text = ("CRÍTICO  %d/%d" if Dispositivo.ativo() else "CRÍTICO  %d/%d golpes acertados") % [carga, total]
	barra_critico.max_value = total
	barra_critico.value = carga
	botao_critico.disabled = carga < total or not ao_alcance
	if Dispositivo.ativo(): botao_critico.hide()
	if pronto and exibir_aviso:
		if not aviso_ativo:
			mostrar_popup_critico()
	elif aviso_ativo:
		ocultar_popup_critico()

func atualizar(fase: int, mortos: int, vidas: int, arma: String, personagem: int = 1) -> void:
	cor = [Color("#74d9bd"), Color("#e8b76d"), Color("#bd9cff")][fase]
	topo.text = ("FASE %d/3  /  GUARDIÕES %d/3  /  %s · %s" if Dispositivo.ativo() else "FASE %d/3  —  MONSTROS %d/3     /     %s · %s") % [fase + 1, mortos, VisualHeroi.NOMES[personagem].to_upper(), arma.to_upper()]
	vidas_label.text = "VIDA %d/3" % vidas
	for i in range(coracoes.size()):
		coracoes[i].texture = Pele.icone("heart" if i < vidas else "heart_empty")
	objetivo.text = ("Saída aberta! Siga para a direita." if mortos == 3 else "Derrote o guardião para abrir o portão.") if Dispositivo.ativo() else ("Portão de saída aberto! Siga para a direita para alcançar a próxima região." if mortos == 3 else "Explore a área liberada. Derrote seu guardião para abrir o próximo portão.")

func limpar() -> void:
	confirmacao_bloqueada = false
	layout_chefe = false
	if is_instance_valid(camada):
		camada.hide()
		camada.queue_free()
	opcoes.clear()
	selecionada = -1

func cartao(pos: Vector2, largura: float, escurecer: bool = false) -> VBoxContainer:
	ocultar_popup_critico()
	limpar()
	camada = Control.new()
	camada.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(camada)
	if escurecer:
		var sombra = ColorRect.new()
		sombra.color = Color(0.04, 0.025, 0.018, 0.9)
		sombra.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		camada.add_child(sombra)
	painel = PanelContainer.new()
	if Dispositivo.ativo():
		pos = Vector2(550, 116) if pos.x == 620 else Vector2(40, 116)
		largura = 690 if pos.x == 550 else 1200
	painel.position = pos
	painel.custom_minimum_size.x = largura
	painel.size.x = largura
	painel.theme = tema_pixel
	painel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	painel.add_theme_stylebox_override("panel", Pele.painel())
	camada.add_child(painel)
	var coluna = VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 12)
	if Dispositivo.ativo():
		adicionar_rolagem(painel, coluna, 500 if pos.x == 550 else 510)
	else:
		painel.add_child(coluna)
	return coluna

func menu() -> void:
	etapa_menu = "personagem"
	var v = cartao(Vector2(150, 116), 980, true)
	v.add_child(label("AS RUÍNAS DO BINÔMIO", 36, Color("#f7d993")))
	v.add_child(label("01 / ESCOLHA SEU PERSONAGEM", 18, cor))
	v.add_child(label("Três heróis. Seis guardiões e um chefe para enfrentar.", 20, Color("#d2b28c")))
	var linha = HBoxContainer.new()
	linha.add_theme_constant_override("separation", 16)
	v.add_child(linha)
	for id in range(1, 4):
		var card = PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.theme = tema_pixel
		card.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		card.add_theme_stylebox_override("panel", Pele.painel(true))
		linha.add_child(card)
		var coluna = VBoxContainer.new()
		card.add_child(coluna)
		var preview = VisualHeroi.previa(id, "espada")
		preview.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		coluna.add_child(preview)
		var nome = label(VisualHeroi.NOMES[id], 24)
		nome.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		coluna.add_child(nome)
		coluna.add_child(botao("Escolher", personagem_escolhido.emit.bind(id)))
	v.add_child(label("Arraste o joystick para mover. Ataque à direita e use o círculo crítico junto ao joystick." if Dispositivo.ativo() else "WASD: mover • Espaço/clique: atacar • Três acertos carregam E: crítico.\nUma pergunta certa mata o guardião. Fuja dos ataques avisados em vermelho!", 17, Color("#d2b28c")))

	var retorno = botao("Voltar ao menu inicial", inicial)
	retorno.position = Vector2(440, 590)
	retorno.size.x = 400
	if Dispositivo.ativo():
		retorno.position = Vector2.ZERO
		v.add_child(retorno)
	else:
		camada.add_child(retorno)
	var creditos = label("Pixel UI Free by heyheythere - https://heyheythere.itch.io/pixel-ui-free - CC BY 4.0", 16)
	creditos.add_theme_font_size_override("font_size", 8)
	creditos.position = Vector2(32, 674)
	creditos.size = Vector2(1150, 16)
	camada.add_child(creditos)

func menu_armas(personagem: int) -> void:
	etapa_menu = "arma"
	var v = cartao(Vector2(200, 102), 880, true)
	v.add_child(label("02 / ESCOLHA SUA ARMA", 30, Color("#f7d993")))
	v.add_child(label("SEU HERÓI: " + VisualHeroi.NOMES[personagem].to_upper(), 18, cor))
	var linha = HBoxContainer.new()
	linha.add_theme_constant_override("separation", 20)
	v.add_child(linha)
	for arma in ["espada", "arco"]:
		var card = PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.theme = tema_pixel
		card.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		card.add_theme_stylebox_override("panel", Pele.painel(true))
		linha.add_child(card)
		var coluna = VBoxContainer.new()
		card.add_child(coluna)
		var preview = VisualHeroi.previa(personagem, arma)
		preview.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		coluna.add_child(preview)
		coluna.add_child(botao("ESPADA / Corte rúnico" if arma == "espada" else "ARCO / Flecha de luz", arma_escolhida.emit.bind(arma)))
	v.add_child(label("O mesmo poder, dois estilos de ataque. Responda corretamente para desferir um golpe crítico! Cada erro custa um coração.", 20, Color("#d2b28c")))
	v.add_child(botao("← Voltar aos personagens", func(): trocar_personagem.emit()))

func pergunta(dados: Dictionary, nome: String, erradas: Array, dica: String = "") -> void:
	var v = cartao(Vector2(150, 126), 980)
	v.add_child(label("ENCONTRO  /  " + nome.to_upper(), 16, cor))
	v.add_child(label(dados.enunciado, 27))
	var grid = GridContainer.new()
	grid.columns = 1 if Dispositivo.ativo() else 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 10)
	v.add_child(grid)
	for i in range(4):
		var b = botao("%s   %s" % [char(65 + i), dados.opcoes[i]], selecionar.bind(i))
		b.custom_minimum_size = Vector2(0, 80) if Dispositivo.ativo() else Vector2(460, 54)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.disabled = i in erradas
		b.icon = Pele.icone("cross") if i in erradas else null
		b.toggle_mode = true
		grid.add_child(b)
		opcoes.append(b)
	feedback = label(dica if dica != "" else "Escolha uma alternativa e confirme seu ataque.", 18, Color("#e8b76d") if dica != "" else Color("#d2b28c"))
	v.add_child(feedback)
	confirmar = botao("Confirmar ataque", func(): resposta_confirmada.emit(selecionada))
	confirmar.disabled = true
	v.add_child(confirmar)

func selecionar(indice: int) -> void:
	selecionada = indice
	for i in range(opcoes.size()):
		opcoes[i].set_pressed_no_signal(i == indice)
		opcoes[i].icon = Pele.icone("check") if i == indice else (Pele.icone("cross") if opcoes[i].disabled else null)
	confirmar.disabled = confirmacao_bloqueada or selecionada < 0

func bloquear() -> void:
	for b in opcoes:
		b.disabled = true
	confirmar.disabled = true
	feedback.text = "O ataque foi lançado…"
	objetivo.text = "O ataque foi lançado…"
	painel.hide()

func resultado(explicacao: String) -> void:
	var v = cartao(Vector2(220, 160), 840)
	v.add_child(label("GOLPE CRÍTICO!", 34, Color("#f7d993")))
	v.add_child(label("Guardião derrotado. Uma nova área foi liberada!", 21, cor))
	v.add_child(label(explicacao, 24))
	v.add_child(botao("Continuar exploração  →", func(): continuar.emit()))

func derrota(fase: int) -> void:
	var v = cartao(Vector2(270, 180), 740, true)
	v.add_child(label("FIM DE JOGO", 40, Color("#f48c96")))
	v.add_child(label("Seus corações acabaram. As dicas ajudam na próxima tentativa! Reinicie a fase %d com três corações." % (fase + 1), 24))
	v.add_child(botao("Tentar fase novamente", func(): reiniciar.emit()))
	v.add_child(botao("Menu / trocar personagem e arma", func(): voltar_menu.emit()))

func vitoria(explicacao: String = "") -> void:
	var v = cartao(Vector2(250, 160), 780, true)
	v.add_child(label("AS RUÍNAS ESTÃO LIVRES", 36, Color("#f7d993")))
	v.add_child(label("6 guardiões e o chefe derrotados  /  3 fases concluídas", 23, cor))
	v.add_child(label("Você praticou conceitos, coeficientes e expansões até o grau 3. Continue aprendendo com cada tentativa!", 25))
	if explicacao != "":
		v.add_child(label(explicacao, 16))
	v.add_child(botao("Jogar novamente / escolher personagem", func(): voltar_menu.emit()))

func inicial() -> void:
	limpar()
	ocultar_popup_critico()
	etapa_menu = "inicio"
	camada = Control.new()
	camada.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(camada)
	var fundo = Control.new()
	fundo.set_script(preload("res://scripts/fundo_menu.gd"))
	camada.add_child(fundo)
	var titulo = label("Ruínas do Binômio", 36, Color("#ffe4a1"))
	titulo.add_theme_font_size_override("font_size", 64)
	titulo.add_theme_color_override("font_shadow_color", Color("#211125"))
	titulo.add_theme_constant_override("shadow_offset_x", 4)
	titulo.add_theme_constant_override("shadow_offset_y", 5)
	titulo.position = Vector2(40, 70)
	titulo.size = Vector2(1200, 100)
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.autowrap_mode = TextServer.AUTOWRAP_OFF
	camada.add_child(titulo)
	conteudo_inicio = Control.new()
	camada.add_child(conteudo_inicio)
	pagina_inicio()

func limpar_pagina_inicio() -> void:
	for filho in conteudo_inicio.get_children():
		conteudo_inicio.remove_child(filho)
		filho.queue_free()

func painel_inicio(titulo: String, largura: float = 600) -> VBoxContainer:
	limpar_pagina_inicio()
	var caixa = PanelContainer.new()
	caixa.theme = tema_pixel
	caixa.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	caixa.add_theme_stylebox_override("panel", Pele.painel())
	if Dispositivo.ativo(): largura = maxf(largura, 620)
	caixa.position = Vector2(1240 - largura, 210 if Dispositivo.ativo() else 228)
	caixa.size.x = largura
	caixa.custom_minimum_size.x = largura
	conteudo_inicio.add_child(caixa)
	var coluna = VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 14)
	if Dispositivo.ativo():
		adicionar_rolagem(caixa, coluna, 420)
	else:
		caixa.add_child(coluna)
	if titulo != "":
		coluna.add_child(label(titulo, 30, Color("#ffe4a1")))
	return coluna

func pagina_inicio() -> void:
	var v = painel_inicio("", 410)
	v.add_child(botao("Iniciar aventura", menu))
	v.add_child(botao("Tutorial", tutorial_inicio))
	v.add_child(botao("Opções", opcoes_inicio))
	v.add_child(botao("Créditos", creditos_inicio))
	(v.get_child(0) as Button).grab_focus()

func tutorial_inicio() -> void:
	var v = painel_inicio("COMO JOGAR", 690)
	v.add_child(label("Joystick: mover. Botão à direita: atacar.\nTrês acertos carregam o círculo crítico.\nToque nele perto do guardião para responder.\nFuja do círculo vermelho para evitar dano.\nNo chefe, responda para desviar e contra-atacar." if Dispositivo.ativo() else "WASD ou setas: mover pelo mapa.\nEspaço ou clique: atacar com espada ou arco.\nAcerte três golpes para carregar o crítico.\nAproxime-se do inimigo e aperte E.\nResponda à pergunta: acertou, crítico fatal!\nErrou? Leia a dica e tente de novo.\nFuja do círculo vermelho para evitar dano.\nDerrote guardiões para abrir os portões.", 16))
	v.add_child(botao("Voltar", pagina_inicio))

func opcoes_inicio() -> void:
	var v = painel_inicio("OPÇÕES", 590)
	for tipo in ["Música", "Efeitos"]:
		var legenda = label(tipo + "  %d%%" % int((volume_musica if tipo == "Música" else volume_efeitos) * 100), 16)
		v.add_child(legenda)
		var slider = HSlider.new()
		slider.theme = tema_pixel
		slider.min_value = 0
		slider.max_value = 1
		slider.step = 0.01
		slider.value = volume_musica if tipo == "Música" else volume_efeitos
		slider.custom_minimum_size = Vector2(0, 64 if Dispositivo.ativo() else 32)
		slider.value_changed.connect(func(valor: float):
			legenda.text = tipo + "  %d%%" % int(valor * 100)
			if tipo == "Música":
				volume_musica = valor
			else:
				volume_efeitos = valor
			audio_alterado.emit(volume_musica, volume_efeitos)
		)
		v.add_child(slider)
	var tela = CheckButton.new()
	tela.theme = tema_pixel
	if Dispositivo.ativo():
		tela.add_theme_font_size_override("font_size", 24)
		tela.custom_minimum_size.y = 72
	tela.text = "Tela cheia"
	tela.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	tela.toggled.connect(func(ativa: bool): DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if ativa else DisplayServer.WINDOW_MODE_WINDOWED))
	v.add_child(tela)
	v.add_child(label("As opções são mantidas durante esta sessão.", 16))
	v.add_child(botao("Voltar", pagina_inicio))

func creditos_inicio() -> void:
	var v = painel_inicio("CRÉDITOS", 760)
	v.add_child(label("Ruínas do Binômio — aventura de matemática.\nHeróis e monstros: CraftPix.\nInterface: Pixel UI Free, de heyheythere (CC BY 4.0).\nCenário do jogo: DungeonTale, de NullTale.\nCenário do menu: Fort of Illusion (kit fornecido).\nEspadas: lukesharples. Arco: omerbhatti34.\nMúsica e imagens originais: fornecidas pela equipe.\nLicenças e origens estão nas pastas dos recursos.", 16))
	v.add_child(botao("Voltar", pagina_inicio))

func hud_visivel(ativo: bool, chefe: bool = false) -> void:
	for no in get_children():
		if no is CanvasItem and no != camada and no != cinema and no != popup_critico:
			no.visible = ativo
			if (chefe or Dispositivo.ativo()) and no is Control and no.position.y >= 642:
				no.hide()
	if Dispositivo.ativo():
		botao_critico.hide()
		vidas_label.position = Vector2(1030, 78)
		vidas_label.size = Vector2(210, 40)
		if not chefe and ativo:
			carga_label.show()
			barra_critico.show()
	ocultar_popup_critico()

func criar_cinema() -> void:
	encerrar_cinema()
	limpar()
	hud_visivel(false)
	cinema = Control.new()
	cinema.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(cinema)
	cortina = ColorRect.new()
	cortina.color = Color.BLACK
	cortina.size = Vector2(1280, 720)
	cinema.add_child(cortina)
	frase_cinema = label("", 32)
	frase_cinema.position = Vector2(80, 280)
	frase_cinema.size = Vector2(1120, 150)
	frase_cinema.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	frase_cinema.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cinema.add_child(frase_cinema)
	titulo_chefe = label("", 32, Color("#e3bcff"))
	titulo_chefe.add_theme_font_size_override("font_size", 48)
	titulo_chefe.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo_chefe.autowrap_mode = TextServer.AUTOWRAP_OFF
	titulo_chefe.position = Vector2(30, 760)
	titulo_chefe.size = Vector2(1220, 100)
	cinema.add_child(titulo_chefe)

func encerrar_cinema() -> void:
	if is_instance_valid(cinema):
		cinema.hide()
		cinema.queue_free()
	cinema = null

func atualizar_chefe(etapa: int, vidas: int) -> void:
	atualizar(2, 0, vidas, get_parent().arma, get_parent().personagem)
	topo.text = "FASE 3/3  /  %s  /  OLHOS %d/3" % [get_parent().chefe_batalha.NOME, etapa]
	objetivo.text = ["Neutralize o olho da mão esquerda.", "Neutralize o olho da mão direita.", "Último ataque: uma resposta errada será fatal!", "A ruína está livre!"][clampi(etapa, 0, 3)]
	hud_visivel(true, true)

func pergunta_chefe(dados: Dictionary, etapa: int, erradas: Array, dica: String = "") -> void:
	var v = cartao(Vector2(620, 120), 620)
	v.add_theme_constant_override("separation", 8)
	layout_chefe = true
	confirmacao_bloqueada = true
	v.add_child(label(["MÃO ESQUERDA", "MÃO DIREITA", "OLHO PRINCIPAL"][etapa], 16, Color("#e3bcff")))
	var enunciado = str(dados.enunciado).replace("DESAFIO FINAL: ", "")
	if Dispositivo.ativo(): enunciado = enunciado.replace("Quais coeficientes usamos para desenvolver ", "Coeficientes de ")
	v.add_child(label(enunciado, 16))
	var alternativas: Container = v
	if Dispositivo.ativo():
		var grade = GridContainer.new()
		grade.columns = 2
		grade.add_theme_constant_override("h_separation", 12)
		grade.add_theme_constant_override("v_separation", 10)
		v.add_child(grade)
		alternativas = grade
	for i in range(4):
		var b = botao("%s   %s" % [char(65 + i), dados.opcoes[i]], selecionar.bind(i))
		b.custom_minimum_size = Vector2(310, 80) if Dispositivo.ativo() else Vector2(0, 48)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.disabled = i in erradas
		b.icon = Pele.icone("cross") if b.disabled else null
		b.toggle_mode = true
		alternativas.add_child(b)
		opcoes.append(b)
	var texto = dica if dica != "" else "Escolha uma alternativa e confirme seu ataque."
	if etapa == 2:
		texto = "Último ataque: uma resposta errada será fatal!"
	feedback = label(texto, 16, Color("#ffb3bf") if etapa == 2 else Color("#f1d6a8"))
	v.add_child(feedback)
	confirmar = botao("Confirmar ataque", func(): resposta_confirmada.emit(selecionada))
	confirmar.disabled = true
	v.add_child(confirmar)

func liberar_confirmacao_chefe() -> void:
	if not layout_chefe or not is_instance_valid(confirmar): return
	confirmacao_bloqueada = false
	confirmar.disabled = selecionada < 0

func resultado_chefe(explicacao: String) -> void:
	var v = cartao(Vector2(620, 120), 620)
	v.add_child(label("OLHO NEUTRALIZADO!", 32, Color("#e3bcff")))
	v.add_child(label(explicacao, 16))
	v.add_child(botao("Continuar", func(): continuar.emit()))

func derrota_chefe() -> void:
	var v = cartao(Vector2(260, 180), 760, true)
	v.add_child(label("FIM DE JOGO", 32, Color("#ffb3bf")))
	v.add_child(label("Tente novamente com três corações. As duas mãos serão restauradas.", 20))
	v.add_child(botao("Tentar novamente", func(): reiniciar.emit()))
	v.add_child(botao("Menu principal", confirmar_saida_chefe))

func confirmar_saida_chefe() -> void:
	var v = cartao(Vector2(230, 180), 820, true)
	v.add_child(label("TEM CERTEZA?", 32))
	v.add_child(label("Seu progresso será perdido e você terá que recomeçar do início da ruína.", 22))
	v.add_child(botao("Continuar aqui", derrota_chefe))
	v.add_child(botao("Sair para o menu", func(): voltar_menu.emit()))

func preparar_historia() -> void:
	criar_cinema()
	cortina.color = Color.BLACK
	fundo_historia = Control.new()
	fundo_historia.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fundo_historia.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	cinema.add_child(fundo_historia)
	imagem_historia = Sprite2D.new()
	imagem_historia.centered = false
	imagem_historia.scale = Vector2(4, 4)
	imagem_historia.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	fundo_historia.add_child(imagem_historia)
	portas_historia = AnimatedSprite2D.new()
	portas_historia.sprite_frames = preload("res://assets/introducao/portas.tres")
	portas_historia.centered = false
	portas_historia.scale = Vector2(4, 4)
	portas_historia.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portas_historia.hide()
	fundo_historia.add_child(portas_historia)
	frase_cinema.hide()
	var fundo_legenda = ColorRect.new()
	fundo_legenda.color = Color(0.02, 0.01, 0.04, 0.88)
	fundo_legenda.position = Vector2(90, 500)
	fundo_legenda.size = Vector2(1100, 140)
	cinema.add_child(fundo_legenda)
	legenda_historia = label("", 16)
	legenda_historia.position = Vector2(114, 516)
	legenda_historia.size = Vector2(1052, 108)
	legenda_historia.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cinema.add_child(legenda_historia)
	var pular = botao("Pular introdução", func(): pular_historia.emit())
	pular.position = Vector2(974, 34)
	pular.size = Vector2(270, 48)
	cinema.add_child(pular)

func mostrar_arte_historia(etapa: int, duracao: float) -> void:
	imagem_historia.visible = etapa < 2
	portas_historia.visible = etapa == 2
	if etapa < 2:
		imagem_historia.texture = load("res://assets/introducao/%s.png" % ["01_selos", "02_despertar"][etapa])
	else:
		portas_historia.speed_scale = 4.0 / duracao
		portas_historia.stop()
		portas_historia.play("abrir")
func adicionar_rolagem(caixa: PanelContainer, coluna: VBoxContainer, altura: float) -> void:
	var rolagem = ScrollContainer.new()
	rolagem.theme = tema_pixel
	rolagem.custom_minimum_size = Vector2(0, altura)
	rolagem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	rolagem.follow_focus = true
	caixa.add_child(rolagem)
	coluna.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rolagem.add_child(coluna)