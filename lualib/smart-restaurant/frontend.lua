local Ingredients = require("smart-restaurant/ingredients")

local cjson = require("cjson")
local frontend = {}
frontend.server = {}
frontend.terminal = {}
frontend.control = {}
frontend.ingredients = Ingredients:new()

function frontend:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function frontend:register(target, obj)
	if target=="server" then
		self.server = obj
	end
	if target=="terminal" then
		self.terminal = obj
	end
	if target=="control" then
		self.control = obj
	end
end

function frontend:recv(ingres)
	ngx.log(ngx.INFO, "ingres:", cjson.encode(ingres))
	self.ingredients:add_group(ingres)
end

function frontend:watch()
	ngx.timer.every(2, terminal_watch, self.terminal, self.server, self.control, self.ingredients.inventory)
end

function terminal_watch(premature, terminal, server, control,  inventory)
	-- 实际中，是要定时查看的
	plate_num, watch_index = terminal:watch()
	ngx.log(ngx.INFO, "plate_num:", plate_num, "inventory:", #inventory)
	for i=2,2,#inventory do
		ngx.log(ngx.INFO, "i:",i, "inventory[i]:", inventory[i])
		if plate_num==inventory[i] then
			server:complete(inventory[i-1])
			inventory:remove(inventory[i-1])
			inventory:remove(plate_num)
			control:from_transfer()
		end
	end
end

function frontend:complete(ingre)
	self.server:complete(ingre)
end

return frontend