extends CharacterBody3D

# Движение
@export var speed: float = 5
@export var sprint_multiplier: float = 3.5
@export var jump_velocity: float = 10.0
@export var gravity: float = 20.0
@export var air_control_factor: float = 0.5
@export var acceleration: float = 20.0
@export var friction: float = 6.0

# Камера
@export var camera_distance: float = 6.0
@export var camera_height: float = 7.0
@export var camera_smooth_speed: float = 10.0
@export var mouse_sensitivity: float = 0.01
@export var min_pitch: float = deg_to_rad(-30)
@export var max_pitch: float = deg_to_rad(60)

# Звук шагов
@export var footstep_sounds: Array[AudioStream] = []
@export var step_interval: float = 0.4

# Узлы
@onready var anim_player: AnimationPlayer = $Character/AnimationPlayer
@onready var mesh: Node3D = $Character
@onready var cam_pivot: Node3D = $CameraPivot
@onready var cam: Camera3D = $CameraPivot/Camera3D
@onready var footstep_player: AudioStreamPlayer3D = $FootstepPlayer

# Вспомогательные переменные
var rotation_x: float = 0.0
var rotation_y: float = 0.0
var step_timer: float = 0.0
var move_velocity: Vector3 = Vector3.ZERO
var remaining_jumps: int = 2
var was_on_floor: bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cam.transform.origin = Vector3(0, 0, camera_distance)

func _input(event):
	if event is InputEventMouseMotion:
		rotation_y -= event.relative.x * mouse_sensitivity
		rotation_x -= event.relative.y * mouse_sensitivity
		rotation_x = clamp(rotation_x, min_pitch, max_pitch)
		cam_pivot.rotation.x = rotation_x
		cam_pivot.rotation.y = rotation_y

	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Assets/Scenes/MainMenu.tscn")

func _physics_process(delta):
	var input_fb = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	var input_lr = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	var move_dir = Vector3.ZERO
	var is_moving = false

	if abs(input_fb) > 0.1 or abs(input_lr) > 0.1:
		is_moving = true
		var cam_basis = cam_pivot.global_transform.basis
		var forward = -cam_basis.z.normalized()
		var right = cam_basis.x.normalized()
		var input_vector = Vector2(input_lr, input_fb).normalized()
		move_dir = (right * input_vector.x + forward * input_vector.y).normalized()

	var current_speed = speed
	if Input.is_action_pressed("sprint"):
		current_speed *= sprint_multiplier

	var target_velocity = move_dir * current_speed

	# Ускорение и инерция
	var accel = acceleration * delta
	if is_on_floor():
		move_velocity.x = lerp(move_velocity.x, target_velocity.x, accel)
		move_velocity.z = lerp(move_velocity.z, target_velocity.z, accel)
	else:
		var air_accel = accel * air_control_factor
		move_velocity.x = lerp(move_velocity.x, target_velocity.x, air_accel)
		move_velocity.z = lerp(move_velocity.z, target_velocity.z, air_accel)

	# Применяем трение если не двигается
	if move_dir == Vector3.ZERO:
		var friction_factor = pow(1.0 - delta * friction, delta * 60.0)
		move_velocity.x *= friction_factor
		move_velocity.z *= friction_factor

	# Применяем горизонтальную скорость
	velocity.x = move_velocity.x
	velocity.z = move_velocity.z

	# Поворот модели
	if is_moving:
		var target_rot = atan2(-move_dir.x, -move_dir.z)
		mesh.rotation.y = lerp_angle(mesh.rotation.y, target_rot, 0.2)

	# Прыжок
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or remaining_jumps > 0):
		velocity.y = jump_velocity
		if not is_on_floor():
			remaining_jumps -= 1

	# Гравитация
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif velocity.y < 0:
		velocity.y = 0

	# Движение
	self.velocity = velocity
	move_and_slide()

	# Сброс прыжков только при приземлении
	if not was_on_floor and is_on_floor():
		remaining_jumps = 1  # потому что 1 прыжок уже на земле, +1 в воздухе = 2
	was_on_floor = is_on_floor()

	update_camera(delta)
	play_animations()
	play_footsteps(delta)

func update_camera(delta):
	var target_pos = global_transform.origin + Vector3(0, camera_height, 0)
	var current_pos = cam_pivot.global_transform.origin
	var new_pos = current_pos.lerp(target_pos, delta * camera_smooth_speed)
	var pivot_tf = cam_pivot.global_transform
	pivot_tf.origin = new_pos
	cam_pivot.global_transform = pivot_tf

	var look_target = global_transform.origin + Vector3(0, 1, 0)
	cam.look_at(look_target, Vector3.UP)

func play_animations():
	if is_on_floor():
		if velocity.length() > 0.1:
			if Input.is_action_pressed("sprint") and anim_player.has_animation("Run"):
				anim_player.play("Run")
			elif anim_player.has_animation("Walk"):
				anim_player.play("Walk")
		else:
			if anim_player.has_animation("Idle"):
				anim_player.play("Idle")
	else:
		if anim_player.has_animation("Jump"):
			anim_player.play("Jump")

func play_footsteps(delta):
	if is_on_floor() and velocity.length() > 0.1:
		step_timer -= delta
		if step_timer <= 0.0:
			if footstep_sounds.size() > 0:
				var snd = footstep_sounds[randi() % footstep_sounds.size()]
				footstep_player.stream = snd
				footstep_player.play()
			step_timer = step_interval * (0.5 if Input.is_action_pressed("sprint") else 1.0)
	else:
		step_timer = 0.0

func lerp_angle(a: float, b: float, t: float) -> float:
	var diff = wrapf(b - a + PI, -PI, PI)
	return a + diff * t
