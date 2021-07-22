local scrollVerticalButton = 4
local scrollHorizontalButton = 3
local toggleVerticalScrollButton = 4
local toggleHorizontalScrollButton = 3
local deferred = false
local verticalScrollToggle = false
local horizontalScrollToggle = false

OverrideOtherMouseDown = hs.eventtap.new({
    hs.eventtap.event.types.otherMouseDown
}, function(e)
    local pressedMouseButton = e:getProperty(
                                   hs.eventtap.event.properties['mouseEventButtonNumber'])
    if scrollVerticalButton == pressedMouseButton or scrollHorizontalButton ==
        pressedMouseButton then
        deferred = true
        return true
    end
end)

ToggleMouseDown = hs.eventtap.new({hs.eventtap.event.types.otherMouseDown},
                                  function(e)
    local pressedMouseButton = e:getProperty(
                                   hs.eventtap.event.properties['mouseEventButtonNumber'])
    if toggleVerticalScrollButton == pressedMouseButton then
        if (verticalScrollToggle) then
            verticalScrollToggle = false
            return true
        else
            verticalScrollToggle = true
            horizontalScrollToggle = false
            return true
        end
    end
    if toggleHorizontalScrollButton == pressedMouseButton then
        if (horizontalScrollToggle) then
            horizontalScrollToggle = false
            return true
        else
            horizontalScrollToggle = true
            verticalScrollToggle = false
            return true
        end
    end
end)

OverrideOtherMouseUp = hs.eventtap.new({hs.eventtap.event.types.otherMouseUp},
                                       function(e)
    -- print("up")
    local pressedMouseButton = e:getProperty(
                                   hs.eventtap.event.properties['mouseEventButtonNumber'])
    if scrollVerticalButton == pressedMouseButton or scrollHorizontalButton ==
        pressedMouseButton then
        if (deferred) then
            OverrideOtherMouseDown:stop()
            OverrideOtherMouseUp:stop()
            hs.eventtap.otherClick(e:location(), 0, pressedMouseButton)
            OverrideOtherMouseDown:start()
            OverrideOtherMouseUp:start()
            return true
        end
        return false
    end
    return false
end)

local scrollmult = -1 -- negative multiplier makes mouse work like traditional scrollwheel
local scrollmultHorizontal = -1
local moveX = 0
local moveY = 0

local function scrollFunction(x, y)
    local oldmousepos = hs.mouse.absolutePosition()
    local scroll = hs.eventtap.event.newScrollEvent({x, y}, {}, 'pixel')
    hs.mouse.absolutePosition(oldmousepos)
    return scroll
end

ToggleMouseButtonThenScroll = hs.eventtap.new({
    hs.eventtap.event.types.mouseMoved
}, function(e)
    if verticalScrollToggle then
        local dy = e:getProperty(
                       hs.eventtap.event.properties['mouseEventDeltaY'])
        moveY = -dy * scrollmult
        return true, {scrollFunction(0, moveY)}
    else
        if horizontalScrollToggle then
            local dx = e:getProperty(
                           hs.eventtap.event.properties['mouseEventDeltaX'])
            moveX = -dx * scrollmultHorizontal
            return true, {scrollFunction(moveX, 0)}
        else
            return false, {}
        end
    end
end)

DragOtherToScroll = hs.eventtap.new({hs.eventtap.event.types.otherMouseDragged},
                                    function(e)
    local pressedMouseButton = e:getProperty(
                                   hs.eventtap.event.properties['mouseEventButtonNumber'])
    if scrollVerticalButton == pressedMouseButton then
        deferred = false
        local dy = e:getProperty(
                       hs.eventtap.event.properties['mouseEventDeltaY'])
        moveY = -dy * scrollmult
        verticalScrollToggle = false
        return true, {scrollFunction(0, moveY)}

    else
        if scrollHorizontalButton == pressedMouseButton then
            deferred = false
            local dx = e:getProperty(
                           hs.eventtap.event.properties['mouseEventDeltaX'])
            moveX = -dx * scrollmultHorizontal
            horizontalScrollToggle = false
            return true, {scrollFunction(moveX, 0)}
        else
            return false, {}
        end
    end
end)
OverrideOtherMouseDown:start()
OverrideOtherMouseUp:start()
ToggleMouseDown:start()
ToggleMouseButtonThenScroll:start()
DragOtherToScroll:start()
