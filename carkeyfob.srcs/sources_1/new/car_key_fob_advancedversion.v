`timescale 1ns / 1ps
module car_key_fob_advancedversion (
    input wire clk,
    input wire reset,
    input wire rx_trigger,         // Fob button press signal
    input wire [15:0] rx_key_code, // 16-bit password
    input wire [1:0] rx_command,   // 01 = Unlock, 10 = Lock, 11 = Open Trunk
    output reg unlock_doors,       
    output reg lock_doors,
    output reg open_trunk,         // Dikki open signal
    output reg alarm_active        
);

    localparam [15:0] VALID_CODE = 16'hA5A5;
    localparam MAX_ATTEMPTS = 2'd3;
    localparam HOLD_TIME = 3'd4;   // Minimum hold time to prevent accidental pocket press

    reg [1:0] failed_attempts;
    reg locked_out;
    reg [2:0] trigger_counter;     // Timer for long-press check

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            unlock_doors <= 1'b0;
            lock_doors <= 1'b0;
            open_trunk <= 1'b0;
            alarm_active <= 1'b0;
            failed_attempts <= 2'd0;
            locked_out <= 1'b0;
            trigger_counter <= 3'd0;
        end else begin
            // Default states (ensure they are single-cycle pulses)
            unlock_doors <= 1'b0; 
            lock_doors <= 1'b0;
            open_trunk <= 1'b0;

            if (rx_trigger && !locked_out) begin
                if (trigger_counter < HOLD_TIME) begin
                    trigger_counter <= trigger_counter + 1'b1; // Keep counting
                end 
                else if (trigger_counter == HOLD_TIME) begin
                    // Button held long enough -> Process command
                    if (rx_key_code == VALID_CODE) begin
                        failed_attempts <= 2'd0; // Reset fails on success
                        case (rx_command)
                            2'b01: unlock_doors <= 1'b1;
                            2'b10: lock_doors <= 1'b1;
                            2'b11: open_trunk <= 1'b1; // Trigger Trunk
                        endcase
                    end else begin
                        failed_attempts <= failed_attempts + 1'b1;
                        if (failed_attempts == MAX_ATTEMPTS - 1) begin
                            locked_out <= 1'b1;
                            alarm_active <= 1'b1; // Trigger Anti-Theft Alarm
                        end
                    end
                    // Increment counter once more so it doesn't trigger continuously
                    trigger_counter <= trigger_counter + 1'b1; 
                end
            end else if (!rx_trigger) begin
                // Reset timer immediately if button is released
                trigger_counter <= 3'd0; 
            end
        end
    end
endmodule
