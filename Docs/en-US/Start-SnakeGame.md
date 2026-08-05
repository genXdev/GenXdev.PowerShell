# Start-SnakeGame

> **SubModule:** GenXdev.Console | **Type:** Function | **Aliases:** `snake`

## Synopsis

> Starts a simple Snake game in the console.

## Description

This function initializes and runs a basic Snake game within the PowerShell
console. The player controls the snake using the arrow keys or WASD keys,
aiming to eat food and grow longer while avoiding collisions with the walls
or itself. The game features dynamic speed adjustment based on available
space and snake length. By default, the console is cleared before starting.


## Syntax

```powershell
Start-SnakeGame [[-InitialLength] <Int32>] [[-Speed] <Int32>] [-MazeWidth <Int32>] [-NoClear] [-ShowRoute] [-WithMaze] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-InitialLength` | Int32 | ☐ | Initial length of the snake (default: 5) |
| `-Speed` | Int32 | ☐ | Game speed in milliseconds between moves<br>(default: 300) |
| `-NoClear` | SwitchParameter | ☐ | Prevents clearing the console before starting<br>the game |
| `-WithMaze` | SwitchParameter | ☐ | Draws a maze within the playfield using ASCII<br>drawing  characters for walls and lines,<br>similar to the border |
| `-ShowRoute` | SwitchParameter | ☐ | Displays the shortest path from the snake's<br>head to the  food using small green centered<br>dots |
| `-MazeWidth` | Int32 | ☐ | Minimum pathway width for the maze (1-10,<br>default: 2) |

## Examples

### Start-SnakeGame Starts the Snake game with default settings (5 segments, 300ms speed).

```powershell
Start-SnakeGame
Starts the Snake game with default settings (5 segments, 300ms speed).
```

### Start-SnakeGame -NoClear -InitialLength 3 -Speed 200 Starts the Snake game without clearing console, with shorter snake and faster speed.

```powershell
Start-SnakeGame -NoClear -InitialLength 3 -Speed 200
Starts the Snake game without clearing console, with shorter snake and faster
speed.
```

### snake -InitialLength 10 Starts the game using the alias with a longer initial snake.

```powershell
snake -InitialLength 10
Starts the game using the alias with a longer initial snake.
```

### Start-SnakeGame -WithMaze Starts the Snake game with a maze in the playfield.

```powershell
Start-SnakeGame -WithMaze
Starts the Snake game with a maze in the playfield.
```

### Start-SnakeGame -WithMaze -ShowRoute Starts the Snake game with a maze and displays the shortest path from the snake to the food with green dots.

```powershell
Start-SnakeGame -WithMaze -ShowRoute
Starts the Snake game with a maze and displays the shortest path from the
snake to the food with green dots.
```

### Start-SnakeGame -WithMaze -MazeWidth 5 Starts the Snake game with a maze that has wider pathways (minimum 5 spaces) for easier navigation.

```powershell
Start-SnakeGame -WithMaze -MazeWidth 5
Starts the Snake game with a maze that has wider pathways (minimum 5 spaces)
for easier navigation.
```

## Parameter Details

### `-InitialLength <Int32>`

> Initial length of the snake (default: 5)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | `5` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Speed <Int32>`

> Game speed in milliseconds between moves (default: 300)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | `300` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoClear`

> Prevents clearing the console before starting the game

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-WithMaze`

> Draws a maze within the playfield using ASCII drawing  characters for walls and lines, similar to the border

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ShowRoute`

> Displays the shortest path from the snake's head to the  food using small green centered dots

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MazeWidth <Int32>`

> Minimum pathway width for the maze (1-10, default: 2)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `2` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Get-IsSpeaking](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-IsSpeaking.md)
- [New-MicrosoftShellTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-MicrosoftShellTab.md)
- [Now](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Now.md)
- [Resume-TextToSpeech](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Resume-TextToSpeech.md)
- [SayDate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/SayDate.md)
- [SayTime](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/SayTime.md)
- [secondscreen](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/secondscreen.md)
- [sidebyside](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/sidebyside.md)
- [Start-TextToSpeech](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-TextToSpeech.md)
- [Stop-TextToSpeech](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Stop-TextToSpeech.md)
- [Suspend-TextToSpeech](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Suspend-TextToSpeech.md)
- [UtcNow](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/UtcNow.md)
