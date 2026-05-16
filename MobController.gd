extends Spatial

const HORSE_SCENE = preload("res://world/horse/horse.tscn")

const GRAVITY = 12
const MOVE_SPEED = 2.0
const SPAWN_RANGE = 10.0
const SAVE_PATH = "user://horses.save"

enum State {
	IDLE,
	WALK,
	EAT,
	AIR,
	DEAD
}

func _ready():
	randomize()
	loadData()
func _process(delta):
	
	if Engine.get_physics_frames() % 24 == 0:
		saveData()
	for mob in get_children():
		if mob.filename != HORSE_SCENE.resource_path:
			continue
		updateNeeds(mob, delta)
		updateState(mob)
		updateGravity(mob, delta)
		updateMovement(mob)
		updateAnimation(mob)
		updateLabel(mob)

func _input(event):
	if event.is_action_pressed("add"):
		spawn()
		saveData()

func updateAnimation(mob):

	var animationPlayer = mob.get_node("AnimationPlayer")
	var state = mob.get_meta("state")
	var stats = mob.get_node("Stats")
	var is_finished = stats.is_finished
	
	if state == State.IDLE:
		if animationPlayer.current_animation != "idle_cycle":
			animationPlayer.play("idle_cycle")
	elif state == State.WALK:
		if animationPlayer.current_animation != "walk_cycle":
			animationPlayer.play("walk_cycle")
	elif state == State.EAT:
		if animationPlayer.current_animation != "eat_cycle":
			animationPlayer.play("eat_cycle")
	elif state == State.AIR:
		if animationPlayer.current_animation != "air_cycle":
			animationPlayer.play("air_cycle")
	elif state == State.DEAD:
		if !is_finished:
			animationPlayer.play("die")
		else:
			animationPlayer.play("dead")

func getRandomDirection():

	var direction = Vector3(
		rand_range(-1.0, 1.0),
		0,
		rand_range(-1.0, 1.0)
	)

	return direction.normalized()

func updateNeeds(mob, delta):

	var stats = mob.get_node("Stats")

	var nutrition = stats.nutrition

	var nutritionTimer = mob.get_meta(
		"nutritionTimer"
	)

	nutritionTimer += delta

	if nutritionTimer >= 1.0:

		nutritionTimer = 0.0

		var state = mob.get_meta("state")

		if state == State.WALK:

			nutrition -= 1

		elif state == State.EAT:

			nutrition += 1

		nutrition = clamp(
			nutrition,
			0,
			100
		)

		stats.nutrition = nutrition

	mob.set_meta(
		"nutritionTimer",
		nutritionTimer
	)
func updateState(mob):
	var stats = mob.get_node("Stats")
	var nutrition = stats.nutrition
	var verticalVelocity = mob.get_meta("verticalVelocity")
	var health = stats.health

	if health <= 0:
		mob.set_meta("state",State.DEAD)
		return
	# ONLY ENTER AIR IF ACTUALLY FALLING
	if !mob.is_on_floor():
		if verticalVelocity < -4.0:
			mob.set_meta("state",State.AIR)
			return
	# EATING
	if nutrition < 80:
		mob.set_meta("state",State.EAT)
		return
	# LEAVE AIR AFTER LANDING
	if mob.is_on_floor():
		var currentState = mob.get_meta("state")
		if currentState == State.AIR:
			mob.set_meta("state",State.IDLE)

	# RANDOM STATE CHANGES
	if randi() % 120 == 0:
		if randf() < 0.4:
			mob.set_meta("state",State.IDLE)
		else:
			mob.set_meta("state",State.WALK)
			mob.set_meta("moveDirection",getRandomDirection())

func updateGravity(mob, delta):

	var verticalVelocity = mob.get_meta(
		"verticalVelocity"
	)

	# STICK TO GROUND/SLOPES
	if mob.is_on_floor():

		verticalVelocity = -1.0

	else:

		verticalVelocity -= GRAVITY * delta

	mob.set_meta(
		"verticalVelocity",
		verticalVelocity
	)

func updateMovement(mob):

	var state = mob.get_meta("state")

	var verticalVelocity = mob.get_meta("verticalVelocity")
	var velocity = Vector3.ZERO
	velocity.y = verticalVelocity
	# WALKING + AIR MOVEMENT
	if (state == State.WALK or state == State.AIR):
		var moveDirection = mob.get_meta("moveDirection")
		velocity.x = moveDirection.x * MOVE_SPEED
		velocity.z = moveDirection.z * MOVE_SPEED
		if moveDirection.length() > 0.1:
			mob.look_at(mob.global_transform.origin- moveDirection,Vector3.UP)
	# STRONGER SNAP FOR SLOPES
	if state == State.DEAD:
		velocity.x = 0
		velocity.z = 0
	mob.move_and_slide_with_snap(velocity,Vector3.DOWN * 2.0,Vector3.UP,true,4,deg2rad(45.0))


func updateLabel(mob):
	var label = mob.get_node("Name")
	var stats = mob.get_node("Stats")
	var mobName = stats.Name
	var nutrition = stats.nutrition
	var health = stats.health
	var state = mob.get_meta("state")
	label.text = (mobName+ " | HP:"+ str(health)+ " | N:"+ str(nutrition)+ " | "+ str(state)
	)

func saveData():
	var mobsData = []
	for mob in get_children():
		if mob.filename != HORSE_SCENE.resource_path:
			continue
		var stats = mob.get_node("Stats")
		mobsData.append({
			"finished": stats.is_finished,
			"position": mob.translation,
			"name": stats.Name,
			"nutrition": stats.nutrition,
			"health": stats.health
		})
	var file = File.new()
	if file.open(SAVE_PATH,File.WRITE) == OK:
		file.store_var({"mobs": mobsData})
		file.close()

func loadData():
	var file = File.new()
	if !file.file_exists(SAVE_PATH):
		return
	if file.open(SAVE_PATH,File.READ) == OK:
		var data = file.get_var()
		file.close()
		if data.has("mobs"):
			for mobData in data["mobs"]:
				spawn(
					mobData["position"],
					mobData["name"],
					mobData.get("nutrition",100),
					mobData.get("health",100),
					mobData["finished"]
				)
func spawn(position = null,mobName = "",nutrition = 100,health = 100,finished = false):
	var mob = HORSE_SCENE.instance()
	if position == null:
		var offsetX = rand_range(-SPAWN_RANGE,SPAWN_RANGE)
		var offsetZ = rand_range(-SPAWN_RANGE,SPAWN_RANGE)
		mob.translation = Vector3(global_transform.origin.x + offsetX,global_transform.origin.y,global_transform.origin.z + offsetZ)
	else:
		mob.translation = position
	var stats = mob.get_node("Stats")
	
	
	if mobName == "":
		mobName = stats.Names[randi() % stats.Names.size()]

	stats.Name = mobName
	stats.nutrition = nutrition
	stats.health = health
	stats.is_finished = finished

	mob.set_meta("state",State.IDLE)
	mob.set_meta("moveDirection",getRandomDirection())
	mob.set_meta("nutritionTimer",0.0)
	mob.set_meta("verticalVelocity",0.0)

	add_child(mob)
