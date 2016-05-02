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

PROXY=my.proxy.com
PORT=1080
EXCEPTIONS=/path/to/exceptions/file

if [ "$(id -u)" != "0" ]; then
   echo "Run this installer as root" 1>&2
   exit 1
fi


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
  docker rmi todorez/chameleonsocks

  if [ $? -eq 0 ]; then
    echo -e "\nRemoved chameleonsocks image"
  else
    echo -e "\nFailed to remove chameleonsocks image"; exit 1
  fi
}


check_docker () {
  docker -v
  if [ $? -eq 0 ]; then
   echo -e "Docker installation verified"
  else
    echo -e "\nPlease make sure that Docker is installed and running"; exit 1
  fi
}


uninstall_ui () {
  remove_container dockerui
  echo -e "\nRemove DockerUI image"
  docker rmi uifd/ui-for-docker

  if [ $? -eq 0 ]; then
    echo -e "\nRemoved DockerUI image"
  else
    echo -e "\nFailed to remove DockerUI image"; exit 1
  fi
}

check_docker

if [[ $# -eq 0 ]] ; then
  usage
fi

for i in "$@"
do
  case $i in
    --install)
      source <(wget -O- https://raw.githubusercontent.com/todorez/chameleonsocks/master/chameleonsocks-install.sh) || \
      { echo 'Downloading chameleonsocks failed' ; exit 1; }
    ;;
    --upgrade)
      uninstall
      echo -e "\nInstall latest chameleonsocks image"
      source <(wget -O- https://raw.githubusercontent.com/todorez/chameleonsocks/master/chameleonsocks-install.sh) || \
      { echo 'Installing chameleonsocks failed' ; exit 1; }
    ;;
    --uninstall)
      uninstall
    ;;
    --install-ui)
      docker run -d --restart=always -p 7777:9000 --privileged --name \
      dockerui -v /var/run/docker.sock:/var/run/docker.sock \
      uifd/ui-for-docker

      if [ $? -eq 0 ]; then
        echo -e "\nAccess Docker UI on http://localhost:7777"
      else
        echo -e "\nInstalling Docker UI failed" ; exit 1;
      fi
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
