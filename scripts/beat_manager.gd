extends Node

@onready var heart: Heart = $"/root/Node2D/Heart"
@onready var beat_label: Label = $"/root/Node2D/Panel/BeatLabel"
@onready var bg_music: AudioStreamPlayer = $"/root/Node2D/BgMusic"

var bpm: float = 158

var secs_per_beat: float = 60.0 / bpm
var secs_per_sixteenth: float = secs_per_beat / 4

var accum: float = 0
var curr_sixteenth: int = -4

# fast forward
var ff_target_16: int = -1

signal _next_16
signal _next_8
signal _next_4
signal _next_2
signal _next_bar

var last_playback_pos: float = 0
var playing: bool = false
@onready var on_web: bool = OS.get_name() == "Web"

signal click_signal

signal start_signal

func next_16() -> void:
    if ff_target_16 >= 0:
        return
    await _next_16

func next_8() -> void:
    if ff_target_16 >= 0:
        return
    await _next_8

func next_4() -> void:
    if ff_target_16 >= 0:
        return
    await _next_4

func next_2() -> void:
    if ff_target_16 >= 0:
        return
    await _next_2

func next_bar() -> void:
    if ff_target_16 >= 0:
        return
    await _next_bar

func _ready() -> void:
    _start_sequence()

func _start_sequence() -> void:
    await click_signal
    print("OS: " + OS.get_name())

    var orig_vol = bg_music.volume_linear
    bg_music.volume_linear = 0.01 
    bg_music.play()

    await get_tree().create_timer(secs_per_beat * 4 * 4).timeout

    bg_music.seek(0)
    bg_music.volume_linear = orig_vol
    playing = true
    start_signal.emit()

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            click_signal.emit()

func is_fast_forwarding() -> bool:
    return ff_target_16 >= 0

func begin_fast_forward(s: String, offset_sixteenths: int) -> void:
    assert(not on_web)
    ff_target_16 = str_to_sixteenth(s) + offset_sixteenths
    assert(ff_target_16 > curr_sixteenth)

func end_fast_forward(s: String, offset_sixteenths: int) -> void:
    assert(not on_web)

    var desired = (str_to_sixteenth(s) + offset_sixteenths) * secs_per_sixteenth
    last_playback_pos = desired
    bg_music.seek(desired)
    accum = 0
    curr_sixteenth = ff_target_16

    ff_target_16 = -1

func _get_curr_playhead() -> float:
    if on_web:
        return 0.0
    return bg_music.get_playback_position() + AudioServer.get_time_since_last_mix()

func _process(_delta: float) -> void:
    if not playing:
        return
    if on_web:
        accum += _delta
    else:
        var playback_head = _get_curr_playhead()
        var delta = playback_head - last_playback_pos
        last_playback_pos = playback_head
        accum += delta

    _process_accum()

    if beat_label:
        beat_label.text = "%d:%d" % [int(curr_sixteenth / 16.0), int((curr_sixteenth % 16) / 4.0) + 1]
        if heart.is_dead():
            beat_label.queue_free()

    if bg_music.is_playing() and heart.is_dead():
        bg_music.stop()

# Returns `true` if there is still more `accum` to be processed
func _process_accum() -> bool:
    if accum >= secs_per_sixteenth:
        accum -= secs_per_sixteenth
        _next_16.emit()
        curr_sixteenth += 1

        if curr_sixteenth % 2 == 0:
            _next_8.emit()
        if curr_sixteenth % 4 == 0:
            _next_4.emit()
        if curr_sixteenth % 8 == 0:
            _next_2.emit()
        if curr_sixteenth % 16 == 0:
            _next_bar.emit()
    return accum > secs_per_sixteenth

func str_to_sixteenth(s: String) -> int:
    var parts = s.split(":")
    var bar = int(parts[0])
    var beat = int(parts[1])
    return bar * 16 + (beat - 1) * 4

func wait_for_bar(s: String, offset_sixteenths: int = 0) -> void:
    var sixteenth = str_to_sixteenth(s) + offset_sixteenths
    if BeatManager.ff_target_16 >= 0:
        if sixteenth < BeatManager.ff_target_16:
            return
        else:
            end_fast_forward(s, offset_sixteenths)
    if curr_sixteenth > sixteenth:
        push_error("wait_for_bar: curr_sixteenth (%d) > desired_sixteenth (%d)" % [curr_sixteenth, sixteenth])
    while curr_sixteenth < sixteenth:
        await _next_16

func wait_for_sixteenth(sixteenth: int) -> void:
    if BeatManager.ff_target_16 >= 0:
        if sixteenth < BeatManager.ff_target_16:
            return
        else:
            end_fast_forward("0:0", sixteenth)
    if curr_sixteenth > sixteenth:
        push_error("wait_for_sixteenth: curr_sixteenth (%d) > sixteenth (%d)" % [curr_sixteenth, sixteenth])
    while curr_sixteenth < sixteenth:
        await _next_16

func wait(note_length: int, n: int) -> void:
    if BeatManager.ff_target_16 >= 0:
        return
    while n > 0:
        if note_length == 16:
            await _next_16
        elif note_length == 8:
            await _next_8
        elif note_length == 4:
            await _next_4
        elif note_length == 2:
            await _next_2
        elif note_length == 1:
            await _next_bar
        else:
            push_error("Invalid note length: %d" % note_length)
            return
        n -= 1
