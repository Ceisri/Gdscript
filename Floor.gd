extends Node

func floor_slope(mob):
	if Engine.get_physics_frames() % 3 == 0:
		if mob:
			if mob.ray_down:
				var ray = mob.ray_down
				if ray.is_colliding():
					var collider = ray.get_collider()
					if collider != mob:
						if !collider.is_in_group("Entity"):
							var normal = ray.get_collision_normal()
							var slope = rad2deg(acos(normal.dot(Vector3.UP)))
							return slope

	return 0
