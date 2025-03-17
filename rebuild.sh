#!/bin/bash

function _rebuildPhpmyadmin() {
  docker-compose --env-file .env up -d --build --force-recreate --remove-orphans phpmyadmin
}

function _rebuildNginx() {
  docker-compose --env-file .env up -d --build --force-recreate --remove-orphans nginx
}

function _rebuildApp() {
  docker-compose --env-file .env up -d --build --force-recreate --remove-orphans app
}

function _rebuildPhp74() {
  docker-compose --env-file .env up -d --build --force-recreate --remove-orphans php74
}

case $1 in
  "phpmyadmin") _rebuildPhpmyadmin ;;
  "nginx") _rebuildNginx ;;
  "app") _rebuildApp ;;
  "php74") _rebuildPhp74 ;;
esac
