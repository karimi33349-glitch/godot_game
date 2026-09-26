extends Control

const LEVEL_ITEM = preload("res://Scenes/PageLevels/LevelItem.tscn")

var game_data: Dictionary = {}

@onready var levels_root: VBoxContainer = $CenterContainer/RootLevels


func _ready() -> void:
	load_game_data()
	create_level_buttons()


func load_game_data() -> void:
	var file := FileAccess.open("res://Data/GAME.json", FileAccess.READ)
	if file == null:
		push_error("ShowLevels: GAME.json not found")
		return

	var json := JSON.new()
	var error := json.parse(file.get_as_text())
	file.close()

	if error != OK or typeof(json.data) != TYPE_DICTIONARY:
		push_error("ShowLevels: invalid GAME.json")
		return

	game_data = json.data


func create_level_buttons() -> void:
	for child in levels_root.get_children():
		child.queue_free()

	if not game_data.has("chapters"):
		return

	var chapters: Array = game_data["chapters"]
	var current_chapter_index := GameState.current_chapter

	if current_chapter_index < 0 or current_chapter_index >= chapters.size():
		return

	var chapter: Dictionary = chapters[current_chapter_index]
	var chapter_index := int(chapter.get("id", current_chapter_index + 1)) - 1
	var levels: Array = chapter.get("levels", [])
	var row: HBoxContainer

	for i in range(levels.size()):
		if i % 4 == 0:
			row = HBoxContainer.new()
			row.alignment = BoxContainer.ALIGNMENT_CENTER
			row.add_theme_constant_override("separation", 12)
			levels_root.add_child(row)

		var level_data: Dictionary = levels[i]
		var item = LEVEL_ITEM.instantiate()
		item.custom_minimum_size = Vector2(50, 50)
		row.add_child(item)

		var locked := not SaveManager.is_level_unlocked(chapter_index, i)
		item.setup(int(level_data.get("id", i + 1)), locked, chapter_index, i)
		item.pressed.connect(_on_level_pressed)


func _on_level_pressed(chapter_index: int, level_index: int) -> void:
	if not SaveManager.is_level_unlocked(chapter_index, level_index):
		return

	GameState.set_level(chapter_index, level_index)
	SceneManager.change_scene("res://Scenes/Game/GameScene.tscn")
