local M = {}

local function pointInRect(pt, rect)
    return pt.x >= rect.x and pt.x <= rect.x + rect.w and pt.y >= rect.y and pt.y <= rect.y + rect.h
end

local function getScreenIndexAndList()
    local screens = hs.screen.allScreens()
    local mousePoint = hs.mouse.absolutePosition()
    local currentScreenIdx = 1
    for i, screen in ipairs(screens) do
        if pointInRect(mousePoint, screen:frame()) then
            currentScreenIdx = i
            break
        end
    end
    return currentScreenIdx, screens
end

local function moveMouseAndMaybeClick(screen)
    local rect = screen:frame()
    local pos = {x = rect.x + rect.w*0.99, y = rect.y + rect.h/2}
    hs.mouse.setAbsolutePosition(pos)
end

function M.focusNextDisplay()
    local idx, screens = getScreenIndexAndList()
    local nextIdx = idx % #screens + 1
    local nextScreen = screens[nextIdx]
    moveMouseAndMaybeClick(nextScreen)
    -- Try to focus a window on the next screen
    for _, w in ipairs(hs.window.orderedWindows()) do
        if w:screen() == nextScreen then w:focus(); return end
    end
    -- If no window found, mouse is still moved and click simulated
end

function M.focusPrevDisplay()
    local idx, screens = getScreenIndexAndList()
    local prevIdx = (idx - 2) % #screens + 1
    local prevScreen = screens[prevIdx]
    moveMouseAndMaybeClick(prevScreen)
    -- Try to focus a window on the previous screen
    for _, w in ipairs(hs.window.orderedWindows()) do
        if w:screen() == prevScreen then w:focus(); return end
    end
    -- If no window found, mouse is still moved and click simulated
end

return M