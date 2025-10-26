extends Node

@onready var beat_label: Label = $"/root/Node2D/BeatLabel"

var bpm: float = 158

var secs_per_beat: float = 60.0 / bpm
var secs_per_sixteenth: float = secs_per_beat / 4

var accum: float = 0
var curr_sixteenth: int = -4

var fast_forward: bool = false

signal next_16
signal next_8
signal next_4
signal next_2
signal next_bar

func _process(delta: float) -> void:
    accum += delta

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
        beat_label.text = "%d:%d.%d" % [int(curr_sixteenth / 16.0), int((curr_sixteenth % 16) / 4.0) + 1, (curr_sixteenth % 4) + 1]

func wait_for_bar(bar: int, offset_sixteenths: int = 0) -> void:
    if curr_sixteenth > bar * 16 + offset_sixteenths:
        push_error("wait_for_bar: curr_sixteenth (%d) > bar * 16 (%d)" % [curr_sixteenth, bar * 16])
    while curr_sixteenth < bar * 16 + offset_sixteenths:
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
