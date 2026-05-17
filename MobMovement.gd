extends Node

onready var controller = $".."
onready var aggro_node = $"../Aggro"

const GRAVITY = 12
const MOVE_SPEED = 2.0
const HUNT_SPEED = 4.0
const HUNT_RADIUS = 15.0

const AGGRO_DROP_DISTANCE = 10.0
const AGGRO_DECAY = 0.1


func updateGravity(mob, delta):

	var verticalVelocity = mob.get_meta("verticalVelocity")

	if mob.is_on_floor():
		verticalVelocity = -1.0
	else:
		verticalVelocity -= GRAVITY * delta

	mob.set_meta("verticalVelocity",verticalVelocity)


func getRandomDirection():
	return Vector3(
		rand_range(-1.0,1.0),
		0,
		rand_range(-1.0,1.0)
	).normalized()


func getNearestPrey(wolf):
	var nearestPrey = null
	var nearestDistance = INF
	for mob in get_tree().get_nodes_in_group("Entity"):

		if mob == wolf:
			continue

		if !mob.is_in_group("Horse"):
			continue

		var distance = wolf.global_transform.origin.distance_to(
			mob.global_transform.origin
		)

		if distance < nearestDistance:
			nearestDistance = distance
			nearestPrey = mob

	return nearestPrey




func get_highest_aggro_target_entity(mob):

	var aggro_target = mob.find_highest_aggro_target()

	if aggro_target == null:
		return null

	if !is_instance_valid(aggro_target.target_entity):
		return null

	if aggro_target.aggro <= 0:
		return null

	return aggro_target.target_entity



var fight_distance = 2
func updateState(mob):

	var State = get_parent().State

	var stats = mob.get_node("Stats")
	var nutrition = stats.nutrition
	var verticalVelocity = mob.get_meta("verticalVelocity")
	var health = stats.health

	if health <= 0:

		mob.set_meta("state",State.DEAD)

	else:

		if mob.is_in_group("Wolf"):

			var target = get_highest_aggro_target_entity(mob)

			if target:

				var distance = mob.global_transform.origin.distance_to(target.global_transform.origin)

				if distance <= fight_distance:
					mob.set_meta("state",State.FIGHT)

				else:
					mob.set_meta("state",State.CHASE)

			else:
				hunting(nutrition,mob)

		if !mob.is_on_floor() and verticalVelocity < -4.0:

			mob.set_meta("state",State.AIR)

		elif nutrition < 80:
			if mob.is_in_group("Herbivor"):
				mob.set_meta("state",State.EAT)

		elif mob.is_on_floor() and mob.get_meta("state") == State.AIR:

			mob.set_meta("state",State.IDLE)

		elif randi() % 120 == 0:

			if randf() < 0.4:

				mob.set_meta("state",State.IDLE)

			else:

				mob.set_meta("state",State.WALK)
				mob.set_meta("moveDirection",getRandomDirection())

func updateMovement(mob):
	aggro_node.update_aggro_decay(mob)

	var state = mob.get_meta("state")
	var verticalVelocity = mob.get_meta("verticalVelocity")

	var velocity = Vector3(
		0,
		verticalVelocity,
		0
	)

	var State = controller.State

	if state == State.WALK or state == State.AIR:

		var moveDirection = mob.get_meta("moveDirection")

		velocity.x = moveDirection.x * MOVE_SPEED
		velocity.z = moveDirection.z * MOVE_SPEED

		if moveDirection.length() > 0.1:

			var targetPos = (
				mob.global_transform.origin
				- moveDirection
			)

			targetPos.y = mob.global_transform.origin.y

			var target_transform = mob.global_transform.looking_at(targetPos,Vector3.UP)

			mob.global_transform.basis = mob.global_transform.basis.slerp(target_transform.basis,0.08)


	elif state == State.HUNT:

		var prey = getNearestPrey(mob)

		if prey:

			var prey_aggro = (
				mob.get_or_create_aggro_target(prey)
			)

			if prey_aggro.aggro <= 0:
				prey_aggro.aggro = 1

		var target = get_highest_aggro_target_entity(mob)

		if target:

			var direction = (target.global_transform.origin- mob.global_transform.origin).normalized()
			direction = get_avoidance_direction(mob,direction,target)
			
			velocity.x = direction.x * HUNT_SPEED
			velocity.z = direction.z * HUNT_SPEED

			var targetPos = (
				mob.global_transform.origin
				- direction
			)

			targetPos.y = mob.global_transform.origin.y

			mob.look_at(targetPos,Vector3.UP)


	elif state == State.CHASE:
		var target = get_highest_aggro_target_entity(mob)
		if target:
			var direction = (target.global_transform.origin - mob.global_transform.origin).normalized()

			direction = get_avoidance_direction(mob,direction,target)

			velocity.x = direction.x * HUNT_SPEED
			velocity.z = direction.z * HUNT_SPEED

			var targetPos = mob.global_transform.origin - direction

			targetPos.y = mob.global_transform.origin.y

			var target_transform = mob.global_transform.looking_at(targetPos,Vector3.UP)

			mob.global_transform.basis = mob.global_transform.basis.slerp(target_transform.basis,0.08)

	elif state == State.FIGHT:

		var target = get_highest_aggro_target_entity(mob)

		if target:
			var direction = (target.global_transform.origin- mob.global_transform.origin).normalized()
			var targetPos = (mob.global_transform.origin- direction)
			targetPos.y = mob.global_transform.origin.y
			var target_transform = mob.global_transform.looking_at(targetPos,Vector3.UP)
			mob.global_transform.basis = mob.global_transform.basis.slerp(target_transform.basis,0.08)

			velocity.x = 0
			velocity.z = 0


	elif state == State.DEAD:

		velocity.x = 0
		velocity.z = 0


	var aggro_info = []

	for aggro_target in mob.targets:

		if is_instance_valid(aggro_target.target_entity):

			aggro_info.append(
				str(aggro_target.target_entity.name)
				+ " : "
				+ str(round(aggro_target.aggro))
			)

	mob.display_aggro_info(aggro_info)


	mob.move_and_slide_with_snap(
		velocity,
		Vector3.DOWN * 2.0,
		Vector3.UP,
		true,
		4,
		deg2rad(45.0)
	)


func get_avoidance_direction(mob, direction, target):

	var ray = mob.ray_forward

	if ray.is_colliding():

		var collider = ray.get_collider()

		if collider != target:

			if !mob.has_meta("avoid_direction"):

				var angle = deg2rad(60)

				if randf() < 0.5:
					angle *= -1

				var avoid_direction = direction.rotated(Vector3.UP,angle).normalized()

				mob.set_meta("avoid_direction",avoid_direction)
				mob.set_meta("avoid_start_position",mob.global_transform.origin)

			return mob.get_meta("avoid_direction")

	if mob.has_meta("avoid_direction"):

		var start_position = mob.get_meta("avoid_start_position")

		var moved_distance = mob.global_transform.origin.distance_to(start_position)

		if moved_distance < 3.0:
			return mob.get_meta("avoid_direction")

		mob.remove_meta("avoid_direction")
		mob.remove_meta("avoid_start_position")

	return direction


func hunting(nutrition,mob):
	var State = get_parent().State
	if nutrition < 30:
		var prey = getNearestPrey(mob)

		if prey:

			var distance = mob.global_transform.origin.distance_to(prey.global_transform.origin)

			mob.set_meta("target",prey)

			if distance <= fight_distance and prey.is_in_group("Entity"):
				mob.set_meta("state",State.FIGHT)

			else:
				mob.set_meta("state",State.HUNT)








