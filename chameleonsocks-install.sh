# Do not exacute or source this file directly. It will be sourced by chameleonsocks.sh

echo -e "\nDownload chameleonsocks image"
wget https://dl.dropboxusercontent.com/u/19449889/chameleonsocks.tar

if [ $? -eq 0 ]; then
  echo -e "\nSUCCESS: Download chameleonsocks image"
else
  echo -e "\nFAIL: Download chameleonsocks image"
  return
fi

echo -e "\nLoad chameleonsocks image"
docker load < chameleonsocks.tar

if [ $? -eq 0 ]; then
  echo -e "\nSUCCESS: Load chameleonsocks image"
else
  echo -e "\nFAIL: Load chameleonsocks image"
  return
fi

echo -e "\nRemove temporary chameleonsocks image tarball"
rm -rf ./chameleonsocks.tar

echo -e "\nCreate chameleonsocks image"
docker create --restart=always --privileged --name chameleonsocks --net=host -e PROXY=$PROXY -e PORT=$PORT todorez/chameleonsocks:latest

if [ $? -eq 0 ]; then
  echo -e "\nSUCCESS: Create chameleonsocks image"
else
  echo -e "\nFAIL: Create chameleonsocks image"
  return
fi

echo -e "\nImport firewall exceptions"
if [ ! -f $EXCEPTIONS ]; then
  wget https://raw.githubusercontent.com/todorez/chameleonsocks/master/confs/chameleonsocks.exceptions
  EXCEPTIONS=`pwd`/chameleonsocks.exceptions
  docker cp $EXCEPTIONS chameleonsocks:/etc/chameleonsocks.exceptions
  rm -rf $EXCEPTIONS
else
  docker cp $EXCEPTIONS chameleonsocks:/etc/chameleonsocks.exceptions
fi

if [ $? -eq 0 ]; then
  echo -e "\nSUCCESS: Import filrewall exceptions"
else
  echo -e "\nFAIL: Import filrewall exceptions"
  return
fi

echo -e "\nLaunch chameleonsocks container"
docker start chameleonsocks

if [ $? -eq 0 ]; then
  echo -e "\nSUCCESS: Launch chameleonsocks container"
else
  echo -e "\nFAIL: Launch chameleonsocks container"
  return
fi
