extends KinematicBody2D


func _ready():
	
	pass


enum PlayerStates {
	fall,
	jump,
	idle,
	wallslide,
	hurt,
	dead,
	glide,
	charge_jump
}

var CurrentState = PlayerStates.fall
class _Gravity:
	const GRAVITY_MULTIPLIER = 3.0
	var Dir = Vector2.DOWN
	var Fall = 22.0 * GRAVITY_MULTIPLIER
	var Default = 12.82 * GRAVITY_MULTIPLIER
	
	func GetDefault() -> Vector2:
		return Dir * Default
	
	func GetFall() -> Vector2:
		return Dir * Fall

var Gravity = _Gravity.new()
var Velocity = Vector2.ZERO

var MOVE_AND_SLIDE_MULTIPLIER = 100.0

func _physics_process(delta):
	
	var CurrentGravity = Gravity.GetDefault()
	if CurrentState == PlayerStates.fall:
		CurrentGravity = Gravity.GetFall()
	
	Velocity += CurrentGravity * delta
	
	if CurrentState == PlayerStates.jump and Velocity.y > 0.0:
		CurrentState = PlayerStates.fall
	
	if Input.is_action_just_pressed("ui_up"):
		CurrentState = PlayerStates.jump
		Velocity.y = -Gravity.Default / 4.0
	
	Velocity = (move_and_slide(Velocity * MOVE_AND_SLIDE_MULTIPLIER, Vector2.UP) / MOVE_AND_SLIDE_MULTIPLIER)
