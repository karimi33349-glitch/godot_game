extends Control

signal pressed(chapter_index: int, level_index: int)

const NORMAL_TEXTURE = preload("res://asset/final2_bg_levels_button.png")
const LOCK_TEXTURE = preload("res://asset/Lock.png")
const FONT = preload("res://fonts/BTitrBd.ttf")

var chapter := 0
var level := 0

@onready var background: TextureRect = $Background
@onready var number: Label = $Number
@onready var click_area: Button = $ClickArea


func _ready() -> void:
	clip_contents = true
	custom_minimum_size = Vector2(50, 50)
	size = Vector2(50, 50)

	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE

	number.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	number.mouse_filter = Control.MOUSE_FILTER_IGNORE
	number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	number.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	number.add_theme_font_override("font", FONT)
	number.add_theme_font_size_override("font_size", 34)
	number.add_theme_color_override("font_color", Color("F8D68C"))
	number.add_theme_color_override("font_outline_color", Color("5A2E0D"))
	number.add_theme_constant_override("outline_size", 5)

	click_area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	click_area.text = ""
	click_area.flat = true
	click_area.focus_mode = Control.FOCUS_NONE
	click_area.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		click_area.add_theme_stylebox_override(state, StyleBoxEmpty.new())

	if not click_area.pressed.is_connected(_on_click_area_pressed):
		click_area.pressed.connect(_on_click_area_pressed)


func setup(id: int, is_locked: bool, chapter_index: int, level_index: int) -> void:
	chapter = chapter_index
	level = level_index

	background.texture = LOCK_TEXTURE if is_locked else NORMAL_TEXTURE
	number.visible = not is_locked
	click_area.disabled = is_locked

	if not is_locked:
		number.text = str(id)
	else:
		number.text = ""


func _on_click_area_pressed() -> void:
	if click_area.disabled:
		return
	pressed.emit(chapter, level)
