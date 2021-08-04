Counter-Strike 1.6 | SnowSK337
==============================
The following repo contains the source files for building a Counter-Strike 1.6 Server with loading of the famous AMP_SNOWSk337 map.
In order to increase performance of your client, add the following commands into your in-game console:
```
rate 20000
cl_cmdrate 105
cl_updaterate 100
ex_interp 0
```

Happy SKEET'ing!


### Running
To run the container, issue the following example command:
```
docker run -it \
-p 27015:27015/udp \
-p 27015:27015/tcp \
-e CS16_SERVER_HOSTNAME="DOCKER CS16 SNOWSK337" \
netwarlan/cs16-snowsk337
```

### Environment Variables
We can make dynamic changes to our CS16 containers by adjusting some of the environment variables passed to our image.
Below are the ones currently supported and their (defaults):

```
CS16_SERVER_PORT (27015)
CS16_SERVER_MAXPLAYERS (32)
CS16_SERVER_MAP (awp_snowsk337)
CS16_SERVER_HOSTNAME (SnowSk337 Server)
CS16_SERVER_PW (No password set)
CS16_SERVER_RCONPW (No password set)
CS16_SERVER_UPDATE_ON_START (false)
```

#### Descriptions

* `CS16_SERVER_PORT` Determines the port our container runs on.
* `CS16_SERVER_MAXPLAYERS` Determines the max number of players the * server will allow.
* `CS16_SERVER_MAP` Determines the starting map.
* `CS16_SERVER_HOSTNAME` Determines the name of the server.
* `CS16_SERVER_PW` Determines the password needed to join the server.
* `CS16_SERVER_RCONPW` Determines the RCON password needed to administer the server.
* `CS16_SERVER_UPDATE_ON_START` Determines whether the server should update itself to latest when the container starts up.