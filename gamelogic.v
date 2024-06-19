/*
*Module: gamelogic.v
*Created By: Anusha Arun Sonar
*  
*Short Description
*---------------------------------------------------------
*This is the game logic for a Multiplayer Arcade Pong Game
*
*
*/

module gamelogic #(
    parameter BALL_SIZE = 5,
    parameter PADDLE_BREADTH = 5,
    parameter PADDLE_LENGTH = 15
)(
    // Clock and Resets
    input              clock,
    input              reset,
    output             resetApp,

    // LT24 LCD Interface
	 output             LT24Reset_n,
    output [15:0]      LT24Data,
	 output             LT24RS,
    output             LT24LCDOn,
	 output             LT24Rd_n,
    output             LT24Wr_n,
    output             LT24CS_n,
	 
	 // Inputs from Keys for both the paddle movement
    input              Up_FirstPaddle,
    input              Down_FirstPaddle,
	 input              Up_SecondPaddle,
    input              Down_SecondPaddle,
	 
	 input              PlaySwitch,
	  // outputs for Seven Segment Displays 
    output [6:0]       segZero,
    output [6:0]       segOne,
    output [6:0]       segFour,
    output [6:0]       segFive,
	 output 				  gameOver
);

//-------- Variables ----------
// Variables for LCD
wire  [15:0] pixelData;
wire         pixelReady;
wire         pixelWrite;
wire  [7:0]	 xAddr;
wire  [8:0]  yAddr;

wire        ClockDividerPaddles;
wire        ClockDividerBall_1;
wire        ClockDividerBall_2;

// First Ball Variables
wire [7:0] firstBall_x_position;
wire [8:0] firstBall_y_position;
// Second Ball Variables
wire [7:0] secondBall_x_position;
wire [8:0] secondBall_y_position;


// First Paddle Variables
wire [7:0] firstPaddle_x_position;
wire [8:0] firstPaddle_y_position;
// Second Paddle Variables
wire [7:0] secondPaddle_x_position;
wire [8:0] secondPaddle_y_position;


//First ball-paddle collision
wire       PaddleBall_1_Collision; 
wire [1:0] PaddleBall_1_HalfCollision; 
//Second ball-paddle collision
wire       PaddleBall_2_Collision; 
wire [1:0] PaddleBall_2_HalfCollision;

wire       FirstBallDirection;
reg        resetFirstBall = 1'b0;
wire       SecondBallDirection;
reg        resetSecondBall = 1'b0;

// Score Variables
reg  [7:0] firstPaddleScore;
reg  [7:0] secondPaddleScore;
wire [11:0] firstPaddleBCD;
wire [11:0] secondPaddleBCD;


// Function to calculate if the distances are within collision range
function automatic isCollision;
    input [10:0] ballPos, paddlePos, objSize, tolerance;
    begin
        isCollision = (ballPos >= paddlePos - objSize - tolerance) && (ballPos <= paddlePos + objSize + tolerance);
    end
endfunction

// Full paddle collision detection for first ball and paddle
assign PaddleBall_1_Collision = (isCollision(firstBall_y_position, firstPaddle_y_position, PADDLE_LENGTH, BALL_SIZE) &&
                              firstBall_x_position == firstPaddle_x_position - PADDLE_BREADTH - BALL_SIZE) ? 1'b1 : 1'b0;

// Top half paddle collision detection for first ball and paddle
assign PaddleBall_1_HalfCollision[1] = (isCollision(firstBall_y_position, firstPaddle_y_position - (PADDLE_LENGTH / 2), PADDLE_LENGTH / 2, BALL_SIZE) &&
                                     firstBall_x_position == firstPaddle_x_position - PADDLE_BREADTH - BALL_SIZE) ? 1'b1 : 1'b0;

// Bottom half paddle collision detection for first ball and paddle 
assign PaddleBall_1_HalfCollision[0] = (isCollision(firstBall_y_position, firstPaddle_y_position + (PADDLE_LENGTH / 2), PADDLE_LENGTH / 2, BALL_SIZE) &&
                                     firstBall_x_position == firstPaddle_x_position - PADDLE_BREADTH - BALL_SIZE) ? 1'b1 : 1'b0;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////												 
												 
// Full paddle collision detection for the second ball and paddle 
assign PaddleBall_2_Collision = (isCollision(secondBall_y_position, secondPaddle_y_position, PADDLE_LENGTH, BALL_SIZE) &&
                              secondBall_x_position == secondPaddle_x_position - PADDLE_BREADTH - BALL_SIZE) ? 1'b1 : 1'b0;

// Top half paddle collision detection for the second ball and paddle
assign PaddleBall_2_HalfCollision[1] = (isCollision(secondBall_y_position, secondPaddle_y_position - (PADDLE_LENGTH / 2), PADDLE_LENGTH / 2, BALL_SIZE) &&
                                     secondBall_x_position == secondPaddle_x_position - PADDLE_BREADTH - BALL_SIZE) ? 1'b1 : 1'b0;

// Bottom half paddle collision detection for the second ball and paddle
assign PaddleBall_2_HalfCollision[0] = (isCollision(secondBall_y_position, secondPaddle_y_position + (PADDLE_LENGTH / 2), PADDLE_LENGTH / 2, BALL_SIZE) &&
                                     secondBall_x_position == secondPaddle_x_position - PADDLE_BREADTH - BALL_SIZE) ? 1'b1 : 1'b0;

								
// Module Instantiations ----------------------------------------------------------------------
// LCD Display Module
localparam LCD_WIDTH  = 240;
localparam LCD_HEIGHT = 320;
LT24Display #(
    .WIDTH       (LCD_WIDTH  ),
    .HEIGHT      (LCD_HEIGHT ),
    .CLOCK_FREQ  (50000000   )
) Display (
    //Clock and Reset In
    .clock       (clock      ),
    .globalReset (reset      ),
    //Reset for User Logic
    .resetApp    (resetApp   ),
    //Pixel Interface
    .xAddr       (xAddr      ),
    .yAddr       (yAddr      ),
    .pixelData   (pixelData  ),
    .pixelWrite  (pixelWrite ),
    .pixelReady  (pixelReady ),
    //Use pixel addressing mode
    .pixelRawMode(1'b0       ),
    //Unused Command Interface
    .cmdData     (8'b0       ),
    .cmdWrite    (1'b0       ),
    .cmdDone     (1'b0       ),
    .cmdReady    (           ),
    //Display Connections
    .LT24Wr_n    (LT24Wr_n   ),
    .LT24Rd_n    (LT24Rd_n   ),
    .LT24CS_n    (LT24CS_n   ),
    .LT24RS      (LT24RS     ),
    .LT24Reset_n (LT24Reset_n),
    .LT24Data    (LT24Data   ),
    .LT24LCDOn   (LT24LCDOn  )
);

// Counter X
wire [7:0] xCount;
Nbitupcounter #(
    .WIDTH     (         8 ),
    .MAX_VALUE (LCD_WIDTH-1)
) xCounter (
    .clock     (clock    ),
    .reset     (resetApp  ),
    .enable    (pixelReady),
    .countValue(xCount   )
);

// Counter Y
wire [8:0] yCount;
wire yCntEnable = pixelReady && (xCount == (LCD_WIDTH-1));
Nbitupcounter #(
    .WIDTH     (           9),
    .MAX_VALUE (LCD_HEIGHT-1)
) yCounter (
    .clock     (clock    ),
    .reset     (resetApp  ),
    .enable    (yCntEnable),
    .countValue(yCount    )
);

wire enableGame;   // wire for the enable 
wire PlayFlag;      
wire ResetFlag;

assign enableGame = PlayFlag;

draw draw(
  .clock(clock),
  .reset(reset),
  .resetApp(resetApp),
  .enableGame(enableGame),
  .PlaySwitch(PlaySwitch),
  .firstBall_x_position(firstBall_x_position),
  .firstBall_y_position(firstBall_y_position),
  .secondBall_x_position(secondBall_x_position),
  .secondBall_y_position(secondBall_y_position),
  .firstPaddle_x_position(firstPaddle_x_position),
  .firstPaddle_y_position(firstPaddle_y_position),
  .secondPaddle_x_position(secondPaddle_x_position),
  .secondPaddle_y_position(secondPaddle_y_position),
  .firstPaddleScore(firstPaddleScore),
  .secondPaddleScore(secondPaddleScore),
  .xCount(xCount),
  .yCount(yCount),
  .pixelReady(pixelReady),
  .ResetFlag(ResetFlag),
  .PlayFlag(PlayFlag),
  .xAddr(xAddr),
  .yAddr(yAddr),
  .pixelData(pixelData),
  .pixelWrite(pixelWrite)
);


//paddles
ClockDivider # (
     .CLOCK_RATE(110)
)ClockDividerPaddle(
     .clock(clock),
     .reset(reset),
     .clockDivider(ClockDividerPaddles)
);
//ball 1
ClockDivider # (
     .CLOCK_RATE(140)
)ClockDividerBall1(
     .clock(clock),
     .reset(reset),
     .clockDivider(ClockDividerBall_1)
);

//ball 2
ClockDivider # (
     .CLOCK_RATE(140)
)ClockDividerBall2(
     .clock(clock),
     .reset(reset),
     .clockDivider(ClockDividerBall_2)
);
 

//First ball movement module
ballmovement #(
  .X_AXIS_BALL_SPEED(1),
  .Y_AXIS_BALL_SPEED(1)
)FirstBallMovement(
  .clock(ClockDividerBall_1),
  .reset(resetFirstBall | ResetFlag),
  .enable(enableGame),
  .xAxisDirectionChanges(PaddleBall_1_Collision), //Changes direction after hitting the x axis 
  .yAxisDirectionChanges(PaddleBall_1_HalfCollision), //2 bits one for hitting the top half(bit 1) and the other for hitting the bottom half(bit 0) of the paddles
  .XAxis_BallValue(firstBall_x_position),       //8 bit output representing the current horizontal position of the ball
  .YAxis_BallValue(firstBall_y_position),       //9 bit output representing the current vertical position of the ball
  .direction(FirstBallDirection)              //A binary output where 1 indicates the ball is moving to the right and 0 indicates movement to the left.
);

//Second ball movement module
ballmovement #(
  .X_AXIS_BALL_SPEED(1),
  .Y_AXIS_BALL_SPEED(1),
  .X_AXIS_BALL_POSITION(20),
  .Y_AXIS_BALL_POSITION(150),
  .TOPMOST_POSITION(10),
  .BOTTOMMOST_POSITION(155)
)SecondBallMovement(
  .clock(ClockDividerBall_2),
  .reset(resetSecondBall | ResetFlag),
  .enable(enableGame),
  .xAxisDirectionChanges(PaddleBall_2_Collision), //Changes direction after hitting the x axis 
  .yAxisDirectionChanges(PaddleBall_2_HalfCollision), //2 bits one for hitting the top half(bit 1) and the other for hitting the bottom half(bit 0) of the paddles
  .XAxis_BallValue(secondBall_x_position),       //8 bit output representing the current horizontal position of the ball
  .YAxis_BallValue(secondBall_y_position),       //9 bit output representing the current vertical position of the ball
  .direction(SecondBallDirection)              //A binary output where 1 indicates the ball is moving to the right and 0 indicates movement to the left.
);


//First Paddle movement module
paddlemovement #(
     .X_AXIS_PADDLE_POSITION(235),
	  .Y_AXIS_PADDLE_POSITION(240),
	  .BOTTOMMOST_POSITION(305)

)paddlemovementfirst(
     .clock(ClockDividerPaddles),
	  .reset(resetApp | ResetFlag),
	  .enable(enableGame),
	  .button ({Up_FirstPaddle,Down_FirstPaddle}),
	  .XAxis_PaddleValue(firstPaddle_x_position),
	  .YAxis_PaddleValue(firstPaddle_y_position)
);

//Second Paddle movement module
paddlemovement #(
     .X_AXIS_PADDLE_POSITION(235),
	  .Y_AXIS_PADDLE_POSITION(150),
	  .BOTTOMMOST_POSITION(150),
	  .TOPMOST_POSITION(15)
)paddlemovementsecond(
     .clock(ClockDividerPaddles),
	  .reset(resetApp | ResetFlag),
	  .enable(enableGame),
	  .button ({Up_SecondPaddle,Down_SecondPaddle}),
	  .XAxis_PaddleValue(secondPaddle_x_position),
	  .YAxis_PaddleValue(secondPaddle_y_position)
);

// Displays First Paddle Score on seven seg 4 and 5
HexTo7Segment FirstPaddleScoreFive (
	.hex (firstPaddleBCD[7:4]),
	.seg (segFive)   
);
HexTo7Segment FirstPaddleScoreFour (
	.hex (firstPaddleBCD[3:0]),
	.seg (segFour)   
);
BinaryToBCD FirstPaddleBCD (
    .bin (firstPaddleScore),
    .bcd (firstPaddleBCD)
);

// Displays Second Paddle Score on seven seg 0 and 1
HexTo7Segment SecondPaddleScoreOne (
	.hex (secondPaddleBCD[7:4]),
	.seg (segOne)   
);
HexTo7Segment SecondPaddleScoreZero (
	.hex (secondPaddleBCD[3:0]),
	.seg (segZero)   
);

BinaryToBCD SecondPaddleBCD (
    .bin (secondPaddleScore),
    .bcd (secondPaddleBCD)
);


// Score thresholds and initial positions
parameter SCORE_LIMIT = 11;
parameter RESET_POSITION = 5;  // Assuming 5 is the position where scoring happens
assign gameOver = (firstPaddleScore >= SCORE_LIMIT || secondPaddleScore >= SCORE_LIMIT);


// Score Calculator
always @(posedge ClockDividerBall_1) begin
    if (resetApp | ResetFlag) begin
        // Reset scores to zero when resetApp signal is asserted
        firstPaddleScore <= 0;
        secondPaddleScore <= 0;
    end else begin
        // Reset the ball positions without changing scores
        resetFirstBall <= 0;
        resetSecondBall <= 0;

        // Check if the second paddle has scored
        if (secondBall_x_position == RESET_POSITION) begin
				resetSecondBall <= 1'b1;  // Reset second ball's position
            secondPaddleScore <= secondPaddleScore + 1;  // Increment score
        end

        // Check if the first paddle has scored
        if (firstBall_x_position == RESET_POSITION) begin
				resetFirstBall <= 1'b1;  // Reset second ball's position
            firstPaddleScore <= firstPaddleScore + 1;  // Increment score
        end
    end

    // Check if any score reaches the score limit
    if (gameOver) begin
        // Reset both scores to zero if either score reaches or exceeds the score limit
        secondPaddleScore <= 0;
        firstPaddleScore <= 0;
    end
end

endmodule



//Referencing code by: T. Carpenter,"LT24Test Pattern Top", 13 Mar,2017.

/* N-Bit Up Counter
 * ----------------
 * By: Thomas Carpenter
 * Date: 13/03/2017 
 *
 * Short Description
 * -----------------
 * This module is a simple up-counter with a count enable.
 * The counter has parameter controlled width, increment,
 * and maximum value.
 *   
 */

module Nbitupcounter #(
    parameter WIDTH = 10,               //10bit wide
    parameter INCREMENT = 1,            //Value to increment counter by each cycle
    parameter MAX_VALUE = (2**WIDTH)-1  //Maximum value default is 2^WIDTH - 1
)(   
    input                    clock,
    input                    reset,
    input                    enable,    //Increments when enable is high
    output reg [(WIDTH-1):0] countValue //Output is declared as "WIDTH" bits wide
);

always @ (posedge clock) begin
    if (reset) begin
        //When reset is high, set back to 0
        countValue <= {(WIDTH){1'b0}};
    end else if (enable) begin
        //Otherwise counter is not in reset
        if (countValue >= MAX_VALUE[WIDTH-1:0]) begin
            //If the counter value is equal or exceeds the maximum value
            countValue <= {(WIDTH){1'b0}};   //Reset back to 0
        end else begin
            //Otherwise increment
            countValue <= countValue + INCREMENT[WIDTH-1:0];
        end
    end
end

endmodule