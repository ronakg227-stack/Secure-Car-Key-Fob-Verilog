`timescale 1ns / 1ps
module car_key_fob_basic (
    input wire clk,
    input wire rx_trigger,           // High when any button is pressed
    input wire [15:0] rx_key_code,   // 16-bit security code
    input wire [1:0] rx_command,     // 01 = Unlock, 10 = Lock
    output reg unlock_doors,         
    output reg lock_doors            
);

    localparam [15:0] VALID_CODE = 16'hA5A5;

    always @(posedge clk) begin
        unlock_doors <= 1'b0;
        lock_doors <= 1'b0;

        if (rx_trigger) begin
            if (rx_key_code == VALID_CODE) begin
                if (rx_command == 2'b01) begin
                    unlock_doors <= 1'b1;
                end else if (rx_command == 2'b10) begin
                    lock_doors <= 1'b1;
                end
            end
        end
    end
endmodule