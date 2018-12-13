## Smart Restaurant
> 基于Nginx Openresty Lua开发

```bash
nginx -c conf/nginx.conf
nginx -c conf/nginx.conf -s reload
nginx -c conf/nginx.conf -s stop
```

## 模拟启动
1. 启动runner：http://localhost:8080/
2. 模拟已经有菜品在旋转：http://localhost:8080/set?i=10&v=20306
3. 模拟接收用户订单，同时分发到backend：http://localhost:8081/
4. 模拟用户消费菜品：http://localhost:8082/complete?ingre=黄瓜