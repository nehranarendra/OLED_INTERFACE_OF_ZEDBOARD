`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TRACTRIX OPTODYNAMICS
// Engineer: NARENDRA KUMAR NEHRA
// 
// Create Date: 11.03.2024 10:47:45
// Design Name: 
// Module Name:  DELAY_GENERATOR
// Project Name: OLED_INTERFACE_FINAL  
// Target Devices: OLED DISPLAY OF ZEDBOARD ZYNQ 7000 SOC
//////////////////////////////////////////////////////////////////////////////////

module DELAY_GENERATOR
   (
       input clock,
       input Delay_Enable,
       output reg Delay_Done
   );
    
   reg [17:0] counter;
 
 always @(posedge clock)
     begin
            if(Delay_Enable & counter != 200000)
                   counter <= counter+1;
             else 
                   counter <= 0;
      end
 
  always @(posedge clock)
     begin
         if(Delay_Enable & counter == 200000)
             Delay_Done <= 1'b1;
         else 
             Delay_Done <= 1'b0;
  end
 
endmodule
