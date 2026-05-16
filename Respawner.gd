extends Node

const RESPAWN_TIME = 10.0
const SPAWN_RANGE = 10.0
onready var controller = $".."

func _ready():
	randomize()
	respawn()

func respawn():
	while true:
		yield(get_tree().create_timer(RESPAWN_TIME),"timeout")
		# REMOVE ALL ENTITIES
		for mob in get_tree().get_nodes_in_group("Entity"):
			mob.queue_free()
		# WAIT 1 FRAME
		yield(get_tree(),"idle_frame")
		# SPAWN NEW MOBS
		for i in range(3):spawn(controller.HORSE_SCENE)

func spawn(scene,position = null,mobName = "",nutrition = 100,health = 100,finished = false):
	var mob = scene.instance()
	if position == null:
		var offsetX = rand_range(-SPAWN_RANGE,SPAWN_RANGE)
		var offsetZ = rand_range(-SPAWN_RANGE,SPAWN_RANGE)
		mob.translation = Vector3(controller.global_transform.origin.x + offsetX,controller.global_transform.origin.y,controller.global_transform.origin.z + offsetZ)
	else:
		mob.translation = position
	var stats = mob.get_node("Stats")
	if mobName == "":
		mobName = stats.Names[randi() % stats.Names.size()]
	stats.Name = mobName
	stats.nutrition = nutrition
	stats.health = health
	stats.is_finished = finished

	mob.set_meta("state",controller.State.IDLE)
	mob.set_meta("moveDirection",controller.getRandomDirection())
	mob.set_meta("nutritionTimer",0.0)
	mob.set_meta("verticalVelocity",0.0)

	controller.add_child(mob)
