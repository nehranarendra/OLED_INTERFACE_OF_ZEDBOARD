`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: MAY BE IT'S YOU
// Engineer: NARENDRA KUMAR NEHRA
// 
// Create Date: 11.03.2024 10:47:45
// Design Name: 
// Module Name:  SPI_INTERFACE
// Project Name: OLED_INTERFACE_FINAL  
// Target Devices: OLED DISPLAY OF ZEDBOARD ZYNQ 7000 SOC
//////////////////////////////////////////////////////////////////////////////////


module SPI_INTERFACE(
 
 input clock,                      //on board zynq clock(100 MHz )
 input reset,
 input [7:0] data_in,
 input load_data,                 //signal indicates new dara for transmission
 
 output reg  Done_Send,          // signal indicates data has been sent over  spi_interface
 output      Spi_Clock,          //10MHz clock 
 output reg  Spi_Data
                     );
     
     reg [2:0] counter    = 0;
     reg [2:0] Data_Count = 0;
     reg [7:0] Shift_Reg;
     reg [1:0] state      = 0;
     reg       clock_10   = 0;  
     reg CE;
     
     assign Spi_Clock = (CE == 1) ? clock_10: 1'b1;
     
     
     
     
    initial clock_10 <=0;
 
     
  
        always @(posedge clock)
              begin
                if(counter != 4)
                     counter <= counter+1;
                else 
                     counter <= 0;
              end 
     
  
  
        always @(posedge clock)
                 begin
                      if(counter == 4)
                            clock_10 <= ~clock_10;
                 end  
  
  
  localparam        IDLE = 'd0,
                    SEND = 'd1,
                    DONE = 'd2;


always @(negedge clock_10)
      begin
             if(reset)
                 begin
                       state      <= IDLE;
                       Data_Count <= 0;
                       Done_Send  <= 1'b0;
                       CE         <= 0;
                       Spi_Data   <= 1'b1;
                  end 
              else 
                begin
                    case(state)
                            IDLE:
                                       begin
                                           if(load_data)
                                                    begin 
                                                     Shift_Reg   <= data_in;
                                                     state       <= SEND;
                                                     Data_Count  <= 0;
                                                    end 
                                      end 
             
                            SEND: 
                                      begin 
                                          Spi_Data  <= Shift_Reg[7];
                                          Shift_Reg <= {Shift_Reg[6:0] ,1'b0};
                                          CE        <= 1;
                   
                                         if(Data_Count !=7)
                                                Data_Count <= Data_Count+1;
                                         else 
                                              begin 
                                                 state <= DONE;
                                               end 
                                       end 
          
                          DONE: 
                                    begin
                                              Done_Send <= 1'b1;
                                              CE        <= 0;
                                           if(!load_data)
                                            begin
                                               Done_Send <= 1'b0;
                                               state     <= IDLE; 
                                             end 
                                    end     
                    endcase 
                 end 
          end      

endmodule
