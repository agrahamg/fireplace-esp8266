local Queue = require "Queue"

local pin = 5
gpio.mode(pin, gpio.OUTPUT)
gpio.write(pin,0)

local function trigger (triggerQueue)
    debug("checking trigger")
    if current == nil and not Queue.isEmpty(triggerQueue) then
        current = Queue.pop(triggerQueue)
        local time = tonumber(current["time"])
        local values = current["values"]

        local function fun(i)
            debug("running command "..i)
            gpio.serout(pin, 1, values[i], 9, function()
                debug("done")

                current = nil
                if i < #values then
                    fun(i+1)
                else
                    trigger(triggerQueue)
                end
            end)
        end

        if time == nil or time == 0 then
            fun(1)
        else
            local t1 = tmr.create()
            t1:register(time, tmr.ALARM_SINGLE, function() fun(1) end)
            t1:start()
        end
    end
end

return trigger