local cjson = require("cjson")
local frontend = {}
frontend.server = {}

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
end

function frontend:recv(ingres)
	ngx.log(ngx.INFO, "ingres:", cjson.encode(ingres))
end

function frontend:complete(ingre)
	self.server:complete(ingre)
end

return frontend