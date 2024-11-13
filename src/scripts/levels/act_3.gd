extends Node2D

@export var FADE_SPEED:float = 20.0

var play_boss_music:bool = true

func _process(delta: float) -> void:
	if !play_boss_music && $AudioStreamPlayer.volume_db < 0:
		$AudioStreamPlayer.volume_db += FADE_SPEED * delta
		$AudioStreamPlayerBoss.volume_db -= FADE_SPEED * delta

func _on_boss_die() -> void:
	$AudioStreamPlayer.play()
	play_boss_music = false
