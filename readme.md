# Counter-Strike 1.6 | SnowSK337

[![Docker Build](https://img.shields.io/github/actions/workflow/status/netwarlan/cs16-snowsk337/docker-publish.yml?label=build)](https://github.com/netwarlan/cs16-snowsk337/actions)
[![License](https://img.shields.io/github/license/netwarlan/cs16-snowsk337)](LICENSE)

The following repo contains the source files for building a Counter-Strike 1.6 Server with loading of the famous AMP_SNOWSk337 map.

## Client Performance
In order to increase performance of your client, add the following commands into your in-game console:
```
rate 20000
cl_cmdrate 105
cl_updaterate 100
ex_interp 0
```

Happy SKEET'ing!


## Running
To run the container, issue the following example command:
```
docker run -it \
-p 27015:27015/udp \
-p 27015:27015/tcp \
-e CS16_SERVER_HOSTNAME="DOCKER SNOWSK337" \
-e CS16_SERVER_UPDATE_ON_START=true \
ghcr.io/netwarlan/cs16-snowsk337
```

If saving container data to a shared volume, you can set `CS16_SERVER_UPDATE_ON_START` to `false` to speed up the container start time. Due to the bugs in SteamCMD for this game, it can take several minutes to update with the external manifests.


## Environment Variables
We can make dynamic changes to our CS16 containers by adjusting some of the environment variables passed to our image.
Below are the ones currently supported and their (defaults):

Environment Variable | Default Value
-------------------- | -------------
CS16_SERVER_PORT | 27015
CS16_SERVER_MAXPLAYERS | 32
CS16_SERVER_MAP | awp_snowsk337
CS16_SERVER_HOSTNAME | SnowSk337 Server
CS16_SVLAN | 0
CS16_SERVER_PW | No password set
CS16_SERVER_RCONPW | No password set
CS16_SERVER_UPDATE_ON_START | false
CS16_SERVER_FASTDOWNLOAD_URL | n/a


## Health Check
The container includes a built-in health check that monitors the HLDS process. Docker will automatically report the container as unhealthy if the game server stops running.


## Troubleshooting

### Server won't start
- Ensure ports 27015 (UDP/TCP) are not already in use
- Check that `CS16_SERVER_UPDATE_ON_START=true` on first run to download game files

### Slow startup
- Initial startup with `CS16_SERVER_UPDATE_ON_START=true` can take several minutes due to SteamCMD manifest workarounds
- Use a persistent volume and set `CS16_SERVER_UPDATE_ON_START=false` for faster subsequent starts

### Players can't connect
- Verify firewall rules allow UDP/TCP on port 27015
- Check `CS16_SVLAN` is set to `0` for internet play


## License
This project is open source. See the repository for license details.