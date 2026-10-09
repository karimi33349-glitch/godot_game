extends Control
@onready var visual = $Visual

@export var font:FontFile

@export var font_size:=100

@export var font_color:=Color(0.86,0.62,0)

@export var outline_size:=12

signal touch_started(letter)
signal touch_entered(letter)
signal touch_ended(letter)
signal selected(letter_button)

#var is_selected := false
@onready var label:Label = $Visual/Label
@onready var animation = $AnimationPlayer

var letter := ""

func _ready():
	label.text = letter
	
	label.add_theme_font_override("font",font)

	label.add_theme_font_size_override(
		"font_size",
		font_size
	)

	label.add_theme_color_override(
		"font_color",
		font_color
	)

	label.add_theme_color_override(
		"font_outline_color",
		Color.BLACK
	)

	label.add_theme_constant_override(
		"outline_size",
		outline_size
	)

#func _gui_input(event):
#
	#if event is InputEventScreenTouch and event.pressed:
#
		#if is_selected:
			#return

		#is_selected = true
		#emit_signal("selected", self)
		#print('من لمس شدم')

func get_letter():

	return letter
	
func select():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		visual,
		"scale",
		Vector2(1.15, 1.15),
		0.08
	)


func deselect():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		visual,
		"scale",
		Vector2.ONE,
		0.08
	)

func set_letter(value:String):
	letter = value

	if is_node_ready():
		label.text = letter
