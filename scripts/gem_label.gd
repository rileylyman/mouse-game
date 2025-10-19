extends Label

func _process(_delta: float) -> void:
    text = "Gems: %d" % GameManager.gems
