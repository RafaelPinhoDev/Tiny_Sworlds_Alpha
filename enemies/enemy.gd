#Define uma classe
class_name Enemy
extends Node2D

@export var health: int = 10
@export var death_prefab: PackedScene
var damage_digite_prefab = PackedScene
@onready var damage_digit_marker = $DamageDigitMarker

func _ready():
	#Pega uma cena de outra pasta
	damage_digite_prefab = preload("res://misc/damage_digit.tscn")

func damage(amount: int) -> void:
	#ammount é dano e health saúde
	health -= amount
	#Piscar o inimigo quando recebe dano
	modulate = Color.RED
	#Betwen, (entre)
	var tween = create_tween()
	#Objeto, propriedade, cor que quer suavizar e duração
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	
	#Criar DamageDigit (dano que o inimigo leva)
	var damage_digit = damage_digite_prefab.instantiate()
	damage_digit.value = amount
	if damage_digit_marker:
		damage_digit.global_position = damage_digit_marker.global_position
	else:
		damage_digit.global_position = global_position
	get_parent().add_child(damage_digit)
	
	
	
	#Processar morte
	if health <= 0:
		die()
		
		
func die() -> void:
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)	
	#Destruir coisas 
	queue_free()
	

