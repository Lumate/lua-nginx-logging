Name
====

lua-nginx-logging - logging utilities for nginx written in lua

Table of Contents
=================

* [Name](#name)
* [Status](#status)
* [Description](#description)
* [Synopsis](#synopsis)
* [Limitations](#limitations)
* [Installation](#installation)
* [TODO](#todo)
* [Author](#author)
* [Copyright and License](#copyright-and-license)
* [See Also](#see-also)

Status
======

This library is still under early development and considered experimental.

Description
===========

This Lua library is a logging utility for the ngx_lua nginx module:

Synopsis
========

```
    lua_package_path "/path/to/lua-nginx-logging/lib/?.lua;;";
    
    server {
    
        location /health/ {
            add_header Access-Control-Allow-Origin *;
            return 200 "healthy\n";
        }
        
        location /timings/ {
            add_header Access-Control-Allow-Origin *;
            content_by_lua '
                local logging = require("logging")
                local count, qps, mean, mode, modecount, mintime, maxtime, stdev, elapsed_time = 
                    logging.get_plot(ngx.shared.log_dict, "request_time")
                ngx.say("Since last measure:\t", elapsed_time, " secs")
                ngx.say("Request Count:\t\t", count)
                ngx.say("Mean req time:\t\t", mean, " secs")
                ngx.say("Requests per Secs:\t", qps)
                ngx.say("Mode req time:\t\t", mode, " secs,", modecount, " times")
                ngx.say("Min req time:\t\t", mintime, " secs")
                ngx.say("Max req time:\t\t", maxtime, " secs")
                ngx.say("StdDev req time:\t", stdev, " secs")
            ';
        }
        
        log_by_lua '
            local logging = require("logging")
            local request_time = ngx.now() - ngx.req.start_time()
            logging.add_to_plot(ngx.shared.log_dict, "request_time", request_time)
       ';
        
    }
```

[Back to TOC](#table-of-contents)

Limitations
===========

* only supports JSON and raw output

[Back to TOC](#table-of-contents)

Installation
============

If you are using your own nginx + ngx_lua build, then you need to configure the lua_package_path directive to add the path of your lua-nginx-loggin source to ngx_lua's LUA_PATH search path, as in

```nginx
    # nginx.conf
    http {
        lua_package_path "/path/to/lua-nginx-logging/?.lua;;";
        ...
    }
```

Ensure that the system account running your Nginx ''worker'' proceses have
enough permission to read the `.lua` file.

[Back to TOC](#table-of-contents)

TODO
====

* Support other response formats
* log other things

[Back to TOC](#table-of-contents)

Author
======

James Marlowe "jamesmarlowe" <jameskmarlowe@gmail.com>, Lumate LLC.

[Back to TOC](#table-of-contents)

Copyright and License
=====================

This module is licensed under the BSD license.

Copyright (C) 2012-2014, by James Marlowe (jamesmarlowe) <jameskmarlowe@gmail.com>, Lumate LLC.

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

[Back to TOC](#table-of-contents)

See Also
========
* the ngx_lua module: http://wiki.nginx.org/HttpLuaModule
* log_by_lua: http://wiki.nginx.org/HttpLuaModule#log_by_lua

[Back to TOC](#table-of-contents)
