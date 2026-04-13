#!/bin/bash

echo "Remove existed container"
cd /home/ubuntu/scripts
docker-compose -f  down || true
