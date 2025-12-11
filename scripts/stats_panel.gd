extends Panel

func _ready() -> void:
    visible = false
    await BeatManager.next_bar
    visible = true
