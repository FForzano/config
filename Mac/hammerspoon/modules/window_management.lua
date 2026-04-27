local M = {}

-- Helper: sposta finestra a porzione schermo
local function move(win, unit)
    if win then win:moveToUnit(unit) end
end

-- 🟥 Quarti di schermo
function M.topLeft()     move(hs.window.focusedWindow(), {0,0,0.5,0.5}) end
function M.topRight()    move(hs.window.focusedWindow(), {0.5,0,0.5,0.5}) end
function M.bottomLeft()  move(hs.window.focusedWindow(), {0,0.5,0.5,0.5}) end
function M.bottomRight() move(hs.window.focusedWindow(), {0.5,0.5,0.5,0.5}) end

-- 🟩 Metà schermo
function M.leftHalf()    move(hs.window.focusedWindow(), hs.layout.left50) end
function M.rightHalf()   move(hs.window.focusedWindow(), hs.layout.right50) end
function M.topHalf()     move(hs.window.focusedWindow(), {0,0,1,0.5}) end
function M.bottomHalf()  move(hs.window.focusedWindow(), {0,0.5,1,0.5}) end

-- ⬜ Schermo intero
function M.fullScreen()  move(hs.window.focusedWindow(), hs.layout.maximized) end

-- 🖥 Movimento finestre tra display (non workspace, quello purtroppo non è esposto dalle API Apple)
function M.moveToNextScreen()
    local win = hs.window.focusedWindow()
    if win then win:moveToScreen(win:screen():next(), true, true, 0) end
end
function M.moveToPrevScreen()
    local win = hs.window.focusedWindow()
    if win then win:moveToScreen(win:screen():previous(), true, true, 0) end
end

return M