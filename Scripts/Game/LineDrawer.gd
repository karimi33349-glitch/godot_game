extends Control

var line_alpha := 1.0
var fading := false

var note_index := 0
const NOTES: Array[AudioStream] = [
	preload("res://sounds/do.wav"),
	preload("res://sounds/re.wav"),
	preload("res://sounds/mi.wav"),
	preload("res://sounds/fa.wav"),
	preload("res://sounds/sol.wav"),
	preload("res://sounds/la.wav")
]

@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var label_user_target: Label = $"../UI/LabelUserTarget"

var current_button: Control = null
var last_button: Control = null
var dragging := false
var selected_buttons: Array[Control] = []
var touch_position := Vector2.ZERO
var user_target := ""
var answers: Array[String] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_answers(level_answers: Array) -> void:
	answers.clear()
	for answer in level_answers:
		answers.append(str(answer))


func _process(delta: float) -> void:
	if fading:
		line_alpha = max(0.0, line_alpha - delta * 5.0)
		if line_alpha == 0.0:
			fading = false
			selected_buttons.clear()
			queue_redraw()

	if dragging:
		touch_position = get_local_mouse_position()
		queue_redraw()


func start_drag(button: Control) -> void:
	line_alpha = 1.0
	fading = false
	selected_buttons.clear()
	current_button = button
	last_button = button
	dragging = true

	selected_buttons.append(button)
	button.select()
	play_next_note()

	user_target = button.get_letter()
	_update_user_target()


func add_button(button: Control) -> void:
	if button == null:
		return

	if button == current_button:
		return

	if button in selected_buttons:
		return

	current_button = button
	last_button = button
	selected_buttons.append(button)

	button.select()
	play_next_note()

	user_target += button.get_letter()
	_update_user_target()
	queue_redraw()


func is_button_selected(button: Control) -> bool:
	return button in selected_buttons


func finish_drag() -> void:
	end_drag()


func end_drag() -> void:
	if not dragging and selected_buttons.is_empty():
		return

	dragging = false
	fading = true
	current_button = null
	last_button = null

	if user_target in answers:
		var style_box := label_user_target.get_theme_stylebox("normal")
		if style_box:
			var green_style = style_box.duplicate()
			green_style.bg_color = Color(0.0, 0.424, 0.0, 0.957)
			label_user_target.add_theme_stylebox_override("normal", green_style)

		await get_tree().create_timer(0.6).timeout
		label_user_target.remove_theme_stylebox_override("normal")
	else:
		label_user_target.remove_theme_stylebox_override("normal")

	for button in selected_buttons:
		if is_instance_valid(button):
			button.deselect()

	selected_buttons.clear()
	user_target = ""
	label_user_target.text = ""
	queue_redraw()


func _update_user_target() -> void:
	if label_user_target == null:
		return

	var center := label_user_target.position + label_user_target.size * 0.5
	label_user_target.text = user_target
	label_user_target.reset_size()
	label_user_target.position = center - label_user_target.size * 0.5


func play_next_note() -> void:
	if NOTES.is_empty():
		return

	audio.stream = NOTES[note_index]
	audio.pitch_scale = 1.0
	audio.play()

	note_index = (note_index + 1) % NOTES.size()


func get_smooth_points(points: Array, detail := 10) -> Array:
	var result: Array = []
	if points.size() < 2:
		return points

	for i in range(points.size() - 1):
		var p0 = points[max(i - 1, 0)]
		var p1 = points[i]
		var p2 = points[i + 1]
		var p3 = points[min(i + 2, points.size() - 1)]

		for t in range(detail):
			var tt := t / float(detail)
			result.append(catmull_rom(p0, p1, p2, p3, tt))

	result.append(points[points.size() - 1])
	return result


func catmull_rom(p0, p1, p2, p3, t):
	var t2 := t * t
	var t3 := t2 * t
	return 0.5 * (
		(2 * p1)
		+ (-p0 + p2) * t
		+ (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2
		+ (-p0 + 3 * p1 - 3 * p2 + p3) * t3
	)


func _draw() -> void:
	if selected_buttons.is_empty():
		return

	var color := Color.WHITE
	color.a = line_alpha

	var points: Array[Vector2] = []

	for button in selected_buttons:
		if not is_instance_valid(button):
			continue
		var point := to_local(button.get_global_rect().get_center())
		points.append(point)

	if dragging:
		points.append(to_local(get_global_mouse_position()))

	if points.size() < 2:
		return

	if points.size() == 2:
		draw_line(points[0], points[1], color, 10.0, true)
		return

	var smooth_points := get_smooth_points(points, 8)
	for i in range(smooth_points.size() - 1):
		draw_line(
			smooth_points[i],
			smooth_points[i + 1],
			color,
			10.0,
			true
		)
