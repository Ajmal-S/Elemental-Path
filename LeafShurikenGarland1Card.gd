extends Area2D

signal played(name)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var isFaceDown = true
var cost = 2
var damage = 0
var heal = 0
var draw = 0
var discard = 0
var energy = 0
var burn = 0
var shock = 0
var refresh = 0
var root = 2
var type = "nature"
var tValue = 0
var importance = 3
var stage = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("mouse_enter", self, "_mouse_enter")
	self.connect("mouse_exit", self, "_mouse_exit")
	$Tooltip/Background.visible = false

func _mouse_enter():
	if not isFaceDown:
		$Tooltip/Background.visible = true


func _mouse_exit():
   $Tooltip/Background.visible = false


func _on_Card_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed and !isFaceDown:
			emit_signal("played","lsg1")
