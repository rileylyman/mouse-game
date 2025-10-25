extends Node

var bpm: float = 155

var secs_per_beat: float = 60.0 / bpm
var secs_per_sixteenth: float = secs_per_beat / 4

var accum: float = 0
var curr_sixteenth: int = -4

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
