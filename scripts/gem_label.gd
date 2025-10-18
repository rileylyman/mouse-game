extends Label

func _process(_delta: float) -> void:
    text = "Gems: " + str(GameManager.gems)
