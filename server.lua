local Queue = require "Queue"
local Commands = require "Commands"
local trigger = require "Trigger"
local config = require "Config"

triggerQueue = Queue.new()
current = nil

enableDebug=true

function debug(string)
    if enableDebug then
        print(string)
    end
end

if srv ~= nil then srv:close() end

srv = net.createServer(net.TCP)
srv:listen(80, function(conn)
    conn:on("receive", function(sck, payload)
        debug("got request")
        debug(payload)            

        local i,j = string.find(payload,"\r\n\r\n")

        local body
        if j ~= nil then
            body = string.sub(payload, j+1)
        end

        debug(body)
        if body ~= nil and body ~= "" then
            local json = sjson.decode(body)

            if config.allow(payload) or json['password'] == config["password"] then
                Commands.get(json['value'], json['time'], function(val)
                    Queue.push(triggerQueue, val)
                    trigger(triggerQueue)
                end)
                sck:send("HTTP/1.1 200 OK\r\nServer: NodeLuau\r\nContent-Type: text/html\r\nConnection: close\r\n\r\n")
            else
                sck:send("HTTP/1.1 401 OK\r\nServer: NodeLuau\r\nContent-Type: text/html\r\nConnection: close\r\n\r\n")
            end
        else
sck:send("HTTP/1.1 200 OK\r\nServer: NodeLuau\r\nContent-Type: text/html\r\nConnection: close\r\n\r\n")
sck:send("<!DOCTYPE html>")
sck:send("<html>")
sck:send("  <head>")
sck:send("    <meta charset=\"utf-8\">")
sck:send("    <title>Fire Control</title>")
sck:send("    <script> ")
sck:send("    document.addEventListener('DOMContentLoaded', () => {")
sck:send("      document.getElementsByTagName('button')[0].addEventListener ('click', () => {")
sck:send("        let toSend = {};")
sck:send("        Array.from(document.getElementsByTagName('form')[0].elements).forEach(obj =>{")
sck:send("          toSend[obj.name] = obj.value;")
sck:send("        });")
sck:send("        var xhr = new XMLHttpRequest();xhr.open('POST', 'whatever');xhr.send(JSON.stringify(toSend));")
sck:send("        xhr.onreadystatechange = () => {")
sck:send("           if (xhr.readyState === 4) {")
sck:send("            document.getElementById('output').innerHTML= xhr.status === 200?'ok':'Error: ' + xhr.status")
sck:send("          }")
sck:send("        }")
sck:send("      });});")
sck:send("    </script>")
sck:send("  </head>")
sck:send("  <body>")
sck:send("    <h1>Control the fire</h1>")
sck:send("    <form>")
sck:send("        command:")
sck:send("          <select name=\"value\">")
sck:send("              <option value=\"on\">on</option>")
sck:send("              <option value=\"off\">off</option>")
sck:send("              <option value=\"up\">up</option>")
sck:send("              <option value=\"full_up\">full up</option>")
sck:send("              <option value=\"down\">down</option>")
sck:send("              <option value=\"full_down\">full down</option>")
sck:send("          </select>")
sck:send("      password:<input name=\"password\" type=\"text\">")
sck:send("      milis:<input name=\"time\" type=\"number\" value=\"0\">")
sck:send("     ")
sck:send("    </form>")
sck:send("   <button>Send</button>")
sck:send("   <div id='output'></div>")
sck:send("  </body>")
sck:send("</html>")
        end
    end)
    conn:on("sent", function(sck) sck:close() end)
end)
