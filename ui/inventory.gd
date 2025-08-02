extends Control

var inventory = {
	"trap":0,
	"branch":0
}

@onready var item_list = $ItemList

func _ready():
	update_item_list()

func update_item_list():
	item_list.clear()
	for item_name in inventory.keys():
		var amount = inventory[item_name]
		item_list.add_item("%s: %d" % [item_name.capitalize(), amount])
