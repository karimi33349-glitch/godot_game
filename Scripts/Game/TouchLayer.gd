extends Control

signal drag_started(button: Control)
signal drag_entered(button: Control)
signal drag_finished

@onready var letter_tray: Control = $"../UI/LetterTray"
@onready var line_drawer: Control = $"../LineDrawer"

var is_dragging := false
var current_mouse_pos := Vector2.ZERO
var last_mouse_pos := Vector2.ZERO
var all_buttons: Array[Control] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func setup(buttons: Array) -> void:
	all_buttons.clear()
	for button in buttons:
		if button is Control:
			all_buttons.append(button)


func _input(event: InputEvent) -> void:
	if letter_tray == null:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			_start_from_position(event.position)
		else:
			_end_drag()
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_start_from_position(event.position)
		else:
			_end_drag()
		return

	if event is InputEventScreenDrag and is_dragging:
		_handle_drag(event.position)
		return

	if event is InputEventMouseMotion and is_dragging:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			_handle_drag(event.position)


func _start_from_position(position: Vector2) -> void:
	var button := _get_button_at(position)
	if button == null:
		return

	is_dragging = true
	current_mouse_pos = position
	last_mouse_pos = position
	drag_started.emit(button)


func _end_drag() -> void:
	if not is_dragging:
		return

	is_dragging = false
	drag_finished.emit()


func _handle_drag(position: Vector2) -> void:
	current_mouse_pos = position

	for button in all_buttons:
		if not is_instance_valid(button):
			continue

		if line_drawer.is_button_selected(button):
			continue

		var center := button.get_global_rect().get_center()
		var closest := Geometry2D.get_closest_point_to_segment(
			center,
			last_mouse_pos,
			position
		)

		if closest.distance_to(center) < button.size.x * 0.45:
			drag_entered.emit(button)
			break

	last_mouse_pos = position


func _get_button_at(position: Vector2) -> Control:
	for button in all_buttons:
		if not is_instance_valid(button):
			continue
		if button.get_global_rect().has_point(position):
			return button

	return null
