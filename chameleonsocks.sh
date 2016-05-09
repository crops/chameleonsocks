#
# Copyright (C) 2016 Intel Corporation
#
# Author: Todor Minchev <todor.minchev@linux.intel.com>
#
# This program is free software; you can redistribute it and/or modify it
# under the terms and conditions of the GNU General Public License,
# version 2, or (at your option) any later version, as published by
# the Free Software Foundation.
#
# This program is distributed in the hope it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#

#!/usr/bin/env bash

#Insert your PROXY, PORT and PROXY_TYPE below
#Possible PROXY_TYPE values: socks4, socks5, http-connect, http-relay
#If you do not provide an exceptions file, the default will be used
#####################################################################
PROXY=my.proxy.com
PORT=1080
PROXY_TYPE=socks5
EXCEPTIONS=/path/to/exceptions/file
#####################################################################
######     DO NOT MODIFY THE FILE BELOW THIS LINE   #################
#####################################################################

if [ "$(id -u)" != "0" ]; then
   echo "Run this installer as root" 1>&2
   exit 1
fi

IMAGE=crops/chameleonsocks:latest
DOCKER_UI=uifd/ui-for-docker
DEFAULT_EXCEPTIONS=https://raw.githubusercontent.com/crops/chameleonsocks/master/confs/chameleonsocks.exceptions

usage () {
  echo -e "\nUsage \n\n$0 [option]\n"
  echo -e "Options:\n"
  echo -e "--install      : Install chameleonsocks"
  echo -e "--upgrade      : Upgrade existing installation"
  echo -e "--uninstall    : Uninstall chameleonsocks"
  echo -e "--install-ui   : Install container management UI"
  echo -e "--uninstall-ui : Uninstall container management UI"
  echo -e "--start        : Stop chameleonsocks"
  echo -e "--stop         : Start chameleonsocks"
  echo -e "--version      : Display chameleonsocks version\n"
  exit 1;
}

remove_container () {
  local CONTAINER=$1
  echo -e "\nStop  $CONTAINER container"
  docker stop $CONTAINER || \
  { echo "Stopping $CONTAINER failed" ; exit 1; }

  echo -e "\nRemove $CONTAINER container"
  docker rm -f $CONTAINER || \
  { echo "Removing $CONTAINER container failed" ; exit 1; }
}

uninstall () {
  remove_container chameleonsocks
  echo -e "\nRemove chameleonsocks image"
  docker rmi $IMAGE || \
  { echo "Removing $IMAGE image failed" ; exit 1; }
}

check_docker () {
  docker -v && echo -e "Docker installation verified" || \
  { echo -e "\nPlease make sure that Docker is installed \
  and running"; exit 1; }
}

uninstall_ui () {
  remove_container dockerui
  echo -e "\nRemove DockerUI image"
  docker rmi $DOCKER_UI || \
  { echo "Removing $DOCKER_UI image failed" ; exit 1; }
}

chameleonsocks_install () {
  echo -e "\nDownloading chameleonsocks image"
  docker pull $IMAGE || \
  { echo "Downloading $IMAGE failed" ; exit 1; }

  echo -e "\nCreate chameleonsocks image"
  docker create --restart=always --privileged --name chameleonsocks --net=host -e PROXY=$PROXY -e PORT=$PORT -e PROXY_TYPE=$PROXY_TYPE $IMAGE || \
  { echo "Creating $IMAGE image failed" ; exit 1; }

  echo -e "\nImport firewall exceptions"
  if [ ! -f $EXCEPTIONS ]; then
    wget $DEFAULT_EXCEPTIONS
    EXCEPTIONS=`pwd`/chameleonsocks.exceptions
    docker cp $EXCEPTIONS chameleonsocks:/etc/chameleonsocks.exceptions || \
    { echo "Importing exceptions file failed" ; exit 1; }
    rm -rf $EXCEPTIONS
  else
    docker cp $EXCEPTIONS chameleonsocks:/etc/chameleonsocks.exceptions || \
    { echo "Importing exceptions file failed" ; exit 1; }
  fi

  echo -e "\nStarting chameleonsocks container"
  docker start chameleonsocks || \
  { echo "Startinging chameleonsocks container failed" ; exit 1; }
}

PROXY_TYPES="socks4
socks5
http-connect
http-relay
"

[[ $PROXY_TYPES =~ $PROXY_TYPE ]] && echo "Proxy Type: $PROXY_TYPE" \
|| { echo "Unsupported proxy type: $PROXY_TYPE" ; exit 1; }

check_docker

if [[ $# -eq 0 ]] ; then
  usage
fi

for i in "$@"
do
  case $i in
    --install)
      echo -e "\nInstalling latest chameleonsocks image"
      chameleonsocks_install
    ;;
    --upgrade)
      uninstall
      echo -e "\nInstalling latest chameleonsocks image"
      chameleonsocks_install
    ;;
    --uninstall)
      uninstall
    ;;
    --install-ui)
      docker run -d --restart=always -p 7777:9000 --privileged --name \
      dockerui -v /var/run/docker.sock:/var/run/docker.sock $DOCKER_UI \
      && echo -e "Access Docker UI on http://localhost:7777" \
      || { echo -e "\nInstalling Docker UI failed"; exit 1; }
    ;;
    --uninstall-ui)
      uninstall_ui
    ;;
    --start)
      docker start chameleonsocks || \
      { echo 'Starting chameleonsocks failed' ; exit 1; }
    ;;
    --stop)
      docker stop chameleonsocks || \
      { echo 'Stopping chameleonsocks failed' ; exit 1; }
    ;;
    --version)
      docker exec chameleonsocks cat /etc/chameleonsocks-version || \
      { echo 'Getting chameleonsocks version failed' ; exit 1; }
    ;;
    *)
      usage
    ;;
  esac
done
