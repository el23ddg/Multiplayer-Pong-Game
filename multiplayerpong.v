/*
* Module: Multiplayerpong.v
*Created By: Premika Devaraj
*
*Short Description
*--------------------------------------------------
* 
*This is the top module for a Multiplayer Arcade Pong Game
*
*/

module multiplayerpong(
	//Declaring input ports

	 // Inputs 
	 input clock, //clock to drive the circuit
	 input key0, // Player 1 paddle movement
	 input key1, // Player 1 paddle movement
	 input key2, //Player 2 paddle movement 
	 input key3, //Player 2 paddle movement
	 input PlaySwitch,     //To start the game and reset it
	 
	 //Output ports- HEX segments 
	 output [6:0] segZero, 
	 output [6:0] segOne,
	 output [6:0] segFour, 
	 output [6:0] segFive,
	 
	 //Output ports - LCD
	 output  resetApp,      
	 output  LT24Wr_n,
	 output 	LT24Rd_n,
	 output  LT24CS_n,
	 output  LT24RS,
	 output  LT24Reset_n,
	 output [15:0] LT24Data,
	 
	 //Output ports - Audio Codec
	 output  LT24LCDOn,
	 output PIN_J12, // I2C clock to the codec
	 output PIN_K12, // I2C data to the codec
	 output PIN_H8,  // DAC clock to the audio codec
	 output PIN_J7   // DAC data to the audio codec
);

// Audio-Related Signals
wire audioClock;
wire [1:0] toneSelect;
reg [1:0] selectedTone;
//reg [1:0] state, nextState;
wire gameOver;


//Module instantiation

//Gamelogic instantiation
gamelogic gamelogic(
    .clock      (clock),
    .reset      (reset),
    .Up_FirstPaddle    (key0),
    .Down_FirstPaddle  (key1),
	 .Up_SecondPaddle   (key2),
	 .Down_SecondPaddle (key3),
	 .PlaySwitch(PlaySwitch),
	 .segFour(segFour),
	 .segFive(segFive),
	 .segZero(segZero),
	 .segOne(segOne),
	 .resetApp(resetApp),
	 .LT24Wr_n(LT24Wr_n),
	 .LT24Rd_n(LT24Rd_n),
	 .LT24CS_n(LT24CS_n),
	 .LT24RS (LT24RS),
	 .LT24Reset_n(LT24Reset_n),
	 .LT24Data (LT24Data),
	 .LT24LCDOn (LT24LCDOn),
	 .gameOver(gameOver)
		 
);
//Audio codec Instantiation

// Instantiate the audio codec clock divider
AudioClockDivider audioClockDivider(
  .clock(clock),
  .reset(resetApp),
  .audioClock(audioClock)
);

// Instantiate the audio output module
AudioCodecOutput audioOutput(
  .clk(audioClock),
  .rst_n(resetApp),
  .toneSelect(selectedTone),
  .dac_clk(PIN_H8),   // DAC clock pin
  .dac_data(PIN_J7)   // DAC data pin
);

// Instantiate the I2C configuration module for the codec
AudioCodecI2C codecConfig(
  .clk(clock),
  .rst_n(resetApp),
  .i2c_clk(PIN_J12), // I2C clock pin
  .i2c_data(PIN_K12) // I2C data pin
);

endmodule   //end of the module



