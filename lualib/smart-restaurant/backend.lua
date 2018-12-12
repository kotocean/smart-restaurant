local Ingredients = require("smart-restaurant/ingredients")

local backend = {}
backend.server = {}
backend.terminal = {}
backend.control = {}
backend.ingredients = Ingredients:new()

function backend:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function backend:register(target, obj)
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

function backend:recv(ingres)
	ngx.log(ngx.INFO, "ingres:", #ingres)
	self.ingredients:add_group(ingres)
end

function backend:complete(frontend_index, ingre)
	self.server:notify("frontend", frontend_index, {ingre})
end

function backend:watch()
	ngx.timer.every(3, terminal_watch, self.terminal, self.server, self.control, self.ingredients.inventory)
end

function terminal_watch(premature, terminal, server, control, inventory)
	math.randomseed(os.time())
	local ingre = inventory[math.random(1, #inventory)]
	ngx.log(ngx.INFO, "ingre:", ingre)
	-- 实际中，是要定时查看的
	local plate_num, watch_index = terminal:watch()
	ngx.log(ngx.INFO, "plate_num:", plate_num)
	if plate_num==0 then
		local plate_num_1 = math.random(1, 1000)
		-- 放上盘子
		ngx.log(ngx.INFO, "actual plate_num", plate_num_1)
		control:to_transfer(plate_num_1)
		server:notify("frontend", 1, {ingre, plate_num_1})
	end
end

return backend