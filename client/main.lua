local timers = {}
local currentTimerId = 0
local displayedTimers = {}
local activeTimerCount = 0

---@class Timer
---@field id number Timer unique identifier
---@field startTime number Game timer value when timer started
---@field duration number Duration in milliseconds
---@field timeLeft number Time left in seconds
---@field unit string Time unit used (sec, min, hr)
---@field amount number Original amount specified
---@field displayId number? UI display identifier if shown
---@field isFlashing boolean Whether the timer is currently flashing

---@param amount number The amount of time units
---@param unit string The time unit (sec, min, hr)
---@param title string? Optional title for the timer
---@return boolean success, number? timerId
function startTimer(amount, unit, title)
    if not amount or type(amount) ~= "number" or amount <= 0 then
        print("^2[bs-countdown]^7 Invalid time amount")
        return false
    end

    if not unit or not Config.TimeUnits[unit] then
        print("^2[bs-countdown]^7 Invalid time unit")
        return false
    end

    local seconds = math.floor(amount * Config.TimeUnits[unit])
    
    currentTimerId = currentTimerId + 1
    local timerId = currentTimerId
    
    timers[timerId] = {
        id = timerId,
        startTime = GetGameTimer(),
        duration = seconds * 1000,
        timeLeft = seconds,
        unit = unit,
        amount = amount,
        title = title,
        displayId = nil,
        isFlashing = false
    }
    
    activeTimerCount = activeTimerCount + 1
    
    CreateThread(function()
        local timer = timers[timerId]
        if not timer then return end
        
        if Config.Debug then
            print(string.format("^2[bs-countdown]^7 Timer started: %d %s -> '%s' with ID %d", amount, unit, title, timerId))
        end
        
        local displayId = showTimerDisplay(timerId, seconds)
        timer.displayId = displayId
        
        local lastSecond = seconds
        while timer and (GetGameTimer() - timer.startTime) < timer.duration do
            local elapsedMs = GetGameTimer() - timer.startTime
            local remainingMs = timer.duration - elapsedMs
            local remainingSec = math.ceil(remainingMs / 1000)
            
            timer.timeLeft = remainingSec
            
            if remainingSec ~= lastSecond then
                lastSecond = remainingSec
                
                local shouldFlash = remainingSec <= Config.UI.flashThreshold
                if shouldFlash ~= timer.isFlashing then
                    timer.isFlashing = shouldFlash
                    updateTimerDisplay(timerId, remainingSec, shouldFlash)
                    
                    if shouldFlash and Config.Sound.enabled then
                        SendNUIMessage({
                            action = 'playSound',
                            volume = Config.Sound.volume
                        })
                    end
                else
                    updateTimerDisplay(timerId, remainingSec)
                end
            end
            
            Wait(100)
        end
        
        if timers[timerId] then
            hideTimerDisplay(timerId)
            
            if Config.Debug then
                print("^2[bs-countdown]^7 Timer finished")
            end
            
            TriggerEvent('bs-countdown:timerEnded', timerId)
            
            timers[timerId] = nil
            activeTimerCount = activeTimerCount - 1
        end
    end)
    
    return true, timerId
end

---@param timerId number? Optional timer ID to stop (stops all if nil)
---@return boolean Success flag
function stopTimer(timerId)
    if not timerId then
        if activeTimerCount == 0 then
            if Config.Debug then
                print("^2[bs-countdown]^7 No timer running")
            end
            return false
        end
        
        for id, timer in pairs(timers) do
            if timer.displayId then
                hideTimerDisplay(id)
            end
        end
        
        timers = {}
        activeTimerCount = 0
        
        if Config.Debug then
            print("^2[bs-countdown]^7 All timers stopped")
        end
        
        return true
    else
        if not timers[timerId] then
            return false
        end
        
        if timers[timerId].displayId then
            hideTimerDisplay(timerId)
        end
        
        timers[timerId] = nil
        activeTimerCount = activeTimerCount - 1
        
        return true
    end
end

---@return boolean isRunning
function isTimerRunning()
    return activeTimerCount > 0
end

---@param timerId number Timer ID
---@param seconds number Initial seconds
---@return number displayId
function showTimerDisplay(timerId, seconds)
    local displayId = findAvailableDisplayId()
    displayedTimers[displayId] = timerId
    local position = calculateDisplayPosition(displayId)
    
    SendNUIMessage({
        action = 'showTimer',
        timerId = timerId,
        displayId = displayId,
        duration = seconds,
        title = timers[timerId].title,
        fadeIn = Config.UI.fadeInDuration,
        position = position
    })
    
    return displayId
end

---@param timerId number Timer ID
---@param seconds number Current seconds
---@param flash boolean? Whether to flash
---@param timerId number Timer ID
---@param seconds number Current seconds
---@param flash boolean? Whether to flash
function updateTimerDisplay(timerId, seconds, flash)
    local displayId = getDisplayIdForTimer(timerId)
    if not displayId then return end
    SendNUIMessage({
        action = 'updateTimer',
        displayId = displayId,
        timeLeft = seconds,
        flash = flash,
        flashColor = Config.UI.flashColor
    })
end

---@param timerId number Timer ID
function hideTimerDisplay(timerId)
    local displayId = getDisplayIdForTimer(timerId)
    if not displayId then return end
    SendNUIMessage({
        action = 'hideTimer',
        displayId = displayId,
        fadeOut = Config.UI.fadeOutDuration
    })
    displayedTimers[displayId] = nil
end

---@return number displayId
function findAvailableDisplayId()
    local id = 1
    while displayedTimers[id] ~= nil do id = id + 1 end
    return id
end

---@param timerId number
---@return number? displayId
function getDisplayIdForTimer(timerId)
    for id, tId in pairs(displayedTimers) do
        if tId == timerId then return id end
    end
    return nil
end

---@param displayId number Display ID
---@return table position
function calculateDisplayPosition(displayId)
    local baseTop = 25
    local increment = 6
    return { top = baseTop + ((displayId - 1) * increment), right = 3 }
end

if Config.EnableCommands then
    RegisterCommand(Config.Commands.start, function(_, args)
        if #args < 2 then
            if Config.Debug then
                print(string.format("^2[bs-countdown]^7 Usage: /%s <amount> <unit> [title]", Config.Commands.start))
            end
            return
        end
        local amount = tonumber(args[1])
        local unit = args[2]
        local title = #args > 2 and table.concat(args, " ", 3) or nil
        startTimer(amount, unit, title)
    end, false)

    RegisterCommand(Config.Commands.stop, function()
        stopTimer()
    end, false)
end

if Config.Debug then
    RegisterCommand('checktimers', function()
        local count = 0
        for id, timer in pairs(timers) do
            count = count + 1
            print(string.format("Timer #%d: %d seconds left", id, timer.timeLeft))
        end
        print(string.format("Total active timers: %d", count))
    end, false)
end
