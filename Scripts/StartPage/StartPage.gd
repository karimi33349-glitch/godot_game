extends Node


func go_to_now_level() -> void:
	var chapter := SaveManager.get_highest_unlocked_chapter()
	var level := SaveManager.get_highest_unlocked_level()

	GameState.set_level(chapter, level)
	SceneManager.change_scene("res://Scenes/Game/GameScene.tscn")


func go_to_chapters_page() -> void:
	SceneManager.change_scene("res://Scenes/PageLevels/Pagechapters.tscn")
