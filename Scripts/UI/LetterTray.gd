extends Control

const LetterButtonScene = preload(
	"res://Scenes/Components/LetterButton.tscn"
)

signal letter_selected(button: Control)
signal letter_deselected(button: Control)

var target_positions: Array[Vector2] = []

const GATHER_TIME := 0.30
const ORBIT_TIME := 0.70
const DEPLOY_TIME := 0.60

var buttons: Array = []
var all_letters: Array = []
var shuffling := false

@export var radius_scale: float = 0.40
@export var detection_threshold: float = 1.8
@onready var changemapbutton = $"../ChangeMapButton"

func _ready() -> void:
	# ✅ فقط یک بار اتصال برقرار می‌شود
	if !changemapbutton.pressed.is_connected(shuffle_letters):
		changemapbutton.pressed.connect(shuffle_letters)

func setup(letters: Array):
	clear()
	all_letters = letters.duplicate()
	create_buttons()

func shuffle_letters():

	if buttons.is_empty():
		return

	play_intro_animation()


func create_buttons():
	var count = all_letters.size()
	if count == 0:
		return
	
	var center = size / 2.0
	target_positions.clear()
	var radius = min(size.x, size.y) * radius_scale
	var button_size = get_button_size(count)
	
	for i in count:
		var button = LetterButtonScene.instantiate()
		add_child(button)
		
		button.set_letter(all_letters[i])
		button.custom_minimum_size = Vector2(button_size, button_size)
		button.size = Vector2(button_size, button_size)
		
		button.selected.connect(_on_button_selected)
		button.deselected.connect(_on_button_deselected)
		
		var angle = -PI / 2 + TAU * i / count
		var pos = center + Vector2(cos(angle), sin(angle)) * radius
		
		button.anchor_left = 0
		button.anchor_right = 0
		button.anchor_top = 0
		button.anchor_bottom = 0

		button.position = center - Vector2(button_size, button_size) * 0.5

		target_positions.append(
			pos - Vector2(button_size, button_size) * 0.5
		)

		buttons.append(button)
	
	await get_tree().process_frame
	play_intro_animation()

func play_intro_animation():
	if shuffling:
		return
	
	if buttons.is_empty():
		return

	var center = size / 2.0

	# مرحله اول: جمع شدن در مرکز
	for b in buttons:
		b.position = center - b.size / 2

	# مرحله دوم: حرکت به مدار
	var orbit_radius = 70.0
	var start_positions: Array = []

	for i in buttons.size():
		var angle = TAU * i / buttons.size()
		start_positions.append(
			center +
			Vector2(cos(angle), sin(angle)) * orbit_radius -
			buttons[i].size / 2
		)

	for i in buttons.size():
		var t = create_tween()
		t.set_trans(Tween.TRANS_SINE)
		t.set_ease(Tween.EASE_OUT)
		t.tween_property(
			buttons[i],
			"position",
			start_positions[i],
			GATHER_TIME
		)

	await get_tree().create_timer(GATHER_TIME).timeout

	# مرحله سوم: چرخش در مدار
	var elapsed := 0.0
	var orbit_speed := 1.5

	while elapsed < ORBIT_TIME:
		elapsed += get_process_delta_time()
		var percent = elapsed / ORBIT_TIME
		var rotation = percent * TAU * orbit_speed

		for i in buttons.size():
			var angle = TAU * i / buttons.size() + rotation
			buttons[i].position = center + Vector2(cos(angle), sin(angle)) * orbit_radius - buttons[i].size / 2

		await get_tree().process_frame

	# مرحله چهارم: پخش شدن به موقعیت‌های جدید
	var shuffled = target_positions.duplicate()
	shuffled.shuffle()
	target_positions = shuffled.duplicate()

	# ✅ بررسی اینکه تعداد shuffled با buttons برابر است
	var max_index = min(buttons.size(), shuffled.size())

	for i in max_index:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(
			buttons[i],
			"position",
			shuffled[i],
			DEPLOY_TIME
		)
		shuffling = false
		

func get_button_size(count: int) -> float:
	match count:
		3:  return 130.0
		4:  return 120.0
		5:  return 110.0
		6:  return 105.0
		7:  return 98.0
		8:  return 92.0
		_:  return 88.0

func get_letter_buttons() -> Array:
	return buttons

func get_nearest_button(pos: Vector2) -> Control:
	var nearest = null
	var min_dist = INF
	
	for button in buttons:
		if not is_instance_valid(button):
			continue
		
		var dist = pos.distance_to(button.get_global_rect().get_center())
		var threshold = button.size.x * detection_threshold
		
		if dist < threshold and dist < min_dist:
			min_dist = dist
			nearest = button
	
	return nearest

func get_nearest_button_with_radius(pos: Vector2, radius: float) -> Control:
	var nearest = null
	var min_dist = radius
	
	for button in buttons:
		if not is_instance_valid(button):
			continue
		
		var dist = pos.distance_to(button.get_global_rect().get_center())
		
		if dist < min_dist:
			min_dist = dist
			nearest = button
	
	return nearest

func clear():
	for child in get_children():
		child.queue_free()
	buttons.clear()
	all_letters.clear()
	target_positions.clear()

func _on_button_selected(button):
	letter_selected.emit(button)

func _on_button_deselected(button):
	letter_deselected.emit(button)
