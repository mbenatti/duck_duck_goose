# DuckDuckGoose

How to run:
  
  * mix deps.get
  * Run multiples nodes using `$ iex --sname node_name -S mix phx.server` (change `sname`) 
  * You can see the port on console to access the api  like `[info] Running DuckDuckGooseWeb.Endpoint with Bandit 1.5.0 at 127.0.0.1:36153 (http)`
 
Now you can visit [`127.0.0.1:36153/api/status`](http://127.0.0.1:36153/api/status) to see if desired node is a goose or a duck
also you can follow the logs to see what is happening