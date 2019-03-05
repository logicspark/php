#!/bin/bash
TAG="$(git symbolic-ref HEAD 2>/dev/null)" ||
TAG="(unnamed branch)"     # detached HEAD
TAG=${TAG##refs/heads/}


docker build -t logicspark/php:$TAG .
docker rm test-php

docker run --rm -it --name test-php -v `pwd`/sss:/data -p 8989:80 logicspark/php:$TAG bash