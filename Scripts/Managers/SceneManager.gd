#extends CanvasLayer
#
#var changing := false
#
#@onready var left  = $Clouds/CloudLeft
#@onready var right = $Clouds/CloudRight
#
#func _ready():
#
	#left.position.x = -left.size.x
#
	#right.position.x = get_viewport().size.x
	#
#func change_scene(scene_path:String):
#
	#if changing:
		#return
#
	#changing = true
#
	#await _close_clouds()
#
	#get_tree().change_scene_to_file(scene_path)
#
	#await get_tree().process_frame
#
	#await _open_clouds()
#
	#changing = false
	#
	#
#func _close_clouds():
#
	#var tween = create_tween()
#
	#tween.set_parallel()
#
	#tween.tween_property(
		#left,
		#"position:x",
		#0,
		#0.35
	#)
#
	#tween.tween_property(
		#right,
		#"position:x",
		#get_viewport().size.x-right.size.x,
		#0.35
	#)
#
	#await tween.finished
	#
#func _open_clouds():
#
	#var tween = create_tween()
#
	#tween.set_parallel()
#
	#tween.tween_property(
		#left,
		#"position:x",
		#-left.size.x,
		#0.35
	#)
#
	#tween.tween_property(
		#right,
		#"position:x",
		#get_viewport().size.x,
		#0.35
	#)
#
	#await tween.finished
	#
##	عکس نداریم
