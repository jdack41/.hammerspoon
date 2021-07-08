-- HANDLE SCROLLING WITH MOUSE BUTTON PRESSED
local scrollVerticalButton = 4
local toggleVerticalScrollButton = 2
local toggleHorizontalScrollButton = 3
local scrollHorizontalButton = 999 -- disabled
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

local scrollmult = -2 -- negative multiplier makes mouse work like traditional scrollwheel
local scrollmultHorizontal = -1
local moveX = 0
local moveY = 0

ToggleMouseButtonThenScroll = hs.eventtap.new({
    hs.eventtap.event.types.mouseMoved
}, function(e)
    if verticalScrollToggle then
        local oldmousepos = hs.mouse.absolutePosition()
        local dy = e:getProperty(
                       hs.eventtap.event.properties['mouseEventDeltaY'])
        moveY = -dy * scrollmult
        local scroll = hs.eventtap.event.newScrollEvent({0, moveY}, {}, 'pixel')
        -- put the mouse back
        hs.mouse.absolutePosition(oldmousepos)
        return true, {scroll}
    else
        if horizontalScrollToggle then
            local oldmousepos = hs.mouse.absolutePosition()
            local dx = e:getProperty(
                           hs.eventtap.event.properties['mouseEventDeltaX'])
            moveX = -dx * scrollmultHorizontal
            local scroll = hs.eventtap.event.newScrollEvent({moveX, 0}, {},
                                                            'pixel')
            -- put the mouse back
            hs.mouse.absolutePosition(oldmousepos)
            return true, {scroll}
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
        local oldmousepos = hs.mouse.absolutePosition()
        local dy = e:getProperty(
                       hs.eventtap.event.properties['mouseEventDeltaY'])
        moveY = -dy * scrollmult
        local scroll = hs.eventtap.event.newScrollEvent({0, moveY}, {}, 'pixel')
        -- put the mouse back
        hs.mouse.absolutePosition(oldmousepos)
        return true, {scroll}

    else
        if scrollHorizontalButton == pressedMouseButton then
            deferred = false
            local oldmousepos = hs.mouse.absolutePosition()
            local dx = e:getProperty(
                           hs.eventtap.event.properties['mouseEventDeltaX'])
            moveX = -dx * scrollmultHorizontal
            local scroll = hs.eventtap.event.newScrollEvent({moveX, 0}, {},
                                                            'pixel')
            -- put the mouse back
            hs.mouse.absolutePosition(oldmousepos)
            return true, {scroll}
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
