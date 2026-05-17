extends Node

const RESPAWN_TIME = 10.0
const SPAWN_RANGE = 10.0
onready var controller = $".."

func _ready():
	randomize()
	respawn()

var respawnTimerRunning = false

func respawn():
	if respawnTimerRunning:
		return
	respawnTimerRunning = true
	while true:
		yield(get_tree().create_timer(RESPAWN_TIME),"timeout")
		var deadHorses = 0
		var deadWolves = 0
		for mob in get_tree().get_nodes_in_group("Entity"):
			var stats = mob.get_node("Stats")
			if stats.health <= 0 and stats.is_finished:
				if mob.filename == controller.HORSE_SCENE.resource_path:
					deadHorses += 1
				elif mob.filename == controller.WOLF_SCENE.resource_path:
					deadWolves += 1
				mob.queue_free()
		yield(get_tree(),"idle_frame")
		for i in range(deadHorses):
			spawn(controller.HORSE_SCENE)
		for i in range(deadWolves):
			spawn(controller.WOLF_SCENE)

func spawn(scene,position = null,mobName = "",nutrition = 100,health = 100,finished = false):

	var mob = scene.instance()

	if position == null:

		var offsetX = rand_range(-SPAWN_RANGE,SPAWN_RANGE)
		var offsetZ = rand_range(-SPAWN_RANGE,SPAWN_RANGE)

		mob.translation = Vector3(
			controller.global_transform.origin.x + offsetX,
			controller.global_transform.origin.y,
			controller.global_transform.origin.z + offsetZ
		)

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
	mob.set_meta("moveDirection",controller.mov_node.getRandomDirection())
	mob.set_meta("nutritionTimer",0.0)
	mob.set_meta("verticalVelocity",0.0)

	controller.add_child(mob)

	return mob
