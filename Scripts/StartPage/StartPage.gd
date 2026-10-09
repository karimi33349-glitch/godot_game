extends Node


func go_to_now_level() -> void:
	var chapter = (
	SaveManager.get_highest_unlocked_chapter()
	)

	var level = (
		SaveManager.get_highest_unlocked_level()
	)

	GameState.set_level(
		chapter,
		level
	)

	get_tree().change_scene_to_file(
		"res://Scenes/Game/GameScene.tscn"
	)

func go_to_chapters_page() -> void:
	
	get_tree().change_scene_to_file("res://Scenes/PageLevels/Pagechapters.tscn")
