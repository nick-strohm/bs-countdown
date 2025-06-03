Config = {}

-- Debug mode
Config.Debug = false    -- Set to true to enable debug messages

-- Time units supported by the timer
Config.TimeUnits = {
    sec = 1,            -- Seconds (multiplier = 1)
    min = 60,           -- Minutes (multiplier = 60)
    hr = 3600           -- Hours (multiplier = 3600)
}

-- Command settings
Config.EnableCommands = true -- Set to true to enable commands (false for API-only usage)
Config.Commands = {
    start = 'timer',      -- Command to start a timer: /timer 5 min
    stop = 'stoptimer'    -- Command to stop a timer: /stoptimer
}

-- UI settings
Config.UI = {
    fadeInDuration = 500,      -- Duration of fade-in animation in ms
    fadeOutDuration = 1000,     -- Duration of fade-out animation in ms
    flashThreshold = 10,       -- Start flashing when timer is below this many seconds
    flashColor = '#ff0000'     -- Color to flash when timer is below threshold (red #ff0000)
}

-- Sound settings
Config.Sound = {
    enabled = true,            -- Enable sound notification at the end of the timer
    volume = 0.5               -- Volume of the sound notification (0.0 to 1.0)
}