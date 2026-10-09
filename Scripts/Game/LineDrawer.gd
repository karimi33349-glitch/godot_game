extends Control

signal word_finished(word: String, buttons: Array)

var line_color = Color.WHITE

@export var normal_color := Color.WHEAT
@export var correct_color := Color.WEB_GREEN
@export var wrong_color := Color.DARK_RED
@export var line_width: float = 15.0
@export var fade_speed: float = 2.5
@export var smooth_detail: int = 30

var dragging := false
var fading := false
var alpha := 1.0

var selected_buttons: Array[Control] = []
var selected_letters: Array[String] = []
var current_button = null

enum LineState {
	NORMAL,
	CORRECT,
	WRONG
}

var State := LineState.NORMAL

var fixed_points: Array[Vector2] = []
var mouse_point: Vector2 = Vector2.ZERO

var is_clearing := false

# ✅ ارجاع به UserAnswer برای به‌روزرسانی
@onready var user_answer = $"../UI/UserAnswer"

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta):
	if fading:
		alpha -= fade_speed * delta
		queue_redraw()
		
		if alpha <= 0:
			alpha = 0
			fading = false
			_clear_safe()
	
	if dragging:
		mouse_point = get_local_mouse_position()
		queue_redraw()

func is_button_selected(button) -> bool:
	return button in selected_buttons

func start_drag(button):
	line_color = Color.WHEAT
	# ✅ فقط خطوط را پاک کن، نه UserAnswer رو
	_clear_line_only()
	dragging = true
	alpha = 1.0
	
	var button_center = button.get_global_rect().get_center()
	var center_local = get_global_transform().affine_inverse() * button_center
	fixed_points.append(center_local)
	mouse_point = get_local_mouse_position()
	
	add_button(button)

func add_button(button):
	if button == null:
		return
	if button == current_button:
		return
	if button in selected_buttons:
		return

	current_button = button
	selected_buttons.append(button)
	selected_letters.append(button.get_letter())

	if is_instance_valid(button):
		button.select()
	
	var button_global = button.get_global_rect().get_center()
	var button_local = get_global_transform().affine_inverse() * button_global
	fixed_points.append(button_local)
	
	mouse_point = get_local_mouse_position()
	
	# ✅ به‌روزرسانی UserTarget
	if is_instance_valid(user_answer) and user_answer.has_method("set_usertarget_label"):
		user_answer.set_usertarget_label("".join(selected_letters))
	
	queue_redraw()

func finish_drag():
	if !dragging:
		return

	dragging = false
	current_button = null

	var word := "".join(selected_letters)
	word_finished.emit(word, selected_buttons.duplicate())

func fade(success_color:Color):

	line_color = success_color
	fading = true

func _clear_line_only():
	fixed_points.clear()
	mouse_point = Vector2.ZERO
	alpha = 1.0
	fading = false
	dragging = false
	queue_redraw()

func _clear_safe():
	is_clearing = true
	
	for button in selected_buttons:
		if is_instance_valid(button):
			button.deselect()
	
	selected_buttons.clear()
	selected_letters.clear()
	current_button = null
	fixed_points.clear()
	mouse_point = Vector2.ZERO
	alpha = 1.0
	fading = false
	dragging = false
	
	# ✅ پاک کردن UserTarget
	if is_instance_valid(user_answer) and user_answer.has_method("set_usertarget_label"):
		user_answer.set_usertarget_label("")

	queue_redraw()
	is_clearing = false

func clear():
	_clear_safe()

func cancel_drag():
	if !dragging:
		return
	
	dragging = false
	current_button = null
	
	for button in selected_buttons:
		if is_instance_valid(button):
			button.deselect()
	
	_clear_safe()

func get_smooth(points: Array, detail := 30) -> Array:
	var result = []

	if points.size() < 2:
		return points

	for i in range(points.size() - 1):
		var p0 = points[max(i - 1, 0)]
		var p1 = points[i]
		var p2 = points[i + 1]
		var p3 = points[min(i + 2, points.size() - 1)]

		for t in range(detail):
			var tt = t / float(detail)
			var point = catmull_rom(p0, p1, p2, p3, tt)
			result.append(point)

	result.append(points[-1])

	return result

func catmull_rom(p0, p1, p2, p3, t):
	var t2 = t * t
	var t3 = t2 * t

	return 0.5 * (
		(2 * p1) +
		(-p0 + p2) * t +
		(2*p0 - 5*p1 + 4*p2 - p3) * t2 +
		(-p0 + 3*p1 - 3*p2 + p3) * t3
	)

func _draw():
	var draw_points: Array[Vector2] = []
	
	for p in fixed_points:
		draw_points.append(p)
	
	if dragging and fixed_points.size() > 0:
		draw_points.append(mouse_point)
	
	if draw_points.size() < 2:
		return
	
	var smooth = get_smooth(draw_points, smooth_detail)
	
	var c = line_color
	c.a = alpha
	
	draw_polyline(smooth, c, line_width, true)
