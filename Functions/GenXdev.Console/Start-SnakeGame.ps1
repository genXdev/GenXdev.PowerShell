# filepath: Start-SnakeGame.ps1

###############################################################################
<#
.SYNOPSIS
Starts a simple Snake game in the console.

.DESCRIPTION
This function initializes and runs a basic Snake game within the PowerShell
console. The player controls the snake using the arrow keys or WASD keys,
aiming to eat food and grow longer while avoiding collisions with the walls
or itself. The game features dynamic speed adjustment based on available
space and snake length. By default, the console is cleared before starting.

.LICENSE
Copyright (C) 2026 René Vaessen / GenXdev

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/gpl-3.0.txt>.

.PARAMETER InitialLength
Sets the initial length of the snake. Valid range is 3-20 segments.
Default is 5 segments.

.PARAMETER Speed
Sets the base game speed in milliseconds between moves. Lower values create
a faster game. Valid range is 50-2000ms. Default is 300ms. Actual speed
adjusts dynamically during gameplay.

.PARAMETER NoClear
Prevents clearing the console before starting the game. By default, the
console is cleared to provide a clean playing field.

.PARAMETER WithMaze
Draws a maze within the playfield using ASCII drawing characters for walls
and lines, similar to the border.

.PARAMETER ShowRoute
Displays the shortest path from the snake's head to the food using small
green centered dots (·). The dots are visual overlays only and do not
affect collision detection.

.PARAMETER MazeWidth
Sets the minimum pathway width for the maze. Valid range is 1-10.
Default is 2. Higher values create wider pathways making the maze easier
to navigate.

.EXAMPLE
Start-SnakeGame

Starts the Snake game with default settings (5 segments, 300ms speed).

.EXAMPLE
Start-SnakeGame -NoClear -InitialLength 3 -Speed 200

Starts the Snake game without clearing console, with shorter snake and faster
speed.

.EXAMPLE
snake -InitialLength 10

Starts the game using the alias with a longer initial snake.

.EXAMPLE
Start-SnakeGame -WithMaze

Starts the Snake game with a maze in the playfield.

.EXAMPLE
Start-SnakeGame -WithMaze -ShowRoute

Starts the Snake game with a maze and displays the shortest path from the
snake to the food with green dots.

.EXAMPLE
Start-SnakeGame -WithMaze -MazeWidth 5

Starts the Snake game with a maze that has wider pathways (minimum 5 spaces)
for easier navigation.
#>
###############################################################################

function Start-SnakeGame {

    [CmdletBinding(SupportsShouldProcess)]
    [Alias('snake')]

    param(

        ###########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "Initial length of the snake (default: 5)"
        )]
        [ValidateRange(3, 20)]
        [int] $InitialLength = 5,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = (
                "Game speed in milliseconds between moves (default: 300)"
            )
        )]
        [ValidateRange(50, 2000)]
        [int] $Speed = 300,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = (
                "Prevents clearing the console before starting the game"
            )
        )]
        [switch] $NoClear,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = (
                "Draws a maze within the playfield using ASCII drawing " +
                "characters for walls and lines, similar to the border"
            )
        )]
        [switch] $WithMaze,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = (
                "Displays the shortest path from the snake's head to the " +
                "food using small green centered dots"
            )
        )]
        [switch] $ShowRoute,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = (
                "Minimum pathway width for the maze (1-10, default: 2)"
            )
        )]
        [ValidateRange(1, 10)]
        [int] $MazeWidth = 2
        ###########################################################################
    )

    begin {

        # initialize game state hashtable to store all game variables
        $script:gameState = @{
            # current console window width in characters
            width           = 0
            # current console window height in characters
            height          = 0
            # left boundary of playable area (x coordinate)
            playFieldLeft   = 1
            # top boundary of playable area (y coordinate)
            playFieldTop    = 1
            # right boundary of playable area (x coordinate)
            playFieldRight  = 0
            # bottom boundary of playable area (y coordinate)
            playFieldBottom = 0
            # current player score (food items eaten)
            score           = 0
            # initial length of snake
            snakeLength     = $InitialLength
            # current game speed in milliseconds
            gameSpeed       = $Speed
            # current movement direction
            direction       = 'Right'
            # list of snake segment positions as tuples
            snake           = $null
            # current food position as tuple
            food            = $null
            # array of console lines for collision detection
            screenBuffer    = $null
            # temporary storage for snake placement
            snakePositions  = $null
            # temporary x coordinate variable
            x               = 0
            # temporary y coordinate variable
            y               = 0
            # character to restore when snake moves
            originalChar    = ''
            # flag to enable debug logging
            loggingEnabled  = $false
            # string builder for log messages
            logBuilder      = $null
            # path to log file
            logPath         = ''
            # timestamp of last direction change
            LastMoveTime    = [DateTime]::UtcNow
            # position where last direction change occurred
            LastMoveCoord   = $null
            # list of positions in current route path
            routePath       = $null
        }

        # initialize logging infrastructure for debugging purposes
        $script:gameState.logBuilder = [System.Text.StringBuilder]::new()

        $script:gameState.logPath = [System.IO.Path]::Join(
            $MyInvocation.MyCommand.Module.ModuleBase,
            'snake.log'
        )

        # delete old log file to start fresh
        if ([System.IO.File]::Exists($script:gameState.logPath)) {

            [System.IO.File]::Delete($script:gameState.logPath)
        }

        ###########################################################################
        # internal logging function to write timestamped debug messages
        function Log {

            param([string]$Line)

            if ($script:gameState.loggingEnabled) {

                $timestamp = Microsoft.PowerShell.Utility\Get-Date -Format (
                    'yyyy-MM-dd HH:mm:ss.fff'
                )


                $logEntry = "[$timestamp] $Line"

                $null = $script:gameState.logBuilder.AppendLine($logEntry)
            }
        }
        ###########################################################################

        # start logging game initialization
        Log "Starting Snake Game initialization"

        # capture current console dimensions for playfield calculation
        $script:gameState.width = [Console]::WindowWidth

        $script:gameState.height = [Console]::WindowHeight

        # calculate playfield boundaries avoiding last column and rows
        $script:gameState.playFieldRight = $script:gameState.width - 2

        $script:gameState.playFieldBottom = $script:gameState.height - 3

        Log (
            "Console dimensions: Width=$($script:gameState.width), " +
            "Height=$($script:gameState.height)"
        )

        Log (
            "Playfield boundaries: Left=$($script:gameState.playFieldLeft), " +
            "Top=$($script:gameState.playFieldTop), " +
            "Right=$($script:gameState.playFieldRight), " +
            "Bottom=$($script:gameState.playFieldBottom)"
        )

        # clear console unless user specified not to
        if (-not $NoClear) {

            Clear-Host

            Log "Screen cleared for border drawing"
        }

        # draw border using box drawing characters
        [Console]::SetCursorPosition(0, 0)
        Microsoft.PowerShell.Utility\Write-Host '┌' -NoNewline
        for ($i = 1; $i -lt $script:gameState.width - 1; $i++) {
            Microsoft.PowerShell.Utility\Write-Host '─' -NoNewline
        }
        Microsoft.PowerShell.Utility\Write-Host '┐' -NoNewline

        for ($y = 1; $y -lt $script:gameState.playFieldBottom + 1; $y++) {
            [Console]::SetCursorPosition(0, $y)
            Microsoft.PowerShell.Utility\Write-Host '│' -NoNewline
            [Console]::SetCursorPosition($script:gameState.width - 1, $y)
            Microsoft.PowerShell.Utility\Write-Host '│' -NoNewline
        }

        [Console]::SetCursorPosition(0, $script:gameState.playFieldBottom + 1)
        Microsoft.PowerShell.Utility\Write-Host '└' -NoNewline
        for ($i = 1; $i -lt $script:gameState.width - 1; $i++) {
            Microsoft.PowerShell.Utility\Write-Host '─' -NoNewline
        }
        Microsoft.PowerShell.Utility\Write-Host '┘' -NoNewline

        Log "Border drawn to console"

        # read current screen buffer after drawing border
        Log "Reading screen buffer"

        $script:gameState.screenBuffer = @(
            [GenXdev.Helpers.ConsoleReader]::ReadFromBuffer(
                0,
                0,
                $script:gameState.width,
                $script:gameState.height
            )
        )

        Log (
            "Screen buffer read successfully, lines: " +
            "$($script:gameState.screenBuffer.Count)"
        )

        if ($WithMaze) {

            # define maze dimensions based on playfield, leaving space around
            $mazeLeft = $script:gameState.playFieldLeft + 1
            $mazeTop = $script:gameState.playFieldTop + 1
            $mazeTotalWidth = $script:gameState.playFieldRight - $script:gameState.playFieldLeft - 2
            $mazeTotalHeight = $script:gameState.playFieldBottom - $script:gameState.playFieldTop - 3  # Leave extra space below for snake

            # calculate pathway width based on available size and MazeWidth parameter
            $pathWidth = [math]::Max(
                $MazeWidth,
                [math]::Min(
                    10,
                    [math]::Floor(
                        [math]::Min($mazeTotalWidth, $mazeTotalHeight) / 20
                    )
                )
            )

            Log "Calculated pathway width: $pathWidth (MazeWidth parameter: $MazeWidth)"

            # calculate number of maze cells to fit
            $cellsWidth = [math]::Floor(($mazeTotalWidth - 1) / ($pathWidth + 1))

            $cellsHeight = [math]::Floor(($mazeTotalHeight - 1) / ($pathWidth + 1))

            if ($cellsWidth -lt 1 -or $cellsHeight -lt 1) {

                $pathWidth = 2

                $cellsWidth = [math]::Floor(
                    ($mazeTotalWidth - 1) / ($pathWidth + 1)
                )

                $cellsHeight = [math]::Floor(
                    ($mazeTotalHeight - 1) / ($pathWidth + 1)
                )

                Log "Adjusted pathway width to 2 due to small size"
            }

            Log (
                "Maze cells: Width=$cellsWidth, Height=$cellsHeight"
            )

            if ($cellsWidth -lt 1 -or $cellsHeight -lt 1) {
                Log "Maze dimensions too small, skipping maze generation"
                $WithMaze = $false
            }
            else {

                # create cells with wall properties
                $cells = Microsoft.PowerShell.Utility\New-Object 'psobject[,]' $cellsHeight, $cellsWidth

                for ($i = 0; $i -lt $cellsHeight; $i++) {

                    for ($j = 0; $j -lt $cellsWidth; $j++) {

                        $cells[$i, $j] = [pscustomobject]@{
                            N = $true
                            S = $true
                            E = $true
                            W = $true
                        }
                    }
                }

                # create visited array for maze generation
                $visited = Microsoft.PowerShell.Utility\New-Object 'bool[,]' $cellsHeight, $cellsWidth

                # define function to carve maze paths
                function Carve {

                    param ($x, $y)

                    $visited[$y, $x] = $true

                    $directions = @(
                        [pscustomobject]@{dir = 'N'; dx = 0; dy = -1 },
                        [pscustomobject]@{dir = 'S'; dx = 0; dy = 1 },
                        [pscustomobject]@{dir = 'E'; dx = 1; dy = 0 },
                        [pscustomobject]@{dir = 'W'; dx = -1; dy = 0 }
                    ) | Microsoft.PowerShell.Utility\Get-Random -Count 4

                    foreach ($d in $directions) {

                        $nx = $x + $d.dx

                        $ny = $y + $d.dy

                        if ($nx -ge 0 -and $nx -lt $cellsWidth -and $ny -ge 0 -and (
                                $ny -lt $cellsHeight
                            ) -and -not $visited[$ny, $nx]) {

                            $cells[$y, $x].($d.dir) = $false

                            $opp = switch ($d.dir) {
                                'N' { 'S' }
                                'S' { 'N' }
                                'E' { 'W' }
                                'W' { 'E' }
                            }

                            $cells[$ny, $nx].$opp = $false

                            Carve $nx $ny
                        }
                    }
                }

                # start carving maze from top-left
                Carve 0 0

                # add braiding to create loops for cooler mazes
                $braidProb = 0.3

                for ($y = 0; $y -lt $cellsHeight; $y++) {

                    for ($x = 0; $x -lt $cellsWidth; $x++) {

                        $walls = @('N', 'S', 'E', 'W') | Microsoft.PowerShell.Core\Where-Object {
                            $cells[$y, $x].$_
                        }

                        if ($walls.Count -eq 3 -and (
                                Microsoft.PowerShell.Utility\Get-Random -Maximum 1.0
                            ) -lt $braidProb) {

                            $dir = $walls | Microsoft.PowerShell.Utility\Get-Random

                            $dx, $dy = switch ($dir) {
                                'N' { 0, -1 }
                                'S' { 0, 1 }
                                'E' { 1, 0 }
                                'W' { -1, 0 }
                            }

                            $nx = $x + $dx

                            $ny = $y + $dy

                            if ($nx -ge 0 -and $nx -lt $cellsWidth -and $ny -ge 0 -and (
                                    $ny -lt $cellsHeight
                                )) {

                                $cells[$y, $x].$dir = $false

                                $opp = switch ($dir) {
                                    'N' { 'S' }
                                    'S' { 'N' }
                                    'E' { 'W' }
                                    'W' { 'E' }
                                }

                                $cells[$ny, $nx].$opp = $false
                            }
                        }
                    }
                }

                # create wide opening at the bottom right
                if ($cellsHeight -gt 0 -and $cellsWidth -gt 0) {

                    $exitCellX = $cellsWidth - 1

                    $cells[($cellsHeight - 1), $exitCellX].S = $false

                    if ($cellsWidth -gt 1) {

                        $exitCellX2 = $cellsWidth - 2

                        $cells[($cellsHeight - 1), $exitCellX2].S = $false

                    }

                    if ($cellsWidth -gt 2) {

                        $exitCellX3 = $cellsWidth - 3

                        $cells[($cellsHeight - 1), $exitCellX3].S = $false

                    }

                }

                # define box drawing characters lookup
                $boxChars = @{
                    '0000' = ' '
                    '0001' = '─'
                    '0010' = '─'
                    '0011' = '─'
                    '0100' = '│'
                    '0101' = '┌'
                    '0110' = '┐'
                    '0111' = '┬'
                    '1000' = '│'
                    '1001' = '└'
                    '1010' = '┘'
                    '1011' = '┴'
                    '1100' = '│'
                    '1101' = '├'
                    '1110' = '┤'
                    '1111' = '┼'
                }

                # build maze lines for rendering
                $mazeLines = Microsoft.PowerShell.Utility\New-Object System.Collections.ArrayList

                for ($h = 0; $h -le $cellsHeight; $h++) {

                    $hline = ''

                    for ($k = 0; $k -le $cellsWidth; $k++) {

                        $north = $false

                        $south = $false

                        $left = $false

                        $right = $false

                        if ($h -gt 0) {

                            $north = if ($k -eq 0) {
                                $true
                            }
                            else {
                                $cells[($h - 1), ($k - 1)].E
                            }
                        }

                        if ($h -lt $cellsHeight) {

                            $south = if ($k -eq 0) {
                                $true
                            }
                            else {
                                $cells[$h, ($k - 1)].E
                            }
                        }

                        if ($h -eq 0 -or $h -eq $cellsHeight) {

                            $left = ($k -gt 0)

                            $right = ($k -lt $cellsWidth)
                        }
                        else {

                            $left = ($k -gt 0) -and $cells[($h - 1), ($k - 1)].S

                            $right = ($k -lt $cellsWidth) -and (
                                $cells[($h - 1), $k].S
                            )
                        }

                        $key = [int]$north, [int]$south, [int]$left, [int]$right -join ''

                        $char = $boxChars[$key]

                        if (-not $char) { $char = ' ' }

                        $hline += $char

                        if ($k -lt $cellsWidth) {

                            $hasHorizontal = if ($h -eq 0 -or $h -eq $cellsHeight -or $k -eq $cellsWidth) {
                                $true
                            }
                            else {
                                $cells[($h - 1), $k].S
                            }

                            if ($hasHorizontal) {

                                $hline += ('─' * $pathWidth)
                            }
                            else {

                                $hline += (' ' * $pathWidth)
                            }
                        }
                    }

                    $null = $mazeLines.Add($hline)

                    if ($h -lt $cellsHeight) {

                        $vline = ''

                        for ($k = 0; $k -le $cellsWidth; $k++) {

                            if ($k -eq 0) {

                                $vline += '│'
                            }
                            else {

                                if ($cells[$h, ($k - 1)].E) {

                                    $vline += '│'
                                }
                                else {

                                    $vline += ' '
                                }
                            }

                            if ($k -lt $cellsWidth) {

                                $vline += (' ' * $pathWidth)
                            }
                        }

                        for ($ph = 0; $ph -lt $pathWidth; $ph++) {

                            $null = $mazeLines.Add($vline)
                        }
                    }
                }

                # update screen buffer with maze walls for collision detection
                for ($i = 0; $i -lt $mazeLines.Count; $i++) {

                    if ($mazeTop + $i -ge $script:gameState.screenBuffer.Count) {

                        break
                    }

                    $line = $mazeLines[$i]

                    if ($line.Length -lt $mazeTotalWidth) {

                        $line += ' ' * ($mazeTotalWidth - $line.Length)
                    }

                    $lineChars = $script:gameState.screenBuffer[
                    $mazeTop + $i
                    ].ToCharArray()

                    for ($j = 0; $j -lt $line.Length; $j++) {

                        if ($mazeLeft + $j -lt $lineChars.Length) {

                            $lineChars[$mazeLeft + $j] = $line[$j]
                        }
                    }

                    $script:gameState.screenBuffer[$mazeTop + $i] = -join $lineChars
                }

                Log "Screen buffer updated with polished maze"

                # draw maze to console
                Log "Drawing maze to console"
                for ($i = 0; $i -lt $mazeLines.Count; $i++) {

                    if ($mazeTop + $i -ge $script:gameState.height) { break }

                    [Console]::SetCursorPosition($mazeLeft, $mazeTop + $i)

                    Microsoft.PowerShell.Utility\Write-Host $mazeLines[$i] -NoNewline
                }

                Log "Maze drawn to console"

                # Create opening in bottom-right corner of maze border
                $openingSize = [math]::Min(5, [math]::Max(2, [math]::Floor($mazeTotalWidth / 10)))
                $openingY = $mazeTop + $mazeLines.Count - 1  # Last line of maze
                # Use actual rendered maze line length instead of $mazeTotalWidth
                $actualMazeWidth = $mazeLines[$mazeLines.Count - 1].Length
                $openingStartX = $mazeLeft + $actualMazeWidth - $openingSize

                Log "Creating maze opening: Y=$openingY, StartX=$openingStartX, Size=$openingSize, MazeLines=$($mazeLines.Count), ActualWidth=$actualMazeWidth"

                # Clear the opening in screen buffer and on console
                for ($ox = 0; $ox -lt $openingSize; $ox++) {
                    $clearX = $openingStartX + $ox
                    if ($clearX -ge 0 -and $clearX -lt $script:gameState.width -and $openingY -ge 0 -and $openingY -lt $script:gameState.height) {
                        # Update screen buffer
                        $lineChars = $script:gameState.screenBuffer[$openingY].ToCharArray()
                        if ($clearX -lt $lineChars.Length) {
                            $lineChars[$clearX] = ' '
                        }
                        $script:gameState.screenBuffer[$openingY] = -join $lineChars

                        # Clear on console
                        [Console]::SetCursorPosition($clearX, $openingY)
                        Microsoft.PowerShell.Utility\Write-Host ' ' -NoNewline
                    }
                }

                Log "Maze opening created in bottom-right corner"
            }
        }

        # initialize snake as strongly-typed list of coordinate tuples
        $script:gameState.snake = (
            Microsoft.PowerShell.Utility\New-Object 'System.Collections.Generic.List[System.Tuple[int, int]]'
        )

        Log "Snake object created"

        ###########################################################################
        # internal function to detect if console window has been resized
        function ScreenIsResized {

            return (
                $script:gameState.width -ne [Console]::WindowWidth -or
                $script:gameState.height -ne [Console]::WindowHeight
            )
        }
        ###########################################################################

        ###########################################################################
        # internal function to check if food position is reachable from snake head
        function IsPositionReachable {

            param(
                [Tuple[int, int]]$fromPos,
                [Tuple[int, int]]$toPos
            )

            # use breadth-first search to find if path exists
            $queue = Microsoft.PowerShell.Utility\New-Object 'System.Collections.Generic.Queue[System.Tuple[int, int]]'
            $visited = @{}

            $queue.Enqueue($fromPos)
            $visited["$($fromPos.Item1),$($fromPos.Item2)"] = $true

            $directions = @(
                @{ dx = 0; dy = -1 },  # Up
                @{ dx = 0; dy = 1 },   # Down
                @{ dx = -1; dy = 0 },  # Left
                @{ dx = 1; dy = 0 }    # Right
            )

            $maxIterations = 10000
            $iterations = 0

            while ($queue.Count -gt 0 -and $iterations -lt $maxIterations) {
                $iterations++
                $current = $queue.Dequeue()

                # check if we reached the target
                if ($current.Item1 -eq $toPos.Item1 -and $current.Item2 -eq $toPos.Item2) {
                    Log "Path found to food after $iterations iterations"
                    return $true
                }

                # explore neighbors
                foreach ($dir in $directions) {
                    $newX = $current.Item1 + $dir.dx
                    $newY = $current.Item2 + $dir.dy
                    $key = "$newX,$newY"

                    # skip if already visited
                    if ($visited.ContainsKey($key)) {
                        continue
                    }

                    # check if position is valid and passable
                    if (
                        $newX -ge $script:gameState.playFieldLeft -and
                        $newX -lt $script:gameState.playFieldRight -and
                        $newY -ge $script:gameState.playFieldTop -and
                        $newY -lt $script:gameState.playFieldBottom -and
                        $script:gameState.screenBuffer[$newY][$newX] -eq ' '
                    ) {
                        $newPos = [Tuple]::Create($newX, $newY)

                        # skip if position is on snake body (except we allow target position)
                        if ($newPos -in $script:gameState.snake -and -not (
                                $newPos.Item1 -eq $toPos.Item1 -and $newPos.Item2 -eq $toPos.Item2
                            )) {
                            continue
                        }

                        $visited[$key] = $true
                        $queue.Enqueue($newPos)
                    }
                }
            }

            Log "No path found to food after $iterations iterations"
            return $false
        }
        ###########################################################################

        ###########################################################################
        # internal function to find shortest path and return it as a list
        function FindShortestPath {

            param(
                [Tuple[int, int]]$fromPos,
                [Tuple[int, int]]$toPos
            )

            # use breadth-first search to find shortest path
            $queue = Microsoft.PowerShell.Utility\New-Object 'System.Collections.Generic.Queue[System.Tuple[int, int]]'
            $visited = @{}
            $parent = @{}

            $queue.Enqueue($fromPos)
            $visited["$($fromPos.Item1),$($fromPos.Item2)"] = $true

            $directions = @(
                @{ dx = 0; dy = -1 },  # Up
                @{ dx = 0; dy = 1 },   # Down
                @{ dx = -1; dy = 0 },  # Left
                @{ dx = 1; dy = 0 }    # Right
            )

            $maxIterations = 10000
            $iterations = 0
            $found = $false

            while ($queue.Count -gt 0 -and $iterations -lt $maxIterations) {
                $iterations++
                $current = $queue.Dequeue()

                # check if we reached the target
                if ($current.Item1 -eq $toPos.Item1 -and $current.Item2 -eq $toPos.Item2) {
                    $found = $true
                    Log "Shortest path found after $iterations iterations"
                    break
                }

                # explore neighbors
                foreach ($dir in $directions) {
                    $newX = $current.Item1 + $dir.dx
                    $newY = $current.Item2 + $dir.dy
                    $key = "$newX,$newY"

                    # skip if already visited
                    if ($visited.ContainsKey($key)) {
                        continue
                    }

                    # check if position is valid and passable
                    if (
                        $newX -ge $script:gameState.playFieldLeft -and
                        $newX -lt $script:gameState.playFieldRight -and
                        $newY -ge $script:gameState.playFieldTop -and
                        $newY -lt $script:gameState.playFieldBottom -and
                        $script:gameState.screenBuffer[$newY][$newX] -eq ' '
                    ) {
                        $newPos = [Tuple]::Create($newX, $newY)

                        # skip if position is on snake body (except target)
                        if ($newPos -in $script:gameState.snake -and -not (
                                $newPos.Item1 -eq $toPos.Item1 -and $newPos.Item2 -eq $toPos.Item2
                            )) {
                            continue
                        }

                        $visited[$key] = $true
                        $parent[$key] = $current
                        $queue.Enqueue($newPos)
                    }
                }
            }

            # reconstruct path if found
            if ($found) {
                $path = Microsoft.PowerShell.Utility\New-Object 'System.Collections.Generic.List[System.Tuple[int, int]]'
                $currentPos = $toPos
                $currentKey = "$($toPos.Item1),$($toPos.Item2)"

                while ($parent.ContainsKey($currentKey)) {
                    $path.Insert(0, $currentPos)
                    $currentPos = $parent[$currentKey]
                    $currentKey = "$($currentPos.Item1),$($currentPos.Item2)"
                }

                # don't include the starting position
                Log "Path reconstructed with $($path.Count) positions"
                return $path
            }

            Log "No path could be reconstructed"
            return $null
        }
        ###########################################################################

        ###########################################################################
        # internal function to draw the route path with green centered dot
        function DrawRoutePath {

            Log "DrawRoutePath called, ShowRoute=$ShowRoute"

            # clear old route if exists
            if ($null -ne $script:gameState.routePath -and $script:gameState.routePath.Count -gt 0) {
                Log "Clearing old route with $($script:gameState.routePath.Count) positions"
                foreach ($pos in $script:gameState.routePath) {
                    # skip if position is now part of snake or is food
                    if ($pos -in $script:gameState.snake -or (
                            $pos.Item1 -eq $script:gameState.food.Item1 -and
                            $pos.Item2 -eq $script:gameState.food.Item2
                        )) {
                        continue
                    }

                    # restore original character from screen buffer
                    [Console]::SetCursorPosition($pos.Item1, $pos.Item2)
                    $char = $script:gameState.screenBuffer[$pos.Item2][$pos.Item1]
                    Microsoft.PowerShell.Utility\Write-Host $char -NoNewline
                }
            }

            # find and draw new route if ShowRoute is enabled
            if ($ShowRoute -and $script:gameState.snake.Count -gt 0) {
                $snakeHead = $script:gameState.snake[0]
                Log "Finding path from ($($snakeHead.Item1),$($snakeHead.Item2)) to ($($script:gameState.food.Item1),$($script:gameState.food.Item2))"
                $script:gameState.routePath = FindShortestPath -fromPos $snakeHead -toPos $script:gameState.food

                if ($null -ne $script:gameState.routePath -and $script:gameState.routePath.Count -gt 0) {
                    Log "Drawing route with $($script:gameState.routePath.Count) positions"
                    foreach ($pos in $script:gameState.routePath) {
                        # skip snake head and food positions
                        if ($pos -in $script:gameState.snake -or (
                                $pos.Item1 -eq $script:gameState.food.Item1 -and
                                $pos.Item2 -eq $script:gameState.food.Item2
                            )) {
                            continue
                        }

                        # draw with small green centered dot (·) - does not update screen buffer
                        [Console]::SetCursorPosition($pos.Item1, $pos.Item2)
                        Microsoft.PowerShell.Utility\Write-Host '·' -NoNewline -ForegroundColor Green
                    }
                    Log "Route drawn"
                }
                else {
                    Log "No route path found or path is empty"
                }
            }
            else {
                Log "ShowRoute disabled or no snake"
                $script:gameState.routePath = $null
            }
        }
        ###########################################################################

        ###########################################################################
        # internal function to find unoccupied space for snake or food placement
        function FindUnoccupiedSpace {

            param(
                [int]$requiredLength = 1,
                [switch]$allowVertical = $false,
                [switch]$insideMaze = $false
            )

            Log (
                "FindUnoccupiedSpace called: RequiredLength=$requiredLength, " +
                "AllowVertical=$allowVertical, InsideMaze=$insideMaze"
            )

            # adjust boundaries if insideMaze
            $minX = if ($insideMaze) { $mazeLeft + 1 } else { $script:gameState.playFieldLeft }
            $maxX = if ($insideMaze) { $mazeLeft + $mazeTotalWidth - 1 } else { $script:gameState.playFieldRight - 1 }
            $minY = if ($insideMaze) { $mazeTop + 1 } else { $script:gameState.playFieldTop }
            $maxY = if ($insideMaze) { $mazeTop + $mazeTotalHeight - 1 } else { $script:gameState.playFieldBottom - 1 }

            if ($insideMaze -and ($maxX -lt $minX -or $maxY -lt $minY)) {
                Log "Maze boundaries invalid for placement, returning null"
                return $null
            }

            # calculate maximum attempts based on playfield size
            $maxAttempts = (
                $script:gameState.width * $script:gameState.height * 4
            )

            $attempts = 0

            # attempt to find suitable placement location
            while ($attempts -lt $maxAttempts) {

                # generate random starting coordinates within playfield
                $startX = Microsoft.PowerShell.Utility\Get-Random `
                    -Minimum $minX `
                    -Maximum ($maxX + 1)

                $startY = Microsoft.PowerShell.Utility\Get-Random `
                    -Minimum $minY `
                    -Maximum ($maxY + 1)

                # handle single space placement for food items
                if ($requiredLength -eq 1) {

                    # verify position is within bounds and unoccupied
                    if (
                        $startX -ge $minX -and
                        $startX -le $maxX -and
                        $startY -ge $minY -and
                        $startY -le $maxY -and
                        $script:gameState.screenBuffer[$startY][$startX] -eq (
                            ' '
                        ) -and -not ([Tuple]::Create($startX, $startY) -in $script:gameState.snake)
                    ) {

                        $candidatePos = [Tuple]::Create($startX, $startY)

                        # check if position is reachable from snake head (only if snake exists and WithMaze is enabled)
                        if ($WithMaze -and $script:gameState.snake.Count -gt 0) {
                            $snakeHead = $script:gameState.snake[0]
                            if (-not (IsPositionReachable -fromPos $snakeHead -toPos $candidatePos)) {
                                Log "Food position ($startX, $startY) is not reachable, trying another position"
                                $attempts++
                                continue
                            }
                        }

                        Log (
                            "Found unoccupied space for food at " +
                            "($startX, $startY) after $attempts attempts"
                        )

                        return $candidatePos
                    }

                    $attempts++

                    continue
                }

                # define possible placement directions for multi-segment snake
                $directions = @(
                    @{
                        dx       = -1
                        dy       = 0
                        name     = 'Left'
                        opposite = 'Right'
                    },
                    @{
                        dx       = 1
                        dy       = 0
                        name     = 'Right'
                        opposite = 'Left'
                    },
                    @{
                        dx       = 0
                        dy       = -1
                        name     = 'Up'
                        opposite = 'Down'
                    },
                    @{
                        dx       = 0
                        dy       = 1
                        name     = 'Down'
                        opposite = 'Up'
                    }
                )

                # restrict to horizontal directions if vertical not allowed
                if (-not $allowVertical) {

                    $directions = $directions[0..1]
                }

                # try each direction for snake placement
                foreach ($dir in $directions) {

                    $positions = @()

                    $canPlace = $true

                    # attempt to place all segments in current direction
                    for ($i = 0; $i -lt $requiredLength; $i++) {

                        $checkX = $startX + ($dir.dx * $i)

                        $checkY = $startY + ($dir.dy * $i)

                        # verify each position is valid and unoccupied
                        if (
                            $checkX -lt $minX -or
                            $checkX -gt $maxX -or
                            $checkY -lt $minY -or
                            $checkY -gt $maxY -or
                            $script:gameState.screenBuffer[$checkY][$checkX] -ne (
                                ' '
                            )
                        ) {

                            $canPlace = $false

                            break
                        }

                        $positions += [Tuple]::Create($checkX, $checkY)
                    }

                    # placement successful in this direction
                    if ($canPlace) {

                        # set initial movement direction opposite to placement
                        if ($requiredLength -gt 1) {

                            $script:gameState.direction = $dir.opposite

                            Log (
                                "Snake placed successfully in direction " +
                                "$($dir.name), setting initial direction to " +
                                "$($dir.opposite)"
                            )
                        }

                        Log (
                            "Found unoccupied space for snake " +
                            "($($positions.Count) segments) after " +
                            "$attempts attempts"
                        )

                        return $positions
                    }

                    # attempt l-shaped placement if linear placement failed
                    if (-not $canPlace -and $i -gt 0) {

                        $positions = @()

                        $canPlace = $true

                        $placedCount = $i

                        # place segments that fit in original direction
                        for ($j = 0; $j -lt $placedCount; $j++) {

                            $positions += [Tuple]::Create(
                                $startX + ($dir.dx * $j),
                                $startY + ($dir.dy * $j)
                            )
                        }

                        # calculate remaining segments needed
                        $remainingLength = $requiredLength - $placedCount

                        # get alternative directions for remaining segments
                        $otherDirections = $directions |
                            Microsoft.PowerShell.Core\Where-Object {
                                $_.name -ne $dir.name
                            }

                        # try each alternative direction
                        foreach ($otherDir in $otherDirections) {

                            $tempCanPlace = $true

                            # verify remaining segments fit in new direction
                            for ($k = 1; $k -le $remainingLength; $k++) {

                                $checkX = $startX + ($otherDir.dx * $k)

                                $checkY = $startY + ($otherDir.dy * $k)

                                if (
                                    $checkX -lt $minX -or
                                    $checkX -gt $maxX -or
                                    $checkY -lt $minY -or
                                    $checkY -gt $maxY -or
                                    $script:gameState.screenBuffer[
                                    $checkY
                                    ][$checkX] -ne ' '
                                ) {

                                    $tempCanPlace = $false

                                    break
                                }
                            }

                            # add remaining segments if placement valid
                            if ($tempCanPlace) {

                                for ($k = 1; $k -le $remainingLength; $k++) {

                                    $positions += [Tuple]::Create(
                                        $startX + ($otherDir.dx * $k),
                                        $startY + ($otherDir.dy * $k)
                                    )
                                }

                                # determine safe direction for l-shaped snake
                                if ($requiredLength -gt 1) {

                                    $head = $positions[0]

                                    $neck = $positions[1]

                                    # calculate direction from neck to head
                                    $headDirection = ''

                                    if ($head.Item1 -gt $neck.Item1) {

                                        $headDirection = 'Right'
                                    }
                                    elseif ($head.Item1 -lt $neck.Item1) {

                                        $headDirection = 'Left'
                                    }
                                    elseif ($head.Item2 -gt $neck.Item2) {

                                        $headDirection = 'Down'
                                    }
                                    elseif ($head.Item2 -lt $neck.Item2) {

                                        $headDirection = 'Up'
                                    }

                                    # set direction away from neck
                                    $script:gameState.direction = $headDirection

                                    Log (
                                        "L-shaped snake placed, setting " +
                                        "initial direction to $headDirection"
                                    )
                                }

                                Log (
                                    "Found L-shaped placement for snake after " +
                                    "$attempts attempts"
                                )

                                return $positions
                            }
                        }
                    }
                }

                $attempts++
            }

            # use fallback center placement if no valid position found
            Log "Using fallback placement for RequiredLength=$requiredLength"

            if ($requiredLength -eq 1) {

                # return center position for single space
                return [Tuple]::Create(
                    (
                        ($script:gameState.playFieldRight - (
                            $script:gameState.playFieldLeft
                        )) / 2 + $script:gameState.playFieldLeft
                    ),
                    (
                        ($script:gameState.playFieldBottom - (
                            $script:gameState.playFieldTop
                        )) / 2 + $script:gameState.playFieldTop
                    )
                )
            }
            else {

                # create horizontal snake in center for multi-segment
                $fallbackPositions = @()

                $centerX = (
                    ($script:gameState.playFieldRight - (
                        $script:gameState.playFieldLeft
                    )) / 2 + $script:gameState.playFieldLeft
                )

                $centerY = (
                    ($script:gameState.playFieldBottom - (
                        $script:gameState.playFieldTop
                    )) / 2 + $script:gameState.playFieldTop
                )

                for ($i = 0; $i -lt $requiredLength; $i++) {

                    $fallbackPositions += [Tuple]::Create(
                        $centerX - $i,
                        $centerY
                    )
                }

                # set safe direction for fallback horizontal snake
                $script:gameState.direction = 'Right'

                Log "Fallback snake placement, setting direction to Right"

                return $fallbackPositions
            }
        }
        ###########################################################################

        ###########################################################################
        # internal function to draw snake and food on screen
        function DrawInitialScreen {

            Log "Starting to draw initial screen - snake and food"

            $blink = if ($WithMaze) { $PSStyle.Blink } else { '' }

            # draw snake segments
            $isHead = $true
            foreach ($segment in $script:gameState.snake) {
                [Console]::SetCursorPosition($segment.Item1, $segment.Item2)
                if ($isHead) {
                    Microsoft.PowerShell.Utility\Write-Host "${blink}O$($PSStyle.Reset)" -NoNewline -ForegroundColor Green
                    $isHead = $false
                }
                else {
                    Microsoft.PowerShell.Utility\Write-Host "${blink}o$($PSStyle.Reset)" -NoNewline -ForegroundColor Green
                }
            }

            # draw food item
            [Console]::SetCursorPosition($script:gameState.food.Item1, $script:gameState.food.Item2)
            Microsoft.PowerShell.Utility\Write-Host "$($PSStyle.Blink)*$($PSStyle.Reset)" -NoNewline -ForegroundColor Red

            Log (
                "Initial screen drawn - snake ($($script:gameState.snake.Count) segments), " +
                "food at ($($script:gameState.food.Item1), $($script:gameState.food.Item2))"
            )

            if ($WithMaze) {

                # Redraw snake without blink
                $isHead = $true
                foreach ($segment in $script:gameState.snake) {
                    [Console]::SetCursorPosition($segment.Item1, $segment.Item2)
                    if ($isHead) {
                        Microsoft.PowerShell.Utility\Write-Host 'O' -NoNewline -ForegroundColor Green
                        $isHead = $false
                    }
                    else {
                        Microsoft.PowerShell.Utility\Write-Host 'o' -NoNewline -ForegroundColor Green
                    }
                }
                Log "Snake redrawn without blink after pause"
            }

            # draw route path if ShowRoute is enabled
            DrawRoutePath
        }
        ###########################################################################

        ###########################################################################
        # internal function to count consecutive free spaces in a direction
        function CountFreeSpaces {

            param(
                [int]$startX,
                [int]$startY,
                [string]$direction
            )

            # initialize direction vectors for movement calculation
            $dx = 0

            $dy = 0

            # set direction vector based on movement direction
            switch ($direction) {

                'Up' { $dy = -1 }
                'Down' { $dy = 1 }
                'Left' { $dx = -1 }
                'Right' { $dx = 1 }
            }

            $count = 0

            # count spaces until obstacle or boundary encountered
            while ($true) {

                # calculate next position to check
                $checkX = $startX + ($dx * ($count + 1))

                $checkY = $startY + ($dy * ($count + 1))

                # stop if boundary reached
                if (
                    $checkX -lt $script:gameState.playFieldLeft -or
                    $checkX -ge $script:gameState.playFieldRight -or
                    $checkY -lt $script:gameState.playFieldTop -or
                    $checkY -ge $script:gameState.playFieldBottom
                ) {

                    break
                }

                # stop if obstacle found in screen buffer
                if ($script:gameState.screenBuffer[$checkY][$checkX] -ne ' ') {

                    break
                }

                $count++
            }

            return $count
        }
        ###########################################################################

        ###########################################################################
        # internal function to dynamically adjust game speed based on context
        function SetCurrentSpeed {

            Log "SetCurrentSpeed function called"

            # initialize counters for space calculation
            $nrOfFreePositionsInCurrentDirection = 0

            $totalNumberOfFreePositionsSinceLastTurn = 0

            # get current snake head position
            $head = $script:gameState.snake[0]

            $currentX = $head.Item1

            $currentY = $head.Item2

            Log (
                "Snake head position: ($currentX, $currentY), direction: " +
                "$($script:gameState.direction)"
            )

            # count free spaces ahead in current direction
            $nrOfFreePositionsInCurrentDirection = CountFreeSpaces `
                -startX $currentX `
                -startY $currentY `
                -direction $script:gameState.direction

            Log (
                "Free positions in current direction " +
                "($($script:gameState.direction)): " +
                "$nrOfFreePositionsInCurrentDirection"
            )

            # calculate movement since last direction change
            Log (
                "LastMoveCoord available: " +
                "($($script:gameState.LastMoveCoord.Item1), " +
                "$($script:gameState.LastMoveCoord.Item2))"
            )

            # determine movement delta from last turn position
            $deltaX = $head.Item1 - $script:gameState.LastMoveCoord.Item1

            $deltaY = $head.Item2 - $script:gameState.LastMoveCoord.Item2

            Log "Delta from last turn: X=$deltaX, Y=$deltaY"

            # determine primary movement axis since last turn
            $movementDirection = ''

            if ([Math]::Abs($deltaX) -gt [Math]::Abs($deltaY)) {

                # horizontal movement is dominant
                $movementDirection = if ($deltaX -gt 0) { 'Right' } else {
                    'Left'
                }
            }
            else {

                # vertical movement is dominant
                $movementDirection = if ($deltaY -gt 0) { 'Down' } else {
                    'Up'
                }
            }

            Log (
                "Primary movement direction since last turn: " +
                "$movementDirection"
            )

            # count free spaces from last turn position
            $totalNumberOfFreePositionsSinceLastTurn = CountFreeSpaces `
                -startX $script:gameState.LastMoveCoord.Item1 `
                -startY $script:gameState.LastMoveCoord.Item2 `
                -direction $movementDirection

            Log (
                "Free spaces from last turn position in " +
                "$movementDirection direction: " +
                "$totalNumberOfFreePositionsSinceLastTurn"
            )

            Log (
                "Analysis: FreeAhead=$nrOfFreePositionsInCurrentDirection, " +
                "FreeSpacesAtLastTurn=" +
                "$totalNumberOfFreePositionsSinceLastTurn"
            )

            # define speed range boundaries for calculation
            $fastest = 20.0

            $slowest = [Math]::Min([Math]::Max(20.0, $speed), 2000.0)

            $delta = $slowest - $fastest

            $fastestLength = 30.0

            Log (
                "Speed calculation parameters: fastest=$fastest, " +
                "slowest=$slowest, delta=$delta, " +
                "fastestLength=$fastestLength"
            )

            # calculate ratio based on snake length
            $ratioSnakeLength = 1.0 - [Math]::Min(
                1.0,
                ($script:gameState.snake.Count / $fastestLength)
            )

            Log (
                "Snake length ratio: 1.0 - " +
                "$($script:gameState.snake.Count)/$fastestLength = " +
                "$ratioSnakeLength"
            )

            # calculate ratio based on remaining free space
            $ratioFreeSpaceLeft = 1.0 - [Math]::Min(
                1.0,
                (
                    $nrOfFreePositionsInCurrentDirection / [Math]::Max(
                        1.0,
                        $totalNumberOfFreePositionsSinceLastTurn
                    )
                )
            )

            Log (
                "Free space ratio: 1.0 - " +
                "$nrOfFreePositionsInCurrentDirection/" +
                "[Math]::Max(1.0, $totalNumberOfFreePositionsSinceLastTurn) " +
                "= $ratioFreeSpaceLeft"
            )

            # calculate distance from center of free space
            $ratioAwayFromCenterOfFreeSpace = (
                [Math]::Abs(0.5 - $ratioFreeSpaceLeft) * 2.0
            )

            Log (
                "Away from center ratio: [Math]::Abs(0.5 - " +
                "$ratioFreeSpaceLeft) * 2.0 = " +
                "$ratioAwayFromCenterOfFreeSpace"
            )

            # calculate console aspect ratio for speed adjustment
            $expectRatio = (
                [double] $script:gameState.width /
                [double] $script:gameState.height
            )

            Log "Console aspect ratio: $expectRatio (Width/Height)"

            # adjust ratio based on movement direction and aspect ratio
            $ratioDirection = if (
                $script:gameState.direction -in @('Left', 'Right')
            ) {
                # horizontal movement speed adjustment
                if ($expectRatio -lt 1) {
                    # landscape orientation
                    (
                        [double] $script:gameState.width /
                        [double] $script:gameState.height
                    )
                }
                else {
                    # portrait orientation
                    (
                        [double] $script:gameState.height /
                        [double] $script:gameState.width
                    )
                }
            }
            else {
                # vertical movement speed adjustment
                if ($expectRatio -lt 1) {
                    # landscape orientation
                    (
                        [double] $script:gameState.height /
                        [double] $script:gameState.width
                    )
                }
                else {
                    # portrait orientation
                    (
                        [double] $script:gameState.width /
                        [double] $script:gameState.height
                    )
                }
            }

            Log (
                "Direction ratio based on movement direction " +
                "($($script:gameState.direction)): $ratioDirection"
            )

            Log (
                "$fastest + ($delta * $ratioSnakeLength * " +
                "$ratioAwayFromCenterOfFreeSpace * $ratioDirection)"
            )

            # calculate final game speed using all ratios
            $script:gameState.gameSpeed = [int] [Math]::Round(
                [Math]::Min(
                    $slowest,
                    $fastest + (
                        $delta * $ratioDirection * (
                            $ratioAwayFromCenterOfFreeSpace +
                            $ratioSnakeLength
                        ) / 2.0
                    )
                ),
                0
            )

            Log "Final game speed: $($script:gameState.gameSpeed)"

            return $script:gameState.gameSpeed
        }
        ###########################################################################

        ###########################################################################
        # internal function to update snake position and handle collisions
        function UpdateSnake {

            param(
                [string]$direction
            )

            Log "UpdateSnake called with direction: $direction"

            # declare strongly-typed variables for snake movement
            [Tuple[int, int]] $previousTail = $null

            [Tuple[int, int]] $head = $null

            [int] $newX = 0

            [int] $newY = 0

            [Tuple[int, int]] $newHead = $null

            [bool] $ateFood = $false

            [bool] $collision = $false

            # store tail position before movement for potential restoration
            $previousTail = $script:gameState.snake[
            $script:gameState.snake.Count - 1
            ]

            Log (
                "Previous tail at: ($($previousTail.Item1), " +
                "$($previousTail.Item2))"
            )

            # get current head position
            $head = $script:gameState.snake[0]

            $newX = $head.Item1

            $newY = $head.Item2

            Log "Current head at: ($($head.Item1), $($head.Item2))"

            # calculate new head position based on movement direction
            switch ($direction) {

                'Up' { $newY = $head.Item2 - 1 }
                'Down' { $newY = $head.Item2 + 1 }
                'Left' { $newX = $head.Item1 - 1 }
                'Right' { $newX = $head.Item1 + 1 }
            }

            $newHead = [Tuple]::Create($newX, $newY)

            Log "New head position: ($newX, $newY)"

            # check for boundary collisions
            if (
                $newX -lt $script:gameState.playFieldLeft -or
                $newX -ge $script:gameState.playFieldRight -or
                $newY -lt $script:gameState.playFieldTop -or
                $newY -ge $script:gameState.playFieldBottom
            ) {

                $collision = $true

                Log "COLLISION: Boundary collision detected at ($newX, $newY)"
            }
            elseif (
                $script:gameState.screenBuffer[$newY][$newX] -ne ' '
            ) {

                # check for screen buffer content collisions
                $collision = $true

                Log (
                    "COLLISION: Screen buffer collision detected at " +
                    "($newX, $newY), char: " +
                    "'$($script:gameState.screenBuffer[$newY][$newX])'"
                )
            }
            elseif ($newHead -in $script:gameState.snake) {

                # check for self-collision with snake body
                $collision = $true

                Log "COLLISION: Self collision detected at ($newX, $newY)"
            }

            # return immediately if any collision detected
            if ($collision) {

                Log "UpdateSnake returning false due to collision"

                return $false
            }

            # determine if food was eaten at new position
            $ateFood = (
                $newHead.Item1 -eq $script:gameState.food.Item1 -and
                $newHead.Item2 -eq $script:gameState.food.Item2
            )

            Log (
                "Food eaten: $ateFood (food at: " +
                "$($script:gameState.food.Item1), " +
                "$($script:gameState.food.Item2))"
            )

            # add new head segment to front of snake
            $script:gameState.snake.Insert(0, $newHead)

            Log (
                "New head added to snake, snake length now: " +
                "$($script:gameState.snake.Count)"
            )

            # remove tail if food not eaten to maintain length
            if (-not $ateFood) {

                # restore original character at previous tail position
                [Console]::SetCursorPosition(
                    $previousTail.Item1,
                    $previousTail.Item2
                )

                $originalChar = $script:gameState.screenBuffer[
                $previousTail.Item2
                ][$previousTail.Item1]

                Microsoft.PowerShell.Utility\Write-Host $originalChar -NoNewline

                # remove tail segment from snake
                $script:gameState.snake.RemoveAt(
                    $script:gameState.snake.Count - 1
                )

                Log (
                    "Tail removed, restored char '$originalChar' at " +
                    "($($previousTail.Item1), $($previousTail.Item2))"
                )
            }

            # render new head position on screen
            [Console]::SetCursorPosition($newHead.Item1, $newHead.Item2)

            Microsoft.PowerShell.Utility\Write-Host 'O' -NoNewline `
                -ForegroundColor Green

            Log "New head drawn at ($($newHead.Item1), $($newHead.Item2))"

            # update previous head to body segment character
            if ($script:gameState.snake.Count -gt 1) {

                [Console]::SetCursorPosition(
                    $script:gameState.snake[1].Item1,
                    $script:gameState.snake[1].Item2
                )

                Microsoft.PowerShell.Utility\Write-Host 'o' -NoNewline `
                    -ForegroundColor Green

                Log (
                    "Previous head updated to body segment at " +
                    "($($script:gameState.snake[1].Item1), " +
                    "$($script:gameState.snake[1].Item2))"
                )
            }

            # handle food consumption and new food placement
            if ($ateFood) {

                # increment player score
                $script:gameState.score++

                Log "Score increased to: $($script:gameState.score)"

                $oldFood = $script:gameState.food

                Log (
                    "Attempting to place new food after eating food at: " +
                    "($($oldFood.Item1), $($oldFood.Item2))"
                )

                # find new unoccupied position for food
                $script:gameState.food = FindUnoccupiedSpace -requiredLength 1 -insideMaze:$WithMaze

                # validate new food placement succeeded
                if ($null -eq $script:gameState.food) {

                    Log (
                        "ERROR: Failed to place new food - " +
                        "FindUnoccupiedSpace returned null"
                    )

                    # use emergency fallback center position
                    $script:gameState.food = [Tuple]::Create(
                        (
                            ($script:gameState.playFieldRight - (
                                $script:gameState.playFieldLeft
                            )) / 2 + $script:gameState.playFieldLeft
                        ),
                        (
                            ($script:gameState.playFieldBottom - (
                                $script:gameState.playFieldTop
                            )) / 2 + $script:gameState.playFieldTop
                        )
                    )

                    Log (
                        "Emergency food placement at center: " +
                        "($($script:gameState.food.Item1), " +
                        "$($script:gameState.food.Item2))"
                    )
                }
                elseif (
                    $script:gameState.food.Item1 -eq $oldFood.Item1 -and
                    $script:gameState.food.Item2 -eq $oldFood.Item2
                ) {

                    Log (
                        "WARNING: New food placed at same location as old " +
                        "food: ($($script:gameState.food.Item1), " +
                        "$($script:gameState.food.Item2))"
                    )
                }
                else {

                    Log (
                        "New food placed successfully at: " +
                        "($($script:gameState.food.Item1), " +
                        "$($script:gameState.food.Item2)) (was at: " +
                        "($($oldFood.Item1), $($oldFood.Item2)))"
                    )
                }

                # perform additional validation of new food position
                if (
                    $script:gameState.food.Item1 -lt (
                        $script:gameState.playFieldLeft
                    ) -or $script:gameState.food.Item1 -ge (
                        $script:gameState.playFieldRight
                    ) -or $script:gameState.food.Item2 -lt (
                        $script:gameState.playFieldTop
                    ) -or $script:gameState.food.Item2 -ge (
                        $script:gameState.playFieldBottom
                    )
                ) {

                    Log (
                        "ERROR: New food placed outside playfield boundaries " +
                        "at ($($script:gameState.food.Item1), " +
                        "$($script:gameState.food.Item2))"
                    )
                }
                elseif ($script:gameState.food -in $script:gameState.snake) {

                    Log (
                        "ERROR: New food placed on snake body at " +
                        "($($script:gameState.food.Item1), " +
                        "$($script:gameState.food.Item2))"
                    )
                }
                else {

                    Log (
                        "Food position validation passed: " +
                        "($($script:gameState.food.Item1), " +
                        "$($script:gameState.food.Item2)) is within bounds " +
                        "and not on snake"
                    )
                }

                # render new food on screen
                [Console]::SetCursorPosition(
                    $script:gameState.food.Item1,
                    $script:gameState.food.Item2
                )

                Microsoft.PowerShell.Utility\Write-Host (
                    "$($PSStyle.Blink)*$($PSStyle.Reset)"
                ) -NoNewline -ForegroundColor Red

                Log (
                    "New food drawn at: ($($script:gameState.food.Item1), " +
                    "$($script:gameState.food.Item2))"
                )

                # update route path after food placement
                DrawRoutePath
            }

            Log "UpdateSnake completed successfully"

            # return success if no collision occurred
            return $true
        }
        ###########################################################################

        ###########################################################################
        # internal function to find row with fewest snake segments
        function getRowWithLeastSnake {

            # count snake segments per row
            $rowCounts = @{}

            foreach ($segment in $script:gameState.snake) {

                if ($rowCounts.ContainsKey($segment.Item2)) {

                    $rowCounts[$segment.Item2]++
                }
                else {

                    $rowCounts[$segment.Item2] = 1
                }
            }

            # find row with minimum segment count
            $minCount = [int]::MaxValue

            $bestRow = -1

            foreach ($row in $rowCounts.Keys) {

                if ($rowCounts[$row] -lt $minCount) {

                    $minCount = $rowCounts[$row]

                    $bestRow = $row
                }
            }

            return $bestRow
        }
        ###########################################################################

        # find suitable positions for initial snake placement
        Log "Starting snake initialization"

        if ($WithMaze) {
            # Calculate maze bottom y
            $totalMazeRows = [int](($cellsHeight + 1) + $cellsHeight * $pathWidth)
            $mazeBottom = [int]($mazeTop + $totalMazeRows - 1)

            # Place snake below maze left corner, moving right
            $startY = [int]($mazeBottom + 1)
            if ($startY -gt $script:gameState.playFieldBottom) {
                $startY = $script:gameState.playFieldBottom
            }
            $startX = [int]($script:gameState.playFieldLeft + $script:gameState.snakeLength - 1)  # Head at rightmost of snake
            $script:gameState.snakePositions = @()
            $canPlace = $true

            for ($i = 0; $i -lt $script:gameState.snakeLength; $i++) {
                $checkX = $startX - $i
                $checkY = $startY

                if (
                    $checkX -lt $script:gameState.playFieldLeft -or
                    $checkX -ge $script:gameState.playFieldRight -or
                    $checkY -lt $script:gameState.playFieldTop -or
                    $checkY -ge $script:gameState.playFieldBottom -or
                    $script:gameState.screenBuffer[$checkY][$checkX] -ne ' '
                ) {
                    $canPlace = $false
                    break
                }

                $script:gameState.snakePositions += [Tuple]::Create($checkX, $checkY)
            }

            if (-not $canPlace) {
                Log "Could not place snake below maze left corner, using random placement"
                $script:gameState.snakePositions = FindUnoccupiedSpace `
                    -requiredLength $script:gameState.snakeLength `
                    -allowVertical
            }
            else {
                $script:gameState.direction = 'Right'
                Log "Snake placed below maze left corner moving right"
            }

            # Place initial food inside maze
            Log "Placing initial food inside maze"
            $script:gameState.food = FindUnoccupiedSpace -requiredLength 1 -insideMaze
            if ($null -eq $script:gameState.food) {
                Log "Could not place food inside maze, using regular placement"
                $script:gameState.food = FindUnoccupiedSpace -requiredLength 1
            }
        }
        else {
            $script:gameState.snakePositions = FindUnoccupiedSpace `
                -requiredLength $script:gameState.snakeLength `
                -allowVertical

            $script:gameState.food = FindUnoccupiedSpace -requiredLength 1
        }

        Log (
            "Snake positions found: " +
            "$($script:gameState.snakePositions.Count) segments"
        )

        # add all positions to snake list at once
        $script:gameState.snake.AddRange(
            [System.Tuple[int, int][]]$script:gameState.snakePositions
        )

        Log (
            "Snake initialized with $($script:gameState.snake.Count) " +
            "segments"
        )

        Log (
            "Food placed at: ($($script:gameState.food.Item1), " +
            "$($script:gameState.food.Item2))"
        )

        # store initial position for speed calculation
        $script:gameState.LastMoveCoord = $script:gameState.snake[0]

        # render initial game screen
        Log "Drawing initial screen"

        DrawInitialScreen

        Log (
            "Begin block completed, current direction: " +
            "$($script:gameState.direction)"
        )
    }

    process {

        Log "Entering main game loop"

        if ($PSCmdlet.ShouldProcess("Start Snake Game", "Modify console state")) {

            # main game loop continues until game over
            while ($true) {

                Log (
                    "Game loop iteration started, direction: " +
                    "$($script:gameState.direction)"
                )

                # check if console window has been resized
                if (ScreenIsResized) {

                    Log "Screen resize detected, ending game"

                    # update dimensions for final message
                    $script:gameState.height = [Console]::WindowHeight

                    $script:gameState.width = [Console]::WindowWidth

                    Clear-Host

                    # display final score message
                    Microsoft.PowerShell.Utility\Write-Host (
                        "`e[93;44m" +
                        (
                            "Screen resized. Game over! Final Score: " +
                            "$($script:gameState.score)"
                        ).PadRight($script:gameState.width - 1, ' ') +
                        "`e[0m"
                    ) -NoNewline

                    break
                }

                # process keyboard input if available
                if ([Console]::KeyAvailable) {

                    $key = [Console]::ReadKey($true)

                    Log (
                        "Key pressed: $($key.Key) (KeyChar: '$($key.KeyChar)')"
                    )

                    # define mappings for both arrow keys and wasd controls
                    $keyMappings = @{
                        [ConsoleKey]::UpArrow    = @{
                            direction = 'Up'
                            opposite  = 'Down'
                            wasd      = $false
                        }
                        [ConsoleKey]::DownArrow  = @{
                            direction = 'Down'
                            opposite  = 'Up'
                            wasd      = $false
                        }
                        [ConsoleKey]::LeftArrow  = @{
                            direction = 'Left'
                            opposite  = 'Right'
                            wasd      = $false
                        }
                        [ConsoleKey]::RightArrow = @{
                            direction = 'Right'
                            opposite  = 'Left'
                            wasd      = $false
                        }
                        [ConsoleKey]::W          = @{
                            direction = 'Up'
                            opposite  = 'Down'
                            wasd      = $true
                        }
                        [ConsoleKey]::A          = @{
                            direction = 'Left'
                            opposite  = 'Right'
                            wasd      = $true
                        }
                        [ConsoleKey]::S          = @{
                            direction = 'Down'
                            opposite  = 'Up'
                            wasd      = $true
                        }
                        [ConsoleKey]::D          = @{
                            direction = 'Right'
                            opposite  = 'Left'
                            wasd      = $true
                        }
                    }

                    # process direction change if valid key pressed
                    if ($keyMappings.ContainsKey($key.Key)) {

                        $mapping = $keyMappings[$key.Key]

                        Log (
                            "Found mapping for key $($key.Key): direction=" +
                            "$($mapping.direction), opposite=" +
                            "$($mapping.opposite)"
                        )

                        # prevent 180-degree turns into snake body
                        if (
                            $script:gameState.direction -ne $mapping.opposite
                        ) {

                            # store position where direction changed
                            $script:gameState.LastMoveCoord = (
                                $script:gameState.snake[0]
                            )

                            # update movement direction
                            $script:gameState.direction = $mapping.direction

                            # record time of direction change
                            $script:gameState.LastMoveTime = (
                                [DateTime]::UtcNow
                            )

                            # identify control type for logging
                            $controlType = if ($mapping.wasd) { ' (WASD)' } else {
                                ''
                            }

                            Log (
                                "Direction changed to: " +
                                "$($mapping.direction)$controlType"
                            )
                        }
                        else {

                            Log (
                                "Direction change blocked: current=" +
                                "$($script:gameState.direction), trying " +
                                "opposite=$($mapping.opposite)"
                            )
                        }
                    }
                    elseif ($key.Key -eq 'Escape') {

                        # exit game when escape key pressed
                        Log "Escape key pressed, exiting game"

                        [Console]::SetCursorPosition(
                            0,
                            $script:gameState.height - 2
                        )

                        Microsoft.PowerShell.Utility\Write-Host (
                            "`e[93;44m" +
                            (
                                "Game exited. Final Score: " +
                                "$($script:gameState.score)"
                            ).PadRight($script:gameState.width - 1, ' ') +
                            "`e[0m"
                        ) -NoNewline

                        return
                    }
                    else {

                        Log "Unhandled key: $($key.Key)"
                    }
                }

                # update snake position and check for collisions
                Log (
                    "Calling UpdateSnake with direction: " +
                    "$($script:gameState.direction)"
                )

                $result = UpdateSnake -direction $script:gameState.direction

                Log "UpdateSnake returned: $result"

                # handle collision game over
                if (-not $result) {

                    Log "Game over due to collision"

                    [Console]::SetCursorPosition(
                        0,
                        $script:gameState.height - 2
                    )

                    Microsoft.PowerShell.Utility\Write-Host (
                        "`e[93;44m" +
                        (
                            "Collision detected! Game over! Final Score: " +
                            "$($script:gameState.score)"
                        ).PadRight($script:gameState.width - 1, ' ') +
                        "`e[0m"
                    ) -NoNewline

                    break
                }

                # calculate and apply dynamic game speed
                $script:gameState.gameSpeed = SetCurrentSpeed

                Log "Sleeping for $($script:gameState.gameSpeed) milliseconds"

                # position cursor at bottom for status display
                [Console]::SetCursorPosition(0, $script:gameState.height - 1)

                Microsoft.PowerShell.Utility\Start-Sleep `
                    -Milliseconds $script:gameState.gameSpeed
            }

            Log "Game loop ended"
        }
    }

    end {

        Log (
            "Snake game ended, final score: $($script:gameState.score)"
        )

        # save debug log if logging enabled
        if ($script:gameState.loggingEnabled) {

            try {

                $logContent = $script:gameState.logBuilder.ToString()

                [System.IO.File]::WriteAllText(
                    $script:gameState.logPath,
                    $logContent,
                    [System.Text.Encoding]::UTF8
                )
            }
            catch {

                Microsoft.PowerShell.Utility\Write-Warning "Failed to save log file: $_"
            }
        }
    }
}
###############################################################################