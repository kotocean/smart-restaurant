local Ingredients = require("smart-restaurant/ingredients")
local cjson = require("cjson")
local http = require("resty.http")

local backend = {}
backend.terminal_controls = {}

function backend:new(o, id)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.id = id
	return o
end

function backend:register(terminal, control)
	table.insert(self.terminal_controls, {terminal=terminal, control=control})
end

function backend:recv(ingres)
	ngx.log(ngx.INFO, "ingres:", cjson.encode(ingres))
	local ingredients = Ingredients:new(nil, "backend_" ..self.id)
	ingredients:add_group(ingres)
end

function backend:complete(ingre)
	ngx.log(ngx.INFO, "ingre:", ingre)
	local ingredients = Ingredients:new(nil, "backend_" ..self.id .."_complete")
	math.randomseed(os.time())
	local plate_num = math.random(1, 1000)
	ingredients:add_group({{ingre=ingre, plate_num=tostring(plate_num)}})
end

function backend:watch()
	ngx.timer.every(5, terminal_watch, notify_server, self.terminal_controls, self.id)
end

function notify_server(query)
	local httpc = http.new()
	local res, err = httpc:request_uri("http://127.0.0.1:8081/notify",{
		query = query
	})
	if not res then
		ngx.log(ngx.INFO, "failed to request:", err)
		return
	end
end

function terminal_watch(premature, notify_hdl,  terminal_controls, id)
	-- 实际中，是要定时查看的
	for i, slave in pairs(terminal_controls) do
		local terminal = slave.terminal
		local control = slave.control

		local plate_num, watch_index = terminal:watch()
		ngx.log(ngx.INFO, "plate_num:", plate_num, ",watch_index:", watch_index)
		if plate_num=="" then
			ngx.log(ngx.INFO, "backend_" ..id .."_complete")
			local ingredients = Ingredients:new(nil, "backend_" ..id .."_complete")

			local ready_obj = ingredients:remove_first() --获取第一个值，并从列表中移除
			-- 放上盘子
			if not ready_obj then
				ngx.log(ngx.INFO, "wait a minutes ...")
			else
				ngx.log(ngx.INFO, "actual plate_num:", ready_obj.plate_num, ",ingre:", ready_obj.ingre)
				control:to_transfer(ready_obj.plate_num)
				-- server:notify("frontend", 1, {ingre, plate_num_1})
				notify_hdl({
					target = "frontend",
					id = 1,
					ingres = {ready_obj.ingre, ready_obj.plate_num}
				})
			end
		end
	end
end

return backend