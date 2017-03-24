print("starting up will wait for 5 seconds")

mytimer = tmr.create()

mytimer:register(5000, tmr.ALARM_SINGLE, function (t)
    print("running file")
    dofile("server.lua") 
    mytimer = nil
end)
mytimer:start()
