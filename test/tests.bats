@test "checking process: nginx (master process)" {
  run docker exec nginx /bin/bash -c "ps aux | grep -v grep | grep 'nginx: master process /usr/sbin/nginx'"
  [ "$status" -eq 0 ]
}

@test "checking process: nginx (worker process)" {
  run docker exec nginx /bin/bash -c "ps aux | grep -v grep | grep 'nginx: worker process'"
  [ "$status" -eq 0 ]
}

@test "checking process: nginx (master process disabled by DISABLE_NGINX)" {
  run docker exec nginx_no_nginx /bin/bash -c "ps aux | grep -v grep | grep 'nginx: master process /usr/sbin/nginx'"
  [ "$status" -eq 1 ]
}

@test "checking process: nginx (worker process disabled by DISABLE_NGINX)" {
  run docker exec nginx_no_nginx /bin/bash -c "ps aux | grep -v grep | grep 'nginx: worker process'"
  [ "$status" -eq 1 ]
}

@test "checking request: status (index.html via http)" {
  run docker exec nginx /bin/bash -c "curl -i -s -L http://localhost/index.html | head -n 1 | cut -d$' ' -f2"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "checking request: content (index.html via http)" {
  run docker exec nginx /bin/bash -c "curl -s -L http://localhost/index.html | wc -l"
  [ "$status" -eq 0 ]
  [ "$output" -eq 18 ]
}

@test "checking request: status (50x.html via http)" {
  run docker exec nginx /bin/bash -c "curl -i -s -L http://localhost/.500test | head -n 1 | cut -d$' ' -f2"
  [ "$status" -eq 0 ]
  [ "$output" -eq 502 ]
}

@test "checking request: content (50x.html via http)" {
  run docker exec nginx /bin/bash -c "curl -s -L http://localhost/.500test | grep '<h1>An error occurred.</h1>'"
  [ "$status" -eq 0 ]
}

@test "checking request: status (405.html via http)" {
  run docker exec nginx /bin/bash -c "curl -i -s -L -X OPTIONS http://localhost/.500test | head -n 1 | cut -d$' ' -f2"
  [ "$status" -eq 0 ]
  [ "$output" -eq 405 ]
}

@test "checking request: content (405.html via http)" {
  run docker exec nginx /bin/bash -c "curl -i -s -L -X OPTIONS http://localhost/.500test | grep '<h1>Method not allowed</h1>'"
  [ "$status" -eq 0 ]
}

@test "checking request: status (403.html via http)" {
  run docker exec nginx /bin/bash -c "curl -i -s -L http://localhost/.403test | head -n 1 | cut -d$' ' -f2"
  [ "$status" -eq 0 ]
  [ "$output" -eq 403 ]
}

@test "checking request: content (403.html via http)" {
  run docker exec nginx /bin/bash -c "curl -i -s -L http://localhost/.403test | grep '<h1>Access Denied</h1>'"
  [ "$status" -eq 0 ]
}

@test "checking request: status (404.html via http)" {
  run docker exec nginx /bin/bash -c "curl -i -s -L http://localhost/.404test | head -n 1 | cut -d$' ' -f2"
  [ "$status" -eq 0 ]
  [ "$output" -eq 404 ]
}

@test "checking request: content (404.html via http)" {
  run docker exec nginx /bin/bash -c "curl -i -s -L http://localhost/.404test | grep '<h1>File not found</h1>'"
  [ "$status" -eq 0 ]
}

@test "checking request: project_intial (index.html via http)" {
  run docker exec nginx_project /bin/bash -c "curl -s -L http://localhost/index.html | wc -l"
  [ "$status" -eq 0 ]
  [ "$output" -eq 272 ]
}

@test "checking request: project_initial (index.html via proxy)" {
  run docker exec nginx_proxy /bin/bash -c "curl -s -L http://localhost/index.html | wc -l"
  [ "$status" -eq 0 ]
  [ "$output" -eq 272 ]
}

@test "checking request: project_updated (index.html via http)" {
  docker stop nginx_project nginx_proxy || true
  docker rm nginx_project nginx_proxy || true
  docker run -d \
    -e DEBUG=true \
    -v /tmp/nginx_project/etc:/etc/nginx/conf.d \
    -v /tmp/nginx_project/html:/var/www/html \
    -e INSTALL_PROJECT=1 \
    -e PROJECT_GIT_REPO=https://github.com/BlackrockDigital/startbootstrap-creative.git \
    -e PROJECT_GIT_TAG=v5.1.4 \
    --name nginx_project madharjan/docker-nginx:1.10.3 
  sleep 3

  docker run -d \
  --link nginx_project:project \
  -e DEBUG=true \
  -e DEFAULT_PROXY=1 \
  -e PROXY_HOST=project \
  -e PROXY_PORT=80 \
  --name nginx_proxy madharjan/docker-nginx:1.10.3 

	sleep 2
  run docker exec nginx_project /bin/bash -c "curl -s -L http://localhost/index.html | wc -l"
  [ "$status" -eq 0 ]
  [ "$output" -eq 262 ]
}

@test "checking request: project_updated (index.html via proxy)" {
  run docker exec nginx_proxy /bin/bash -c "curl -s -L http://localhost/index.html | wc -l"
  [ "$status" -eq 0 ]
  [ "$output" -eq 262 ]
}

@test "checking request: status (50x.html via proxy)" {
  run docker exec nginx_proxy /bin/bash -c "curl -i -s -L http://localhost/.500test | head -n 1 | cut -d$' ' -f2"
  [ "$status" -eq 0 ]
  [ "$output" -eq 502 ]
}

@test "checking request: content (50x.html via proxy)" {
  run docker exec nginx_proxy /bin/bash -c "curl -s -L http://localhost/.500test | grep '<h1>An error occurred.</h1>'"
  [ "$status" -eq 0 ]
}

@test "checking request: status (405.html via proxy)" {
  run docker exec nginx_proxy /bin/bash -c "curl -i -s -L -X DELETE http://localhost/.500test | head -n 1 | cut -d$' ' -f2"
  [ "$status" -eq 0 ]
  [ "$output" -eq 405 ]
}

@test "checking request: content (405.html via proxy)" {
  run docker exec nginx_proxy /bin/bash -c "curl -i -s -L -X DELETE http://localhost/.500test | grep '<h1>Method not allowed</h1>'"
  [ "$status" -eq 0 ]
}

@test "checking request: status (403.html via proxy)" {
  run docker exec nginx_proxy /bin/bash -c "curl -i -s -L http://localhost/.403test | head -n 1 | cut -d$' ' -f2"
  [ "$status" -eq 0 ]
  [ "$output" -eq 403 ]
}

@test "checking request: content (403.html via proxy)" {
  run docker exec nginx_proxy /bin/bash -c "curl -i -s -L http://localhost/.403test | grep '<h1>Access Denied</h1>'"
  [ "$status" -eq 0 ]
}

@test "checking request: status (404.html via proxy)" {
  run docker exec nginx_proxy /bin/bash -c "curl -i -s -L http://localhost/.404test | head -n 1 | cut -d$' ' -f2"
  [ "$status" -eq 0 ]
  [ "$output" -eq 404 ]
}

@test "checking request: content (404.html via proxy)" {
  run docker exec nginx_proxy /bin/bash -c "curl -i -s -L http://localhost/.404test | grep '<h1>File not found</h1>'"
  [ "$status" -eq 0 ]
}

