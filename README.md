# ELEC5566M Mini-Project Repository - Multiplayer Pong Game

This is the repository for building a Multiplayer ping pong game in Verilog HDL on the DE1-SoC board, utilizing the LT24 LCD as a display, this project serves as an interactive LCD-based FPGA demonstrator. The design follows a hierarchical approach with a Top module which instantiates other submodules.

| Module Files          | Purpose       | 
| -------------  |:-------------:| 
| multiplayerpong.v     | This is the top module of the Arcade ping-pong game |
| gamelogic.v    | This module orchestrates all core gameplay mechanics, ensuring dynamic and consistent responses to player interactions within the game environment. |
| ballmovement.v | This module illustrates the logic used to move the balls in the game. |
| paddlemovement.v | This module illustrates the logic used to move the paddles in the game.  |
| clockdivider.v | This module divides the FPGA's clock frequency. |
| LT24Display.v | This module is the LT24 LCD driver segment. |
| BinarytoBCD.v |  This module is for an N-bit Binary to BCD converter.|
| HexTo7Segment.v | This module is to drive the 7-segment Hex displays on the DE1-SoC board. |
| AudioCodec.v,AudioI2C.v, Audioclockdivider.v| These modules are used to drive the audio codec on the DE1-SoC. |

### Design Requirements
1. DE1-SoC
2. LT24 LCD
### Install
1. Quartus Prime Lite
2. ModelSim
3. Github Desktop
### Block Diagram of the circuit
The top module instantiates the game logic and audio blocks. The gamelogic instantiates all the other sub-modules, each of which serve a specific functionality.

![blockdiagram](https://github.com/leeds-embedded-systems/ELEC5566M-Mini-Project-Group-28/assets/159080845/92f9cfa0-0380-4596-9f21-b1d7c714c508)

### Schematics
This has the RTL view of the modules.
Main module - The top module of the game, instantiates all the submodules. Acts as the orchestrator for the game, interfacing directly with the hardware components like the DE1-SoC board and the LT24 LCD. This module coordinates the interactions between all sub-modules and manages the overall game state and timing.

<img width="960" alt="multiplayerpong_RTL" src="https://github.com/leeds-embedded-systems/ELEC5566M-Mini-Project-Group-28/assets/159080845/ebd980a5-aca5-41ed-9b17-0b9f89699608">
Gamelogic.v - The game logic module is mainly responsible for detecting collisions between the ball and the paddles in the Pong game. It interfaces with other modules for LCD display, ball movement, paddle movement and scoring calculation. It also modules instantiated for converting the score from binary to BCD and display the same on the 7-segment hex display. 

<img width="960" alt="gamelogic_RTL" src="https://github.com/leeds-embedded-systems/ELEC5566M-Mini-Project-Group-28/assets/159080845/4e09fdd6-a2c4-45f0-8337-dae8b575f789">

Draw.v
The module draw is designed for the Terasic LT24 LCD display, aimed at rendering graphical elements the game. It dynamically generates the game's visual elements, including balls, paddles, and game status screens, based on the game state and player inputs. The module is parameterized with constants defining object sizes and uses a state machine to control display logic based on the game's progress.

<img width="960" alt="internal_draw_rtl" src="https://github.com/leeds-embedded-systems/ELEC5566M-Mini-Project-Group-28/assets/159080845/a1a02672-7162-49fe-832a-855f1670557d">

### State Machines 
The modules draw.v, ball and paddle-movement use state machines to control the state of the game
### Layout of the Images being displayed on the LCD
Width 240 x Height 320 pixels
1. Startscreen
![startscreen](https://github.com/leeds-embedded-systems/ELEC5566M-Mini-Project-Group-28/assets/159080845/5b8ce57c-deb3-4563-9e17-2d938a485e8f)
2. Player1 win screen
![player1](https://github.com/leeds-embedded-systems/ELEC5566M-Mini-Project-Group-28/assets/159080845/a03b73f0-8c99-4595-bd1e-0ba036361908)
3. Player2 win screen
![player2](https://github.com/leeds-embedded-systems/ELEC5566M-Mini-Project-Group-28/assets/159080845/482c4d50-33a1-4e74-a5d7-6b446e51e3d2)

### Hardware
Demo of the game

https://github.com/leeds-embedded-systems/ELEC5566M-Mini-Project-Group-28/assets/159080845/64ff9957-fb0a-4ba2-b9d7-6df72a81b6a1



