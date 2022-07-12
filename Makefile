deploy:
	ssh private-isu " \
		cd /home/isucon; \
		git checkout .; \
		git fetch; \
		git checkout $(BRANCH); \
		git reset --hard origin/$(BRANCH)"

build:
	ssh private-isu " \
		cd /home/isucon/webapp/go; \
		/home/isucon/local/go/bin/go build -o isucondition main.go; \
		sudo systemctl restart isucondition.go"

mysql-deploy:
	ssh private-isu "sudo dd of=/etc/mysql/mysql.conf.d/mysqld.cnf" < ./etc/mysql/mysql.conf.d/mysqld.cnf

mysql-rotate:
	ssh private-isu "sudo rm -f /var/log/mysql/mysql-slow.log"

mysql-restart:
	ssh private-isu "sudo systemctl restart mysql.service"

nginx-reload:
	ssh private-isu "sudo systemctl reload nginx.service"

nginx-rotate:
	ssh private-isu "sudo rm -f /var/log/nginx/access.log"

nginx-restart:
	ssh private-isu "sudo systemctl restart nginx.service"

bench-run:
	ssh private-isu-bench " \
		cd /home/isucon/bench; \
		./bench -all-addresses 127.0.0.11 -target 127.0.0.11:443 -tls -jia-service-url http://127.0.0.1:4999"

pt-query-digest:
	ssh private-isu "sudo pt-query-digest --limit 10 /var/log/mysql/mysql-slow.log"

ALPSORT=sum
ALPM="/api/isu/.+/icon,/api/isu/.+/graph,/api/isu/.+/condition,/api/isu/[-a-z0-9]+,/api/condition/[-a-z0-9]+,/api/catalog/.+,/api/condition\?,/isu/........-....-.+,/?jwt=.+"
OUTFORMAT=count,method,uri,min,max,sum,avg,p99

alp:
	ssh private-isu "sudo alp ltsv --file=/var/log/nginx/access.log --nosave-pos --pos /tmp/alp.pos --sort $(ALPSORT) --reverse -o $(OUTFORMAT) -m $(ALPM) -q"

pprof-kill:
	ssh private-isu "pgrep -f 'pprof' | xargs kill;"

pprof:
	ssh private-isu "/home/isucon/local/go/bin/go tool pprof -http=0.0.0.0:1080 webapp/go/isucondition http://localhost:6060/debug/pprof/profile?seconds=75"
