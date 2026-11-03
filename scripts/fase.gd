extends Node2D

var campo_a: LineEdit
var campo_b: LineEdit
var mensagem: Label
@onready var player = $Player
@onready var piramide = $Piramide
@onready var porta = $Porta

func _ready() -> void:
	porta.body_entered.connect(_on_porta_body_entered)
	criar_interface()

func criar_interface() -> void:
	var camada = CanvasLayer.new()
	add_child(camada)
	var painel = PanelContainer.new()
	painel.position = Vector2(20, 20)
	camada.add_child(painel)
	var organizacao = VBoxContainer.new()
	painel.add_child(organizacao)
	var titulo = Label.new()
	titulo.text = "BINÔMIO DE NEWTON — PROTÓTIPO"
	organizacao.add_child(titulo)
	campo_a = criar_campo(organizacao, "Valor de A:", "2")
	campo_b = criar_campo(organizacao, "Valor de B:", "3")
	var botao = Button.new()
	botao.text = "Gerar pirâmide"
	botao.focus_mode = Control.FOCUS_NONE
	organizacao.add_child(botao)
	botao.pressed.connect(gerar_piramide)
	mensagem = Label.new()
	mensagem.text = "Digite A e B. A/D ou setas: andar. Espaço/W/↑: pular."
	organizacao.add_child(mensagem)
	var reiniciar = Button.new()
	reiniciar.text = "Reiniciar fase"
	reiniciar.focus_mode = Control.FOCUS_NONE
	reiniciar.pressed.connect(func(): get_tree().reload_current_scene())
	organizacao.add_child(reiniciar)

func criar_campo(pai: VBoxContainer, texto: String, padrao: String) -> LineEdit:
	var linha = HBoxContainer.new()
	pai.add_child(linha)
	var label = Label.new()
	label.text = texto
	linha.add_child(label)
	var campo = LineEdit.new()
	campo.text = padrao
	campo.max_length = 3
	campo.custom_minimum_size.x = 100
	linha.add_child(campo)
	return campo

func gerar_piramide() -> void:
	if not campo_a.text.is_valid_int() or not campo_b.text.is_valid_int():
		mensagem.text = "A e B precisam ser números inteiros."
		return
	var a = int(campo_a.text)
	var b = int(campo_b.text)
	if not piramide.gerar(a, b):
		mensagem.text = "Use A e B não negativos, com soma entre 1 e 12."
		return
	campo_a.release_focus()
	campo_b.release_focus()
	mensagem.text = "Pirâmide com %d linhas. Clique fora do painel para posicionar." % (a + b)

func _on_porta_body_entered(body: Node2D) -> void:
	if body == player:
		mensagem.text = "PARABÉNS! VOCÊ COMPLETOU A FASE!"
		player.set_physics_process(false)
		player.set_process_unhandled_key_input(false)
