## Introduction

This a tiny library, intended to be used with OpenResty applications, when
you need to execute a subprocess (or shell command). It works similar to
**os.execute** and **io.popen**, except that it is completely non-blocking, and
therefore is safe to use even for commands that take long time to complete.

The library depends on a daemon component that you would need to run
on your webserver - **sockproc**. The basic idea is that the shell library
connects to the unix domain socket of sockproc daemon, sends the command
along with any input data that the child program is expecting, and then
reads back the exit code, output stream data, and error stream data of
the child process. Because we use co-socket API, provided by ngx-lua
module, the nginx reactor is never blocked

More info on sockproc server, including complete source code here:
https://github.com/juce/sockproc


## Example usage

Make sure to have sockproc running and listenning on a UNIX domain socket:

    $ ./sockproc /tmp/shell.sock

In your OpenResty config:

    location /test {
        content_by_lua '
            local shell = require("resty.shell")
            local status, out, err = shell.execute("uname -a")

            ngx.header.content_type = "text/plain"
            ngx.say("Hello from:\n" .. out)
        ';
    }


## License

The MIT License (MIT)
