extends Control

@onready var chapter_box: VBoxContainer = $VBoxContainer

var game_data: Dictionary = {}
var text_font: FontFile = preload("res://fonts/Lalezar-Regular.ttf")


func _ready() -> void:
	load_game_data()
	create_chapters()


func load_game_data() -> void:
	var file := FileAccess.open("res://Data/GAME.json", FileAccess.READ)
	if file == null:
		push_error("PageLevels: GAME.json not found")
		return

	var json := JSON.new()
	var error := json.parse(file.get_as_text())
	file.close()

	if error != OK or typeof(json.data) != TYPE_DICTIONARY:
		push_error("PageLevels: invalid GAME.json")
		return

	game_data = json.data


func create_chapters() -> void:
	for child in chapter_box.get_children():
		child.queue_free()

	var chapters: Array = game_data.get("chapters", [])
	var bg_texture: Texture2D = load("res://asset/open_level_now.png")
	if bg_texture == null:
		push_error("PageLevels: chapter background not found")
		return

	var texture_aspect := bg_texture.get_width() / float(bg_texture.get_height())
	var target_width := 800.0
	var target_height := target_width / texture_aspect

	for chapter_data in chapters:
		var chapter_id := int(chapter_data.get("id", 0))
		var chapter_name := str(chapter_data.get("title", ""))

		var panel := Panel.new()
		var panel_style := StyleBoxFlat.new()
		panel_style.bg_color = Color.TRANSPARENT
		panel.add_theme_stylebox_override("panel", panel_style)
		panel.custom_minimum_size = Vector2(target_width, target_height)
		panel.size = Vector2(target_width, target_height)
		panel.clip_contents = true
		chapter_box.add_child(panel)

		var bg := TextureRect.new()
		bg.texture = bg_texture
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(bg)

		var label := Label.new()
		label.text = "باب " + chapter_name
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_font_override("font", text_font)
		label.add_theme_font_size_override("font_size", 90)
		label.add_theme_color_override("font_color", Color(0.151, 0.082, 0.022, 1.0))
		label.add_theme_color_override("font_outline_color", Color(0.929, 0.867, 0.737, 1.0))
		label.add_theme_constant_override("outline_size", 20)
		panel.add_child(label)

		var button := Button.new()
		button.text = ""
		button.flat = true
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.pressed.connect(_on_chapter_pressed.bind(chapter_id, chapter_name))
		panel.add_child(button)


func _on_chapter_pressed(chapter_id: int, chapter_name: String) -> void:
	var chapter_index := chapter_id - 1
	GameState.set_chapter(chapter_index)
	SceneManager.change_scene("res://Scenes/PageLevels/ShowLevels.tscn")
