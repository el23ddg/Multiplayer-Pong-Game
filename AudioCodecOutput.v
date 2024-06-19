/*
*Module: AudioCodecOutput.v
*Created By: ngul28
*  https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=836&PartNo=4
*/

module AudioCodecOutput(

	input wire clk,       // Main clock input
	input wire rst_n,     // Active low reset
	input wire [1:0] toneSelect, // Tone selector signal (0: paddle move, 1: ball hit, 2: victory)
	output reg dac_clk,   // DAC clock signal to codec (PIN_H8)
	output reg dac_data   // DAC data signal to codec (PIN_J7)
);

	// Tone Frequencies (according to codec clock rate)
	localparam FREQ_MOVE = 500;
	localparam FREQ_HIT = 1000;
	localparam FREQ_VICTORY = 2000;

	reg [15:0] tone_counter;
	reg [15:0] tone_value;
	reg [31:0] sample_counter;
	reg [31:0] max_count;

	// Select max_count value based on toneSelect
	always @(toneSelect) begin
		case (toneSelect)
			2'b00: max_count = (50000000 / FREQ_MOVE) / 2; // Paddle move
			2'b01: max_count = (50000000 / FREQ_HIT) / 2;  // Ball hit
			2'b10: max_count = (50000000 / FREQ_VICTORY) / 2; // Victory
			default: max_count = (50000000 / FREQ_MOVE) / 2; // Default to move tone
		endcase
	end

	// Generate the selected tone
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			tone_counter <= 16'd0;
			tone_value <= 16'd0;
			sample_counter <= 32'd0;
			dac_clk <= 0;
			dac_data <= 0;
		end else begin
			sample_counter <= sample_counter + 32'd1;
			if (sample_counter >= max_count) begin
				sample_counter <= 32'd0;
				tone_value <= ~tone_value; // Toggle for a square wave
			end

			// Assign the tone value to the DAC output
			dac_data <= tone_value;
			dac_clk <= ~dac_clk; // Toggle clock
		end
		
	end
	
endmodule