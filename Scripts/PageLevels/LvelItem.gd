extends Control

signal pressed(chapter_index:int, level_index:int)

const NORMAL_TEXTURE = preload("res://asset/final2_bg_levels_button.png")
const LOCK_TEXTURE   = preload("res://asset/Lock.png")
const FONT = preload("res://fonts/BTitrBd.ttf" 	)

var chapter := 0
var level := 0

@onready var background : TextureRect = $Background
@onready var number : Label = $Number
@onready var click_area : Button = $ClickArea


func _ready():

	custom_minimum_size = Vector2(200,200)

	############################
	# Background
	############################

	background.set_anchors_preset(Control.PRESET_FULL_RECT)

	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	background.mouse_filter = Control.MOUSE_FILTER_IGNORE

	############################
	# Number
	############################

	number.set_anchors_preset(Control.PRESET_FULL_RECT)

	number.mouse_filter = Control.MOUSE_FILTER_IGNORE

	number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	number.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	var settings := LabelSettings.new()

	settings.font = FONT
	settings.font_size = 120
	settings.outline_size = 15

	settings.font_color = Color("F8D68C")
	settings.outline_color = Color("5A2E0D")

	number.label_settings = settings

	number.position = Vector2.ZERO
	number.size = size

	############################
	# Click Area
	############################

	click_area.set_anchors_preset(Control.PRESET_FULL_RECT)

	click_area.flat = true
	click_area.focus_mode = Control.FOCUS_NONE

	var empty := StyleBoxEmpty.new()

	click_area.add_theme_stylebox_override("normal",empty)
	click_area.add_theme_stylebox_override("hover",empty)
	click_area.add_theme_stylebox_override("pressed",empty)
	click_area.add_theme_stylebox_override("focus",empty)
	click_area.add_theme_stylebox_override("disabled",empty)

	click_area.pressed.connect(_pressed)


func setup(
	id:int,
	is_locked:bool,
	chapter_index:int,
	level_index:int
):

	chapter = chapter_index
	level = level_index

	background.texture = LOCK_TEXTURE if is_locked else NORMAL_TEXTURE

	click_area.disabled = is_locked

	number.visible = !is_locked

	if !is_locked:
		number.text = str(id)


func _pressed():

	pressed.emit(chapter,level)
