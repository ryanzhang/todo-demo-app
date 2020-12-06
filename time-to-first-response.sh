#/bin/bash
date
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost:8000/todo.html)" != "200" ]]; do sleep .00001; done
echo First response completed
date
