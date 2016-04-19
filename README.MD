## CHAMELEONSOCKS

CHAMELEONSOCKS provides containerized system-wide redsocks-based TCP redirector to generic SOCKS or HTTP proxies

**NOTE: You will need Internet connectivity to run the installer/upgrade script**

###  1 . Install Docker

**Install Docker by following the official instructions for your distribution**

```
https://docs.docker.com/engine/installation/#on-linux
```

###  2 . Download chameleonsocks installer/upgrade script

* **Switch to the root user**

```
su root
```

* **Set https_proxy environment variable so you can download the installer**

```
export https_proxy=https://my.proxy.com:port_number
```


* **Execute the following command to download the installer and make it executable**

```
wget https://raw.githubusercontent.com/todorez/chameleonsocks/master/chameleonsocks.sh && chmod 755 chameleonsocks.sh
```

###  3 . Configure your proxy server and exception rules

* **Open chameleonsocks.sh in your favourite text editor and enter your proxy server (PROXY) and proxy server port (PORT)**

  Example:<br>
  PROXY=my.proxy.com<br>
  PORT=1080

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

* **To add your own proxy exception rules, please append your subnets or individual ip addresses to the default exceptions file
and add its absolute path to the EXCEPTIONS variable in chameleonsocks.sh.**

  The default execeptions file can be found here:
  https://github.com/todorez/chameleonsocks/blob/master/confs/chameleonsocks.exceptions

  Example:<br>
  EXCEPTIONS=/path/to/my/exceptions/chameleonsocks.exceptions

###  4 . Install chameleonsocks
```
./chameleonsocks.sh --install
```

*OR*

###  4 . Upgrade existing chameleonsocks installation  ##

```
./chameleonsocks.sh --upgrade
```

#### **CHECK CHAMELEONSOCKS VERSION**

```
docker exec chameleonsocks cat /etc/chameleonsocks-version
```

#### **DISABLING/ENABLING CHAMELEONSOCKS**

* **Install Docker UI**

```
docker run -d --restart=always -p 7777:9000 --privileged --name dockerui -v /var/run/docker.sock:/var/run/docker.sock dockerui/dockerui
```

* **Start/Stop chameleonsocks using the web UI**

```
http://localhost:7777
```

Click the "containers" tab -> Select the "chameleonsocks" container -> Start/Stop the container to enable/disable the proxy

