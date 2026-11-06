extends RefCounted
static var forcar = false
static func ativo() -> bool:
	return forcar or "--touch" in OS.get_cmdline_user_args() or DisplayServer.is_touchscreen_available() or OS.has_feature("android") or OS.has_feature("ios")
