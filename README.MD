## CHAMELEONSOCKS

CHAMELEONSOCKS provides containerized system-wide redsocks-based TCP redirector to generic SOCKS or HTTP proxies

**NOTE: You will need Internet connectivity to run the installer/upgrade script**

###  1 . Install Docker

**Install Docker by following the official instructions for your distribution**

```
https://docs.docker.com/engine/installation/#on-linux
```

###  2 . Download chameleonsocks.sh script

* **Switch to the root user**

```
su root
```

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

  **Chameleonsocks provides support for standard PAC files. Set the PAC_URL variable in chameleonsocks.sh to the URL of your PAC file and the subnet exceptions from the PAC file will be extracted and applied to the chameleonsocks ruleset **

  Example:<br>
  PAC_URL=http://my.pacfile-server.com<br>

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
