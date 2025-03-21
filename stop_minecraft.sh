#!/bin/bash

wait_java_stop() {
  for ((i=0; i<60; i++))
  do
    if ! systemctl is-active --quiet minecraft-java.service; then
      echo "Minecraft finished in $i seconds"
      return 0
    else
      echo "Waiting... $i"
    fi
    sleep 1
  done

  echo "Timed out waiting for Minecraft to stop."
  return 1
}

shutdown_minecraft() {
  # Send stop command
  # Be careful: writing to /run/minecraft-java.stdin while it's stopped will start Minecraft

  if systemctl is-active minecraft-java.service; then
    echo "stop" > /run/minecraft-java.stdin
    wait_java_stop
  fi
}

echo "Terminating Minecraft Java process"
shutdown_minecraft
