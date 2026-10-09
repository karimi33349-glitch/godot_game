extends Control

# ✅ سیگنال‌ها (اینجا تعریف می‌شوند)
signal drag_started(button: Control)
signal drag_entered(button: Control)
signal drag_finished()

@onready var letter_tray = $"../UI/LetterTray"
@onready var line_drawer = $"../LineDrawer"

var is_dragging := false
var last_selected_button = null
var current_mouse_pos: Vector2 = Vector2.ZERO
var is_mouse_dragging := false
var last_mouse_pos: Vector2 = Vector2.ZERO

var all_buttons: Array = []

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE

# ✅ تابع setup برای دریافت دکمه‌ها
func setup(buttons: Array):
	all_buttons = buttons

func _process(delta):
	if not is_dragging or not is_mouse_dragging:
		return
	_handle_drag(current_mouse_pos)

func _input(event):
	if letter_tray == null:
		return
	
	# شروع درگ با لمس
	if event is InputEventScreenTouch and event.pressed:
		var button = _get_button_at(event.position)
		if button:
			_start_drag(button, event.position)
	
	# شروع درگ با ماوس
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var button = _get_button_at(event.position)
		if button:
			_start_drag(button, event.position)
	
	# پایان درگ با لمس
	if event is InputEventScreenTouch and not event.pressed:
		_end_drag()
	
	# پایان درگ با ماوس
	if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_end_drag()
	
	# حرکت با لمس
	if event is InputEventScreenDrag:
		if is_dragging:
			current_mouse_pos = event.position
			_handle_drag(event.position)
	
	# حرکت با ماوس
	if event is InputEventMouseMotion:
		if is_dragging and event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			current_mouse_pos = event.position
			_handle_drag(event.position)

func _start_drag(button, pos):
	is_dragging = true
	is_mouse_dragging = true
	last_selected_button = null
	current_mouse_pos = pos
	last_mouse_pos = pos
	
	# ✅ ارسال سیگنال شروع درگ
	drag_started.emit(button)
	

func _end_drag():
	if is_dragging:
		is_dragging = false
		is_mouse_dragging = false
		last_selected_button = null
		
		# ✅ ارسال سیگنال پایان درگ
		drag_finished.emit()
		

func _handle_drag(pos: Vector2):

	for button in all_buttons:

		if !is_instance_valid(button):
			continue

		if line_drawer.is_button_selected(button):
			continue

		var center = button.get_global_rect().get_center()

		var distance = Geometry2D.get_closest_point_to_segment(
			center,
			last_mouse_pos,
			get_global_mouse_position()
		).distance_to(center)

		if distance < button.size.x * 0.45:

			last_selected_button = button
			drag_entered.emit(button)
			line_drawer.add_button(button)

	last_mouse_pos = get_global_mouse_position()

# ============================================
# ✅ تشخیص دکمه در موقعیت
# ============================================
func _get_button_at(pos: Vector2) -> Control:

	for button in all_buttons:

		if !is_instance_valid(button):
			continue

		if button.get_global_rect().has_point(pos):
			return button

	return null
