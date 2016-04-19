#!/usr/bin/env bash

PROXY=my.proxy.com
PORT=1080
EXCEPTIONS=/path/to/exceptions/file

if [ "$(id -u)" != "0" ]; then
   echo "Run this installer as root" 1>&2
   exit 1
fi

if [[ $# -eq 0 ]] ; then
  echo -e "\nUsage \n\n$0 --install \n\nOR\n\n$0 --upgrade\n"
  exit 0
fi

for i in "$@"
do
  case $i in
    --install)
      source <(wget -O- https://raw.githubusercontent.com/todorez/chameleonsocks/master/chameleonsocks-install.sh)
    ;;
    --upgrade)
      echo -e "\nStop chameleonsocks container"
      docker stop chameleonsocks

      echo -e "\nRemove chameleonsocks container"
      docker rm -f chameleonsocks

      echo -e "\nRemove chameleonsocks image"
      docker rmi todorez/chameleonsocks

      if [ $? -eq 0 ]; then
        echo -e "\nSUCCESS: Remove chameleonsocks image"
      else
        echo -e "\nFAIL: Remove chameleonsocks image"
        echo -e "\nIf chameleonsocks is not installed please run the "chameleonsocks.sh --install" instead"
        exit 0
      fi

      echo -e "\nInstall latest chameleonsocks image"
      source <(wget -O- https://raw.githubusercontent.com/todorez/chameleonsocks/master/chameleonsocks-install.sh)
    ;;
    *)
      echo -e "\nUsage \n\n$0 --install \n\nOR\n\n$0 --upgrade\n"
      exit 0
    ;;
  esac
done
