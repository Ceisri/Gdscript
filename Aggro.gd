extends Node

onready var controller = $".."

#____________________________COLLECTIVE AGGRO MANAGEMENT____________________________________________


func update_aggro_decay(mob):
	mob.cleanup_aggro_targets()
	update_distance_aggro_decay(mob)
	update_stuck_aggro_decay(mob)
func update_stuck_aggro_decay(mob):
	if Engine.get_physics_frames() % 32 == 0:
		var last_position = mob.get_meta("last_stuck_position") if mob.has_meta("last_stuck_position") else mob.global_transform.origin
		var moved_distance = mob.global_transform.origin.distance_to(last_position)

		mob.set_meta("last_stuck_position", mob.global_transform.origin)

		if moved_distance < 0.2:
			var state = mob.get_meta("state")

			for aggro_target in mob.targets:
				if is_instance_valid(aggro_target.target_entity):
					var distance = mob.global_transform.origin.distance_to(aggro_target.target_entity.global_transform.origin)
					var can_decay = true

					if distance <= mob.fight_distance:
						var stuck_timer = mob.get_meta("stuck_timer") if mob.has_meta("stuck_timer") else 0

						stuck_timer += 32

						mob.set_meta("stuck_timer", stuck_timer)
						can_decay = stuck_timer >= 600
					else:
						mob.set_meta("stuck_timer", 0)

					if can_decay:
						if state == controller.State.FIGHT:
							aggro_target.aggro -= 1
						else:
							aggro_target.aggro -= 10

						if aggro_target.aggro < 0:
							aggro_target.aggro = 0
func update_distance_aggro_decay(mob):

	if Engine.get_physics_frames() % 32 == 0:

		for aggro_target in mob.targets:

			if is_instance_valid(aggro_target.target_entity):

				var distance = mob.global_transform.origin.distance_to(
					aggro_target.target_entity.global_transform.origin
				)

				if distance > mob.aggro_drop_distance:

					aggro_target.aggro *= 0.9

					if aggro_target.aggro < 1:
						aggro_target.aggro = 0
