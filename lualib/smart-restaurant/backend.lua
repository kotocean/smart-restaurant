local Ingredients = require("smart-restaurant/ingredients")
local cjson = require("cjson")
local http = require("resty.http")

local backend = {}
backend.terminal = {}
backend.control = {}

function backend:new(o, id)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	self.id = id
	return o
end

function backend:register(target, obj)
	if target=="terminal" then
		self.terminal = obj
	end
	if target=="control" then
		self.control = obj
	end
end

function backend:recv(ingres)
	ngx.log(ngx.INFO, "ingres:", cjson.encode(ingres))
	local ingredients = Ingredients:new(nil, "backend_" ..self.id)
	ingredients:set(ingres)
end

function backend:complete(ingre)
	ngx.log(ngx.INFO, "ingre:", ingre)
	local ingredients = Ingredients:new(nil, "backend_" ..self.id .."_complete")
	math.randomseed(os.time())
	local plate_num = math.random(1, 1000)
	ingredients:set({ingre=ingre, plate_num=tostring(plate_num)})
	-- local httpc = http.new()
	-- local res, err = httpc:request_uri("http://127.0.0.1:8081/notify",{
	-- 	query = {
	-- 		target = "fronted",
	-- 		id = frontend_id,
	-- 		ingres = {ingre}
	-- 	}
	-- })
	-- if not res then
	-- 	ngx.log(ngx.INFO, "failed to request:", err)
	-- 	return
	-- end
end

function backend:watch()
	ngx.timer.every(5, terminal_watch, self.terminal, self.control, self.id)
end

function terminal_watch(premature, terminal, control, id)
	
	ngx.log(ngx.INFO, "backend_id:", id)
	-- 实际中，是要定时查看的
	local plate_num, watch_index = terminal:watch()
	ngx.log(ngx.INFO, "plate_num:", plate_num, ",watch_index:", watch_index)
	if plate_num=="" then
		ngx.log(ngx.INFO, "backend_" ..id .."_complete")
		local ingredients = Ingredients:new(nil, "backend_" ..id .."_complete")
		local ready_obj = ingredients:get()
		-- 放上盘子
		if not ready_obj then
			ngx.log(ngx.INFO, "wait a minutes ...")
		else
			ngx.log(ngx.INFO, "actual plate_num:", ready_obj.plate_num, ",ingre:", ready_obj.ingre)
			control:to_transfer(ready_obj.plate_num)
			ingredients:delete()
			-- server:notify("frontend", 1, {ingre, plate_num_1})
		end
	end
end

return backend