/*Module: ballmovement.v */
/*Author- Debjani Dutta Gupta */
/* Description: */
/* This is for the movement of the ball after colliding with the walls and paddles*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module ballmovement #(
     parameter X_AXIS_BALL_POSITION = 20,     //The start position of the ball in the x axis 
	  parameter Y_AXIS_BALL_POSITION = 240,    //The start position of the ball in the y axis
	  parameter LEFTMOST_POSITION = 10,        //The left boundary of the game arena 
	  parameter TOPMOST_POSITION = 175,        //The top boundary of the game arena for each ball
	  parameter BOTTOMMOST_POSITION = 310,     //The boundary of the game arena for the ball (ball 1)
	  parameter X_AXIS_BALL_SPEED = 1,         //The horizontal velocity of the ball
	  parameter Y_AXIS_BALL_SPEED = 1          //The vertical velocity of the ball
)(
     input            clock,
	  input            reset,
	  input            xAxisDirectionChanges,  //Changes direction after hitting the x axis 
	  input      [1:0] yAxisDirectionChanges,  //2 bits one for hitting the top half(bit 1) and the other for hitting the bottom half(bit 0) of the paddles
	  input            enable,                 //A signal to enable or disable the updating of the ball’s position. This might be used to pause the game or hold the ball's position under certain conditions.
	  output reg [7:0] XAxis_BallValue,        //8 bit output representing the current horizontal position of the ball
	  output reg [8:0] YAxis_BallValue,        //9 bit output representing the current vertical position of the ball
	  output reg       direction               //A binary output where 1 indicates the ball is moving to the right and 0 indicates movement to the left.
);

//State definitions for 4 directions of the ball movement
localparam MOVE_RIGHT = 1'b1, MOVE_LEFT = 1'b0;
localparam MOVE_DOWN = 1'b1, MOVE_UP = 1'b0;

//State registers
reg xState, yS	tate;

always @(posedge clock or posedge reset) begin
   if (reset) begin 
	   XAxis_BallValue <= X_AXIS_BALL_POSITION; //The horizontal position of the ball is set back to the starting position in the x axis
	   YAxis_BallValue <= Y_AXIS_BALL_POSITION; //The vertical position of the ball is set back to the starting position in the y axis 
      xState <= MOVE_RIGHT;                    //The movement states are initialized to MOVE_RIGHT and MOVE_DOWN which means after reset 
		yState <= MOVE_DOWN;                     //the ball will start moving towards the bottom right corner of the game arena
	end else begin
	  if(enable) begin
      case(xState)                             //horizontal movement of the ball   
	      MOVE_RIGHT: begin
		      if(xAxisDirectionChanges && XAxis_BallValue >= 220-10)  //if xAxisDirectionChanges is high and the ball is near the edge of the game arena then the state switches to MOVE_LEFT
			       xState <= MOVE_LEFT;
				else 
		          XAxis_BallValue <= XAxis_BallValue + X_AXIS_BALL_SPEED;
			end
         MOVE_LEFT: begin
            if(XAxis_BallValue <= LEFTMOST_POSITION)                //if the ball reaches the left most position of the game arena the state switches to MOVE_RIGHT
	             xState <= MOVE_RIGHT;
			   else 
	             XAxis_BallValue <= XAxis_BallValue - X_AXIS_BALL_SPEED;
			end	
      endcase			
    
	   case(yState)                             //vertical movement of the ball
		   MOVE_DOWN: begin
			   if(yAxisDirectionChanges[0] || YAxis_BallValue >= BOTTOMMOST_POSITION) 
	              yState <= MOVE_UP;
				else 
	              YAxis_BallValue <= YAxis_BallValue + Y_AXIS_BALL_SPEED;
			end	
         MOVE_UP: begin
			   if(yAxisDirectionChanges[1] || YAxis_BallValue <= TOPMOST_POSITION)
	              yState <= MOVE_DOWN;
				else 
	              YAxis_BallValue <= YAxis_BallValue - Y_AXIS_BALL_SPEED;
			end
       endcase
	  end	 
    end 
end 

endmodule