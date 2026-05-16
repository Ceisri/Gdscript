extends Node

const RESPAWN_TIME = 10.0

onready var mobController = $".."

func _ready():

	randomize()

	respawn()

func respawn():

	while true:

		yield(
			get_tree().create_timer(RESPAWN_TIME),
			"timeout"
		)

		# REMOVE ALL ENTITIES
		for mob in get_tree().get_nodes_in_group("Entity"):
			mob.queue_free()
		# WAIT 1 FRAME
		yield(
			get_tree(),
			"idle_frame"
		)

		# SPAWN NEW MOBS
		for i in range(3):

			mobController.spawn()
