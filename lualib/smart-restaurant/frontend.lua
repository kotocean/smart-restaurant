local Ingredients = require("smart-restaurant/ingredients")

local cjson = require("cjson")
local http = require("resty.http")

local frontend = {}
frontend.terminal = {}
frontend.control = {}

function frontend:new(o, id)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.id = id
	return o
end

function frontend:register(target, obj)
	if target=="terminal" then
		self.terminal = obj
	end
	if target=="control" then
		self.control = obj
	end
end

function frontend:recv(ingres)
	ngx.log(ngx.INFO, "ingres:", cjson.encode(ingres))
	
	local ingredients = Ingredients:new(nil, "frontend_" ..self.id)
	ingredients:add_group({{ingre=ingres[1], plate_num=ingres[2]}}) -- 多次接收放到列表中
end

function complete_server(query)
	local httpc = http.new()
	local res, err = httpc:request_uri("http://127.0.0.1:8081/complete",{
		query = query
	})
	if not res then
		ngx.log(ngx.INFO, "failed to request:", err)
		return
	end
end

function frontend:status()
	local ingredients = Ingredients:new(nil, "frontend_" ..self.id)
	return ingredients:get()
end

function frontend:watch()
	ngx.timer.every(5, terminal_watch, complete_server, self.terminal, self.control, self.id)
end

function terminal_watch(premature, complete_hdl, terminal, control, id)
	-- 实际中，是要定时查看的
	plate_num, watch_index = terminal:watch()
	ngx.log(ngx.INFO, "plate_num:", plate_num, ",watch_index:", watch_index)
	
	if plate_num ~= "" then
		local ingredients = Ingredients:new(nil, "frontend_" ..id)
		local ready_list = ingredients:get()

		ngx.log(ngx.INFO, "ready_list:", cjson.encode(ready_list))
		-- 放上盘子
		if not ready_list then
			ngx.log(ngx.INFO, "wait a minutes ...")
		else
			for i, ingre in pairs(ready_list) do
				ngx.log(ngx.INFO, "frontend_watch_ingre:", cjson.encode(ingre))
				if ingre.plate_num == plate_num then
					control:from_transfer(plate_num)
					ingredients:remove(ingre)
					-- server complete
					complete_hdl({
						id = 1,
						ingre = ingre
					})
					return
				end
			end
			ngx.log(ngx.INFO, "wait a minutes ...")
		end
	end
end

return frontend