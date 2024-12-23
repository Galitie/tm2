extends Resource

@export var title : String
@export_enum("tst1", "test12") var stat1 : int
@export_range(0,10) var stat1_value : int
@export_range(0,10) var stat2_value : int

func _init(card_title="Placeholder", card_stat1 = 0, card_stat1_value = 0, card_stat2_value = 0):
	title = card_title
	stat1 = card_stat1
	stat1_value = card_stat1_value
	stat2_value = card_stat2_value
