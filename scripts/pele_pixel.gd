extends RefCounted

const RAIZ = "res://addons/pixel_ui/"
static var tema_cache: Theme

static func tema() -> Theme:
	if tema_cache != null:
		return tema_cache
	tema_cache = (load(RAIZ + "themes/wood.tres") as Theme).duplicate(true)
	var fonte = (load("res://assets/font/pixel_portugues.fnt") as FontFile).duplicate(true)
	# O atlas original cobre ASCII; manter português e matemática via fallback.
	var reservas: Array[Font] = [ThemeDB.fallback_font]
	fonte.fallbacks = reservas
	tema_cache.default_font = fonte
	tema_cache.default_font_size = 16
	var vistos: Dictionary = {}
	for tipo in tema_cache.get_type_list():
		for nome in tema_cache.get_stylebox_list(tipo):
			var estilo = tema_cache.get_stylebox(nome, tipo)
			if not estilo is StyleBoxTexture or vistos.has(estilo.get_instance_id()):
				continue
			vistos[estilo.get_instance_id()] = true
			for lado in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
				estilo.set_texture_margin(lado, estilo.get_texture_margin(lado) * 2)
				estilo.set_content_margin(lado, estilo.get_content_margin(lado) * 2)
	return tema_cache

static func painel(interno: bool = false) -> StyleBoxTexture:
	var tipo = "InsetPanel" if interno else "PanelContainer"
	var estilo = tema().get_stylebox("panel", tipo).duplicate() as StyleBoxTexture
	estilo.content_margin_left = 16 if interno else 24
	estilo.content_margin_right = 16 if interno else 24
	estilo.content_margin_top = 14 if interno else 18
	estilo.content_margin_bottom = 14 if interno else 18
	return estilo

static func tamanho(pedido: int) -> int:
	return 32 if pedido >= 26 else (24 if preload("res://scripts/dispositivo.gd").ativo() else 16)

static func icone(nome: String) -> Texture2D:
	return load(RAIZ + "icons/" + nome + ".png") as Texture2D
