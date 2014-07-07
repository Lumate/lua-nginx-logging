-- Lumate - logging
-- usage: add the following to locations or globally in a server/http block
--           log_by_lua '
--                local logging = require("logging")
--                local request_time = ngx.now() - ngx.req.start_time()
--                logging.add_to_plot(ngx.shared.log_dict, "request_time", request_time)
--           '; 

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

function logging.add_to_plot(dict, key, value)
    local sum_key = key .. "-sum"
    local count_key = key .. "-count"
    local start_time_key = key .. "-start_time"
    local request_time_key = value

    dict:add(start_time_key, ngx.now())

    incr(dict, sum_key, value)
    incr(dict, count_key)
    incr(dict, request_time_key)
end

function logging.get_plot(dict, key)
    local sum_key = key .. "-sum"
    local count_key = key .. "-count"
    local start_time_key = key .. "-start_time"
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

    return count, qps, mean, mode, modecount, mintime, maxtime, stdev, elapsed_time
end

return logging
