local backend = {}
backend.server = {}
backend.terminal = {}
backend.control = {}

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
	ngx.log(ngx.INFO, "ingres:", table.maxn(ingres))
end

function backend:complete(frontend_index, ingre)
	self.server:notify("frontend", frontend_index, {ingre})
end

function backend:watch(frontend_index, ingre)
	ngx.timer.every(2, terminal_watch, self.terminal, self.server, self.control, frontend_index, ingre)
end

function terminal_watch(premature, terminal, server, control, frontend_index, ingre)
	-- 实际中，是要定时查看的
	plate_num, watch_index = terminal:watch()
	ngx.log(ngx.INFO, "plate_num:", plate_num)
	if plate_num==0 then
		math.randomseed(os.time())
		plate_num = math.random(1, 1000)
		-- 放上盘子
		control:to_transfer(plate_num)
		server:notify("frontend", frontend_index, {ingre, plate_num})
	end
end

return backend