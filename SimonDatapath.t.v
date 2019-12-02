//===============================================================================
// Testbench Module for Simon Datapath
//===============================================================================
`timescale 1ns/100ps

`include "SimonDatapath.v"

// Print an error message (MSG) if value ONE is not equal
// to value TWO.
`define ASSERT_EQ(ONE, TWO, MSG)               \
	begin                                      \
		if ((ONE) !== (TWO)) begin             \
			$display("\t[FAILURE]:%s", (MSG)); \
		end                                    \
	end #0

// Set the variable VAR to the value VALUE, printing a notification
// to the screen indicating the variable's update.
// The setting of the variable is preceeded and followed by
// a 1-timestep delay.
`define SET(VAR, VALUE) $display("Setting %s to %s...", "VAR", "VALUE"); #1; VAR = (VALUE); #1

// Cycle the clock up and then down, simulating
// a button press.
`define CLOCK $display("Pressing uclk..."); #1; clk = 1; #1; clk = 0; #1

module SimonDatapathTest;

	// Local Vars
	reg clk = 0;
	reg level = 1;
	reg [3:0] pattern = 4'b0000;
	reg rst = 0;
	reg clear_i = 1;
	reg increment_n = 0;
	reg increment_i = 0;
	reg input_led_pattern = 1;
	wire seq_remain;
	wire valid_repeat;
	wire valid_input;
	wire [3:0] pattern_leds;

	// LED Light Parameters
	localparam LED_MODE_INPUT    = 3'b001;
	localparam LED_MODE_PLAYBACK = 3'b010;
	localparam LED_MODE_REPEAT   = 3'b100;
	localparam LED_MODE_DONE     = 3'b111;

	// VCD Dump
	integer idx;
	initial begin
		$dumpfile("SimonDatapathTest.vcd");
		$dumpvars;
		for (idx = 0; idx < 64; idx = idx + 1) begin
			$dumpvars(0, dpath.mem.mem[idx]);
		end
	end

	// Simon Control Module
	SimonDatapath dpath(
		.clk     (clk),
		.level   (level),
		.pattern (pattern),
		.rst	 (rst),
		// More ports here...
		.clear_i	 (clear_i),
		.increment_n (increment_n),
		.increment_i (increment_i),
		.input_led_pattern (input_led_pattern),
		.seq_remain (seq_remain),
		.valid_repeat (valid_repeat),
		.valid_input (valid_input),
		.pattern_leds (pattern_leds)
	);

	// Main Test Logic
	initial begin
		// Your Test Logic Here
		// Reset the datapath
		$display("\nResetting the Datapath");
		`SET(rst, 1);
		`CLOCK;

		`SET(rst, 0);
		`CLOCK;		

		`SET(pattern, 4'b1001);
		`SET(input_led_pattern, 1);
		`CLOCK;

		`ASSERT_EQ(valid_input, 1, "valid_input should be true.");
		`ASSERT_EQ(pattern_leds, pattern, "pattern_leds should be in user input pattern.");

		`SET(increment_n, 1);
		`CLOCK;
		`SET(increment_n, 0);
		`SET(input_led_pattern, 0);
		`SET(clear_i, 1);
		`CLOCK;

		`ASSERT_EQ(seq_remain, 1, "seq_remain should be true (i = 0, n = 1, i < n).");
		`ASSERT_EQ(pattern_leds, 4'b1001, "pattern_leds should be the stored patterns.");

		`SET(increment_i, 1);
		`CLOCK;
		
		`ASSERT_EQ(seq_remain, 0, "seq_remain should be false (i = 1, n = 1, i == n).");
		`ASSERT_EQ(valid_repeat, 1, "valid_repeat should be true (read_data == pattern).");

		// Test level change is not stored
		`SET(level, 0);
		`CLOCK;

		`ASSERT_EQ(valid_input, 1, "valid_input should be true (permlevel == 1 despite level changing to 0).");

		$finish;
	end

endmodule
