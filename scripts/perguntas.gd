extends RefCounted

static func todas() -> Array:
	return [
		{"enunciado": "Em (x + 2)², quais são A, B e n?", "opcoes": ["A = x, B = 2, n = 2", "A = 2, B = 2, n = x", "A = x, B = 2, n = 1", "A = x², B = 4, n = 2"], "correta": 0, "dica": "Compare com (A + B)ⁿ. O expoente fica fora dos parênteses.", "explicacao": "Em (A + B)ⁿ, A = x, B = 2 e n = 2. O expoente determina o grau da expansão."},
		{"enunciado": "Quais são os coeficientes de (A + B)²?", "opcoes": ["1, 1, 1", "1, 2, 1", "1, 3, 1", "2, 2, 2"], "correta": 1, "dica": "O termo do meio vem de AB + BA.", "explicacao": "(A + B)² = A² + 2AB + B². Os coeficientes são 1, 2 e 1."},
		{"enunciado": "Qual é a expansão de (x + 3)²?", "opcoes": ["x² + 9", "x² + 3x + 9", "x² + 6x + 9", "x² + 6x + 6"], "correta": 2, "dica": "Use A² + 2AB + B² com A = x e B = 3.", "explicacao": "x² + 2·x·3 + 3² = x² + 6x + 9. Não se esqueça do termo do meio!"},
		{"enunciado": "Quais são os coeficientes de (A + B)³?", "opcoes": ["1, 2, 2, 1", "1, 3, 3, 1", "1, 3, 1", "1, 4, 4, 1"], "correta": 1, "dica": "A linha de grau 3 de Pascal tem quatro números.", "explicacao": "(A + B)³ = A³ + 3A²B + 3AB² + B³. Os coeficientes são 1, 3, 3 e 1."},
		{"enunciado": "Qual é o termo em x² na expansão de (x + 2)³?", "opcoes": ["2x²", "3x²", "12x²", "6x²"], "correta": 3, "dica": "O termo procurado é 3A²B. Use A = x e B = 2.", "explicacao": "3A²B = 3·x²·2 = 6x². A expansão completa é x³ + 6x² + 12x + 8."},
		{"enunciado": "Qual é a expansão de (x − 1)³?", "opcoes": ["x³ − 3x² + 3x − 1", "x³ − 1", "x³ + 3x² + 3x + 1", "x³ − 3x² − 3x − 1"], "correta": 0, "dica": "Use B = −1. Potências pares de −1 são positivas; ímpares são negativas.", "explicacao": "x³ + 3x²(−1) + 3x(−1)² + (−1)³ = x³ − 3x² + 3x − 1."},
		{"enunciado": "Quais são os coeficientes de (A + B)⁴?", "opcoes": ["1, 3, 3, 1", "1, 4, 4, 4, 1", "1, 4, 6, 4, 1", "1, 2, 6, 2, 1"], "correta": 2, "dica": "Some vizinhos da linha 1, 3, 3, 1 e coloque 1 nas pontas.", "explicacao": "A linha de grau 4 é 1, 4, 6, 4, 1. Ela multiplica A⁴, A³B, A²B², AB³ e B⁴."},
		{"enunciado": "Qual é o termo em x² na expansão de (x − 2)⁴?", "opcoes": ["−24x²", "24x²", "6x²", "−12x²"], "correta": 1, "dica": "O termo é 6A²B². Aqui, B² = (−2)² = 4.", "explicacao": "6·x²·(−2)² = 6·x²·4 = 24x². O expoente par torna o sinal positivo."},
		{"enunciado": "DESAFIO FINAL: qual é a expansão de (x − 1)⁴?", "opcoes": ["x⁴ − 4x³ − 6x² − 4x + 1", "x⁴ − 1", "x⁴ + 4x³ + 6x² + 4x + 1", "x⁴ − 4x³ + 6x² − 4x + 1"], "correta": 3, "dica": "Combine 1, 4, 6, 4, 1 com as potências de −1: os sinais alternam.", "explicacao": "x⁴ + 4x³(−1) + 6x²(−1)² + 4x(−1)³ + (−1)⁴ = x⁴ − 4x³ + 6x² − 4x + 1."}
	]
