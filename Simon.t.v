//===============================================================================
// Testbench Module for Simon
//===============================================================================
`timescale 1ns/100ps

`include "Simon.v"

`define ASSERT_EQ(ONE, TWO, MSG)               \
	begin                                      \
		if ((ONE) !== (TWO)) begin             \
			$display("\t[FAILURE]:%s", (MSG)); \
			errors = errors + 1;               \
		end                                    \
	end #0

`define SET(VAR, VALUE) $display("Setting %s to %s...", "VAR", "VALUE"); #1; VAR = (VALUE); #1

`define CLOCK $display("Pressing uclk..."); #1; clk = 1; #1; clk = 0; #1

`define SHOW_MODE(MODE) $display("\nEntering Mode: %s\n-----------------------------------", MODE)

module SimonTest;

	// Local Vars
	reg clk = 0;
	reg sysclk = 0;
	reg rst = 0;
	reg level = 0;
	reg [3:0] pattern = 4'd0;
	wire [2:0] mode_leds;
	wire [3:0] pattern_leds;

	// Error Counts
	reg [7:0] errors = 0;

	// LED Light Parameters
	localparam LED_MODE_INPUT    = 3'b001;
	localparam LED_MODE_PLAYBACK = 3'b010;
	localparam LED_MODE_REPEAT   = 3'b100;
	localparam LED_MODE_DONE     = 3'b111;

	// VCD Dump
	integer idx;
	initial begin
		$dumpfile("SimonTest.vcd");
		$dumpvars;
		for (idx = 0; idx < 64; idx = idx + 1) begin
			$dumpvars(0, simon.dpath.mem.mem[idx]);
		end
	end

	// Simon Module
	Simon simon(
		.sysclk       (sysclk),
		.pclk         (clk),
		.rst          (rst),
		.level        (level),
		.pattern      (pattern),

		.pattern_leds (pattern_leds),
		.mode_leds    (mode_leds)
	);

	// Main Test Logic
	initial begin
		// Reset the game
		`SHOW_MODE("Unknown");
		`SET(rst, 1);
		`CLOCK;

		//-----------------------------------------------
		// Input Mode
		// ----------------------------------------------
		`SHOW_MODE("Input");
		`SET(rst, 0);

		`SET(pattern, 4'b1010);
		`CLOCK;

		`ASSERT_EQ(pattern_leds, pattern, "Pattern LEDs should match switches in input mode.");
		`ASSERT_EQ(mode_leds, LED_MODE_INPUT, "Mode should be input because of invalid input.");

		`SET(level, 1);
		`CLOCK;

		`ASSERT_EQ(mode_leds, LED_MODE_INPUT, "Cannot change level while not in reset.");

		`SET(rst, 1);
		`SET(level, 1);
		`CLOCK;
		`SET(rst, 0);
		`SET(pattern, 4'b1010);
		`CLOCK;

		//-----------------------------------------------
		// Playback Mode
		// ----------------------------------------------
		`SHOW_MODE("Playback");
		`ASSERT_EQ(mode_leds, LED_MODE_PLAYBACK, "Mode should go to playback after input!");

		`SET(pattern, 4'b0000);
		`ASSERT_EQ(pattern_leds, 4'b1010, "Pattern LEDs should show first pattern in sequence.");

		`CLOCK;

		//-----------------------------------------------
		// Repeat Mode
		// ----------------------------------------------
		`SHOW_MODE("Repeat");
		`ASSERT_EQ(mode_leds, LED_MODE_REPEAT, "Mode should go to repeat after playback has ended!");

		`SET(pattern, 4'b1110);
		`ASSERT_EQ(pattern_leds, 4'b1110, "Pattern LEDs should match switches in repeat mode");

		// Insert Guess
		`CLOCK;

		//-----------------------------------------------
		// Done Mode
		// ----------------------------------------------
		`SHOW_MODE("Done");
		`ASSERT_EQ(mode_leds, LED_MODE_DONE, "Mode should go to done after failed guess!");

		// Modify Switches
		`SET(pattern, 4'b0000);
		`ASSERT_EQ(pattern_leds, 4'b1010, "Pattern LEDs should show first pattern in sequence!");

		// Wrap Around
		`CLOCK;
		`ASSERT_EQ(pattern_leds, 4'b1010, "Pattern LEDs should stay in first pattern in sequence!");

		`ASSERT_EQ(mode_leds, LED_MODE_DONE, "Mode should stay in done after failed guess!");
		

		$display("\nTESTS COMPLETED (%d FAILURES)", errors);
		$finish;
	end

endmodule
