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
		
		if Input.is_action_pressed("jump"):
			UpHold = 0.1
		
		if Input.is_action_pressed("ui_down"):
			DownHold = 0.1
		
		if Input.is_action_just_pressed("ui_left"):
			LeftJustPress = 0.1
		
		if Input.is_action_just_pressed("ui_right"):
			RightJustPress = 0.1
		
		if Input.is_action_just_pressed("jump"):
			UpJustPress = 0.1
		
		if Input.is_action_just_pressed("ui_down"):
			DownJustPress = 0.1
		
		
var Controls = _Controls.new()

var MOVE_AND_SLIDE_MULTIPLIER = 100.0

var VelocityX = 0.0
var TargetVelocityX = 0.0
var AccelerationX = 10.0

var MoveSpeed = 5.3
var JumpDivisor = 3.4
#var DeccelerationX = 4.0

var jumped = false

func Jump(divisor):
	CurrentState = PlayerStates.jump
	Velocity.y = -Gravity.Default / divisor
	jumped = true

var WallJumped = 0.0
var WallSliding = 0.0
var LastWall = "none"

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
			var LeftWallSlide = Controls.LeftHold > 0.0 && collided == "left"
			var RightWallSlide = Controls.RightHold > 0.0 && collided == "right"
			
			if LeftWallSlide or RightWallSlide:
				WallSliding = 0.2
			
			if WallSliding > 0.0:
				CurrentGravity = Gravity.GetWallSlide()
				Velocity.y = lerp(Velocity.y, min(Velocity.y, 0.5), delta * 4.4)
				
			if Controls.UpJustPress > 0.0:
				if WallJumped <= 0.0:
					WallJumped = 0.13
				if collided == "left" && Controls.RightJustPress > 0.0:
					TargetVelocityX = 0.77
					VelocityX = TargetVelocityX * MoveSpeed * 0.3
					
					Jump(JumpDivisor + (0.0 if (LastWall != collided) else 2.0))
					WallJumped = 0.13
					Controls.UpJustPress = 0.0
					LastWall = collided
				elif collided == "right" && Controls.LeftJustPress > 0.0:
					TargetVelocityX = -0.77
					VelocityX = TargetVelocityX * MoveSpeed * 0.3
					Jump(JumpDivisor + (0.0 if (LastWall != collided) else 2.0))
					WallJumped = 0.13
					Controls.UpJustPress = 0.0
					LastWall = collided
				
				elif WallJumped <= 0.05:
					TargetVelocityX *= -0.1
					VelocityX = TargetVelocityX * MoveSpeed * 0.2
					Jump(-(JumpDivisor + 20.5))
					LastWall = collided
					WallJumped = 0.13
					Controls.UpJustPress = 0.0
					
					
	
	WallSliding -= delta
	WallJumped -= delta
	WallSliding = clamp(WallSliding, 0.0, 1000.0) # Prevent underflow
	WallJumped = clamp(WallJumped, 0.0, 1000.0) # Prevent underflow
	
	var IsWallJumping = WallJumped > 0.0
	
	if Input.is_action_pressed("ui_left") && !IsWallJumping:
		TargetVelocityX = -1.0
	if Input.is_action_pressed("ui_right") && !IsWallJumping:
		TargetVelocityX = 1.0
	TargetVelocityX = clamp(TargetVelocityX, -1.0, 1.0)
	
	if !IsWallJumping && !Input.is_action_pressed("ui_left") && !Input.is_action_pressed("ui_right"):
		if CurrentState != PlayerStates.idle:
			TargetVelocityX = lerp(TargetVelocityX, 0.0, delta * 2)
		else:
			TargetVelocityX = 0.0#lerp(TargetVelocityX, 0.0, delta * 25)
	var MoveSpeedMultiplier = 1.2 if (CurrentState == PlayerStates.fall or CurrentState == PlayerStates.jump) else 1.0
	VelocityX = lerp(VelocityX, TargetVelocityX * MoveSpeed * MoveSpeedMultiplier, delta * AccelerationX)
	
	
	Velocity += CurrentGravity * delta
	Velocity.x = VelocityX
	
	if CurrentState == PlayerStates.jump and Velocity.y > 0.0:
		CurrentState = PlayerStates.fall
	
	if CurrentState == PlayerStates.idle:
		if !jumped && Controls.UpJustPress > 0.0:
			Jump(JumpDivisor - 0.3)
			Controls.UpJustPress = 0.0
			LastWall = "none"
		elif !GetHitGround():
			CurrentState = PlayerStates.fall
			


	var preVelocityY = Velocity.y
	Velocity = (move_and_slide(Velocity * MOVE_AND_SLIDE_MULTIPLIER, Vector2.UP) / MOVE_AND_SLIDE_MULTIPLIER)

	if (CurrentState == PlayerStates.jump or CurrentState == PlayerStates.fall) and GetHitGround():
		jumped = false
		WallJumped = 0.0
		CurrentState = PlayerStates.idle
		VelocityX *= 0.5
