/*
*
Module: draw.v

Created By: Premika Devaraj
---------------------------------------------
Short Module Description

This is the module to draw the elements on the Terasic LT24 LCD.

Referencing few lines of code by T. Carpenter, “LT24 LCD Driver,” Mar. 13, 2017 

*/

module draw #(
	parameter BALL_SIZE = 5,
	parameter PADDLE_BREADTH = 5,
	parameter PADDLE_LENGTH = 15
	)(
//Declare input and output ports

    input clock,            //Clock used to drive the LCD panel
    input resetApp,         //Reset used in the code
	 input reset,
	 input enableGame,
	 input PlaySwitch,
	 input [7:0] firstBall_x_position,
	 input [8:0] firstBall_y_position,
	 input [7:0] secondBall_x_position,
    input [8:0] secondBall_y_position,
	 input [7:0] firstPaddle_x_position,
	 input [8:0] firstPaddle_y_position,
	 input [7:0] secondPaddle_x_position,
	 input [8:0] secondPaddle_y_position,
	 input [7:0] firstPaddleScore,
    input [7:0] secondPaddleScore,
	 input [7:0] xCount,
	 input [8:0] yCount,
	 input pixelReady,
	 output reg ResetFlag,
	 output reg PlayFlag,
	 output reg [7:0] xAddr,
	 output reg [8:0] yAddr,
	 output reg [15:0] pixelData,
	 output reg pixelWrite
);


//Constants for player win screen start positions and width

localparam PLAYER1WINSTART = 76800;           	// Starting address for Player 1 win screen
localparam PLAYER2WINSTART = 76800+9600;      	// Starting address for Player 2 win screen, offset by 9600
localparam PLAYERWIN_WIDTH = 40;						// Width of the player win screens
localparam IMGEND = PLAYER2WINSTART + 9600 -1;  // End address for the last image
// Pixel color constants
localparam PX1 = 16'hFFFF;							//color code for white
localparam PX2 = 16'hF800;							//color code for red
localparam PX3 = 16'h001F;							//color code for blue
localparam PX4 = 16'h39E7;							//color code for a specific shade of teal
// Image identifiers for different screen regions
localparam PX1ID = IMGEND + 1; 					// Identifier for a unique image following the last player win screen
localparam PX2ID = PX1ID + 1;  					// Next identifier increment
localparam PX3ID = PX2ID + 1;  					// Next identifier increment
localparam PX4ID = PX3ID + 1;  					// Next identifier increment

// Declare an array to store image data for different game states
reg [15:0] Images [0:PX4ID];

initial begin
    $readmemh("STARTSCREEN.hex", Images, 0, PLAYER1WINSTART - 1); // Load start screen image data into Images array
    $readmemh("PLAYER1WINS.hex", Images, PLAYER1WINSTART, PLAYER2WINSTART - 1); // Load player 1 win screen image data
    $readmemh("PLAYER2WINS.hex", Images, PLAYER2WINSTART, PLAYER2WINSTART + 9600 - 1); // Load player 2 win screen image data
    Images[PX1ID] = PX1; // Assign the color value for PX1ID
    Images[PX2ID] = PX2; // Assign the color value for PX2ID
    Images[PX3ID] = PX3; // Assign the color value for PX3ID
    Images[PX4ID] = PX4; // Assign the color value for PX4ID
end

//Referencing code by T. Carpenter, “LT24 LCD Driver,” Mar. 13, 2017 
always @ (posedge clock or posedge resetApp) begin
   if (resetApp) begin
	    pixelWrite <= 1'b0;
	 end else begin 
	 pixelWrite <= 1'b1;
	 end
end		
	
//Defining a macro square 
`define SQUARE(x) ((x)*(x))

//State machine to display a start screen and winner screen

reg [1:0] State; 

//Parameter definitions
localparam START_STATE = 2'd0;  // Initial state of the state machine
localparam END1_STATE = 2'd1;   //First possible end state of the state machine
localparam END2_STATE = 2'd2;   // Second possible end state of the state machine
localparam PLAY_STATE = 2'd3;   // State during which the main activity or function is executed

always @ (posedge clock or posedge resetApp)
		if(resetApp) begin
		  State <= START_STATE;       // Reset state to START_STATE on resetApp signal
        PlayFlag <= 1'b0;           // Reset PlayFlag to 0 when system is reset
        ResetFlag <= 1'b1;          // Set ResetFlag to 1 to indicate system has been reset
		end else begin
			case(State)
			   START_STATE : begin
					if(PlaySwitch) begin
						State <= PLAY_STATE; // Transition to PLAY_STATE if PlaySwitch is activated
					end
					PlayFlag <= 1'b0;       // Reset PlayFlag to 0 in START_STATE
					ResetFlag <= 1'b1;      // Set ResetFlag to 1 to indicate a reset condition
			end
				PLAY_STATE : begin
					if(!PlaySwitch) begin
						State <= START_STATE;  // Return to START_STATE if PlaySwitch is deactivated
					end else if(firstPaddleScore == 4'd10) begin // Transition to END1_STATE if firstPaddleScore reaches 10
						State <= END1_STATE;
					end else if(secondPaddleScore == 4'd10) begin // Transition to END2_STATE if secondPaddleScore reaches 10
						State <= END2_STATE;
					end
					PlayFlag <= 1'b1;									//PlayFlag set to indicate gameplay is active
					ResetFlag <= 1'b0;								//ResetFlag set to 0
			end	
				END1_STATE : begin        
					if(!PlaySwitch) begin
						State<= START_STATE;     // Return to START_STATE if PlaySwitch is deactivated
					end
					PlayFlag <= 1'b0;			    // Clear PlayFlag as game is not active in END1_STATE
					ResetFlag = 1'b0;           // Clear ResetFlag in END1_STATE
			end
				END2_STATE : begin             
					if(!PlaySwitch) begin       
						State <= START_STATE;   // Return to START_STATE if PlaySwitch is deactivated

					end
				PlayFlag <= 1'b0;              // Clear PlayFlag as game is not active in END2_STATE
				ResetFlag <= 1'b0;             // Clear ResetFlag in END2_STATE
			end
				
				default: begin
				State <= START_STATE;
				PlayFlag <= 1'b0;
				ResetFlag <= 1'b1;
			end
		endcase
	end
 
// function to calculate the linear index of a pixel based on its coordinates and modify calculation depending on the machine's state
function [19:0] PixelNum;
		input [7:0] xCount;
		input [8:0] yCount;
		input [2:0] State;
		begin
				PixelNum = (yCount * 240) + xCount;                  // Calculate pixel number based on y and x coordinates
				if(State == START_STATE) begin 
					PixelNum = (yCount * 240) +xCount;					  // Recalculate pixel number in START_STATE
				end else if((State == PLAY_STATE) || (yCount <= 140-1) || (yCount >= 180-1))  begin
				
						//Set whole new screen frame white
						 PixelNum = PX1ID;
						 
					      // Draw Ball
					     if (`SQUARE(xCount - firstBall_x_position) + `SQUARE(yCount - firstBall_y_position) <= `SQUARE(BALL_SIZE)) begin
								PixelNum    = PX2ID;  // Set PixelNum to PX2ID for pixels within the first ball's radius
						  end
						  // Draw Second Ball
						  if (`SQUARE(xCount - secondBall_x_position) + `SQUARE(yCount - secondBall_y_position) <= `SQUARE(BALL_SIZE)) begin
								PixelNum    = PX3ID;  // Set PixelNum to PX3ID for pixels within the second ball's radius
						  end
					     // Draw Right Paddle
						  if (xCount > firstPaddle_x_position - PADDLE_BREADTH && xCount < firstPaddle_x_position + PADDLE_BREADTH && 
						  yCount > firstPaddle_y_position - PADDLE_LENGTH && yCount < firstPaddle_y_position + PADDLE_LENGTH) begin 
								PixelNum    = PX2ID;  // Assign pixel identifier for the first paddle area
						  end 
						  
						  // Draw Second Paddle
						  if (xCount > secondPaddle_x_position - PADDLE_BREADTH && xCount < secondPaddle_x_position + PADDLE_BREADTH && 
						  yCount > secondPaddle_y_position - PADDLE_LENGTH && yCount < secondPaddle_y_position + PADDLE_LENGTH) begin 
								PixelNum    = PX3ID; // Assign pixel identifier for the second paddle area
						  end 

						  // Draw left Wall
						  if (xCount > 0 && xCount < 4 && 
						  yCount > 0 && yCount < 320) begin 
								PixelNum    = PX4ID;  // Assign pixel identifier for the left wall area
						  end
						  
						  // Draw Top Wall
						  if (xCount > 0 && xCount < 240 && 
						  yCount > 165 && yCount < 170) begin 
								PixelNum    = PX4ID;   // Assign pixel identifier for the top wall area
						  end
					end else if(State == END1_STATE) begin
						PixelNum = ((yCount - 140) * 240) + xCount + PLAYER2WINSTART;   // Calculate PixelNum for the END1_STATE, offset for player 1 win screen
					end else if(State == END2_STATE) begin
						PixelNum = ((yCount - 140) * 240) + xCount + PLAYER1WINSTART;   // Calculate PixelNum for the END2_STATE, offset for player 2 win screen
					end
	end
endfunction

//Referencing code by T. Carpenter, “LT24 LCD Driver,” Mar. 13, 2017 
	
//Pixel handling logic
always @ (posedge clock or posedge resetApp) begin
	if (resetApp) begin
			pixelData  <= 16'b0;                            // Reset pixel data to zero on reset
			xAddr		  <= 8'b0;										// Reset x address counter to zero
			yAddr      <= 9'b0;										// Reset y address counter to zero
	end else if(pixelReady) begin
	     //X/Y address are counter values
			xAddr      <= xCount;									// Set x address to current x counter value	
			yAddr      <= yCount;                           // Set y address to current y counter value
	pixelData <= Images[PixelNum(xCount, yCount, State)]; // Load pixel data from Images array based on PixelNum calculation
	end 
end
		
endmodule