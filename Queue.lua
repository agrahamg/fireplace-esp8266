local Queue = {}
function Queue.new ()
    return {first = 0, last = -1}
end

function Queue.push (queue, value)
    local last = queue.last + 1
    queue.last = last
    queue[last] = value
end

function Queue.pop (queue)
    local first = queue.first
    if first > queue.last then error("list is empty") end
    local value = queue[first]
    queue[first] = nil        -- to allow garbage collection
    queue.first = first + 1
    return value
end

function Queue.isEmpty(queue)
    return queue.first > queue.last
end

return Queue