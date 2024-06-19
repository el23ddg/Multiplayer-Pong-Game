/*
By: Ali Alhawaiji
Module:Clock Divider
----------------------------
This module divides the FPGA's clock frequency.
*/	


module ClockDivider #(
    parameter CLOCK_RATE = 100,                                // The rate that the output triggers high
    parameter MAX_VALUE = (50000000 / CLOCK_RATE) / 2,         // Max value to count to
    parameter WIDTH = 32
)(
    input clock,
    input reset,
    output reg clockDivider
);

reg [WIDTH-1:0] counter;  // Define a counter register of WIDTH bits

// Counter and toggle logic in a single always block
always @(posedge clock or posedge reset) begin
    if (reset) begin
        counter <= 0;
        clockDivider <= 0;
    end else begin
        if (counter >= MAX_VALUE - 1) begin
            clockDivider <= ~clockDivider;  // Toggle the clockDivider output
            counter <= 0;                 // Reset counter
        end else begin
            counter <= counter + 1;       // Increment counter
        end
    end
end

endmodule