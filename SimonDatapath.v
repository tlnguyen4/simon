//==============================================================================
// Datapath for Simon Project
//==============================================================================

`include "Memory.v"

module SimonDatapath(
	// External Inputs
	input        clk,           // Clock
	input        level,         // Switch for setting level
	input  [3:0] pattern,       // Switches for creating pattern
	input		 rst,

	// Datapath Control Signals
	input		 clear_i,
	input        increment_n,
	input        increment_i, 
	input        input_led_pattern,
	input        write_pattern,

	// Datapath Outputs to Control
	output reg   seq_remain,
	output reg	 valid_repeat,
	output reg	 valid_input,

	// External Outputs
	output reg [3:0] pattern_leds   // LED outputs for pattern
);

	// Declare Local Vars Here
	reg [5:0] n = 6'd0;
	reg [5:0] i = 6'd0;
	reg perm_level = 1'b0;
	wire [3:0] read_data;


	//----------------------------------------------------------------------
	// Internal Logic -- Manipulate Registers, ALU's, Memories Local to
	// the Datapath
	//----------------------------------------------------------------------

	always @(posedge clk) begin
		// Sequential Internal Logic Here
		if (rst) begin
			perm_level <= level;
			i <= 6'd0;
			n <= 6'd0;
		end

		if (clear_i) begin
			i <= 6'd0;
		end

		if (increment_i) begin
			i <= i + 6'd1;
		end

		if (increment_n) begin
			n <= n + 6'd1;
		end
	end

	// 64-entry 4-bit memory (from Memory.v) -- Fill in Ports!
	Memory mem(
		.clk     (clk),
		.rst     (rst),
		.r_addr  (i),
		.w_addr  (n),
		.w_data  (pattern),
		.w_en    (write_pattern),
		.r_data  (read_data)
	);

	//----------------------------------------------------------------------
	// Output Logic -- Set Datapath Outputs
	//----------------------------------------------------------------------

	always @( * ) begin
		// Output Logic Here
		seq_remain <= (i < n - 1'b1);
		valid_repeat <= (read_data == pattern);
		valid_input <= perm_level || ((perm_level == 1'b0) && (pattern == 4'b0001 || pattern == 4'b0010 || pattern == 4'b0100 || pattern == 4'b1000));
		if (input_led_pattern) begin
			pattern_leds <= pattern;
		end
		else begin
			pattern_leds <= read_data;
		end
	end

endmodule
