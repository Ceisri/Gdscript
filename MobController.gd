extends Spatial

const HORSE_SCENE = preload("res://world/horse/horse.tscn")


const MOVE_SPEED = 2.0
const SPAWN_RANGE = 10.0
const SAVE_PATH = "user://horses.save"
onready var mov_node = $MobMovement
onready var anim_node = $MobAnimation
onready var spawn_node = $Spawner
enum State {IDLE,WALK,EAT,AIR,DEAD}

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
		mov_node.updateGravity(mob, delta)
		mov_node.updateMovement(mob)
		anim_node.updateAnimation(mob)
		updateLabel(mob)

func _input(event):
	if event.is_action_pressed("add"):
		spawn_node.spawn(HORSE_SCENE)
		saveData()

func getRandomDirection():
	var direction = Vector3(rand_range(-1.0, 1.0),0,rand_range(-1.0, 1.0))
	return direction.normalized()

func updateNeeds(mob, delta):
	var stats = mob.get_node("Stats")
	var nutrition = stats.nutrition
	var nutritionTimer = mob.get_meta("nutritionTimer")
	nutritionTimer += delta
	if nutritionTimer >= 1.0:
		nutritionTimer = 0.0
		var state = mob.get_meta("state")
		if state == State.WALK:
			nutrition -= 1
		elif state == State.EAT:
			nutrition += 1
		nutrition = clamp(nutrition,0,100)
		stats.nutrition = nutrition
	mob.set_meta("nutritionTimer",nutritionTimer)

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


func updateLabel(mob):
	var label = mob.get_node("Name")
	var stats = mob.get_node("Stats")
	var mobName = stats.Name
	var nutrition = stats.nutrition
	var health = stats.health
	var state = mob.get_meta("state")
	label.text = (mobName+ " | HP:"+ str(health)+ " | N:"+ str(nutrition)+ " | "+ str(state))

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
			"health": stats.health})

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
				spawn_node.spawn(
					HORSE_SCENE,
					mobData["position"],
					mobData["name"],
					mobData.get("nutrition",100),
					mobData.get("health",100),
					mobData["finished"]
				)
