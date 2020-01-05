# ocamlchat_ahref
Simple one-to-one chat written in OCaml

This application has a Command-line interface and can be started with the following flags:
```
-m server/client (required flag)
-a IP_ADDR (optional, defaults to localhost)
-p PORT_NO (optional, defaults to 12345)
```
> **More information can be found via `-help` option.**

----

### **Starting the server:**  
Command: `./_build/default/main.exe -m server`.  
This starts a TCP server on the local machine, listening to port 12345.

> **You can start the client on another port by specifying it via the `-p` flag!** 

----

### **Connecting the client to the server:**  
Command: `./_build/default/main.exe -m client`.  
Starts a TCP client and connect to a server at localhost listening on port 12345.

> **You can specify the client to connect to a remote host via the `-a` flag!** 

----
