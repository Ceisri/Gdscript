extends Node


func chase(mob)->void:
	var highest_aggro = null
	var highest_value = 0

	for aggro_target in mob.targets:
		if is_instance_valid(aggro_target.target_entity):
			if aggro_target.aggro > highest_value:
				highest_value = aggro_target.aggro
				highest_aggro = aggro_target.target_entity

	if highest_aggro:
		var distance_to_target = mob.global_transform.origin.distance_to(highest_aggro.global_transform.origin)
		var direction = (highest_aggro.global_transform.origin - mob.global_transform.origin).normalized()

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
