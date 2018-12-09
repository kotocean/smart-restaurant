local cjson = require("cjson")

local terminal = {}
-- 当前读码器对应的桌号
terminal.table_number = 0
terminal.watch_index = 0

function terminal:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function terminal:set_table_number(number)
	self.table_number = number
end

function terminal:set_watch_index(index)
	self.watch_index = index
end

function terminal:watch()
	transfer_space = ngx.shared.share_transfer_space:get("transfer_space")
	ngx.log(ngx.INFO, "transfer_space:", transfer_space, ", watch_index:", self.watch_index)
	plate_space = cjson.decode(transfer_space)
	-- 返回观测到的当前位置的盘号
	return plate_space[self.watch_index], self.watch_index
end

return terminal