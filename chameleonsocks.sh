#!/bin/bash
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

#If you do not provide an exceptions file, the default will be used
#####################################################################
# This is the domain name or ip address of your proxy server. It must
# be defined or nothing will work. Do not specify a protocol type
# such as http:// or https://.
: ${PROXY:=my.proxy.com}
# This is the port number of your proxy server
: ${PORT:=1080}
# Possible PROXY_TYPE values: socks4, socks5, http-connect, http-relay
: ${PROXY_TYPE:=socks5}
# a file containing local company specific exceptions
: ${EXCEPTIONS:=/path/to/exceptions/file}
# Autoproxy url, this is often something like
# http://autoproxy.server.com or http://wpad.server.com/wpad.out
# ONLY additional exceptions are pulled from here. not the proxy
# ${PAC_URL=http://my.pacfile-server.com}

#####################################################################
######     DO NOT MODIFY THE FILE BELOW THIS LINE   #################
#####################################################################

SUDO=`which sudo`
if [ ${SUDO} == "" ] && [ "$(id -u)" != "0" ]; then
   echo "Need sudo for this to run or you need to be root" 1>&2
   exit 1
fi
if [ "$(id -u)" = "0" ]; then
    SUDO=""
fi

VERSION=1.2
IMAGE=crops/chameleonsocks:$VERSION
DOCKER_UI=uifd/ui-for-docker
DEFAULT_EXCEPTIONS=https://raw.githubusercontent.com/crops/chameleonsocks/master/confs/chameleonsocks.exceptions
DOCKER_IMAGE=https://github.com/crops/chameleonsocks/releases/download/v$VERSION/chameleonsocks-$VERSION.tar.gz

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
  docker rmi -f $(docker images | awk '$1 ~ /crops[/]chameleonsocks/ { print $3 }') || \
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

chameleonsocks_start () {
    if docker start chameleonsocks > /dev/null 2>&1; then
	echo "started"
	return
    else
	echo "No Existing Container. Trying to recreate one..."
    fi
    if [ "$PROXY" = "my.proxy.com" ] ||  [ "x$PROXY" = "x" ]; then
	echo "PROXY must be set either in this file (above) or in the environment"
	exit 1;
    fi

    echo -e "\nCreate chameleonsocks image"
    ${SUDO} docker create --restart=always --privileged --name chameleonsocks --net=host -e PROXY=$PROXY -e PORT=$PORT -e PROXY_TYPE=$PROXY_TYPE -e PAC_URL=$PAC_URL $IMAGE  || \
	{ echo "Creating $IMAGE image failed" ; exit 1; }

    echo -e "\nImport firewall exceptions"
    if [ ! -f $EXCEPTIONS ]; then
	echo "Overriding exceptions with default exceptions"
	EXCEPTIONS=`pwd`/chameleonsocks.exceptions
	if [ ! -f $EXCEPTIONS ]; then
	    echo "Grabbing default exceptions from chameleonsocks github"
	    wget $DEFAULT_EXCEPTIONS
	fi
	docker cp $EXCEPTIONS chameleonsocks:/etc/chameleonsocks.exceptions || \
	    { echo "Importing exceptions file failed" ; exit 1; }
	rm -rf $EXCEPTIONS
    else
	echo "Using $EXCEPTIONS for chameleonsocks exceptions if these do not "
	echo "include the default exceptions, you may want to add them"
	docker cp $EXCEPTIONS chameleonsocks:/etc/chameleonsocks.exceptions || \
	    { echo "Importing exceptions file failed" ; exit 1; }
    fi

    echo -e "\nStarting chameleonsocks container"
    docker start chameleonsocks || \
	{ echo "Startinging chameleonsocks container failed" ; exit 1; }


}

chameleonsocks_install () {
if docker images $IMAGE | grep -q chameleonsocks; then
    echo -e "$IMAGE found. Skipping the redownload. \nDo $0 --uninstall to force"
else
    echo -e "\nDownloading chameleonsocks image"
    FILENAME=$(basename "$DOCKER_IMAGE")
    wget $DOCKER_IMAGE && gunzip -c ./$FILENAME | docker load && rm -rf ./$FILENAME || \
	{ echo "Downloading $IMAGE failed" ; exit 1; }
fi
    chameleonsocks_start
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
      ${SUDO} docker run -d --restart=always -p 7777:9000 --privileged --name \
      dockerui -v /var/run/docker.sock:/var/run/docker.sock $DOCKER_UI \
      && echo -e "Access Docker UI on http://localhost:7777" \
      || { echo -e "\nInstalling Docker UI failed"; exit 1; }
    ;;
    --uninstall-ui)
      uninstall_ui
    ;;
    --start)
     chameleonsocks_start
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
