//==============================================================================
// Control Module for Simon Project
//==============================================================================

module SimonControl(
	// External Inputs
	input        clk,           // Clock
	input        rst,           // Reset

	// Datapath Inputs
	input        valid_input,
	input 	     valid_repeat,
	input        seq_remain,

	// Datapath Control Outputs
	output reg   clear_i,
	output reg   increment_n,
	output reg   input_led_pattern,
	output reg   increment_i,
	output reg   write_pattern,

	// External Outputs
	output reg [2:0] mode_leds
);

	// Declare Local Vars Here
	reg [1:0] state;
	reg [1:0] next_state;

	// LED Light Parameters
	localparam LED_MODE_INPUT    = 3'b001;
	localparam LED_MODE_PLAYBACK = 3'b010;
	localparam LED_MODE_REPEAT   = 3'b100;
	localparam LED_MODE_DONE     = 3'b111;

	// Declare State Names Here
	localparam STATE_INPUT = 2'd0;
	localparam STATE_PLAYBACK = 2'd1;
	localparam STATE_REPEAT = 2'd2;
	localparam STATE_DONE = 2'd3;

	// Next State Combinational Logic
	always @( * ) begin
		// Write your Next State Logic Here
		next_state = state;

		case (state)
			STATE_INPUT: begin
				if (valid_input) begin
					next_state = STATE_PLAYBACK;
				end
				else begin
					next_state = STATE_INPUT;
				end
			end

			STATE_PLAYBACK: begin
				if (!seq_remain) begin
					next_state = STATE_REPEAT;
				end
				else begin
					next_state = STATE_PLAYBACK;
				end
			end

			STATE_REPEAT: begin
				if (valid_repeat) begin
					if (seq_remain) begin
						next_state = STATE_REPEAT;
					end
					else begin
						next_state = STATE_INPUT;
					end
				end
				else begin
					next_state = STATE_DONE;
				end
			end

			STATE_DONE: begin
				// next_state = STATE_DONE;
			end
		endcase
	end

	// Output Combinational Logic
	always @( * ) begin
		clear_i <= (state == STATE_INPUT && valid_input) || 
					(state == STATE_PLAYBACK && !seq_remain) || 
					(state == STATE_REPEAT && !valid_repeat) || 
					(state == STATE_DONE && !seq_remain);
		increment_i <= ((state == STATE_PLAYBACK) && seq_remain) || 
						((state == STATE_REPEAT) && valid_repeat) || 
						(state == STATE_DONE);
		increment_n <= (state == STATE_INPUT && valid_input);
		input_led_pattern <= (state == STATE_INPUT) || 
							(state == STATE_REPEAT);
		write_pattern <= (state == STATE_INPUT && valid_input);
	
		case (state)
			STATE_INPUT: begin
				mode_leds <= LED_MODE_INPUT;
			end

			STATE_PLAYBACK: begin
				mode_leds <= LED_MODE_PLAYBACK;
			end

			STATE_REPEAT: begin
				mode_leds <= LED_MODE_REPEAT;
			end

			STATE_DONE: begin
				mode_leds <= LED_MODE_DONE;
			end
		endcase 
	end

	// State Update Sequential Logic
	always @(posedge clk) begin
		if (rst) begin
			// Update state to reset state
			state <= STATE_INPUT;
		end
		else begin
			// Update state to next state
			state <= next_state;
		end
	end
endmodule
