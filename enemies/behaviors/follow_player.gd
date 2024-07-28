extends Node

#Acessa a classe 
var enemy: Enemy
@export var speed: float = 1
var sprite: AnimatedSprite2D


#APega o segundo script do inimigo, que é o de vida e junca com o de seguir
func _ready():
	enemy = get_parent()
	#Pega o node pelo nome 
	sprite = enemy.get_node("AnimatedSprite2D")
	pass

func _physics_process(delta: float) -> void:
	#calcula a direção
	var player_position = GameManager.player_position
	var difference = player_position - enemy.position
	var input_vector = difference.normalized()
	#movimenta o inimigo
	enemy.velocity = input_vector * speed * 100.0
	enemy.move_and_slide()
	
	#Gira sprite
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true
