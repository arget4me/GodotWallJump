extends Camera2D

export(NodePath) var FollowTarget
var target : Node2D = null


export(float) var YUpdateTreashold : float = 25.0
export(float) var XUpdateTreashold : float = 3.0

func _ready():
	target = get_node(FollowTarget)


var YFollowTime = 0.0
var XFollowTime = 0.0

func _physics_process(delta):
	if target == null:
		return
	
	if YFollowTime >= 0.0:
		YFollowTime -= delta
	
	if XFollowTime >= 0.0:
		XFollowTime -= delta
	
	if abs(position.x - target.position.x) >= XUpdateTreashold or XFollowTime > 0.0:
		position.x = lerp(position.x, target.position.x, delta * 15.0)
		if XFollowTime <= 0.0:
			XFollowTime = 1.0
	
	if abs(position.y - target.position.y) >= YUpdateTreashold or YFollowTime > 0.0:
		position.y = lerp(position.y, target.position.y, delta * 15.0)
		if YFollowTime <= 0.0:
			YFollowTime = 1.0
	
	
