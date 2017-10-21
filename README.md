# netrat

fun stuff that lets you launch a tcp server using `ncat` on windows...

***

## Hack on it

`source('https://raw.githubusercontent.com/chiefBiiko/netrat/master/dev/ncat.R')`

***

## Usage

```
# install ncat-portable-5.59BETA1 on a windows machine's `C:` drive
install_ncat()

# launch a ncat server that logs incoming messages to the R console 
# and a ncat_server.log file in the current working directory
PIDS <- init_ncat_server(locate_ncat(), 'localhost', 50000)

# connect to the ncat server from a terminal window like this
>C:\ncat-portable-5.59BETA1\ncat.exe localhost 50000
>tell the server some fun stuff...

# kill the two child processes (an R session and ncat.exe) once done
lapply(PIDS, tools::pskill)
```

Quite useless though since one can just use `ncat`, `netcat` or any 
other derivative for easy networking right from a terminal.

***

## License

MIT