/*
*Module: AudioCodecI2C.v
*Created By: ngul28
*  https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=836&PartNo=4
*/

module AudioCodecI2C(

	input wire clk,      // Clock input
	input wire rst_n,    // Active low reset
	output reg i2c_clk,  // I²C clock to codec (PIN_J12)
	output reg i2c_data  // I²C data to codec (PIN_K12)
);

	// I²C Communication Parameters
	localparam I2C_ADDRESS = 7'b0011010; // WM8731 address
	reg [15:0] i2c_cmd;
	reg [3:0] state;
	reg [7:0] bit_cnt;
	reg [15:0] cmd_list [0:3]; // List of codec commands
	reg [1:0] cmd_idx;

	// Initialize commands in the configuration list
	initial begin
		// Power down all paths except DAC
		cmd_list[0] = 16'h0C0F;
		// Enable digital audio interface
		cmd_list[1] = 16'h1201;
		// Set volume control
		cmd_list[2] = 16'h1C50;

	end

	// I²C State Machine for Sending Configuration Commands
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			state <= 0;
			i2c_clk <= 1;
			i2c_data <= 1;
			bit_cnt <= 0;
			cmd_idx <= 0;
			i2c_cmd <= cmd_list[cmd_idx];
		end else begin
			case (state)
				0: begin // Start Condition
					i2c_clk <= 1;
					i2c_data <= 0;
					state <= 1;
				end
				1: begin // Send Address
					i2c_clk <= ~i2c_clk;
					if (i2c_clk == 1) begin
						i2c_data <= I2C_ADDRESS[6 - bit_cnt];
						bit_cnt <= bit_cnt + 1;
						if (bit_cnt == 7) begin
							state <= 2;
							bit_cnt <= 0;
						end
					end
				end
				2: begin // Send Command Data
					i2c_clk <= ~i2c_clk;
					if (i2c_clk == 1) begin
						i2c_data <= i2c_cmd[15 - bit_cnt];
						bit_cnt <= bit_cnt + 1;
						if (bit_cnt == 16) begin
							state <= 3;
							bit_cnt <= 0;
						end
					end
				end
				3: begin // Stop Condition
					i2c_clk <= 1;
					i2c_data <= 1;
					if (cmd_idx < 2) begin
						cmd_idx <= cmd_idx + 1;
						i2c_cmd <= cmd_list[cmd_idx];
						state <= 0; // Restart for next command
					end else begin
						state <= 4; // Finish configuration
					end
				end
				4: begin // Done state
					// Configuration completed
				end
				
			endcase
			
		end
		
	end
	
endmodule