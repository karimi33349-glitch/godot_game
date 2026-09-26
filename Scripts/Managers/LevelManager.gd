extends Node

signal level_started(level_data: Dictionary)
signal level_changed(chapter_index: int, level_index: int)

@export_file("*.json") var game_file := "res://Data/GAME.json"

var game_data: Dictionary = {}


func _ready() -> void:
	load_game_data()


func load_game_data() -> void:
	var file := FileAccess.open(game_file, FileAccess.READ)
	if file == null:
		push_error("LevelManager: GAME.json not found: " + game_file)
		return

	var json := JSON.new()
	var error := json.parse(file.get_as_text())
	file.close()

	if error != OK:
		push_error("LevelManager: JSON error: " + json.get_error_message())
		return

	if typeof(json.data) != TYPE_DICTIONARY or not json.data.has("chapters"):
		push_error("LevelManager: GAME.json has no valid 'chapters'.")
		return

	game_data = json.data


func generate_letters(answers: Array) -> Array:
	var longest := ""

	for word in answers:
		var value := str(word)
		if value.length() > longest.length():
			longest = value

	var letters: Array = []
	for character in longest:
		letters.append(character)

	letters.shuffle()
	return letters


func has_next_level() -> bool:
	if game_data.is_empty():
		return false

	var chapters: Array = game_data.get("chapters", [])
	var chapter_index := GameState.current_chapter
	var level_index := GameState.current_level

	if chapter_index < 0 or chapter_index >= chapters.size():
		return false

	var levels: Array = chapters[chapter_index].get("levels", [])
	if level_index < 0 or level_index >= levels.size():
		return false

	if level_index < levels.size() - 1:
		return true

	return chapter_index < chapters.size() - 1


func start_level(chapter: int, level: int) -> void:
	if not _is_valid_level(chapter, level):
		push_error("LevelManager: Invalid level %d/%d" % [chapter, level])
		return

	GameState.set_level(chapter, level)

	var level_data: Dictionary = game_data["chapters"][chapter]["levels"][level]

	level_started.emit(level_data)
	level_changed.emit(chapter, level)


func next_level() -> void:
	if game_data.is_empty():
		return

	var chapters: Array = game_data["chapters"]
	var chapter := GameState.current_chapter
	var level := GameState.current_level

	if chapter < 0 or chapter >= chapters.size():
		return

	var levels: Array = chapters[chapter]["levels"]

	if level < levels.size() - 1:
		start_level(chapter, level + 1)
		return

	if chapter < chapters.size() - 1:
		start_level(chapter + 1, 0)
		return

	print("Game Finished")


func restart() -> void:
	start_level(GameState.current_chapter, GameState.current_level)


func get_current_level() -> Dictionary:
	if not _is_valid_level(GameState.current_chapter, GameState.current_level):
		return {}
	return game_data["chapters"][GameState.current_chapter]["levels"][GameState.current_level]


func get_current_chapter() -> Dictionary:
	if game_data.is_empty():
		return {}

	var chapters: Array = game_data.get("chapters", [])
	if GameState.current_chapter < 0 or GameState.current_chapter >= chapters.size():
		return {}

	return chapters[GameState.current_chapter]


func _is_valid_level(chapter: int, level: int) -> bool:
	if game_data.is_empty() or not game_data.has("chapters"):
		return false

	var chapters: Array = game_data["chapters"]
	if chapter < 0 or chapter >= chapters.size():
		return false

	var levels: Array = chapters[chapter].get("levels", [])
	return level >= 0 and level < levels.size()
