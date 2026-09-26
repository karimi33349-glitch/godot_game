extends CanvasLayer

var changing := false


func change_scene(scene_path: String) -> void:
	if changing:
		return

	if not ResourceLoader.exists(scene_path):
		push_error("SceneManager: Scene not found: " + scene_path)
		return

	changing = true
	var error := get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("SceneManager: Could not change scene: " + scene_path)

	changing = false
