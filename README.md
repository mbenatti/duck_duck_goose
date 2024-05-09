# DuckDuckGoose


The objective of this project is to evaluate the functionality, reliability, and fault tolerance of a system designed to select a single node as a "Goose" within a cluster of nodes, with all other nodes designated as "Ducks." The system should dynamically handle node failures, rejoins, and network partitions while ensuring that only one Goose node is active at any given time.


Technologies used:

- Libcluster
- OTP(genserver, etc)
- Phoenix framework 
- Elixir 

Technical details

1) Design Verification:
Selection of a Goose node, handling of node failures and rejoins,
2) Node Selection:
Selects one node as the Goose and designates all other nodes as Ducks.
3) Failover Mechanism:
Simulate the failure of the current Goose node and verify that another Duck node is automatically promoted to become the new Goose.
Validate that the failover process occurs seamlessly without impacting the overall operation of the system.
4) Goose Rejoin:
Simulate the rejoining of a previously failed Goose node and confirm that it is appropriately demoted to a Duck if another Goose node is already active.

How to run:
  
  * mix deps.get
  * Run multiples nodes using `$ iex --sname node_name -S mix phx.server` (change `sname`) 
  * You can see the port on console to access the api  like `[info] Running DuckDuckGooseWeb.Endpoint with Bandit 1.5.0 at 127.0.0.1:36153 (http)`
 
Now you can visit [`127.0.0.1:36153/api/status`](http://127.0.0.1:36153/api/status) to see if desired node is a goose or a duck
also you can follow the logs to see what is happening