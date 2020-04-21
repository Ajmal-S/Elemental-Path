extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var selectedCards = 0
var checkBoxes
# Called when the node enters the scene tree for the first time.
func _ready():
	$bgm.play()
	$Done.disabled = true
	$CH.text = str(Global.PlayerMaxHealth)
	$CE.text = str(Global.PlayerEnergy)
	$CDR.text = str(Global.PlayerDrawStrength)
	$CHD.text = str(Global.PlayerHandLimit)
	var itemsToHideLater = get_tree().get_nodes_in_group("SixCard")
	print(itemsToHideLater)
	if Global.DeckUpgradeSize != 6:
		for item in itemsToHideLater:
			item.visible = false
	var entries = []
	for card in Global.DeckUpgradeList:
		entries.append(card.substr(0,3))
	for cardType in Global.DeckList:
		var i = entries.find(cardType)
		if i == -1:
			get_node(cardType+"Check").visible = false
	checkBoxes = get_tree().get_nodes_in_group("checks")
	for card in Global.DeckUpgradeList:
		var temp = load(Global.CardResourceDictionary[card])
		var inst = temp.instance()
		add_child(inst)
		inst.isFaceDown = false
		inst.get_node("AnimatedSprite").play("faceUp")	
		var pos = get_node(card.substr(0,3)).get_position()
		inst.set_position(Vector2(pos.x + 200, pos.y -110))
	for box in checkBoxes:
		box.connect("toggled", self, "box_checked")
		#print(box.name)

func box_checked(pressed):
	if pressed:
		selectedCards += 1
	else:
		selectedCards -= 1
		$Done.disabled = true
		for box in checkBoxes:
			if box.disabled:
				box.disabled = false
	if selectedCards == Global.DeckUpgradeSize:
		for box in checkBoxes:
			if !box.pressed:
				box.disabled = true
		$Done.disabled = false 
	#print(selectedCards)
			


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Done_pressed():
	var cardsToAddOrUpgrade = []
	for box in checkBoxes:
		if box.pressed:
			cardsToAddOrUpgrade.append(box.name.substr(0,3))
	if Global.DeckUpgradeSize == 6:
		Global.PlayerDeckList = []
		for card in cardsToAddOrUpgrade:
			Global.PlayerDeckList.append(card+str(1))
		Global.DeckUpgradeSize = 3
	else:
		var temp = []
		for index in range(Global.PlayerDeckList.size()):
			temp.append(Global.PlayerDeckList[index].substr(0,3))
		for card in cardsToAddOrUpgrade:
			var i = temp.find(card)
			if i == -1:
				Global.PlayerDeckList.append(card+str(1))
			else:
				var stage = int(Global.PlayerDeckList[i].substr(3,1)) + 1
				Global.PlayerDeckList[i] = card + str(stage)
	print(Global.PlayerDeckList)
	update_deck_upgrade()
	Global.nextSceneIndex += 1
	Global.goto_next_scene()

func update_deck_upgrade():
	print(Global.DeckUpgradeList)
	var temp = []
	var cardsPresent = []
	for card in Global.PlayerDeckList:
		cardsPresent.append(card.substr(0,3))
	for card in Global.DeckList:
		var i = cardsPresent.find(card)
		if i == -1:
			temp.append(card + str(1))
	for card in Global.PlayerDeckList:
		var name = card.substr(0,3)
		var nextStage = int(card.substr(3,1)) + 1
		if nextStage <= 3:
			temp.append(name + str(nextStage))
	Global.DeckUpgradeList = temp
	print(Global.DeckUpgradeList)


			
