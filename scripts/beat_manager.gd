extends Node

@onready var heart: Heart = $"/root/Node2D/Heart"
@onready var beat_label: Label = $"/root/Node2D/BeatLabel"
@onready var bg_music: AudioStreamPlayer = $"/root/Node2D/BgMusic"

var bpm: float = 158

var secs_per_beat: float = 60.0 / bpm
var secs_per_sixteenth: float = secs_per_beat / 4

var accum: float = 0
# var total: float = 0
var curr_sixteenth: int = -4

var fast_forward: bool = false

signal next_16
signal next_8
signal next_4
signal next_2
signal next_bar

var last_playback_pos: float = 0

signal start_signal

func _ready() -> void:
    _start_sequence()

func _start_sequence() -> void:
    await get_tree().create_timer(secs_per_beat * 4 * 4).timeout
    bg_music.play()
    start_signal.emit()

func _process(_delta: float) -> void:
    var playback_head = bg_music.get_playback_position() + AudioServer.get_time_since_last_mix()
    var delta = playback_head - last_playback_pos
    last_playback_pos = playback_head
    accum += delta
    # total += delta
    # print("diff: %f, total: %f, track: %f" % [total - playback_head, total, playback_head])

    if accum >= secs_per_sixteenth:
        accum -= secs_per_sixteenth
        next_16.emit()
        curr_sixteenth += 1

        if curr_sixteenth % 2 == 0:
            next_8.emit()
        if curr_sixteenth % 4 == 0:
            next_4.emit()
        if curr_sixteenth % 8 == 0:
            next_2.emit()
        if curr_sixteenth % 16 == 0:
            next_bar.emit()

    if beat_label:
        beat_label.text = "%d:%d" % [int(curr_sixteenth / 16.0), int((curr_sixteenth % 16) / 4.0) + 1]
        if heart.is_dead():
            beat_label.queue_free()

    if heart.is_dead():
        bg_music.stop()

func wait_for_bar(s: String, offset_sixteenths: int = 0) -> void:
    var parts = s.split(":")
    var bar = int(parts[0])
    var beat = int(parts[1])
    var sixteenth = bar * 16 + (beat - 1) * 4 + offset_sixteenths
    if curr_sixteenth > sixteenth:
        push_error("wait_for_bar: curr_sixteenth (%d) > bar * 16 (%d)" % [curr_sixteenth, bar * 16])
    while curr_sixteenth < sixteenth:
        await next_16

func wait_for_sixteenth(sixteenth: int) -> void:
    if curr_sixteenth > sixteenth:
        push_error("wait_for_sixteenth: curr_sixteenth (%d) > sixteenth (%d)" % [curr_sixteenth, sixteenth])
    while curr_sixteenth < sixteenth:
        await next_16

func wait(note_length: int, n: int) -> void:
    while n > 0:
        if note_length == 16:
            await next_16
        elif note_length == 8:
            await next_8
        elif note_length == 4:
            await next_4
        elif note_length == 2:
            await next_2
        elif note_length == 1:
            await next_bar
        else:
            push_error("Invalid note length: %d" % note_length)
            return
        n -= 1
