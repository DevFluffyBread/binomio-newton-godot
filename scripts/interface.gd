extends CanvasLayer

const VisualHeroi = preload("res://scripts/visual_heroi.gd")
signal personagem_escolhido(personagem: int)
signal trocar_personagem
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

func estilo(fundo: Color, borda: Color, raio: int = 12) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = fundo
	s.border_color = borda
	s.set_border_width_all(2)
	s.set_corner_radius_all(raio)
	s.content_margin_left = 20
	s.content_margin_right = 20
	s.content_margin_top = 14
	s.content_margin_bottom = 14
	return s

func label(texto: String, tamanho: int = 22, tinta: Color = Color("#eef2fb")) -> Label:
	var l = Label.new()
	l.text = texto
	l.add_theme_font_size_override("font_size", tamanho)
	l.add_theme_color_override("font_color", tinta)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l

func botao(texto: String, acao: Callable) -> Button:
	var b = Button.new()
	b.text = texto
	b.custom_minimum_size.y = 48
	b.add_theme_font_size_override("font_size", 20)
	b.add_theme_stylebox_override("normal", estilo(Color("#233248"), Color("#3b5268")))
	b.add_theme_stylebox_override("hover", estilo(Color("#30455a"), cor))
	b.add_theme_stylebox_override("pressed", estilo(Color("#345a60"), cor))
	b.add_theme_stylebox_override("focus", estilo(Color(0, 0, 0, 0), cor))
	b.add_theme_stylebox_override("disabled", estilo(Color("#18202e"), Color("#293244")))
	b.pressed.connect(acao)
	return b

func _ready() -> void:
	var barra = Panel.new()
	barra.position = Vector2(24, 20)
	barra.size = Vector2(1232, 82)
	barra.add_theme_stylebox_override("panel", estilo(Color("#151f30"), Color("#354355")))
	add_child(barra)
	topo = label("", 22)
	topo.position = Vector2(44, 33)
	topo.size = Vector2(830, 30)
	add_child(topo)
	vidas_label = label("", 27, Color("#f48c96"))
	vidas_label.position = Vector2(1030, 30)
	vidas_label.size = Vector2(210, 40)
	add_child(vidas_label)
	objetivo = label("", 15, Color("#a5b8ce"))
	objetivo.position = Vector2(44, 69)
	objetivo.size = Vector2(1100, 26)
	add_child(objetivo)
	var controles = label("WASD ou SETAS  MOVER EM QUATRO DIREÇÕES     •     Acerte para atacar. Errou? Leia a dica e tente outra vez.", 16, Color("#c6d1df"))
	controles.position = Vector2(30, 675)
	controles.size = Vector2(1220, 35)
	add_child(controles)

func atualizar(fase: int, mortos: int, vidas: int, arma: String, personagem: int = 1) -> void:
	cor = [Color("#74d9bd"), Color("#e8b76d"), Color("#bd9cff")][fase]
	topo.text = "FASE %d/3  —  MONSTROS %d/3     /     %s · %s" % [fase + 1, mortos, VisualHeroi.NOMES[personagem].to_upper(), arma.to_upper()]
	vidas_label.text = "♥ ".repeat(vidas) + "♡ ".repeat(3 - vidas)
	objetivo.text = "Portão de saída aberto! Siga para a direita para alcançar a próxima região." if mortos == 3 else "Explore a área liberada. Derrote seu guardião para abrir o próximo portão."

func limpar() -> void:
	if is_instance_valid(camada):
		camada.hide()
		camada.queue_free()
	opcoes.clear()
	selecionada = -1

func cartao(pos: Vector2, largura: float, escurecer: bool = false) -> VBoxContainer:
	limpar()
	camada = Control.new()
	camada.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(camada)
	if escurecer:
		var sombra = ColorRect.new()
		sombra.color = Color(0.025, 0.04, 0.08, 0.9)
		sombra.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		camada.add_child(sombra)
	painel = PanelContainer.new()
	painel.position = pos
	painel.custom_minimum_size.x = largura
	painel.size.x = largura
	painel.add_theme_stylebox_override("panel", estilo(Color("#162234"), cor))
	camada.add_child(painel)
	var coluna = VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 12)
	painel.add_child(coluna)
	return coluna

func menu() -> void:
	etapa_menu = "personagem"
	var v = cartao(Vector2(150, 116), 980, true)
	v.add_child(label("AS RUÍNAS DO BINÔMIO", 36, Color("#efbc66")))
	v.add_child(label("01 / ESCOLHA SEU PERSONAGEM", 18, cor))
	v.add_child(label("Três heróis. A mesma coragem para enfrentar os nove guardiões.", 20, Color("#a5b8ce")))
	var linha = HBoxContainer.new()
	linha.add_theme_constant_override("separation", 16)
	v.add_child(linha)
	for id in range(1, 4):
		var card = PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.add_theme_stylebox_override("panel", estilo(Color("#1d2b40"), Color("#364c61")))
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
	v.add_child(label("Depois, escolha espada ou arco. Todos os heróis têm as mesmas habilidades.\nWASD ou setas para explorar as salas • Três corações por fase", 17, Color("#a5b8ce")))

func menu_armas(personagem: int) -> void:
	etapa_menu = "arma"
	var v = cartao(Vector2(200, 102), 880, true)
	v.add_child(label("02 / ESCOLHA SUA ARMA", 30, Color("#efbc66")))
	v.add_child(label("SEU HERÓI: " + VisualHeroi.NOMES[personagem].to_upper(), 18, cor))
	var linha = HBoxContainer.new()
	linha.add_theme_constant_override("separation", 20)
	v.add_child(linha)
	for arma in ["espada", "arco"]:
		var card = PanelContainer.new()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.add_theme_stylebox_override("panel", estilo(Color("#1d2b40"), Color("#364c61")))
		linha.add_child(card)
		var coluna = VBoxContainer.new()
		card.add_child(coluna)
		var preview = VisualHeroi.previa(personagem, arma)
		preview.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		coluna.add_child(preview)
		coluna.add_child(botao("ESPADA / Corte rúnico" if arma == "espada" else "ARCO / Flecha de luz", arma_escolhida.emit.bind(arma)))
	v.add_child(label("O mesmo poder, dois estilos de ataque. Responda corretamente para desferir um golpe crítico! Cada erro custa um coração.", 20, Color("#a5b8ce")))
	v.add_child(botao("← Voltar aos personagens", func(): trocar_personagem.emit()))

func pergunta(dados: Dictionary, nome: String, erradas: Array, dica: String = "") -> void:
	var v = cartao(Vector2(150, 126), 980)
	v.add_child(label("ENCONTRO  /  " + nome.to_upper(), 16, cor))
	v.add_child(label(dados.enunciado, 27))
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 10)
	v.add_child(grid)
	for i in range(4):
		var b = botao("%s   %s" % [char(65 + i), dados.opcoes[i]], selecionar.bind(i))
		b.custom_minimum_size = Vector2(460, 54)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.disabled = i in erradas
		b.toggle_mode = true
		grid.add_child(b)
		opcoes.append(b)
	feedback = label(dica if dica != "" else "Escolha uma alternativa e confirme seu ataque.", 18, Color("#e8b76d") if dica != "" else Color("#a5b8ce"))
	v.add_child(feedback)
	confirmar = botao("Confirmar ataque", func(): resposta_confirmada.emit(selecionada))
	confirmar.disabled = true
	v.add_child(confirmar)

func selecionar(indice: int) -> void:
	selecionada = indice
	for i in range(opcoes.size()):
		opcoes[i].set_pressed_no_signal(i == indice)
	confirmar.disabled = false

func bloquear() -> void:
	for b in opcoes:
		b.disabled = true
	confirmar.disabled = true
	feedback.text = "O ataque foi lançado…"
	objetivo.text = "O ataque foi lançado…"
	painel.hide()

func resultado(explicacao: String) -> void:
	var v = cartao(Vector2(220, 160), 840)
	v.add_child(label("GOLPE CRÍTICO!", 34, Color("#efbc66")))
	v.add_child(label("Guardião derrotado. Uma nova área foi liberada!", 21, cor))
	v.add_child(label(explicacao, 24))
	v.add_child(botao("Continuar exploração  →", func(): continuar.emit()))

func derrota(fase: int) -> void:
	var v = cartao(Vector2(270, 180), 740, true)
	v.add_child(label("FIM DE JOGO", 40, Color("#f48c96")))
	v.add_child(label("Seus corações acabaram. As dicas ajudam na próxima tentativa! Reinicie a fase %d com três corações." % (fase + 1), 24))
	v.add_child(botao("Tentar fase novamente", func(): reiniciar.emit()))
	v.add_child(botao("Menu / trocar personagem e arma", func(): voltar_menu.emit()))

func vitoria() -> void:
	var v = cartao(Vector2(250, 160), 780, true)
	v.add_child(label("AS RUÍNAS ESTÃO LIVRES", 36, Color("#efbc66")))
	v.add_child(label("9 guardiões derrotados  /  3 fases concluídas", 23, cor))
	v.add_child(label("Você dominou coeficientes, termos e expansões até o grau 4. O verdadeiro golpe crítico foi aprender com cada tentativa.", 25))
	v.add_child(botao("Jogar novamente / escolher personagem", func(): voltar_menu.emit()))
