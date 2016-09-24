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
  run docker exec nginx /bin/bash -c "curl -I -s -L http://localhost/index.html | head -n 1 | cut -d$' ' -f2"
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}

@test "checking request: content (index.html via http)" {
  run docker exec nginx /bin/bash -c "curl -s -L http://localhost/index.html | wc -l"
  [ "$status" -eq 0 ]
  [ "$output" -eq 18 ]
}
