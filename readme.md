Counter-Strike 1.6 | SnowSK337
==============================
[![Build Status](https://travis-ci.org/netwarlan/cs16-snowsk337.svg?branch=master)](https://travis-ci.org/netwarlan/cs16-snowsk337)

The following repo contains the source files for building a Counter-Strike 1.6 Server with loading of the famous AMP_SNOWSk337 map.
In order to increase performance of your client, add the following commands into your in-game console:
```
rate 20000
cl_cmdrate 105
cl_updaterate 100
ex_interp 0
```

Happy SKEET'ing!


Running the conatiner
---------------------
To run the container, issue the following comand:
```
docker run -d \
-p 27015:27015/tcp \
-p 27015:27015/udp \
netwarlan/cs16-snowsk337
```

Recent Fixes
------------
- Fixed MAP rotation. (We only play snowsk337 on this server)
- Removed all other maps (Reduces Image size)
- Fixing RUN so that it shows up on the LAN server browser