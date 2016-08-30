## Introduction

This a tiny library, intended to be used with OpenResty applications, when
you need to execute a subprocess (or shell command). It works similarly to
**os.execute** and **io.popen**, except that it is completely non-blocking, and
therefore is safe to use even for commands that take long time to complete.

The library depends on a daemon component that you would need to run
on your webserver - [**sockproc**](https://github.com/juce/sockproc). The basic 
idea is that the shell library connects to the unix domain socket of sockproc daemon, 
sends the command along with any input data that the child program is expecting, and then
reads back the exit code, output stream data, and error stream data of
the child process. Because we use co-socket API, provided by
[lua-nginx-module](https://github.com/openresty/lua-nginx-module),
the nginx worker is never blocked.

More info on sockproc server, including complete source code here:
https://github.com/juce/sockproc


## Example usage

Make sure to have sockproc running and listenning on a UNIX domain socket:

    $ ./sockproc /tmp/shell.sock

In your OpenResty config:

    location /test {
        content_by_lua '
            local shell = require("resty.shell")

            -- define a table to hold arguments with the following elements:
            --
            -- timeout: timeout for the socket connection
            --
            -- data: STDIN to send to sockproc
            --
            -- socket: either a table containg the elements 'host' and 'port' for tcp connections,
            -- or a string defining a unix socket
            local args = {
                socket = "unix:/tmp/shell.sock",
            }

            local status, out, err = shell.execute("uname -a", args)

            ngx.header.content_type = "text/plain"
            ngx.say("Hello from:\n" .. out)
        ';
    }


## License

The MIT License (MIT)
