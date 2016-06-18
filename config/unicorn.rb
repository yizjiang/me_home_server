root = "/Users/meejia/me_home_server"
working_directory root

worker_processes 2

preload_app true

timeout 60
listen "/var/run/unicorn/meejia/server.sock", :backlog => 64
pid "/var/run/unicorn/meejia/server.pid"
stderr_path "/tmp/unicorn/meejia/log/server.stderr.log"
stdout_path "/tmp/unicorn/meejia/log/server.stdout.log"
