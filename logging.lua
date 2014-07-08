-- Lumate - logging
-- usage: add the following to locations or globally in a server/http block
--           log_by_lua '
--                local logging = require("logging")
--                local request_time = ngx.now() - ngx.req.start_time()
--                logging.log_response_time(ngx.shared.log_dict, request_time)
--           '; 

local cjson  = require "cjson"

local logging = {}

local function incr(dict, key, increment)
    increment = increment or 1
    local newval, err = dict:incr(key, increment)
    
    if not newval or err then
      dict:add(key, increment)
      newval = increment
    end
    
    return newval
end

function logging.log_response_time(dict, value)
    local sum_key = "request_time-sum"
    local count_key = "request_time-count"
    local start_time_key = "request_time-start_time"
    local request_time_key = value
    
    dict:add(start_time_key, ngx.now())
    
    incr(dict, sum_key, value)
    incr(dict, count_key)
    incr(dict, request_time_key)
    
    return true
end

function logging.log_response_status(dict)
    local response_code = ngx.var.status or ""
    local response_key = "response_code-"..response_code
    
    incr(dict, response_key)
    
    return true
end

function logging.get_timing_values(dict)
    local keys = dict:get_keys(0)
    local response_times = {}
    
    for k,v in pairs(keys) do
        if tonumber(v) then
            val = dict:get(v)
            response_times[#response_times] = {response_time = v, count = val}
        end
    end
    
    dict:flush_all()
    
    return cjson.encode(response_times)
end

function logging.get_timing_summary(dict)
    local sum_key = "request_time-sum"
    local count_key = "request_time-count"
    local start_time_key = "request_time-start_time"
    local keys = dict:get_keys(0)
    local start_time = dict:get(start_time_key)
    local count = dict:get(count_key) or 0
    local sum = dict:get(sum_key) or 0
    local mean = 0
    local stdevsum = 0
    local qps = 0
    
    if count > 0 then mean = sum / count end
    
    for k,v in pairs(keys) do
        if tonumber(v) then
            val = dict:get(v)
            maxval = maxval and (maxval > val and maxval or val) or val
            if oldmax ~= maxval then mode = v modecount = val end
            oldmax = maxval
            mintime = mintime and (mintime < v and mintime or v) or v
            maxtime = maxtime and (maxtime > v and maxtime or v) or v
            stdevsum = stdevsum + (mean - v)^2
        end
    end
    
    local stdev = math.sqrt(stdevsum/count)
    
    local elapsed_time = 0
    
    if start_time then
        elapsed_time = ngx.now() - start_time
    end
    
    if elapsed_time > 0 then
        qps = count / elapsed_time
    end
    
    dict:flush_all()
    
    local summary = {count=count,
                     qps=qps,
                     mean=mean,
                     mode=mode,
                     modecount=modecount,
                     mintime=mintime,
                     maxtime=maxtime,
                     stdev=stdev,
                     elapsed_time=elapsed_time}
    
    return cjson.encode(summary)
end

function logging.get_response_summary(dict)
    local response_key_prefix = "response_code-"
    local response_codes = {}
    local keys = dict:get_keys(0)
    
    for k,v in pairs(keys) do
        if v:find(response_key_prefix, 1, true) then
            val = dict:get(v)
            response_codes[#response_codes] = {response_code = v, count = val}
        end
    end
    
    return cjson.encode(response_codes)
end

return logging
