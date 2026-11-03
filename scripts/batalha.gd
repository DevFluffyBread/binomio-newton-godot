extends Node

signal respondida(acertou: bool)
var pergunta: Dictionary = {}
var erradas: Array[int] = []
var bloqueada = true

func iniciar(dados: Dictionary) -> void:
	pergunta = dados
	erradas.clear()
	bloqueada = false

func responder(indice: int) -> void:
	if bloqueada or indice < 0 or indice >= 4 or indice in erradas:
		return
	bloqueada = true
	var acertou: bool = indice == pergunta.correta
	if not acertou:
		erradas.append(indice)
	respondida.emit(acertou)
