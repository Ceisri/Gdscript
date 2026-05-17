extends Node

onready var floor_node = $Floor
func gravity(mob):
	var gravity = mob.stats.weight
	if mob.ray_down:
		var ray = mob.ray_down
		if !mob.is_on_floor():
			if !ray.is_colliding():
				mob.move_and_slide(Vector3.DOWN * gravity)
			else:
				var collider = ray.get_collider()
				if collider != mob:
					if collider.is_in_group("Entity"):
						mob.move_and_slide(Vector3.DOWN * gravity)
