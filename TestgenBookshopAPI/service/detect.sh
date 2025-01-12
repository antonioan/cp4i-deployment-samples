#!/bin/bash

overlay_dir="/var/lib/containers/storage/overlay"
overlay_dir2="/var/lib/docker/overlay2"
containers=$(sudo docker ps -a --format "{{.ID}}")

echo "Mapping overlay directories to containers and images:"

for container in $containers; do
  # Inspect the container metadata
  metadata=$(sudo docker inspect $container)
  
  # Extract writable layer and image name
  rootfs=$(echo "$metadata" | jq -r '.[0].GraphDriver.Data.MergedDir')
  lowerdirs=$(echo "$metadata" | jq -r '.[0].GraphDriver.Data.LowerDir')
  image=$(echo "$metadata" | jq -r '.[0].Image')
  
  echo "Container ID: $container"
  echo "Image: $image"

  # Ensure the directory is under the overlay_dir path
  if [[ "$rootfs" == "$overlay_dir"* ]]; then
    echo "Writeable Layer: ${rootfs#$overlay_dir/}"
  elif [[ "$rootfs" == "$overlay_dir2"* ]]; then
    echo "Writeable Layer 2: ${rootfs#$overlay_dir2/}"
  else
    echo "Writeable Layer: Not found under $overlay_dir or $overlay_dir2"
  fi
  
  # List all referenced layers
  if [[ -n "$lowerdirs" ]]; then
    echo "Referenced Layers:"
    echo "$lowerdirs" | tr ':' '\n' | sed "s|^$overlay_dir/||"
  fi
  
  echo
done

