`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.03.2024 17:13:55
// Design Name: 
// Module Name: OLED_DATA_SEND
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module OLED_DATA_SEND(
           
    input CLOCK,   //100MHZ onboard clock
    input RESET,
    
    output    oled_spi_clk,
    output    oled_spi_data,
    output    oled_vdd,
    output    oled_vbat,
    output    oled_reset_n,
    output    oled_dc_n

    );
 
 localparam myString = "HELLO NAREN THIS SIDE WELCOME TO MY PROFILE                     ";  
 localparam StringLen =64;
 
 reg [1:0] state;
 reg [7:0] SendData;
 reg SendDataValid;
 integer byteCounter;
 wire SendDone;
 
 localparam IDLE = 'd0,
            SEND = 'd1,
            DONE = 'd2;
 
 always @(posedge CLOCK)
 begin
    if(RESET)
    begin
        state <= IDLE;
        byteCounter <= StringLen;
        SendDataValid <= 1'b0;
    end
    else
    begin
        case(state)
            IDLE:begin
                if(!SendDone)
                begin
                    SendData <= myString[(byteCounter*8-1)-:8];
                    SendDataValid <= 1'b1;
                    state <= SEND;
                end
            end
            SEND:begin
                if(SendDone)
                begin
                    SendDataValid <= 1'b0;
                    byteCounter <= byteCounter-1;
                    if(byteCounter != 1)
                        state <= IDLE;
                    else
                        state <= DONE;
                end
            end
            DONE:begin
                state <= DONE;
            end
        endcase
    end
 end
 
 OLED_INTERFACE OLED
    (
    
    .clock(CLOCK),   //100MHZ onboard clock
    .reset(RESET),
    
    .oled_spi_clk(oled_spi_clk),
    .oled_spi_data(oled_spi_data),
    .oled_vdd(oled_vdd),
    .oled_vbat(oled_vbat),
    .oled_reset_n(oled_reset_n),
    .oled_dc_n(oled_dc_n),
    
    .SendData(SendData),
    .SendDataValid(SendDataValid),
    .SendDone(SendDone)
   );
      
endmodule


   
