# bs-countdown: Standalone Timer for RedM

`bs-countdown` is a FREE versatile, standalone timer resource for RedM. It provides a clean, modern UI for displaying countdown timers and offers a simple API for integration into other scripts. It features customizable titles, configurable time units, and optional in-game commands (for Developers).

![bs-countdown preview](https://i.imgur.com/fpoMN1l.jpeg)

## Features

- **Standalone**: No framework dependencies
- **Customizable Timers**: Start timers with specific amounts, units (seconds, minutes, hours), and optional titles
- **Modern UI**: Clean, minimalist, and immersive timer display using Vue 3
- **Sound Notifications**: Optional sound playback when a timer is flashing
- **Multiple Timers**: Supports display and management of multiple concurrent timers
- **Configurable Commands**: In-game commands to start and stop timers can be enabled or disabled
- **Debug Mode**: Verbose logging for easier troubleshooting

## Installation

1.  Download or clone the `bs-countdown` resource
2.  Place the `bs-countdown` folder into your server's `resources` directory
3.  Add `ensure bs-countdown` to your `server.cfg` file
4.  Restart your server or the resource

## API Usage (Exports)

You can control the timers from your other Lua scripts using these exports.

**Example: Starting a timer from another resource**
```lua
-- client_script.lua in another resource

-- Start a 5-minute timer with a title
local success, timerId = exports['bs-countdown']:startTimer(5, 'min', 'My Custom Event')

if success then
    print('Timer started with ID:', timerId)
else
    print('Failed to start timer.')
end

-- Start a 30-second timer without a title (will default to "Countdown")
exports['bs-countdown']:startTimer(30, 'sec')
```

### `startTimer(amount, unit, title)`

Starts a new timer.

-   **Parameters**:
    -   `amount` (number): The duration of the timer (e.g., 5, 30).
    -   `unit` (string): The unit of time ('sec', 'min', 'hr' - as defined in `Config.TimeUnits`).
    -   `title` (string, optional): A custom title for the timer. If nil or empty, defaults to "Countdown".
-   **Returns**:
    -   `success` (boolean): `true` if the timer was started successfully, `false` otherwise.
    -   `timerId` (number or nil): A unique ID for the timer if successful, otherwise `nil`. This ID is used to stop the timer.

### `stopTimer(timerId)`

Stops an active timer.

-   **Parameters**:
    -   `timerId` (number): The ID of the timer to stop (obtained from `startTimer`).
-   **Returns**:
    -   `success` (boolean): `true` if the timer was found and stopped, `false` otherwise.

**Example:**
```lua
local timerToStop = 1337 -- Assuming timerId 1337 exists
local stopped = exports['bs-countdown']:stopTimer(timerToStop)
if stopped then
    print('Timer ' .. timerToStop .. ' stopped.')
else
    print('Timer ' .. timerToStop .. ' not found or already stopped.')
end
```

### `isTimerRunning(timerId)`

Checks if a specific timer is currently running.

-   **Parameters**:
    -   `timerId` (number): The ID of the timer to check.
-   **Returns**:
    -   `isRunning` (boolean): `true` if the timer with the given ID is active, `false` otherwise.

**Example:**
```lua
local checkTimerId = 1
local isRunning = exports['bs-countdown']:isTimerRunning(checkTimerId)
if isRunning then
    print('Timer ' .. checkTimerId .. ' is currently running.')
else
    print('Timer ' .. checkTimerId .. ' is not running.')
end
```

## Chat Commands

If `Config.EnableCommands` is `true`, the following commands are available:

-   **Start Timer**: `/<start_command_name> <amount> <unit> [title]`
    -   Example: `/timer 10 sec 'Short Break'`
    -   Example: `/timer 1 min` (title will default to "Countdown")

-   **Stop Timer**: `/<stop_command_name> <timerId>`
    -   Example: `/stoptimer 1` (stops the timer with ID 1)

## Troubleshooting

-   **Timer Not Appearing**: Check the F8 console for Lua errors from `bs-countdown` or NUI errors (JavaScript errors).
-   **Commands Not Working**: Ensure `Config.EnableCommands` is `true` in `config.lua`.

## License

This resource is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
