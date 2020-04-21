extends Node

var current_scene = null
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var DeckUpgradeSize = 6
var DeckList = ["fba", "fbe", "sff", "lsa", "lsg", "sfn", "lba", "lbe", "sfl", "wpa","mfe", "sfw"]
var DeckUpgradeList = ["fba1", "fbe1", "sff1", "lsa1", "lsg1", "sfn1", "lba1", "lbe1", "sfl1", "wpa1","mfe1", "sfw1"]
var DeckUpgradeListOriginal = ["fba1", "fbe1", "sff1", "lsa1", "lsg1", "sfn1", "lba1", "lbe1", "sfl1", "wpa1","mfe1", "sfw1"]
var PlayerDeckList = ["mfe1", "lbe1", "wpa1", "lba1", "lsa1", "fba1"]
var CardResourceDictionary = {"mfe3":"res://MysticFountain3Card.tscn", "mfe2":"res://MysticFountain2Card.tscn", "mfe1":"res://MysticFountain1Card.tscn", "wpa3":"res://WavePulseAttack3Card.tscn", "wpa2":"res://WavePulseAttack2Card.tscn", "wpa1":"res://WavePulseAttack1Card.tscn", "lbe3":"res://StormTrap3Card.tscn", "lbe2":"res://StormTrap2Card.tscn", "lbe1":"res://StormTrap1Card.tscn", "lba3":"res://LightningBoltAttack3Card.tscn", "lba2":"res://LightningBoltAttack2Card.tscn", "lba1":"res://LightningBoltAttack1Card.tscn", "fbe3" : "res://FlameBinding3Card.tscn", "fbe2" : "res://FlameBinding2Card.tscn", "fbe1" : "res://FlameBinding1Card.tscn", "fba3" : "res://FireBallAttack3Card.tscn", "fba2" : "res://FireBallAttack2Card.tscn", "fba1" : "res://FireBallAttack1Card.tscn", "lsg3" : "res://LeafShurikenGarland3Card.tscn", "lsg2" : "res://LeafShurikenGarland2Card.tscn", "lsa3" : "res://LeafShurikenAttack3Card.tscn", "lsa2" : "res://LeafShurikenAttack2Card.tscn", "sfw3":"res://SacrificeWaterFairy3Card.tscn", "sfw2":"res://SacrificeWaterFairy2Card.tscn", "sfw1":"res://SacrificeWaterFairy1Card.tscn", "sfl3":"res://SacrificeStormFairy3Card.tscn","sfl2":"res://SacrificeStormFairy2Card.tscn", "sfl1":"res://SacrificeStormFairy1Card.tscn", "sff3":"res://SacrificeFireFairy3Card.tscn", "sff2":"res://SacrificeFireFairy2Card.tscn","sff1":"res://SacrificeFireFairy1Card.tscn", "sfn3":"res://SacrificeNatureFairy3Card.tscn", "sfn2":"res://SacrificeNatureFairy2Card.tscn", "sfn1":"res://SacrificeNatureFairy1Card.tscn", "fsb1" : "res://FireballStage1Card.tscn", "lsa1" : "res://LeafShurikenAttack1Card.tscn", "lsg1" : "res://LeafShurikenGarland1Card.tscn"}
var AnimationResourceDictionary = {"mfe3":"res://MysticFountain3Animation.tscn","mfe2":"res://MysticFountain2Animation.tscn","mfe1":"res://MysticFountain1Animation.tscn", "wpa3":"res://WavePulseAttack3Animation.tscn", "wpa2":"res://WavePulseAttack2Animation.tscn", "wpa1":"res://WavePulseAttack1Animation.tscn", "lbe3":"res://StormTrap3Animation.tscn", "lbe2":"res://StormTrap2Animation.tscn", "lbe1":"res://StormTrap1Animation.tscn", "lba3":"res://LightningBoltAttack3Animation.tscn", "lba2":"res://LightningBoltAttack2Animation.tscn", "lba1":"res://LightningBoltAttack1Animation.tscn", "fbe3" : "res://FlameBinding3Animation.tscn", "fbe2" : "res://FlameBinding2Animation.tscn", "fbe1" : "res://FlameBinding1Animation.tscn", "fba3" : "res://FireBallAttack3Animation.tscn", "fba2" : "res://FireBallAttack2Animation.tscn", "fba1" : "res://FireBallAttack1Animation.tscn", "lsg3" : "res://LeafShurikenGarland3Animation.tscn", "lsg2" : "res://LeafShurikenGarland2Animation.tscn", "lsa3" : "res://LeafShurikenAttack3Animation.tscn", "lsa2" : "res://LeafShurikenAttack2Animation.tscn", "sfw3":"res://SacrificeWaterFairy3Animation.tscn",  "sfw2":"res://SacrificeWaterFairy2Animation.tscn", "sfw1":"res://SacrificeWaterFairy1Animation.tscn", "sfl3":"res://SacrificeStormFairy3Animation.tscn", "sfl2":"res://SacrificeStormFairy2Animation.tscn", "sfl1":"res://SacrificeStormFairy1Animation.tscn", "sff3":"res://SacrificeFireFairy3Animation.tscn", "sff2":"res://SacrificeFireFairy2Animation.tscn", "sff1":"res://SacrificeFireFairy1Animation.tscn", "sfn3":"res://SacrificeNatureFairy3Animation.tscn", "sfn2":"res://SacrificeNatureFairy2Animation.tscn", "sfn1":"res://SacrificeNatureFairy1Animation.tscn","fsb1" : "res://FireballStage1Animation.tscn", "lsa1" : "res://LeafShurikenAttack1Animation.tscn", "lsg1" : "res://LeafShurikenGarland1Animation.tscn"}
var PlayerMaxHealth = 10
var EnemyIndex = 0
var PlayerDrawStrength = 1
var PlayerHandLimit = 3
var PlayerEnergy = 2
var nextSceneIndex = 0
#health energy draw hand
var EnemyStats = [[6,1,1,2],[14,3,2,3],[30,5,3,6],[35,5,4,7]]
var EnemyDecks = [["lsa1", "lsg1", "sfn1"], ["wpa2", "mfe2", "sfw2", "lsa2", "lsg1"], ["wpa1", "mfe1", "lsa3", "sfn2", "lsg2", "fba3", "fbe2", "sff3"], ["wpa3", "mfe3", "sfw3", "lba3", "lbe3", "sfl3", "lsa3", "lsg2", "fba2", "fbe2"]]
var next_scene = ["res://Title Screen.tscn","res://DeckUpgradeScreen.tscn", "res://ForestBattleStage.tscn", "res://DeckUpgradeScreen.tscn", "res://FrogBattleStage.tscn", "res://ChooseUpgradeScreen.tscn", "res://DeckUpgradeScreen.tscn", "res://DragonBattleStage.tscn","res://ChooseUpgradeScreen.tscn", "res://DeckUpgradeScreen.tscn", "res://StormQueenBattleStage.tscn"]
# Called when the node enters the scene tree for the first time.
func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)

func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path)
	
func goto_next_scene():
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", next_scene[nextSceneIndex])


func _deferred_goto_scene(path):
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
