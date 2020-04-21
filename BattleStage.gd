extends Node2D

var cardAnimation = {}
var rand_generate = RandomNumberGenerator.new()
var playerTurn = true



#player variables
var playerCards = {}
var playerCurrentDeck = []
var playerCurrentDiscard = [] 
var playerCurrentHand = {}
var playerHandPositions = {1:Vector2(700,460), 2:Vector2(800,460), 3:Vector2(620,460), 4:Vector2(880,460), 5:Vector2(540,460), 6:Vector2(960,460), 7:Vector2(460,460), 8:Vector2(1040,460)}
var playerDrawStrength = 1
var playerHandLimit = 1
var playerHandCount = 0

var playerCurrentHealth = 0
var playerBurnt = 0
var playerRooted = 0
var playerRefreshed = 0
var playerShocked = 0
var playerEnergy = {"normal":0, "fire":0, "nature":0, "water":0, "lightning":0}

#enemy variables
var enemyDeckList = ["fba1", "fbe2", "lsa2", "lsg2", "sfn2", "sff2"]
var enemyCards = {}
var enemyCurrentDeck = []
var enemyCurrentDiscard = [] 
var enemyCurrentHand = {}
var enemyHandPositions = {1:Vector2(800,70), 2:Vector2(700,70), 3:Vector2(880,70), 4:Vector2(620,70), 5:Vector2(960,70), 6:Vector2(540,70), 7:Vector2(1040,70), 8:Vector2(460,70)}
var enemyDrawStrength = 4
var enemyHandLimit = 6
var enemyHandCount = 0

var enemyNormalEnergy = 6
var enemyMaxHealth = 10
var enemyCurrentHealth = 10
var enemyBurnt = 0
var enemyRooted = 0
var enemyRefreshed = 0
var enemyShocked = 0
var enemyEnergy = {"normal":6, "fire":0, "nature":0, "water":0, "lightning":0}
var noCardToPlay = false
var playerAnimations = []
var enemyAnimations = []
var playerStateMachine
var enemyStateMachine
# Called when the node enters the scene tree for the first time.
func _ready():
	playerStateMachine = $PlayerAnimationTree.get("parameters/playback")
	enemyStateMachine = $EnemyAnimationTree.get("parameters/playback")
	playerDrawStrength = Global.PlayerDrawStrength
	playerHandLimit = Global.PlayerHandLimit
	playerCurrentHealth = Global.PlayerMaxHealth
	playerEnergy["normal"] = Global.PlayerEnergy
	enemyMaxHealth = Global.EnemyStats[Global.EnemyIndex][0]
	enemyNormalEnergy = Global.EnemyStats[Global.EnemyIndex][1]
	enemyDrawStrength = Global.EnemyStats[Global.EnemyIndex][2]
	enemyHandLimit = Global.EnemyStats[Global.EnemyIndex][3]
	enemyEnergy["normal"] = enemyNormalEnergy
	enemyDeckList = Global.EnemyDecks[Global.EnemyIndex]
	enemyCurrentHealth = enemyMaxHealth
	rand_generate.randomize()
	$HUD/Start.connect("pressed", self, "start_game")	
	$HUD/EndTurn.connect("pressed", self, "end_player_turn")	
	load_cards()
	update_hud()
	$HUD/EndTurn.disabled = true
	
func load_cards():
	for card in Global.PlayerDeckList:
		add_player_card_to_scence(card)	
		move_card_to_player_deck(card)
	for card in enemyDeckList:
		add_enemy_card_to_scence(card)	
		move_card_to_enemy_deck(card)

func add_player_card_to_scence(name):
	playerCurrentHand[name] = 0
	playerCards[name] = load(Global.CardResourceDictionary[name])
	playerCards[name] = playerCards[name].instance()
	add_child(playerCards[name])
	playerCards[name].connect("played", self, "resolve_card_played_player")
	add_card_animation_to_scene(name)

func move_card_to_player_deck(name):
	playerCards[name].isFaceDown = true
	playerCards[name].get_node("AnimatedSprite").play("faceDown")	
	playerCards[name].set_position(Vector2(305, 600))
	playerCurrentDeck.append(name)	

func add_card_animation_to_scene(name):
	cardAnimation[name] = load(Global.AnimationResourceDictionary[name])
	cardAnimation[name] = cardAnimation[name].instance()
	add_child(cardAnimation[name])
	cardAnimation[name].hide()
	
func add_enemy_card_to_scence(name):
	enemyCurrentHand[name] = 0
	enemyCards[name] = load(Global.CardResourceDictionary[name])
	enemyCards[name] = enemyCards[name].instance()
	add_child(enemyCards[name])
	if !(name in Global.PlayerDeckList):
		add_card_animation_to_scene(name)

func move_card_to_enemy_deck(name):
	enemyCards[name].isFaceDown = true
	enemyCards[name].get_node("AnimatedSprite").play("faceDown")	
	enemyCards[name].set_position(Vector2(1205, -35))
	enemyCurrentDeck.append(name)	

func start_game():
	$FightBgm.play()
	$HUD/EndTurn.disabled = false
	$HUD/Start.disabled = true
	player_draw_card(playerDrawStrength)
	enemy_draw_card(enemyDrawStrength)

func end_player_turn():
	player_draw_card(playerDrawStrength)
	playerTurn = false
	$HUD/EndTurn.disabled = true
	noCardToPlay = false
	if enemyRooted > 0:
		enemyRooted -= 1
		enemyCurrentHealth += 1
		if enemyCurrentHealth > enemyMaxHealth:
			enemyCurrentHealth = enemyMaxHealth
		enemyAnimations.append("ehl")
	if enemyBurnt > 0:
		enemyBurnt -= 1
		enemyCurrentHealth -= 2
		enemyAnimations.append("edmg")
	if enemyRefreshed > 0:
		enemyStateMachine.travel("edrw")
		enemyRefreshed -= 1
		enemy_draw_card(1)
	if enemyShocked > 0:
		enemyShocked -= 1
		resolve_enemy_discard(1)
	enemyEnergy["normal"] = enemyNormalEnergy	
	$EnemyTurnTimer.start()
	update_hud()
	

func player_draw_card(cards):
	while(playerHandCount < playerHandLimit):
		if playerCurrentDeck.size() == 0:
			if playerCurrentDiscard.size() == 0:
				break
			for discardedCard in playerCurrentDiscard:
				move_card_to_player_deck(discardedCard)
			playerCurrentDiscard = []
		else :
			if cards == 0:
				break
			var rand_int = rand_generate.randi_range(0, playerCurrentDeck.size() - 1)
			move_card_to_player_hand(playerCurrentDeck[rand_int])
			playerCurrentDeck.remove(rand_int)
			cards -= 1
			

func enemy_draw_card(cards):
	while(enemyHandCount < enemyHandLimit):
		if enemyCurrentDeck.size() == 0:
			if enemyCurrentDiscard.size() == 0:
				break
			for discardedCard in enemyCurrentDiscard:
				move_card_to_enemy_deck(discardedCard)
			enemyCurrentDiscard = []
		else :
			if cards == 0:
				break
			var rand_int = rand_generate.randi_range(0, enemyCurrentDeck.size() - 1)
			move_card_to_enemy_hand(enemyCurrentDeck[rand_int])
			enemyCurrentDeck.remove(rand_int)
			cards -= 1

func move_card_to_player_hand(name):
	var handPosition = find_hand_position(playerCurrentHand)
	playerCurrentHand[name] = handPosition
	playerCards[name].set_position(playerHandPositions[handPosition])
	playerCards[name].isFaceDown = false
	playerCards[name].get_node("AnimatedSprite").play("faceUp")
	playerHandCount += 1

func move_card_to_enemy_hand(name):
	var handPosition = find_hand_position(enemyCurrentHand)
	enemyCurrentHand[name] = handPosition
	enemyCards[name].set_position(enemyHandPositions[handPosition])
	enemyCards[name].isFaceDown = false
	enemyCards[name].get_node("AnimatedSprite").play("faceUp")
	enemyHandCount += 1

func find_hand_position(hand):
	var pos = 1
	while(true):
		if pos in hand.values():
			pos += 1
		else:
			break
	return pos	

func _on_EnemyTurnTimer_timeout():
	if enemyHandCount == 0 or noCardToPlay:
		noCardToPlay = false
		if playerRooted > 0:
			playerRooted -= 1
			playerCurrentHealth += 1
			if playerCurrentHealth > Global.PlayerMaxHealth:
				playerCurrentHealth = Global.PlayerMaxHealth
			playerAnimations.append("phl")
		if playerBurnt > 0:
			playerBurnt -= 1
			playerCurrentHealth -= 2
			playerAnimations.append("pdmg")
		if playerRefreshed > 0:
			playerStateMachine.travel("pdrw")
			playerRefreshed -= 1
			player_draw_card(1)
		if playerShocked > 0:
			playerShocked -= 1
			resolve_player_discard(1)
		playerEnergy["normal"] = Global.PlayerEnergy		
		$EnemyTurnTimer.stop()		
		$HUD/EndTurn.disabled = false
		enemy_draw_card(enemyDrawStrength)
		playerTurn = true
		update_hud()
	else:
		var cardToPlay = []
		var temp = []
		var index = 0
		for card in enemyCurrentHand.keys():
			if enemyCurrentHand[card] > 0:
				cardToPlay.append(card)
		if cardToPlay.size() > 0:
			while(index < cardToPlay.size()):
				if enemyCards[cardToPlay[index]].cost <= enemyEnergy["normal"] + enemyEnergy[enemyCards[cardToPlay[index]].type]:
					temp.append(cardToPlay[index])
				index += 1
			index = 0
			cardToPlay = temp
			temp = []
#			for index in range(0,cardToPlay.size()):
#				if enemyCards[cardToPlay[index]].cost > enemyEnergy["normal"] + enemyEnergy[enemyCards[cardToPlay[index]].type]:
#					cardToPlay.remove(index)
		var highestStage = -1
		var highestType = -1
		var highestImp = -1

		for card in cardToPlay:
			if enemyCards[card].stage > highestStage:
				highestStage = enemyCards[card].stage
		if cardToPlay.size() > 0:
			while(index < cardToPlay.size()):
				if enemyCards[cardToPlay[index]].stage == highestStage:
					temp.append(cardToPlay[index])
				index += 1
			index = 0
			cardToPlay = temp
			temp = []
#			for index in range(0,cardToPlay.size()):
#				if enemyCards[cardToPlay[index]].stage < highestStage:
#					cardToPlay.remove(index)
		for card in cardToPlay:
			if enemyCards[card].tValue > highestType:
				highestType= enemyCards[card].tValue
		if cardToPlay.size() > 0:
			while(index < cardToPlay.size()):
				if enemyCards[cardToPlay[index]].tValue == highestType:
					temp.append(cardToPlay[index])
				index += 1
			index = 0
			cardToPlay = temp
			temp = []
#			for index in range(cardToPlay.size()):
#				if enemyCards[cardToPlay[index]].tValue < highestType:
#					cardToPlay.remove(index)
		for card in cardToPlay:
			if enemyCards[card].importance > highestImp:
				highestImp = enemyCards[card].importance	
			print(highestImp)
		if cardToPlay.size() > 0:
			while(index < cardToPlay.size()):
				if enemyCards[cardToPlay[index]].importance == highestImp:
					temp.append(cardToPlay[index])
				index += 1
			index = 0
			cardToPlay = temp
			temp = []
#			for index in range(0,cardToPlay.size()):
#				if enemyCards[cardToPlay[index]].importance < highestImp:
#					cardToPlay.remove(index)

		print(cardToPlay)
		if cardToPlay.size() == 1:
			resolve_card_played_enemy(cardToPlay[0])
		else:
			noCardToPlay = true

func resolve_card_played_player(name):
	if playerTurn:
		var cardBeingPlayed = playerCards[name]
		if cardBeingPlayed.cost <= playerEnergy["normal"] + playerEnergy[cardBeingPlayed.type]:		
			move_card_to_player_discard(name)	
			resolve_card_animation(name, "Player")
			resolve_energy_cost_player(name)
			playerCurrentHealth += cardBeingPlayed.heal
			if cardBeingPlayed.heal > 0:
				playerAnimations.append("phl")
			if playerCurrentHealth > Global.PlayerMaxHealth:
				playerCurrentHealth = Global.PlayerMaxHealth
			enemyCurrentHealth -= cardBeingPlayed.damage
			if cardBeingPlayed.damage > 0:
				enemyAnimations.append("edmg")
			if cardBeingPlayed.draw > 0:
				playerStateMachine.travel("pdrw")
				player_draw_card(cardBeingPlayed.draw)
			resolve_enemy_discard(cardBeingPlayed.discard)
			enemyBurnt += cardBeingPlayed.burn
			enemyShocked += cardBeingPlayed.shock
			playerRefreshed += cardBeingPlayed.refresh
			playerRooted += cardBeingPlayed.root	
			if cardBeingPlayed.energy > 0:
				playerEnergy[cardBeingPlayed.type] += cardBeingPlayed.energy
				if cardBeingPlayed.type == "fire" and enemyBurnt > 0:
					enemyCurrentHealth -= floor(cardBeingPlayed.stage * 1.5)
					playerAnimations.append("phl")
				if cardBeingPlayed.type == "lightning" and enemyShocked > 0:
					resolve_enemy_discard(cardBeingPlayed.stage)
				if cardBeingPlayed.type == "nature" and playerRooted > 0:
					enemyAnimations.append("edmg")
					playerCurrentHealth += floor(cardBeingPlayed.stage * 1.5)
					if playerCurrentHealth > Global.PlayerMaxHealth:
						playerCurrentHealth = Global.PlayerMaxHealth
				if cardBeingPlayed.type == "water" and playerRefreshed > 0:
					playerStateMachine.travel("pdrw")
					player_draw_card(cardBeingPlayed.stage)
			

func resolve_energy_cost_player(name):
	var cardCost = playerCards[name].cost
	if playerEnergy[playerCards[name].type] > 0:
		if playerEnergy[playerCards[name].type] >= cardCost:
			playerEnergy[playerCards[name].type] -= cardCost
			cardCost = 0
		else:
			cardCost -= playerEnergy[playerCards[name].type]
			playerEnergy[playerCards[name].type] = 0
	playerEnergy["normal"] -= cardCost

func resolve_enemy_discard(discard):
	if discard > 0:
		enemyStateMachine.travel("edsc")
		var cardsInHand = []
		for cardName in enemyCurrentHand.keys():
			if enemyCurrentHand[cardName] > 0:
				cardsInHand.append(cardName)
		while(cardsInHand.size() > 0 and discard > 0):				
			var rand_int = rand_generate.randi_range(0, cardsInHand.size() - 1)
			move_card_to_enemy_discard(cardsInHand[rand_int])
			cardsInHand.remove(rand_int)
			discard -= 1

func resolve_card_played_enemy(name):
	var cardBeingPlayed = enemyCards[name]
	if cardBeingPlayed.cost <= enemyEnergy["normal"] + enemyEnergy[cardBeingPlayed.type]:		
		move_card_to_enemy_discard(name)	
		resolve_card_animation(name, "Enemy")
		resolve_energy_cost_enemy(name)
		enemyCurrentHealth += cardBeingPlayed.heal
		if cardBeingPlayed.heal > 0:
			enemyAnimations.append("ehl")
		if enemyCurrentHealth > enemyMaxHealth:
			enemyCurrentHealth = enemyMaxHealth
		playerCurrentHealth -= cardBeingPlayed.damage
		if cardBeingPlayed.damage > 0:
			playerAnimations.append("pdmg")
		if cardBeingPlayed.draw > 0:
			enemyStateMachine.travel("edrw")
		enemy_draw_card(cardBeingPlayed.draw)
		resolve_player_discard(cardBeingPlayed.discard)
		playerBurnt += cardBeingPlayed.burn
		playerShocked += cardBeingPlayed.shock
		enemyRefreshed += cardBeingPlayed.refresh
		enemyRooted += cardBeingPlayed.root	
		if cardBeingPlayed.energy > 0:
			enemyEnergy[cardBeingPlayed.type] += cardBeingPlayed.energy
			if cardBeingPlayed.type == "fire" and playerBurnt > 0:
				playerCurrentHealth -= floor(cardBeingPlayed.stage * 1.5)
				playerAnimations.append("pdmg")
			if cardBeingPlayed.type == "lightning" and playerShocked > 0:
				resolve_player_discard(cardBeingPlayed.stage)
			if cardBeingPlayed.type == "nature" and enemyRooted > 0:
				enemyCurrentHealth += floor(cardBeingPlayed.stage * 1.5)
				enemyAnimations.append("ehl")
				if enemyCurrentHealth > enemyMaxHealth:
					enemyCurrentHealth = enemyMaxHealth
			if cardBeingPlayed.type == "water" and enemyRefreshed > 0:
				enemyStateMachine.travel("edrw")
				enemy_draw_card(cardBeingPlayed.stage)

func resolve_energy_cost_enemy(name):
	var cardCost = enemyCards[name].cost
	if enemyEnergy[enemyCards[name].type] > 0:
		if enemyEnergy[enemyCards[name].type] >= cardCost:
			enemyEnergy[enemyCards[name].type] -= cardCost
			cardCost = 0
		else:
			cardCost -= enemyEnergy[enemyCards[name].type]
			enemyEnergy[enemyCards[name].type] = 0
	enemyEnergy["normal"] -= cardCost

func resolve_player_discard(discard):
	if discard > 0:
		playerStateMachine.travel("pdsc")
		var cardsInHand = []
		for cardName in playerCurrentHand.keys():
			if playerCurrentHand[cardName] > 0:
				cardsInHand.append(cardName)
		while(cardsInHand.size() > 0 and discard > 0):				
			var rand_int = rand_generate.randi_range(0, cardsInHand.size() - 1)
			move_card_to_player_discard(cardsInHand[rand_int])
			cardsInHand.remove(rand_int)
			discard -= 1

func move_card_to_player_discard(name):
	playerCards[name].set_position(Vector2(440, 600))
	playerCards[name].isFaceDown = true
	playerCards[name].get_node("AnimatedSprite").play("faceDown")
	playerCurrentDiscard.append(name)
	playerCurrentHand[name] = 0
	playerHandCount -= 1

func move_card_to_enemy_discard(name):
	enemyCards[name].set_position(Vector2(1105, -35))
	enemyCards[name].isFaceDown = true
	enemyCards[name].get_node("AnimatedSprite").play("faceDown")
	enemyCurrentDiscard.append(name)
	enemyCurrentHand[name] = 0
	enemyHandCount -= 1

func resolve_card_animation(card, animation):
	var animationPlayer = cardAnimation[card].get_node("AnimationPlayer")
	print(animationPlayer.get_current_animation())
	animationPlayer.connect("animation_finished", self, "hide_animation")
	animationPlayer.set_assigned_animation(card + animation)
	cardAnimation[card].show()
	animationPlayer.play()

func hide_animation(name):
	var cardName = name.substr(0,4)
	cardAnimation[cardName].hide()
	update_hud()
	print(name)

func update_hud():
	for state in enemyAnimations:
		enemyStateMachine.travel(state)
	enemyAnimations = []
	$HUD/EnemyHealth.text = str(enemyCurrentHealth)
	$HUD/EnemyEnergy.text = str(enemyEnergy["normal"])
	$HUD/EnemyFireEnergy.text = str(enemyEnergy["fire"])
	$HUD/EnemyNatureEnergy.text = str(enemyEnergy["nature"])
	$HUD/EnemyWaterEnergy.text = str(enemyEnergy["water"])
	$HUD/EnemyLightningEnergy.text = str(enemyEnergy["lightning"])
	$HUD/EnemyBurnt.text = str(enemyBurnt)
	$HUD/EnemyRefreshed.text = str(enemyRefreshed)
	$HUD/EnemyShocked.text = str(enemyShocked)
	$HUD/EnemyRooted.text = str(enemyRooted)
	
	for state in playerAnimations:
		playerStateMachine.travel(state)
	playerAnimations = []
	$HUD/PlayerHealth.text = str(playerCurrentHealth)
	$HUD/PlayerEnergy.text = str(playerEnergy["normal"])
	$HUD/PlayerFireEnergy.text = str(playerEnergy["fire"])
	$HUD/PlayerNatureEnergy.text = str(playerEnergy["nature"])
	$HUD/PlayerWaterEnergy.text = str(playerEnergy["water"])
	$HUD/PlayerLightningEnergy.text = str(playerEnergy["lightning"])
	$HUD/PlayerBurnt.text = str(playerBurnt)
	$HUD/PlayerRefreshed.text = str(playerRefreshed)
	$HUD/PlayerShocked.text = str(playerShocked)
	$HUD/PlayerRooted.text = str(playerRooted)
	
	if playerCurrentHealth <= 0:
		$EnemyTurnTimer.stop()
		$FightBgm.stop()
		$LoseBgm.play()
		
		remove_cards_and_disable_hud()
		$LostGameTimer.connect("timeout", self, "handle_lost_game")
		$PLayerSprite.play("death")
		$LostGameTimer.start()
	elif enemyCurrentHealth <=0:
		$EnemyTurnTimer.stop()
		$FightBgm.stop()
		$WinBgm.play()
		
		remove_cards_and_disable_hud()
		$WonGameTimer.connect("timeout", self, "handle_game_won")
		$EnemySprite.play("death")
		$WonGameTimer.start()
	pass

func handle_game_won():
	$WonGameTimer.stop()
	$EnemySprite.visible = false
	var toDisplay = get_tree().get_nodes_in_group("won")
	for item in toDisplay:
		item.visible = true
	$Continue.disabled = false
	Global.nextSceneIndex += 1
	Global.EnemyIndex += 1

func handle_lost_game():
	$LostGameTimer.stop()
	$PLayerSprite.visible = false
	var toDisplay = get_tree().get_nodes_in_group("lost")
	for item in toDisplay:
		item.visible = true
	$RESTART.disabled = false
	Global.nextSceneIndex = 0
	Global.EnemyIndex = 0

func remove_cards_and_disable_hud():
	$HUD/EndTurn.disabled = true
	for card in enemyCards.keys():
		enemyCards[card].queue_free()
	for card in playerCards.keys():
		playerCards[card].queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass





func _on_Continue_pressed():
	if Global.EnemyIndex == 1:
		Global.PlayerMaxHealth += 10
		Global.PlayerHandLimit += 2
		Global.PlayerDrawStrength += 1
		Global.PlayerEnergy += 1
	if Global.EnemyIndex == 4:
		Global.PlayerMaxHealth = 10
		Global.PlayerHandLimit = 3
		Global.PlayerDrawStrength = 1
		Global.PlayerEnergy = 2
		Global.EnemyIndex = 0
		Global.nextSceneIndex  = 0
		Global.DeckUpgradeList = Global.DeckUpgradeListOriginal
		Global.PlayerDeckList = []
		Global.DeckUpgradeSize = 6
	Global.goto_next_scene()


func _on_RESTART_pressed():
	Global.PlayerMaxHealth = 10
	Global.PlayerHandLimit = 3
	Global.PlayerDrawStrength = 1
	Global.PlayerEnergy = 2
	Global.DeckUpgradeList = Global.DeckUpgradeListOriginal
	Global.PlayerDeckList = []
	Global.DeckUpgradeSize = 6
	Global.goto_next_scene()
