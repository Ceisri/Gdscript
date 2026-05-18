extends Node


onready var state_node = $".."




func hunt(mob):
	var bodies = []

	for target in get_tree().get_nodes_in_group("Entity"):
		if target.global_transform.origin.distance_to(mob.global_transform.origin) < mob.stats.hunt_radius:
			bodies.append(target)
		if target.global_transform.origin.distance_to(mob.global_transform.origin) < mob.stats.hunt_radius:
			if target.stats.food_chain < mob.stats.food_chain:
				var direction = (target.global_transform.origin - mob.global_transform.origin).normalized()
				var distance_to_target = mob.global_transform.origin.distance_to(target.global_transform.origin) 
				rotate(mob,direction)
				if distance_to_target >= mob.stats.attack_range:
					moveforward(mob,direction)
				


func moveforward(mob,direction):
	mob.move_and_slide(direction * mob.stats.run_speed)

func rotate(mob,direction):
	if direction == Vector3.ZERO:
		return

	var target_pos = mob.global_transform.origin - direction
	target_pos.y = mob.global_transform.origin.y

	var target_transform = mob.global_transform.looking_at(target_pos,Vector3.UP)

	mob.global_transform.basis = mob.global_transform.basis.slerp(target_transform.basis,0.1)
