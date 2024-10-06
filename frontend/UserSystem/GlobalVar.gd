extends Node

var global_player_health = 100 ## 預設玩家血量

var user_email: String = "" ## 玩家帳號

var user_id = 1

var story = ""

var images = ""

var question1 = {}

var question2 = {}

#用以記錄wave3的問題、答案(格式同上)
var question3 = {}

var aiResponse = ""

var history_id = 5

var history_data = {}

var current_category = "Chinese"

var wave_data = {}

var battle_question = {}

var player_score = 0

var opponent_score = 0

var compete_id = 0

var opponent_id = 0

var player_selected_answer = ""

var opponent_selected_answer = ""
