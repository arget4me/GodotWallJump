extends Camera2D

export(NodePath) var FollowTarget
var target : Node2D = null


export(float) var YUpdateTreashold : float = 25.0
export(float) var XUpdateTreashold : float = 3.0

func _ready():
	target = get_node(FollowTarget)


func _physics_process(delta):
	if target == null:
		return
	
	if abs(position.x - target.position.x) >= XUpdateTreashold:
		position.x = target.position.x
		
	if abs(position.y - target.position.y) >= YUpdateTreashold:
		position.y = target.position.y
	
	
