extends Node

func wander(mob):
	updateState(mob)

	if mob.get_meta("is_stopped"):
		return

	switchDirection(mob)
	moveforward(mob)
	rotate(mob)

func updateState(mob):
	var frames = Engine.get_physics_frames()

	if !mob.has_meta("state_next"):
		mob.set_meta("state_next", frames + int(rand_range(120,600)))
		mob.set_meta("is_stopped", false)
		mob.set_meta("is_moving", true)
		return

	if frames >= mob.get_meta("state_next"):
		var stopped = !mob.get_meta("is_stopped")

		mob.set_meta("is_stopped", stopped)
		mob.set_meta("is_moving", !stopped)

		mob.set_meta("state_next", frames + int(rand_range(120,600)))

func switchDirection(mob):
	var frames = Engine.get_physics_frames()
	var next = mob.get_meta("next_switch") if mob.has_meta("next_switch") else 0

	if frames >= next:
		mob.set_meta("next_switch", frames + int(rand_range(100,4000)))
		mob.set_meta("dir", Vector3(rand_range(-1,1),0,rand_range(-1,1)).normalized())

func moveforward(mob):
	var dir = mob.get_meta("dir") if mob.has_meta("dir") else Vector3.ZERO
	mob.move_and_slide(-dir * mob.stats.walk_speed)

func rotate(mob):
	var dir = mob.get_meta("dir") if mob.has_meta("dir") else Vector3.ZERO
	if dir == Vector3.ZERO:
		return

	var target_pos = mob.global_transform.origin + (-dir)
	target_pos.y = mob.global_transform.origin.y

	var target_transform = mob.global_transform.looking_at(target_pos, Vector3.UP)

	mob.global_transform.basis = mob.global_transform.basis.slerp(target_transform.basis, 0.1)
