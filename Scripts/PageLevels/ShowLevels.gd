extends Control

const LEVEL_ITEM = preload(
	"res://Scenes/PageLevels/LevelItem.tscn"
)

var game_data: Dictionary = {}

@onready var levels_root: VBoxContainer = (
	$CenterContainer/RootLevels
)


func _ready():

	load_game_data()

	create_level_buttons()


# =========================================================
# LOAD JSON
# =========================================================

func load_game_data():

	var file := FileAccess.open(
		"res://Data/GAME.json",
		FileAccess.READ
	)

	if file == null:

		push_error(
			"GAME.json not found"
		)

		return


	var json := JSON.new()

	var error := json.parse(
		file.get_as_text()
	)

	file.close()


	if error != OK:

		push_error(
			json.get_error_message()
		)

		return


	game_data = json.data


# =========================================================
# CREATE LEVEL BUTTONS
# =========================================================

func create_level_buttons():

	for child in levels_root.get_children():
		child.queue_free()

	var chapter = null

	var current_chapter_index := (
		GameState.current_chapter
	)

	for c in game_data["chapters"]:

		var index := int(c["id"]) - 1

		if index == current_chapter_index:

			chapter = c
			break

	if chapter == null:

		push_error(
			"Chapter not found: "
			+ str(current_chapter_index)
		)

		return

	var chapter_index := (
		int(chapter["id"]) - 1
	)

	var row: HBoxContainer = null

	for i in range(chapter["levels"].size()):

		var unlocked := SaveManager.is_level_unlocked(
			chapter_index,
			i
		)

		print(
			"Chapter: ",
			chapter_index,
			" Level: ",
			i,
			" Unlocked: ",
			unlocked
		)
		if i % 4 == 0:

			row = HBoxContainer.new()

			row.alignment = (
				BoxContainer.ALIGNMENT_CENTER
			)
			
			row.add_theme_constant_override(
				"separation",
				12
			)

			levels_root.add_child(row)

		var level_data = chapter["levels"][i]

		var item = LEVEL_ITEM.instantiate()

		item.custom_minimum_size = Vector2(
			50,
			50
		)

		row.add_child(item)

		# فقط و فقط SaveManager
		var locked := not SaveManager.is_level_unlocked(
			chapter_index,
			i
		)

		item.setup(
			int(level_data["id"]),
			locked,
			chapter_index,
			i
		)

		item.pressed.connect(
			_on_level_pressed
		)


# =========================================================
# LEVEL CLICK
# =========================================================

func _on_level_pressed(
	chapter_index:int,
	level_index:int
):

	# اگر قفل است اصلاً وارد نشو
	if not SaveManager.is_level_unlocked(
		chapter_index,
		level_index
	):

		return


	GameState.set_level(
		chapter_index,
		level_index
	)


	get_tree().change_scene_to_file(
		"res://Scenes/Game/GameScene.tscn"
	)
