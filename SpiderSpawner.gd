extends Spatial

const SPIDER_SCENE = preload("res://world/spider/spider.tscn")

const FIGHT_DISTANCE = 2
onready var mov_node = $MobMovement
onready var anim_node = $MobAnimation
onready var spawn_node = $Spawner

var textures = []

enum State {IDLE,WALK,EAT,AIR,DEAD,HUNT,FIGHT}

func _ready():
	randomize()
	loadTextures()
	loadData()

func _process(delta):

	if Engine.get_physics_frames() % 24 == 0:
		saveData()

#	for mob in get_children():
#
#		if !mob.is_in_group("Entity"):
#			continue
#
#		updateNeeds(mob,delta)
#		updateState(mob)
#
#		mov_node.updateGravity(mob,delta)
#		mov_node.updateMovement(mob)
#
#		anim_node.updateAnimation(mob)
#
#		updateLabel(mob)

func _input(event):

	if event.is_action_pressed("add3"):

		var health = randi() % 101 + 100
		var mob = spawn_node.spawn(scene,null,"",100,health)

		applyTexture(mob)

func updateNeeds(mob,delta):
	pass

#func updateState(mob):
#
#	var stats = mob.get_node("Stats")
#
#	var health = stats.health
#	var nutrition = stats.nutrition
#	var verticalVelocity = mob.get_meta("verticalVelocity")
#
#	if health <= 0:
#		mob.set_meta("state",State.DEAD)
#		return
#	if verticalVelocity == null:
#		verticalVelocity = 0.0
#
#	if !mob.is_on_floor() and verticalVelocity < -4.0:
#		mob.set_meta("state",State.AIR)
#		return
#
#	if nutrition < 80:
#		mob.set_meta("state",State.EAT)
#		return
#
#	if mob.is_on_floor() and mob.get_meta("state") == State.AIR:
#		mob.set_meta("state",State.IDLE)
#
#	if randi() % 120 == 0:
#
#		if randf() < 0.4:
#			mob.set_meta("state",State.IDLE)
#
#		else:
#			mob.set_meta("state",State.WALK)
#			mob.set_meta("moveDirection",mov_node.getRandomDirection())

func updateLabel(mob):

	var stats = mob.get_node("Stats")

	var text = (
		stats.Name
		+ " | HP:" + str(stats.health)
		+ " | N:" + str(stats.nutrition)
		+ " | " + str(mob.get_meta("state"))
	)

	mob.get_node("Name").text = text

func loadTextures():

	var dir = Directory.new()

	if dir.open("res://world/spider/texture/") != OK:
		return

	dir.list_dir_begin()

	var file = dir.get_next()

	while file != "":

		if file.ends_with(".png"):
			textures.append(load("res://world/spider/texture/" + file))

		file = dir.get_next()

	dir.list_dir_end()

func applyTexture(mob):

	if textures.size() <= 0:
		return

	var mesh = mob.get_node("Armature/Skeleton/Mesh")

	var material = load("res://world/spider/spider.material").duplicate()

	material.albedo_texture = textures[randi() % textures.size()]

	mesh.material_override = material

func saveData():
	var dir = Directory.new()

	var saveDirectory = "user://" + name + "/"
	var savePath = saveDirectory + "SavedData.dat"

	if !dir.dir_exists(saveDirectory):
		dir.make_dir_recursive(saveDirectory)

	var data = []

	for node in get_children():

		if !node.is_in_group("Entity"):
			continue

		var stats = node.get_node("Stats")

		var entry = {
			"scene": node.filename,
			"position": node.translation,
			"name": stats.Name,
			"nutrition": stats.nutrition,
			"health": stats.health,
			"finished": stats.is_finished
		}

		data.append(entry)

	var file = File.new()

	if file.open(savePath,File.WRITE) == OK:
		file.store_var(data)
		file.close()
func loadData():

	var savePath = "user://" + name + "/SavedData.dat"

	var file = File.new()

	if !file.file_exists(savePath):
		return

	if file.open(savePath,File.READ) != OK:
		return

	var data = file.get_var()

	file.close()

	for entry in data:

		var packedScene = load(entry["scene"])
		var node = packedScene.instance()

		node.translation = entry["position"]

		var stats = node.get_node("Stats")

		stats.Name = entry["name"]
		stats.nutrition = entry["nutrition"]
		stats.health = entry["health"]
		stats.is_finished = entry["finished"]

		add_child(node)
