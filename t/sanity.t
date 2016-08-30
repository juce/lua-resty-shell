use Test::Nginx::Socket::Lua;

use lib 't';
use MockSockProc;

repeat_each(1);
plan tests => repeat_each() * 3 * blocks();

no_shuffle();
run_tests();

__DATA__

=== TEST 1: Load module
--- config
    location = /t {
		content_by_lua_block {
			local shell = require "resty.shell"

			ngx.exit(ngx.OK)
        }
    }
--- request
    GET /t
--- response_body
--- error_code: 200
--- no_error_log
[error]

=== TEST 2: Execute a command with default options
--- config
    location = /t {
		content_by_lua_block {
			local shell = require "resty.shell"

			local mock_cmd = "cmd-foo"

			local args = {}

			local status, out, err = shell.execute(mock_cmd, args)

			ngx.say(status)
			ngx.say(out)
			ngx.say(tostring(err))

			ngx.exit(ngx.OK)
        }
    }
--- tcp_listen: /tmp/shell.sock
--- tcp_reply eval
sub {
	my $req = shift;
	return MockSockProc::mock_exec_succeed($req);
}
--- request
    GET /t
--- response_body
0
successful exec of cmd-foo ()
nil
--- error_code: 200
--- no_error_log
[error]

=== TEST 3: Execute a command with some input data
--- config
    location = /t {
		content_by_lua_block {
			local shell = require "resty.shell"

			local mock_cmd = "cmd-foo"

			local args = {
				data = "mock-stdin"
			}

			local status, out, err = shell.execute(mock_cmd, args)

			ngx.say(status)
			ngx.say(out)
			ngx.say(tostring(err))

			ngx.exit(ngx.OK)
        }
    }
--- tcp_listen: /tmp/shell.sock
--- tcp_reply eval
sub {
	my $req = shift;
	return MockSockProc::mock_exec_succeed($req);
}
--- request
    GET /t
--- response_body
0
successful exec of cmd-foo (mock-stdin)
nil
--- error_code: 200
--- no_error_log
[error]

=== TEST 4: Execute a failed command
--- config
    location = /t {
		content_by_lua_block {
			local shell = require "resty.shell"

			local mock_cmd = "cmd-foo"

			local args = {
				data = "mock-stdin"
			}

			local status, out, err = shell.execute(mock_cmd, args)

			ngx.say(status)
			ngx.say(out)
			ngx.say(tostring(err))

			ngx.exit(ngx.OK)
        }
    }
--- tcp_listen: /tmp/shell.sock
--- tcp_reply eval
sub {
	my $req = shift;
	return MockSockProc::mock_exec_fail($req);
}
--- request
    GET /t
--- response_body
-1
nil
failed to exec cmd-foo
--- error_code: 200
--- no_error_log
[error]

=== TEST 5: Execute a command with a long timeout
--- config
    location = /t {
		content_by_lua_block {
			local shell = require "resty.shell"

			local mock_cmd = "cmd-foo"

			local args = {
				timeout = 5000
			}

			local status, out, err = shell.execute(mock_cmd, args)

			ngx.say(status)
			ngx.say(out)
			ngx.say(tostring(err))

			ngx.exit(ngx.OK)
        }
    }
--- tcp_listen: /tmp/shell.sock
--- tcp_reply eval
sub {
	my $req = shift;
	return MockSockProc::mock_exec_succeed($req);
}
--- request
    GET /t
--- response_body
0
successful exec of cmd-foo ()
nil
--- error_code: 200
--- no_error_log
[error]

=== TEST 6: Execute a command with an alternate unix socket
--- config
    location = /t {
		content_by_lua_block {
			local shell = require "resty.shell"

			local mock_cmd = "cmd-foo"

			local args = {
				socket = "unix:/tmp/alt.sock"
			}

			local status, out, err = shell.execute(mock_cmd, args)

			ngx.say(status)
			ngx.say(out)
			ngx.say(tostring(err))

			ngx.exit(ngx.OK)
        }
    }
--- tcp_listen: /tmp/alt.sock
--- tcp_reply eval
sub {
	my $req = shift;
	return MockSockProc::mock_exec_succeed($req);
}
--- request
    GET /t
--- response_body
0
successful exec of cmd-foo ()
nil
--- error_code: 200
--- no_error_log
[error] 

=== TEST 7: Execute a command with a TCP conection
--- config
    location = /t {
		content_by_lua_block {
			local shell = require "resty.shell"

			local mock_cmd = "cmd-foo"

			local args = {
				socket = {
					host = "127.0.0.1",
					port = 9999
				}
			}

			local status, out, err = shell.execute(mock_cmd, args)

			ngx.say(status)
			ngx.say(out)
			ngx.say(tostring(err))

			ngx.exit(ngx.OK)
        }
    }
--- tcp_listen: 9999
--- tcp_reply eval
sub {
	my $req = shift;
	return MockSockProc::mock_exec_succeed($req);
}
--- request
    GET /t
--- response_body
0
successful exec of cmd-foo ()
nil
--- error_code: 200
--- no_error_log
[error] 

=== TEST 8: Time out a command
--- config
	lua_socket_log_errors off;

    location = /t {
		content_by_lua_block {
			local shell = require "resty.shell"

			local mock_cmd = "cmd-foo"

			local args = {
				timeout = 50
			}

			local status, out, err = shell.execute(mock_cmd, args)

			ngx.say(status)
			ngx.say(tostring(out))
			ngx.say(tostring(err))

			ngx.exit(ngx.OK)
        }
    }
--- tcp_listen: /tmp/shell.sock
--- tcp_reply eval
sub {
	my $req = shift;
	return MockSockProc::mock_exec_succeed($req);
}
--- tcp_reply_delay: 100ms
--- request
    GET /t
--- response_body
-1
nil
timeout
--- error_code: 200
--- no_error_log
[error]

=== TEST 9: Attempt to connect to a non-existent server
--- config
	lua_socket_log_errors off;

    location = /t {
		content_by_lua_block {
			local shell = require "resty.shell"

			local mock_cmd = "cmd-foo"

			local args = {
				socket = {
					host = "127.0.0.1",
					port = 9998
				}
			}

			local status, out, err = shell.execute(mock_cmd, args)

			ngx.say(status)
			ngx.say(tostring(out))
			ngx.say(tostring(err))

			ngx.exit(ngx.OK)
        }
    }
--- tcp_listen: 9999
--- tcp_reply eval
sub {
	my $req = shift;
	return MockSockProc::mock_exec_succeed($req);
}
--- tcp_reply_delay: 100ms
--- request
    GET /t
--- response_body
-2
nil
connection refused
--- error_code: 200
--- no_error_log
[error]

=== TEST 10: Connect to a TCP server with invalid options
--- config
    location = /t {
		content_by_lua_block {
			local shell = require "resty.shell"

			local mock_cmd = "cmd-foo"

			local args = {
				socket = {
					host = "127.0.0.1",
				}
			}

			local status, out, err = shell.execute(mock_cmd, args)

			ngx.say(status)
			ngx.say(out)
			ngx.say(tostring(err))

			ngx.exit(ngx.OK)
        }
    }
--- tcp_listen: 9999
--- tcp_reply eval
sub {
	my $req = shift;
	return MockSockProc::mock_exec_succeed($req);
}
--- request
    GET /t
--- response_body
-3
nil
invalid socket table options passed
--- error_code: 200
--- no_error_log
[error] 

=== TEST 11: Provide an invalid format for socket args
--- config
    location = /t {
		content_by_lua_block {
			local shell = require "resty.shell"

			local mock_cmd = "cmd-foo"

			local args = {
				socket = true
			}

			local status, out, err = shell.execute(mock_cmd, args)

			ngx.say(status)
			ngx.say(out)
			ngx.say(tostring(err))

			ngx.exit(ngx.OK)
        }
    }
--- tcp_listen: 9999
--- tcp_reply eval
sub {
	my $req = shift;
	return MockSockProc::mock_exec_succeed($req);
}
--- request
    GET /t
--- response_body
-3
nil
socket was not a table with tcp options or a string
--- error_code: 200
--- no_error_log
[error] 

