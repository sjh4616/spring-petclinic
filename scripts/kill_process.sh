#!/bin/bash
cd /home/ubuntu
docker compose -f scripts/docker-compose.yml down || true
