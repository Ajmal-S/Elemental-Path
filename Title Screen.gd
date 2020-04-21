extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$bgm.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	Global.nextSceneIndex += 1
	Global.goto_next_scene() # Replace with function body.


func _on_Button2_pressed():
	Global.goto_scene("res://GameGuide.tscn")
