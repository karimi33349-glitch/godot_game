extends CanvasLayer

signal next_level_pressed
signal levels_pressed

@onready var blocker: Control = $Blocker
@onready var panel: Control = $Blocker/Panel

@onready var title_label: Label = $Blocker/Panel/Title
@onready var background: TextureRect = $Blocker/Panel/Background

@onready var bottom_buttons: Control = $Blocker/Panel/BottomButtons
@onready var next_button: Button = $Blocker/Panel/BottomButtons/NextButton
@onready var levels_button: Button = $Blocker/Panel/BottomButtons/LevelsButton

const POPUP_BG = preload(
	"res://asset/6ca85650-402e-45b5-bfc1-f7776653ec8c_03.png"
)

const NEXT_BUTTON_TEXTURE = preload(
	"res://asset/next_button_bg.png"
)

const LEVELS_BUTTON_TEXTURE = preload(
	"res://asset/bg_go_to_page_levels.png"
)

const FONT = preload("res://fonts/Lalezar-Regular.ttf")

var overlay: ColorRect

var next_visual: TextureRect
var levels_visual: TextureRect

var breathing_tween: Tween
var is_open := false


func _ready() -> void:

	visible = false

	# =====================================================
	# BLOCKER
	# =====================================================

	blocker.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	blocker.z_index = 1000


	# =====================================================
	# PANEL
	# =====================================================

	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.clip_contents = false


	# =====================================================
	# OVERLAY
	# =====================================================

	_create_overlay()


	# =====================================================
	# BACKGROUND
	# =====================================================

	background.texture = POPUP_BG

	background.mouse_filter = Control.MOUSE_FILTER_IGNORE

	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE

	background.stretch_mode = (
		TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	)

	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	background.z_index = 0


	# =====================================================
	# TITLE
	# =====================================================

	title_label.visible = true
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_label.z_index = 100

	title_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	title_label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	title_label.layout_direction = (
		Control.LAYOUT_DIRECTION_RTL
	)

	title_label.text_direction = (
		Control.TEXT_DIRECTION_RTL
	)


	var title_settings := LabelSettings.new()

	title_settings.font = FONT

	# بزرگ‌تر برای خوانایی
	title_settings.font_size = 60

	title_settings.font_color = Color(0.0, 0.0, 0.0, 1.0)

	title_settings.outline_size = 8

	title_settings.outline_color = Color(0.878, 0.776, 0.412, 0.78)

	title_label.label_settings = title_settings


	# =====================================================
	# ترتیب لایه‌ها
	# =====================================================

	panel.move_child(
		background,
		0
	)

	panel.move_child(
		title_label,
		panel.get_child_count() - 1
	)

	panel.move_child(
		bottom_buttons,
		panel.get_child_count() - 1
	)


	# =====================================================
	# BUTTONS
	# =====================================================

	_setup_buttons()


	# =====================================================
	# RESIZE
	# =====================================================

	if not get_viewport().size_changed.is_connected(
		_update_layout
	):

		get_viewport().size_changed.connect(
			_update_layout
		)

	_update_layout()


# =========================================================
# OVERLAY
# =========================================================

func _create_overlay() -> void:

	overlay = ColorRect.new()

	overlay.name = "PopupOverlay"

	overlay.color = Color(
		0.03,
		0.025,
		0.02,
		0.80
	)

	overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	blocker.add_child(overlay)

	blocker.move_child(
		overlay,
		0
	)


# =========================================================
# LAYOUT
# =========================================================

func _update_layout() -> void:

	if not is_instance_valid(panel):
		return

	var viewport_size := (
		get_viewport()
		.get_visible_rect()
		.size
	)

	var texture_size := POPUP_BG.get_size()

	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return


	var texture_ratio := (
		texture_size.x / texture_size.y
	)


	# -----------------------------------------------------
	# PANEL
	# -----------------------------------------------------

	var popup_width := viewport_size.x * 0.90

	popup_width = min(
		popup_width,
		600.0
	)

	var popup_height := (
		popup_width / texture_ratio
	)


	var max_height := (
		viewport_size.y * 0.60
	)

	if popup_height > max_height:

		popup_height = max_height

		popup_width = (
			popup_height *
			texture_ratio
		)


	panel.size = Vector2(
		popup_width,
		popup_height
	)

	panel.custom_minimum_size = panel.size

	panel.pivot_offset = panel.size * 0.5


	# -----------------------------------------------------
	# CENTER
	# -----------------------------------------------------

	panel.position = Vector2(
		(viewport_size.x - panel.size.x) * 0.5,
		(viewport_size.y - panel.size.y) * 0.43
	)


	# =====================================================
	# TITLE
	# =====================================================

	title_label.position = Vector2(
		panel.size.x * 0.08,
		panel.size.y * 0.30
	)

	title_label.size = Vector2(
		panel.size.x * 0.84,
		panel.size.y * 0.30
	)


	# =====================================================
	# BOTTOM AREA
	# =====================================================

	bottom_buttons.position = Vector2(
		panel.size.x * 0.07,
		panel.size.y * 0.63
	)

	bottom_buttons.size = Vector2(
		panel.size.x * 0.86,
		panel.size.y * 0.28
	)

	_layout_buttons()


# =========================================================
# BUTTON SETUP
# =========================================================

func _setup_buttons() -> void:

	# =====================================================
	# NEXT BUTTON
	# =====================================================

	next_button.text = ""
	next_button.icon = null

	next_button.flat = true
	next_button.focus_mode = Control.FOCUS_NONE

	next_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)


	# =====================================================
	# LEVELS BUTTON
	# =====================================================

	levels_button.text = ""
	levels_button.icon = null

	levels_button.flat = true
	levels_button.focus_mode = Control.FOCUS_NONE

	levels_button.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)


	# =====================================================
	# NEXT VISUAL
	# =====================================================

	next_visual = TextureRect.new()

	next_visual.name = "NextVisual"
	next_visual.texture = NEXT_BUTTON_TEXTURE

	next_visual.expand_mode = (
		TextureRect.EXPAND_IGNORE_SIZE
	)

	# پر کردن کامل دکمه
	next_visual.stretch_mode = (
	TextureRect.STRETCH_KEEP_ASPECT_CENTERED
)

	next_visual.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	next_visual.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	next_visual.z_index = 0

	next_button.add_child(
		next_visual
	)

	var next_settings := LabelSettings.new()

	next_settings.font = FONT
	next_settings.font_size = 45

	next_settings.font_color = Color(
		0.0, 0.0, 0.0, 0.965
	)

	next_settings.outline_size = 6

	next_settings.outline_color = Color(
		"5A2E0D"
	)



	# =====================================================
	# LEVELS VISUAL
	# =====================================================

	levels_visual = TextureRect.new()

	levels_visual.name = "LevelsVisual"

	levels_visual.texture = LEVELS_BUTTON_TEXTURE

	levels_visual.expand_mode = (
		TextureRect.EXPAND_IGNORE_SIZE
	)

	levels_visual.stretch_mode = (
		TextureRect.STRETCH_KEEP_ASPECT_COVERED
	)

	levels_visual.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	levels_visual.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	levels_visual.z_index = 0

	levels_button.add_child(
		levels_visual
	)


	# =====================================================
	# SIGNALS
	# =====================================================

	if not next_button.pressed.is_connected(
		_on_next_pressed
	):

		next_button.pressed.connect(
			_on_next_pressed
	)


	if not levels_button.pressed.is_connected(
		_on_levels_pressed
	):

		levels_button.pressed.connect(
			_on_levels_pressed
	)


# =========================================================
# BUTTON LAYOUT
# =========================================================

func _layout_buttons() -> void:

	var width := bottom_buttons.size.x
	var height := bottom_buttons.size.y

	# منوی مراحل
	var levels_size := 140.0

	levels_button.size = Vector2(
		levels_size,
		levels_size
	)

	levels_button.position = Vector2(
		40.0,
		(height - levels_size) * 0.5 - 40.0
	)


	# ادامه
	var next_width = min(
		width * 0.95,
		400.0
	)

	var next_height := 150.0

	next_button.size = Vector2(
		next_width,
		next_height
	)

	next_button.position = Vector2(
		width - next_width + 20.0 ,
		(height - next_height) * 0.5 - 50.0
	)


# =========================================================
# SHOW POPUP
# =========================================================

func show_popup(
	text: String = "احسنتم!\nاین مرحله رو تموم کردی",
	has_next: bool = true
) -> void:

	if is_open:
		return

	is_open = true
	visible = true

	title_label.visible = true
	title_label.text = text

	next_button.visible = has_next
	levels_button.visible = true

	_update_layout()

	# =====================================================
	# STOP OLD TWEEN
	# =====================================================

	if breathing_tween:

		breathing_tween.kill()

		breathing_tween = null


	# =====================================================
	# SHOW ANIMATION
	# بدون Scale روی Panel
	# =====================================================

	panel.modulate.a = 0.0

	var target_y := panel.position.y

	panel.position.y = (
		target_y + 30.0
	)


	var tween := create_tween()

	tween.set_parallel(true)

	tween.tween_property(
		panel,
		"position:y",
		target_y,
		0.30
	).set_trans(
		Tween.TRANS_BACK
	).set_ease(
		Tween.EASE_OUT
	)

	tween.tween_property(
		panel,
		"modulate:a",
		1.0,
		0.22
	)


	await tween.finished


	if next_button.visible:
		start_breathing()


# =========================================================
# BREATHING
# =========================================================

func start_breathing() -> void:

	if not is_open:
		return

	if not next_button.visible:
		return


	if breathing_tween:

		breathing_tween.kill()


	next_button.scale = Vector2.ONE


	breathing_tween = create_tween()

	breathing_tween.set_loops()


	breathing_tween.tween_property(
		next_button,
		"scale",
		Vector2(
			1.06,
			1.06
		),
		0.80
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN_OUT
	)

	breathing_tween.tween_property(
		next_button,
		"scale",
		Vector2.ONE,
		0.80
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN_OUT
	)


# =========================================================
# HIDE
# =========================================================

func hide_popup() -> void:

	if not is_open:
		return

	is_open = false


	if breathing_tween:

		breathing_tween.kill()
		breathing_tween = null


	var tween := create_tween()

	tween.set_parallel(true)

	tween.tween_property(
		panel,
		"position:y",
		panel.position.y + 25.0,
		0.18
	)

	tween.tween_property(
		panel,
		"modulate:a",
		0.0,
		0.16
	)

	await tween.finished

	visible = false


# =========================================================
# NEXT
# =========================================================

func _on_next_pressed() -> void:

	if not next_button.visible:
		return

	await hide_popup()

	next_level_pressed.emit()


# =========================================================
# LEVELS
# =========================================================

func _on_levels_pressed() -> void:

	await hide_popup()

	levels_pressed.emit()
