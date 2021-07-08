-- HANDLE SCROLLING WITH MOUSE BUTTON PRESSED
local scrollMouseButton = 4
local scrollHorizontalButton = 3
local deferred = false

overrideOtherMouseDown = hs.eventtap.new({ hs.eventtap.event.types.otherMouseDown }, function(e)
    -- print("down")
    local pressedMouseButton = e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber'])
    if scrollMouseButton == pressedMouseButton or scrollHorizontalButton == pressedMouseButton 
        then 
            deferred = true
            return true
        end
end)

overrideOtherMouseUp = hs.eventtap.new({ hs.eventtap.event.types.otherMouseUp }, function(e)
     -- print("up")
    local pressedMouseButton = e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber'])
    if scrollMouseButton == pressedMouseButton or srollHorizontalButton == pressedMouseButton 
        then 
            if (deferred) then
                overrideOtherMouseDown:stop()
                overrideOtherMouseUp:stop()
                hs.eventtap.otherClick(e:location(), 0, pressedMouseButton)
                overrideOtherMouseDown:start()
                overrideOtherMouseUp:start()
                return true
            end
            return false
        end
        return false
end)

local scrollmult = -2	-- negative multiplier makes mouse work like traditional scrollwheel
local scrollmultHorizontal = -1
local scrollAmountMultiplier = 1
local moveX = 0
local moveY = 0

dragOtherToScroll = hs.eventtap.new({ hs.eventtap.event.types.otherMouseDragged }, function(e)
    local pressedMouseButton = e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber'])
--     print ("pressed mouse " .. pressedMouseButton)
    if scrollMouseButton == pressedMouseButton 
        then 
            -- print("scroll");
            deferred = false
            local oldmousepos = hs.mouse.absolutePosition()
            local dy = e:getProperty(hs.eventtap.event.properties['mouseEventDeltaY'])
            moveY = -dy * scrollmult            
            local scroll = hs.eventtap.event.newScrollEvent({0, moveY},{},'pixel')
            -- put the mouse back
            hs.mouse.absolutePosition(oldmousepos)
            return true, {scroll}
        end 
    if scrollHorizontalButton == pressedMouseButton 
        then 
--             print("scroll");
            deferred = false
            local oldmousepos = hs.mouse.absolutePosition()
            local dx = e:getProperty(hs.eventtap.event.properties['mouseEventDeltaX'])
            moveX = -dx * scrollmultHorizontal
            local scroll = hs.eventtap.event.newScrollEvent({moveX, 0},{},'pixel')
            -- put the mouse back
            hs.mouse.absolutePosition(oldmousepos)
            return true, {scroll}
        end 
end)

overrideOtherMouseDown:start()
overrideOtherMouseUp:start()
dragOtherToScroll:start()
