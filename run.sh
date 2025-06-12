#!/bin/bash
docker rm -f nomad 2>/dev/null || true

docker volume create --name "mc"

docker run --rm -d \
  --name nomad \
  -p 4646:4646 \
  -p 25565:25565 \
  --privileged \
  -v //var/run/docker.sock:/var/run/docker.sock \
  -v mc:/minecraft \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  --cgroupns=host \
  hashicorp/nomad:1.7.6 \
  nomad agent -dev -bind=0.0.0.0

sleep 5

docker exec nomad mkdir -p /home/minecraft
docker cp minecraft.hcl nomad:/home/minecraft/

# Nomad dev server started with:
# Web UI at http://localhost:4646
# Volume mounted at /minecraft
# Job file available at /home/minecraft/minecraft.hcl
