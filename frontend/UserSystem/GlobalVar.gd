extends Node

var global_player_health = 100 ## 預設玩家血量

var user_email: String = "" ## 玩家帳號


var user_id: int ##玩家id

#用以記錄wave2的問題、答案(格式為: 問題, answer, option1, option2, option3, option4)
var question2 = []

#用以記錄wave3的問題、答案(格式同上)
var question3 = []

var aiResponse = ""
