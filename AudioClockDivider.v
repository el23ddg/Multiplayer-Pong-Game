/*
*Module: AudioClockDivider.v
*Created By: ngul28
*  https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=836&PartNo=4
*/


module AudioClockDivider(

	input clock,
	input reset,
	output reg audioClock

);

	parameter AUDIO_CLOCK_RATE = 44100;  // Set to the desired audio sample rate
	localparam MAX_VALUE = (50000000 / AUDIO_CLOCK_RATE) / 2; // clock frequency
	localparam WIDTH = 32;

	reg [WIDTH-1:0] counter;

	always @(posedge clock or posedge reset) begin
		if (reset) begin
			counter <= 0;
			audioClock <= 0;
		end else begin
			if (counter >= MAX_VALUE - 1) begin
				audioClock <= ~audioClock;
				counter <= 0;
			end else begin
				counter <= counter + 1;
			end
		end
	end


endmodule