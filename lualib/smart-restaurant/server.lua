local Ingredients = require("smart-restaurant/ingredients")
local cjson = require("cjson")
local http = require "resty.http"

local server={}

server.name = "Smart Restaurant Server"
server.backends = {}
server.frontends = {}
server.ingredients = Ingredients:new(nil, "server")

function server:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function server:register(target, id)
	if target=="backend" then
		table.insert(self.backends, id)
	end
	if target=="frontend" then
		table.insert(self.frontends, id)
	end
end


function server:recv(ingres)
	ngx.log(ngx.INFO, "ingres:", #ingres)
	self.ingredients:set(ingres)
	ngx.log(ngx.INFO, cjson.encode(self.ingredients:get()))
	--派发出去
	local n = #self.backends
	ngx.log(ngx.INFO, "backends nums:", n)
	math.randomseed(os.time())
	if n>0 then
		-- 随机选择一个备菜端 1~n
		local index = math.random(1, n)
		self:notify("backend", self.backends[index], ingres)
	end
end

function server:notify(target, id, ingres)
	ngx.log(ngx.INFO, 	"---------->>>>>>>>>> target:",target, ",id:", id,",ingres:", #ingres)

	if target=="backend" then
		ngx.log(ngx.INFO, "backend:", id, ",ingres:", cjson.encode(ingres))

		local httpc = http.new()
		local res, err = httpc:request_uri("http://127.0.0.1:8082/recv",{
			query = {
				id = id,
				ingres = ingres
			}
		})
		if not res then
			ngx.log(ngx.INFO, "failed to request:", err)
			return
		end
	end

	if target=="frontend" then
		ngx.log(ngx.INFO, "frontend:", id, ",ingres:", cjson.encode(ingres))

		local httpc = http.new()
		local res, err = httpc:request_uri("http://127.0.0.1:8083/recv",{
			query = {
				id = id,
				ingres = ingres
			}
		})
		if not res then
			ngx.log(ngx.INFO, "failed to request:", err)
			return
		end
	end
end

function server:complete(id, ingre)
	self.ingredients:remove(ingre)
	-- 标记食材已成功被消费者取走
	if type(ingre)=="table" then
		ngx.log(ngx.INFO, "frontend:", id, ",ingre:", cjson.encode(ingre), " complete!")
	else
		ngx.log(ngx.INFO, "frontend:", id, ",ingre:", ingre, " complete!")
	end
end

return server