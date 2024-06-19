/*Module: paddlemovement.v */
/*Author- Debjani Dutta Gupta */
/* Description: */
/* This is for the movement of the paddles across the y-axis */
///////////////////////////////////////////////////////////////////////////////////////////////////////////

module paddlemovement #(
      parameter X_AXIS_PADDLE_POSITION = 120,  //start position of the paddle in the x axis
		parameter Y_AXIS_PADDLE_POSITION = 240,  //start position of the paddle in the y axis 
		parameter TOPMOST_POSITION = 185,        //top position for first paddle can be changed to another value during instantiation
		parameter BOTTOMMOST_POSITION = 305,     //bottom position for first paddle can be changed to another value during instantiation
		parameter Y_AXIS_PADDLE_SPEED = 15       //speed of the paddle 
)(
      input clock,
		input reset,
		input enable,  //A signal to enable or disable the updating of the paddle’s position. This might be used to pause the game or hold the paddle's position under certain conditions.
		input      [1:0] button,
		output reg [7:0] XAxis_PaddleValue,
		output reg [8:0] YAxis_PaddleValue
);

// Define states for the paddle movement 
localparam IDLE = 2'b00;
localparam MOVING_UP = 2'b01;
localparam MOVING_DOWN = 2'b10;

// state registers 
reg [1:0] currentState, nextState;

// register to hold previous state of buttons to detect edges 
reg [1:0] button_prev;


always @(posedge clock or posedge reset) begin
   if(reset) begin
	   currentState      <= IDLE;                     //paddle doesnot move
		XAxis_PaddleValue <= X_AXIS_PADDLE_POSITION;   //setting the paddle in the initial x axis position
		YAxis_PaddleValue <= Y_AXIS_PADDLE_POSITION;   //setting the paddle in the initial y axis position
		button_prev       <= 2'b11;                    //a setup condition often used to detect a change from a previously unpressed state
	end else begin
     if(enable) begin	
      currentState <= nextState;                     //This transition reflects a change in the paddle's movement state.
	   button_prev  <= button;                        //button_prev is updated to the current state of button, enabling the detection of changes in button state on the next clock cycle
	   
	   case(currentState)                             //moving the paddle up and down 
	       MOVING_DOWN:
			    if(YAxis_PaddleValue < BOTTOMMOST_POSITION)
				    YAxis_PaddleValue <= YAxis_PaddleValue + Y_AXIS_PADDLE_SPEED;
			 MOVING_UP:
			    if(YAxis_PaddleValue > TOPMOST_POSITION)
				    YAxis_PaddleValue <= YAxis_PaddleValue - Y_AXIS_PADDLE_SPEED;
		endcase
	 end 	
	end 
end 


always @(*) begin
   nextState = currentState;       //stay in the current state
   case(currentState)
       IDLE: begin
		     if(button[0] == 1'b0 && button_prev[0] == 1'b1 && YAxis_PaddleValue < BOTTOMMOST_POSITION - Y_AXIS_PADDLE_SPEED)
			     nextState = MOVING_DOWN;
			  else if(button[1] == 1'b0 && button_prev[1] == 1'b1 && YAxis_PaddleValue > TOPMOST_POSITION + Y_AXIS_PADDLE_SPEED)
			     nextState = MOVING_UP;
		 end
		 MOVING_DOWN: nextState = IDLE; //from MOVING_DOWN state transition back to IDLE
		 MOVING_UP: nextState = IDLE;   //from MOVING_UP state transition back to IDLE
	 endcase
end
			  
endmodule