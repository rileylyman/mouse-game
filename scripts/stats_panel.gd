extends Panel

func _ready() -> void:
    visible = false
    await BeatManager._next_bar
    visible = true
