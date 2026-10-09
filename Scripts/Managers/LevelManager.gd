extends Node

signal level_started(level_data)
signal level_changed(chapter_index, level_index)

@export var game_file := "res://Data/GAME.json"

var game_data:Dictionary = {}


func _ready():
	load_game_data()


func load_game_data():

	var file = FileAccess.open(game_file, FileAccess.READ)

	if file == null:
		push_error("GAME.json not found")
		return

	var json = JSON.new()

	if json.parse(file.get_as_text()) != OK:
		push_error(json.get_error_message())
		return

	file.close()

	game_data = json.get_data()

func generate_letters(answers:Array)->Array:

	var longest := ""

	for word in answers:
		if word.length() > longest.length():
			longest = word

	var letters := []

	for c in longest:
		letters.append(c)

	letters.shuffle()

	return letters

func has_next_level() -> bool:

	if game_data.is_empty():
		return false


	var chapters: Array = (
		game_data["chapters"]
	)


	var chapter := GameState.current_chapter
	var level := GameState.current_level


	var levels: Array = (
		chapters[chapter]["levels"]
	)


	# مرحله بعد در همین فصل
	if level < levels.size() - 1:

		return true


	# فصل بعد وجود دارد
	if chapter < chapters.size() - 1:

		return true


	return false
	
func start_level(chapter:int, level:int):

	GameState.set_level(chapter, level)

	var level_data = game_data["chapters"][chapter]["levels"][level]

	level_started.emit(level_data)

	level_changed.emit(chapter, level)


func next_level():

	var levels = game_data["chapters"][GameState.current_chapter]["levels"]

	# مرحله بعد در همین فصل
	if GameState.current_level < levels.size() - 1:

		start_level(
			GameState.current_chapter,
			GameState.current_level + 1
		)

	# پایان فصل
	else:

		# اگر فصل آخر بود
		if GameState.current_chapter >= game_data["chapters"].size() - 1:

			print("Game Finished")
			return

		# اولین مرحله فصل بعد
		start_level(
			GameState.current_chapter + 1,
			0
		)
		
func restart():

	start_level(GameState.current_chapter,GameState.current_level)


func get_current_level():

	return game_data["chapters"][GameState.current_chapter]["levels"][GameState.current_level]


func get_current_chapter():

	return game_data["chapters"][GameState.current_chapter]
