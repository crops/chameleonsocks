## CHAMELEONSOCKS

CHAMELEONSOCKS provides containerized system-wide redsocks-based TCP redirector to generic SOCKS or HTTP proxies.  There is a script to aid in the initial setup.  This script pulls a tar.gz and loads it as a docker image. It then creates a persistent container that includes your specific proxy/exception information and that persistent container is what is run to provide redirection. Note: This requires root access since the containers need to be run in privileged mode.

**NOTE: You will need Internet connectivity to run the installer/upgrade script**
##  Quickstart Instructions

### 1 . Download the installer and make it executable

```
https_proxy=https://myproxy.mycomp.com:<port> wget https://raw.githubusercontent.com/crops/chameleonsocks/master/chameleonsocks.sh && chmod 755 chameleonsocks.sh
```
### 2 . Run the installer with the minimum number of required args

```
https_proxy=https://myproxy.mycomp.com:<port> PROXY=mysocksproxy.mycomp.com PORT=<socksproxyport> PAC_URL=http://wpad.mycomp.com/wpad.dat ./chameleonsocks.sh --install
```


## Extended Instructions
###  1 . Install Docker

**Install Docker by following the official instructions for your distribution**

```
https://docs.docker.com/engine/installation/#on-linux
```

###  2 . Download chameleonsocks.sh script

* **Set https_proxy environment variable so you can download the installer**

```
export https_proxy=https://my.proxy.com:port_number
```


* **Execute the following command to download the script and to make it executable**

```
wget https://raw.githubusercontent.com/crops/chameleonsocks/master/chameleonsocks.sh && chmod 755 chameleonsocks.sh
```

###  3 . Configure your proxy server and exception rules

* **Open chameleonsocks.sh in your favourite text editor and enter your proxy server (PROXY), proxy server port (PORT) and proxy server type (PROXY_TYPE). supported PROXY_TYPE values are: socks4, socks5, http-connect, http-relay **

  Example:<br>
  PROXY=my.proxy.com<br>
  PORT=1080<br>
  PROXY_TYPE=socks5

  **NOTE: The installer provides the following proxy exception rules by default. Requests sent to the following subnets will not
  be redirected to the proxy.**

  0.0.0.0/8<br>
  127.0.0.0/8<br>
  169.254.0.0/16<br>
  224.0.0.0/4<br>
  240.0.0.0/4<br>
  10.0.0.0/8<br>
  172.16.0.0/12<br>
  192.168.0.0/16<br>

  **Chameleonsocks provides support for standard PAC or WPAD (Web Proxy Auto Discovery) files. Set the PAC_URL variable in chameleonsocks.sh to the URL of your PAC file or WPAD file and the subnet exceptions from the PAC file will be extracted and applied to the chameleonsocks ruleset.  Note: ONLY exceptions will be pulled from the PAC_URL file, not the proxy itself. **

  Example:<br>
  PAC_URL=http://my.pacfile-server.com<br>
-or-<br>
  PAC_URL=http://my.wpad-server.com/wpad.dat<br>

* **To add your own proxy exception rules, please append your subnets or individual ip addresses to the default exceptions file
and add its absolute path to the EXCEPTIONS variable in chameleonsocks.sh.**

  The default execeptions file can be found here:
  https://github.com/crops/chameleonsocks/blob/master/confs/chameleonsocks.exceptions

  Example:<br>
  EXCEPTIONS=/path/to/my/exceptions/chameleonsocks.exceptions

###  4 . Install chameleonsocks
```
./chameleonsocks.sh --install
```

*OR*

###  4. Upgrade existing chameleonsocks installation  ##

```
./chameleonsocks.sh --upgrade
```

### 5 . **Start/Stop chameleonsocks**

#### **You can start/stop chameleonsocks in one of two ways:**

* **By using the chameleonsocks.sh script from the command line**

  **Start chameleonsocks**
  ```
  ./chameleonsocks.sh --start
  ```

  **Stop chameleonsocks**
  ```
  ./chameleonsocks.sh --stop
  ```

* **By using the Docker UI interface**

  **Install Docker UI**
  ```
  ./chameleonsocks.sh --install-ui
  ```

  **Open the following URL in your web browser**

  ```
  http://localhost:7777
  ```

  Click the "containers" tab -> Select the "chameleonsocks" container -> Start/Stop the container to enable/disable the proxy

  **Uninstall Docker UI**

  ```
  ./chameleonsocks.sh --uninstall-ui
  ```

### **Check chameleonsocks version**

```
./chameleonsocks.sh --version
```

### **Uninstall chameleonsocks**
```
./chameleonsocks.sh --uninstall
```

### **NOTE: Instructions for installing chameleonsocks with Docker Toolbox on Windows**

*  **Download the installer script with your favourte web browser**

   *  https://raw.githubusercontent.com/crops/chameleonsocks/master/chameleonsocks.sh

*  **Download the chameleonsocks image with your favourte web browser**

   *  https://github.com/crops/chameleonsocks/releases/download/v1.2/chameleonsocks-1.2.tar.gz

*  **Launch Docker Quickstart Terminal and navige to the directory where the installer and the image were downloaded**

*  **Install chameleonsocks with the following command**

  ```
  ./chameleonsocks.sh --install_local chameleonsocks-1.2.tar.gz

  ```

### **Troubleshooting/Tips**
If you want to try different combinations because your proxy got moved
or because you discover that the XXX proxy is much faster for you,
you can quickly do the following:<br>
To get the initial image (where myproxy.com:8080 is your https proxy):<br>
```
https_proxy=https://myproxy.com:8080 ./chameleonsocks.sh --install
```
You can tell if you have the initial docker image by doing
```
docker images | grep chameleon
```
and you should see something like: crops/chameleonsocks  VERSION (1.X)...<br>
To try different settings you can either edit the chameleonsocks.sh file or prepend environment variables to the call.
```
PROXY=myproxy.com PAC_URL=http://autoproxy.mycomp.com ./chameleonsocks.sh --start
```
To retry do:
```
 ./chameleonsocks.sh --stop && docker rm chameleonsocks
PROXY=myproxy2.com PAC_URL=http://autoproxy.mycomp.com ./chameleonsocks.sh --start
```
If you want to stop and start chameleonsocks without using the script after having made the container
the first time (which DOES need the script), do:
```
docker stop chameleonsocks
docker start chameleonsocks
```
To see what may be wrong, you can do:
```
docker logs chameleonsocks
```
Note: if you are using a proxy.pac type autoconfig for your exceptions, it can take some time
(?30 seconds?) to get the file and have the container start routing.  If you're autoproxy breaks,
you need to redo the install and not set the autoproxy (PAC_URL).  This will give you just the
default exceptions.
