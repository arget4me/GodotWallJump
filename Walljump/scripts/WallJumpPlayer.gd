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
	const GRAVITY_MULTIPLIER = 2.4
	var Dir = Vector2.DOWN
	var Fall = 11.3 * GRAVITY_MULTIPLIER
	var Default = 9.82 * GRAVITY_MULTIPLIER
	var WallSlide = 1.5 * GRAVITY_MULTIPLIER
	
	func GetDefault() -> Vector2:
		return Dir * Default
	
	func GetFall() -> Vector2:
		return Dir * Fall
		
	func GetWallSlide() -> Vector2:
		return Dir * WallSlide

var Gravity = _Gravity.new()
var Velocity = Vector2.ZERO

class _Controls:
	var LeftHold = 0.0
	var RightHold = 0.0
	var UpHold = 0.0
	var DownHold = 0.0
	
	var LeftJustPress = 0.0
	var RightJustPress = 0.0
	var UpJustPress = 0.0
	var DownJustPress = 0.0
	
	func ClearX():
		LeftHold = 0.0
		RightHold = 0.0
		
	func ClearY():
		UpHold = 0.0
		DownHold = 0.0
		
	func Clear():
		ClearX()
		ClearY()
	
	func Tick(delta : float):
		LeftHold -= delta
		RightHold -= delta
		UpHold -= delta
		DownHold -= delta
		LeftJustPress -= delta
		RightJustPress -= delta
		UpJustPress -= delta
		DownJustPress -= delta
		
		if Input.is_action_pressed("ui_left"):
			LeftHold = 0.1
		
		if Input.is_action_pressed("ui_right"):
			RightHold = 0.1
		
		if Input.is_action_pressed("ui_up"):
			UpHold = 0.1
		
		if Input.is_action_pressed("ui_down"):
			DownHold = 0.1
		
		if Input.is_action_just_pressed("ui_left"):
			LeftJustPress = 0.1
		
		if Input.is_action_just_pressed("ui_right"):
			RightJustPress = 0.1
		
		if Input.is_action_just_pressed("ui_up"):
			UpJustPress = 0.1
		
		if Input.is_action_just_pressed("ui_down"):
			DownJustPress = 0.1
		
		
var Controls = _Controls.new()

var MOVE_AND_SLIDE_MULTIPLIER = 100.0

var VelocityX = 0.0
var TargetVelocityX = 0.0
var AccelerationX = 12.0

var MoveSpeed = 5.3
var JumpDivisor = 3.4
#var DeccelerationX = 4.0

var jumped = false

func Jump(divisor):
	CurrentState = PlayerStates.jump
	Velocity.y = -Gravity.Default / divisor
	jumped = true

var WallJumped = 0.0

func get_which_wall_collided():
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		if collision.normal.x > 0:
			return "left"
		elif collision.normal.x < 0:
			return "right"
	return "none"

func GetHitGround():
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		if collision.normal.dot(Vector2.UP) >= 0.95:
			return true
	return false

func _physics_process(delta):
	Controls.Tick(delta)
	
	var CurrentGravity = Gravity.GetDefault()
	
	if CurrentState == PlayerStates.fall:
		CurrentGravity = Gravity.GetFall()
		
		var collided = get_which_wall_collided()
		if collided != "none":
			var LeftCorrect = Controls.LeftHold > 0.0 && collided == "left"
			var RightCorrect = Controls.RightHold > 0.0 && collided == "right"
			
			if LeftCorrect or RightCorrect:
				CurrentGravity = Gravity.GetWallSlide()
				Velocity.y = min(Velocity.y, 0.5)
				
				if Controls.UpJustPress > 0.0:
					Jump(JumpDivisor)
					
					if LeftCorrect:
						TargetVelocityX = 0.77
					if RightCorrect:
						TargetVelocityX = -0.77
					WallJumped = 0.34
					Controls.UpJustPress = 0.0

	WallJumped -= delta
	var IsWallJumping = WallJumped > 0.0
	
	if Controls.LeftHold > 0.0 && !IsWallJumping:
		TargetVelocityX -= 1.0
	if Controls.RightHold > 0.0 && !IsWallJumping:
		TargetVelocityX += 1.0
	TargetVelocityX = clamp(TargetVelocityX, -1.0, 1.0)
	
	if !IsWallJumping && !Controls.LeftHold > 0.0 && !Controls.RightHold > 0.0:
		TargetVelocityX = lerp(TargetVelocityX, 0.0, delta * 25.0)
	
	
	VelocityX = lerp(VelocityX, TargetVelocityX * MoveSpeed, delta * AccelerationX)
	
	
	Velocity += CurrentGravity * delta
	Velocity.x = VelocityX
	
	if CurrentState == PlayerStates.jump and Velocity.y > 0.0:
		CurrentState = PlayerStates.fall
	
	if CurrentState == PlayerStates.idle:
		if !jumped && Controls.UpJustPress > 0.0:
			Jump(JumpDivisor - 0.3)
			Controls.UpJustPress = 0.0
		elif !GetHitGround():
			CurrentState = PlayerStates.fall
			

	var preVelocityY = Velocity.y
	Velocity = (move_and_slide(Velocity * MOVE_AND_SLIDE_MULTIPLIER, Vector2.UP) / MOVE_AND_SLIDE_MULTIPLIER)

	if GetHitGround(): #preVelocityY > 0.1 && Velocity.y <= 0.0 && Velocity.y > -0.01:
		jumped = false
		WallJumped = 0.0
		CurrentState = PlayerStates.idle
	
	
	print(CurrentState)
