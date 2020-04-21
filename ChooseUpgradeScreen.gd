extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$bgm.play()
	$Done.disabled = true
	$CH.text = str(Global.PlayerMaxHealth)
	$CE.text = str(Global.PlayerEnergy)
	$CHD.text = str(Global.PlayerHandLimit)
	$CDR.text = str(Global.PlayerDrawStrength)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_HealthCheck_toggled(button_pressed):
	if button_pressed:
		if $HandCheck.pressed:
			$DeckCheck.disabled = true
			$Done.disabled = false
		elif $DeckCheck.pressed:
			$HandCheck.disabled = true
			$Done.disabled = false
	else: 
		$DeckCheck.disabled = false
		$HandCheck.disabled = false
		$Done.disabled = true


func _on_HandCheck_toggled(button_pressed):
	if button_pressed:
		if $DeckCheck.pressed:
			$HealthCheck.disabled = true
			$Done.disabled = false
		elif $HealthCheck.pressed:
			$DeckCheck.disabled = true
			$Done.disabled = false
	else: 
		$DeckCheck.disabled = false
		$HealthCheck.disabled = false
		$Done.disabled = true


func _on_DeckCheck_toggled(button_pressed):
	if button_pressed:
		if $HandCheck.pressed:
			$HealthCheck.disabled = true
			$Done.disabled = false
		elif $HealthCheck.pressed:
			$HandCheck.disabled = true
			$Done.disabled = false
	else: 
		$HealthCheck.disabled = false
		$HandCheck.disabled = false
		$Done.disabled = true


func _on_Done_pressed():
	if $HealthCheck.pressed:
		Global.PlayerMaxHealth += 10
		Global.PlayerEnergy += 1
	if $HandCheck.pressed:
		Global.PlayerDrawStrength += 1
		Global.PlayerHandLimit += 1
	if !($DeckCheck.pressed):
		Global.nextSceneIndex += 1
	Global.nextSceneIndex += 1
	Global.goto_next_scene()
