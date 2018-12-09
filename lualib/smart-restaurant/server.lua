local Ingredients = require("smart-restaurant/ingredients")

local server={}

server.name = "Smart Restaurant Server"
server.backends = {}
server.frontends = {}
server.ingredients = Ingredients:new()

function server:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function server:register(target, obj)
	if target=="backend" then
		table.insert(self.backends, obj)
	end
	if target=="frontend" then
		table.insert(self.frontends, obj)
	end
end


function server:recv(ingres)
	ngx.log(ngx.INFO, "ingres:", table.maxn(ingres))
	for index, ingre in pairs(ingres) do
		self.ingredients:add(ingre)
	end
	ngx.log(ngx.INFO, table.maxn(self.ingredients.inventory))
	--派发出去
	local n = table.maxn(self.backends)
	ngx.log(ngx.INFO, "backends maxn:", n)
	math.randomseed(os.time())
	if n>0 then
		local target_index = math.random(1, n)
		self:notify("backend", target_index, ingres)
	end
end

function server:notify(target, index, ingres)
	ngx.log(ngx.INFO, 	"target:",target, ",index:", index,",ingres:", table.maxn(ingres))

	if target=="backend" then
		self.backends[index]:recv(ingres)
	end

	if target=="frontend" then
		self.frontends[index]:recv(ingres)
	end
end

function server:complete(ingre)
	self.ingredients:remove(ingre)
	-- 标记食材已成功被消费者取走
	ngx.log(ngx.INFO, "ingre:", ingre, " complete!")
end

return server