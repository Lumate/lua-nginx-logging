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
    
        location /logging/health/ {
            add_header Access-Control-Allow-Origin *;
            content_by_lua '
                local cjson  = require "cjson"
                local logging = require("logging")
                if logging and cjson then
                    ngx.say("healthy\n")
                    return ngx.exit(ngx.OK)
                end
            ';
        }
        
        location /logging/response/summary/(?<response_format>[\S]+)? {
            add_header Access-Control-Allow-Origin *;
            content_by_lua '
                local logging = require("logging")
                local response = logging.get_response_summary(ngx.shared.log_dict)
                return response
            ';
        }
        
        log_by_lua '
            local logging = require("logging")
            local request_time = ngx.now() - ngx.req.start_time()
            logging.log_response_time(ngx.shared.log_dict, request_time)
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
You can install it with luarocks `luarocks install lua-nginx-logging`

Otherwise you need to configure the lua_package_path directive to add the path of your lua-nginx-loggin source to ngx_lua's LUA_PATH search path, as in

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
