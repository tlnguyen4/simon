//==============================================================================
// Simon Module for Simon Project
//==============================================================================

`include "ButtonDebouncer.v"
`include "SimonControl.v"
`include "SimonDatapath.v"

module Simon(
	input        sysclk,
	input        pclk,
	input        rst,
	input        level,
	input  [3:0] pattern,

	output [3:0] pattern_leds,
	output [2:0] mode_leds
);

	// Declare local connections here
	wire clear_i;
	wire increment_n;
	wire increment_i;
	wire input_led_pattern;
	wire seq_remain;
	wire valid_repeat;
	wire valid_input;
	wire write_pattern;

	//============================================
	// Button Debouncer Section
	//============================================

	//--------------------------------------------
	// IMPORTANT!!!! If simulating, use this line:
	//--------------------------------------------
	wire uclk = pclk;
	//--------------------------------------------
	// IMPORTANT!!!! If using FPGA, use this line:
	//--------------------------------------------
	// wire uclk;
	// ButtonDebouncer debouncer(
	// 	.sysclk(sysclk),
	// 	.noisy_btn(pclk),
	// 	.clean_btn(uclk)
	// );

	//============================================
	// End Button Debouncer Section
	//============================================

	// Datapath -- Add port connections
	SimonDatapath dpath(
		.clk           (uclk),
		.level         (level),
		.pattern       (pattern),
		.rst           (rst),
		.clear_i       (clear_i),
		.increment_n   (increment_n),
		.increment_i   (increment_i),
		.input_led_pattern (input_led_pattern),
		.write_pattern (write_pattern),
		.seq_remain    (seq_remain),
		.valid_repeat  (valid_repeat),
		.valid_input   (valid_input),
		.pattern_leds  (pattern_leds)
	);

	// Control -- Add port connections
	SimonControl ctrl(
		.clk           (uclk),
		.rst           (rst),
		.valid_input   (valid_input),
		.valid_repeat  (valid_repeat),
		.seq_remain    (seq_remain),
		.clear_i       (clear_i),
		.increment_n   (increment_n),
		.increment_i   (increment_i),
		.write_pattern (write_pattern),
		.input_led_pattern (input_led_pattern),
		.mode_leds     (mode_leds)
	);

endmodule
