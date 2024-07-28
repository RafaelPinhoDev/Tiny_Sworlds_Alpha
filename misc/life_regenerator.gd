extends Node2D

@export var regeneration_amount: int = 10

func _ready():
	#Identifica quando algum corpo entra na area
	$Area2D.body_entered.connect(on_body_entered)
	
func on_body_entered(body: Node2D) -> void:
		if body.is_in_group("player"):
			var player: Player = body
			player.heal(regeneration_amount)
			#emite que o player pegou a carne
			player.meat_collected.emit(regeneration_amount)
			queue_free()
