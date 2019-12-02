//===============================================================================
// Testbench Module for Simon Controller
//===============================================================================
`timescale 1ns/100ps

`include "SimonControl.v"

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

module SimonControlTest;

	// Local Vars
	reg clk = 0;
	reg rst = 0;
	// More vars here...
	reg valid_input = 0;
	reg valid_repeat = 0;
	reg seq_remain = 0;
	wire clear_i;
	wire increment_n;
	wire increment_i;
	wire input_led_pattern;
	wire [2:0] mode_leds;
	wire write_pattern;

	// LED Light Parameters
	localparam LED_MODE_INPUT    = 3'b001;
	localparam LED_MODE_PLAYBACK = 3'b010;
	localparam LED_MODE_REPEAT   = 3'b100;
	localparam LED_MODE_DONE     = 3'b111;

	// VCD Dump
	initial begin
		$dumpfile("SimonControlTest.vcd");
		$dumpvars;
	end

	// Simon Control Module
	SimonControl ctrl(
		.clk (clk),
		.rst (rst),
		// More ports here...
		.valid_input (valid_input),
		.valid_repeat (valid_repeat),
		.seq_remain (seq_remain),
		.clear_i (clear_i),
		.increment_n (increment_n),
		.increment_i (increment_i),
		.input_led_pattern (input_led_pattern),
		.write_pattern(write_pattern),
		.mode_leds (mode_leds)
	);

	// Main Test Logic
	initial begin
		// Reset the game
		`SET(rst, 1);
		`CLOCK;
		`SET(rst, 0);

		// Your Test Logic Here
		`ASSERT_EQ(mode_leds, 3'b001, "Mode should be input mode (001).");

		`SET(valid_input, 0);
		`CLOCK;

		`ASSERT_EQ(clear_i, 0, "i should not be cleared.");
		`ASSERT_EQ(increment_n, 0, "n should not be incremented.");
		`ASSERT_EQ(mode_leds, 3'b001, "Mode should still be input mode (001) because pattern is invalid for level.");
		`ASSERT_EQ(input_led_pattern, 1, "pattern_led should show user input.");

		`SET(valid_input, 1);
		`ASSERT_EQ(increment_n, 1, "n should be incremented because a valid pattern was inputed.");
		
		`CLOCK;

		`ASSERT_EQ(clear_i, 1, "i should be cleared because switched to new state PLAYBACK.");
		`ASSERT_EQ(mode_leds, 3'b010, "Mode should be switched to Playback.");
		`ASSERT_EQ(input_led_pattern, 0, "pattern led should show stored patterns.");
		
		`SET(seq_remain, 1);
		`CLOCK;

		`ASSERT_EQ(clear_i, 0, "i should not be cleared because there is sequence remaining in PLAYBACK.");
		`ASSERT_EQ(increment_n, 0, "n should not be incremented in PLAYBACK.");
		`ASSERT_EQ(mode_leds, 3'b010, "Mode should be PLAYBACK.");
		`ASSERT_EQ(input_led_pattern, 0, "pattern led should show stored patterns.");

		`SET(seq_remain, 0);
		`CLOCK;

		`ASSERT_EQ(clear_i, 1, "i should be cleared because entering REPEAT.");
		`ASSERT_EQ(increment_n, 0, "n should not be incremented in PLAYBACK.");
		`ASSERT_EQ(mode_leds, 3'b100, "Mode should be REPEAT.");
		`ASSERT_EQ(input_led_pattern, 1, "pattern led should show user input.");

		`SET(seq_remain, 1);
		`SET(valid_repeat, 1);
		`CLOCK;

		`ASSERT_EQ(mode_leds, 3'b100, "Should still be in repeat because there is remaining pattern to guess.");

		`SET(seq_remain, 0);
		`SET(valid_input, 0);
		`CLOCK;

		`ASSERT_EQ(mode_leds, 3'b001, "Finished guessing sequence and should return to INPUT.");
		`ASSERT_EQ(increment_n, 0, "n should not be incremented when just returned to INPUT state.");
		`ASSERT_EQ(clear_i, 0, "i should not be cleared");
		`ASSERT_EQ(input_led_pattern, 1, "pattern led should show user input.");

		$finish;
	end

endmodule
