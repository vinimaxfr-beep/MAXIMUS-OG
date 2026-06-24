extends Node

const PLAYER_NAME := "Boina"
const TEXT_SPEED := 0.02
const FADE_SPEED := 1.5

var paragraphs = [
	{"text": "Escute,[wait=0.67] %s…" % PLAYER_NAME, "audio": "res://Assets/Audios/paragrafo_ (1).ogg"},

	{"text": "Antes do seu primeiro passo…[wait=2.55]\nhouve um [shake]fim[/shake].", "audio": "res://Assets/Audios/paragrafo_ (2).ogg"},

	{"text": "Um homem chamado [b]Maximus[/b].[wait=2.7]\nUm gladiador conhecido não só pela força…[wait=0.5]\nmas pela presença.\nNa arena… ele não lutava apenas para vencer…[wait=0.6]\nlutava como se cada batalha fosse [b]eterna[/b].\nE um dia…[wait=0.5]\ncomo todos os guerreiros… ele caiu.", "audio": "res://Assets/Audios/paragrafo_ (3).ogg"},

	{"text": "Mas algumas histórias…[wait=1.0]\nse recusam a terminar.\n\nAlgo permaneceu.[wait=0.6]\nUma vontade antiga… persistente…\nUm desejo que atravessa o tempo…[wait=0.5]\nmantendo o conflito vivo… de formas que poucos conseguem perceber.", "audio": "res://Assets/Audios/paragrafo_ (4).ogg"},

	{"text": "E agora… você.[wait=1.0]\n\n%s…" % PLAYER_NAME, "audio": "res://Assets/Audios/paragrafo_ (5).ogg"},

	{"text": "Mais um entre tantos que foram levados à arena.\nMais um nome que poderia ser esquecido…[wait=0.5]\ncomo tantos outros.", "audio": "res://Assets/Audios/paragrafo_ (6).ogg"},

	{"text": "Mas há algo [b]diferente[/b].[wait=0.8]\n\nEnquanto outros aceitam seu destino…\nvocê [shake]questiona[/shake].\n\nEnquanto outros olham apenas para frente…\nvocê percebe o que está ao redor.", "audio": "res://Assets/Audios/paragrafo_ (7).ogg"},

	{"text": "E então surge uma ideia…[wait=1.0]\n\n\"E se houver uma [b]saída[/b]?\"", "audio": "res://Assets/Audios/paragrafo_ (8).ogg"},

	{"text": "Não algo óbvio.\nNão algo entregue facilmente.[wait=0.5]\nMas algo que precisa ser entendido…\nreunido… descoberto aos poucos.", "audio": "res://Assets/Audios/paragrafo_ (9).ogg"},

	{"text": "Sua jornada começa.[wait=1.0]\n\nVocê começará a caminhar.\nPor caminhos antigos… inimigos inevitáveis… tarefas importantes…\nsalas que parecem guardar histórias… mesmo em silêncio.\nMecanismos… símbolos… marcas…\nfragmentos de algo maior… esperando para serem compreendidos.", "audio": "res://Assets/Audios/paragrafo_ (10).ogg"},

	{"text": "Ao longo do caminho… você encontrará desafios.\nAlguns exigirão [b]habilidade[/b].\nOutros… atenção.\nE alguns… apenas paciência para enxergar além do que está na superfície.", "audio": "res://Assets/Audios/paragrafo_ (11).ogg"},

	{"text": "Nem tudo estará escondido.\nMas nem tudo estará completo.\n\nCertas coisas vão parecer pequenas demais para importar.\nOutras… importantes demais para ignorar.", "audio": "res://Assets/Audios/paragrafo_ (12).ogg"},

	{"text": "Cada passo seu constrói algo.\nMesmo quando você não percebe.\n\nE quanto mais você avança…\nmais o mundo ao seu redor parece se conectar.\n\nComo peças de um grande desenho…\nque só faz sentido quando visto por inteiro.", "audio": "res://Assets/Audios/paragrafo_ (13).ogg"},

	{"text": "No final…[wait=1.0]\n\nSempre existe um final.\n\nUm caminho que leva para fora.\nUma chance de deixar tudo isso para trás.", "audio": "res://Assets/Audios/paragrafo_ (14).ogg"},

	{"text": "Mas…[wait=0.8]\nisso depende daquilo que foi vivido.\n\nDo que foi visto…\ndo que foi entendido…\ne, principalmente… do que foi levado consigo.", "audio": "res://Assets/Audios/paragrafo_ (15).ogg"},

	{"text": "Então siga, %s…\n\nExplore.\nObserve.\nReflita." % PLAYER_NAME, "audio": "res://Assets/Audios/paragrafo_ (16).ogg"},

	{"text": "Porque, neste lugar…\no que você ignora… pode ser tão importante quanto o que você encontra.", "audio": "res://Assets/Audios/paragrafo_ (17).ogg"},

	{"text": "E quando chegar a hora de partir…\npergunte a si mesmo:\n\n\"Será que eu realmente compreendi tudo o que estava diante de mim?\"", "audio": "res://Assets/Audios/paragrafo_ (18).ogg"},

	{"text": "Agora vá.[wait=1.0]\n\nA sua jornada já começou…\n\n[shake]Acorde[/shake], %s!" % PLAYER_NAME, "audio": "res://Assets/Audios/paragrafo_ (19).ogg"},
]

@onready var subtitle_label:RichTextLabel = $SubtitleLabel
@onready var skip_button: Button = $SkipButton
@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer

var current_index := 0
var can_skip := false
var is_typing := false
var full_text := ""

var shaking := false
var base_position := Vector2.ZERO

func _ready():
	skip_button.visible = false
	subtitle_label.modulate.a = 0.0
	subtitle_label.bbcode_enabled = true

	base_position = subtitle_label.position

	audio_player.finished.connect(_on_audio_finished)
	skip_button.pressed.connect(_on_skip_pressed)

	_play_paragraph(0)

func _process(delta):
	if shaking:
		subtitle_label.position = base_position + Vector2(randf_range(-2,2), randf_range(-2,2))
	else:
		subtitle_label.position = base_position

func _play_paragraph(index):
	if index >= paragraphs.size():
		_end_cutscene()
		return

	current_index = index
	can_skip = false
	is_typing = true
	skip_button.visible = false

	full_text = paragraphs[index]["text"]
	subtitle_label.text = ""

	await _fade_in()

	audio_player.stream = load(paragraphs[index]["audio"])
	audio_player.play()

	await _type_text(full_text)

func _type_text(text):
	var i := 0

	while i < text.length():
		if not is_typing:
			subtitle_label.text = _clean_text(text)
			return

		if text[i] == "[":
			var end = text.find("]", i)
			if end != -1:
				var tag = text.substr(i, end - i + 1)

				if tag.begins_with("[wait="):
					var time = float(tag.replace("[wait=", "").replace("]", ""))
					await get_tree().create_timer(time).timeout

				elif tag == "[shake]":
					shaking = true

				elif tag == "[/shake]":
					shaking = false

				i = end + 1
				continue

		if text.substr(i, 3) == "[b]":
			subtitle_label.append_text("[b]")
			i += 3
			continue
		elif text.substr(i, 4) == "[/b]":
			subtitle_label.append_text("[/b]")
			i += 4
			continue

		subtitle_label.append_text(text[i])
		i += 1

		await get_tree().create_timer(TEXT_SPEED).timeout

func _clean_text(text):
	var result = text
	result = result.replace("[shake]", "").replace("[/shake]", "")

	while result.find("[wait=") != -1:
		var start = result.find("[wait=")
		var end = result.find("]", start)
		result = result.substr(0, start) + result.substr(end + 1)

	return result

func _fade_in():
	while subtitle_label.modulate.a < 1.0:
		subtitle_label.modulate.a += FADE_SPEED * get_process_delta_time()
		await get_tree().process_frame

func _fade_out():
	while subtitle_label.modulate.a > 0.0:
		subtitle_label.modulate.a -= FADE_SPEED * get_process_delta_time()
		await get_tree().process_frame

func _on_audio_finished():
	can_skip = true
	skip_button.visible = true

	if is_typing:
		is_typing = false
		subtitle_label.text = _clean_text(full_text)

func _on_skip_pressed():
	_try_skip()

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		_try_skip()

func _try_skip():
	if not can_skip:
		return

	can_skip = false
	skip_button.visible = false

	await _fade_out()
	_play_paragraph(current_index + 1)

func _end_cutscene():
	await _fade_out()
	subtitle_label.visible = false
	skip_button.visible = false
	get_tree().change_scene_to_file("res://Scenes/fase_teste.tscn")
