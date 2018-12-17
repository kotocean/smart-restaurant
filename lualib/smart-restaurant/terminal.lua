local cjson = require("cjson")

local terminal = {}

function terminal:new(o, watch_index)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.watch_index = watch_index
	return o
end

function read_share_transfer_space()
	local share_transfer_space = ngx.shared.share_transfer_space:get("share_transfer_space")
	return cjson.decode(share_transfer_space)
end

function terminal:watch()
	local transfer_space = read_share_transfer_space()
	ngx.log(ngx.INFO, "transfer_space:", cjson.encode(transfer_space), ", watch_index:", self.watch_index)
	-- 返回观测到的当前位置的盘号
	ngx.log(ngx.INFO, transfer_space[self.watch_index], ",", self.watch_index)
	return transfer_space[self.watch_index], self.watch_index
end

return terminal