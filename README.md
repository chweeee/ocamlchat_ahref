# ocamlchat_ahref
Simple one-to-one chat written in OCaml

This application has a Command-line interface and can be started with the following flags:
```
-m server/client (required flag)
-a IP_ADDR (optional, defaults to localhost)
-p PORT_NO (optional, defaults to 12345)
```
> More information can be found via `-help` option

**Starting the server: **
We can start the server via the command: `./_build/default/main.exe -ms server`.  
This starts a TCP server on the local machine, listening to port 12345.
