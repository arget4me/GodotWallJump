extends Area2D

var HideTimer = 0.0
func Hide():
	if HideTimer <= 0.0:
		HideTimer = 12.0
		hide()
		

func _process(delta):
	if HideTimer > 0.0:
		HideTimer -= delta
	else:
		show()

func _on_Coin_body_entered(body):
	if body is Player:
		Hide()
