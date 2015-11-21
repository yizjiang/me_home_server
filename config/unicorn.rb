worker_processes 1

preload_app true

timeout 60

listen "/tmp/unicorn_server.sock", :backlog => 64
pid "/tmp/unicorn_server.pid"
