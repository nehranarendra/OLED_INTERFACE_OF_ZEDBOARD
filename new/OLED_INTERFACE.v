
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: TRACTRIX OPTODYNAMICS
// Engineer: NARENDRA KUMAR NEHRA
// 
// Create Date:  11.03.2024 10:47:15
// Design Name: OLED_INTERFACE_FINAL
// Module Name: OLED_INTERFACE
// Project Name: 
// Target Devices: OLED DISPLAY OF ZEDBOARD ZYNQ 7000 SOC

module OLED_INTERFACE
    (
    
    input clock,   //100MHZ onboard clock
    input reset,
    
    output wire   oled_spi_clk,
    output  wire  oled_spi_data,
    output reg    oled_vdd,
    output reg    oled_vbat,
    output reg    oled_reset_n,
    output reg    oled_dc_n,
    
    input [6:0] SendData,
    input       SendDataValid,
    output reg  SendDone
   );
   
   
   reg [4:0]   state;
   reg [4:0]   NextState;
   reg [7:0]   SPI_DATA;
   reg         StartDelay;
   reg         SPI_LOAD;
   reg  [1:0]  CURRENT_PAGE;
   reg  [7:0] COLUMNCOUNTER;
   reg  [3:0] ByteCounter;
   
   
   wire [63:0] CharBitMap;
   wire DelayDone;
   wire SPI_DONE;
   
   
   localparam IDLE         = 'd0,
              DELAY        = 'd1,
              INIT         = 'd2,
              RESET        = 'd3,
              CHARGE_PUMP  = 'd4,
              WAIT_SPI     = 'd5,
              CHARGEPUMP1  = 'd6,
              PRECHARGE    = 'd7,
              PRECHARGE1   = 'd8,
              VBATON      =  'd9,
              CONTRAST     = 'd10,
              CONTRAST1    = 'd11,
              SEGMENTREMAP = 'd12,
              SCANDIRECTION= 'd13,
              COM_PIN      = 'd14,
              COM_PIN1     = 'd15,
              TURNONDISPLAY= 'd16,
              FULL_DISPLAY = 'D17,
              DONE         = 'd18,
              PAGEADRESS   = 'D19,
              PAGEADRESS1  = 'D20,
              PAGEADRESS2  = 'd21,
              COLUMNADDR   = 'd22,
              SEND_DATA    = 'd23; 
              
   
   always @(posedge clock)
   begin
        if(reset)
        begin
          state        <= IDLE;
          NextState    <= IDLE;
          oled_vdd     <= 1'b1;
          oled_vbat    <= 1'b1;
          oled_reset_n <= 1'b1;
          oled_dc_n    <= 1'b1;
          StartDelay   <= 1'b0;
          SPI_DATA     <= 8'h0;
          SPI_LOAD     <= 1'b0;
          CURRENT_PAGE <= 0;
          SendDone     <= 1'b0;
          COLUMNCOUNTER<= 0;
          ByteCounter  <= 0;
        end
        else
        begin
        case(state)
           
            IDLE: 
                    begin
                       oled_vbat    <= 1'b1;
                       oled_reset_n   <= 1'b1;
                       oled_dc_n    <= 1'b0;
                       oled_vdd     <= 1'b0;
                       state        <= DELAY;
                       NextState    <= INIT;
                    end 
            DELAY: 
                    begin
                        StartDelay  <= 1'b1;
                        if(DelayDone)
                        begin
                           state <= NextState;
                           StartDelay  <= 1'b0;
                        end
                     end 
            INIT:
                    begin
                      SPI_DATA <= 'hAE;
                      SPI_LOAD <= 1'b1;
                        if(SPI_DONE)
                       begin
                           SPI_LOAD    <= 1'b0;
                           oled_reset_n  <= 1'b0;
                           state       <= DELAY;
                           NextState   <= RESET;
                       end
                     end
             RESET: 
                    begin
                       oled_reset_n   <= 1'b1;
                       state        <= DELAY;
                       NextState    <= CHARGE_PUMP;
                    end  
                    
                    
              CHARGE_PUMP:
                    begin
                      SPI_DATA <= 'h8D;
                      SPI_LOAD <= 1'b1;
                        if(SPI_DONE)
                       begin
                           SPI_LOAD    <= 1'b0;
                           state       <=  WAIT_SPI;
                           NextState   <= CHARGEPUMP1;
                       end
                     end
       
             WAIT_SPI:
                    begin
                    if(!SPI_DONE)
                       begin
                           state       <= NextState;
                       end
                     end
                     
             CHARGEPUMP1:
                    begin
                      SPI_DATA <= 'h14;
                      SPI_LOAD <= 1'b1;
                        if(SPI_DONE)
                       begin
                           SPI_LOAD    <= 1'b0;
                           state       <=  WAIT_SPI;
                           NextState   <= PRECHARGE;
                       end
                     end
                     
                     
             PRECHARGE:
                    begin
                      SPI_DATA <= 'hD9;
                      SPI_LOAD <= 1'b1;
                        if(SPI_DONE)
                       begin
                           SPI_LOAD    <= 1'b0;
                           state       <=  WAIT_SPI;
                           NextState   <= PRECHARGE1;
                       end
                     end
             
             PRECHARGE1:
                    begin
                      SPI_DATA <= 'hF1;
                      SPI_LOAD <= 1'b1;
                        if(SPI_DONE)
                       begin
                           SPI_LOAD    <= 1'b0;
                           state       <=  WAIT_SPI;
                           NextState   <=  VBATON;
                       end
                     end
                     
              VBATON:
                     begin
                       oled_vbat  <= 1'b0;
                       state      <= DELAY;
                       NextState  <= CONTRAST;
                    
                     end
                     
             CONTRAST:
                    begin
                      SPI_DATA <= 'h81;
                      SPI_LOAD <= 1'b1;
                        if(SPI_DONE)
                       begin
                           SPI_LOAD    <= 1'b0;
                           state       <=  WAIT_SPI;
                           NextState   <=  CONTRAST1;
                       end
                     end 
                     
              CONTRAST1:
                    begin
                      SPI_DATA <= 'hFF;
                      SPI_LOAD <= 1'b1;
                        if(SPI_DONE)
                       begin
                           SPI_LOAD    <= 1'b0;
                           state       <=  WAIT_SPI;
                           NextState   <= SEGMENTREMAP;
                       end
                     end
                      
              SEGMENTREMAP:
                    begin
                      SPI_DATA <= 'hA0;
                      SPI_LOAD <= 1'b1;
                        if(SPI_DONE)
                       begin
                           SPI_LOAD    <= 1'b0;
                           state       <=  WAIT_SPI;
                           NextState   <= SCANDIRECTION;
                       end
                     end 
                     
            SCANDIRECTION:
                    begin
                      SPI_DATA <= 'hC0;
                      SPI_LOAD <= 1'b1;
                        if(SPI_DONE)
                       begin
                           SPI_LOAD    <= 1'b0;
                           state       <=  WAIT_SPI;
                           NextState   <= COM_PIN;
                       end
                     end 
                           
             COM_PIN:
                    begin
                      SPI_DATA <= 'hDA;
                      SPI_LOAD <= 1'b1;
                        if(SPI_DONE)
                       begin
                           SPI_LOAD    <= 1'b0;
                           state       <=  WAIT_SPI;
                           NextState   <= COM_PIN1;
                       end
                     end
             COM_PIN1:
                    begin
                      SPI_DATA <= 'h00;
                      SPI_LOAD <= 1'b1;
                        if(SPI_DONE)
                       begin
                           SPI_LOAD    <= 1'b0;
                           state       <=  WAIT_SPI;
                           NextState   <= TURNONDISPLAY;
                       end
                     end
                     
              TURNONDISPLAY:
                    begin
                      SPI_DATA <= 'hAF;
                      SPI_LOAD <= 1'b1;
                        if(SPI_DONE)
                       begin
                           SPI_LOAD    <= 1'b0;
                           state       <=  WAIT_SPI;
                           NextState   <=  PAGEADRESS;
                       end
                     end
                     
           
             
               PAGEADRESS:
                    begin
                      SPI_DATA <= 'h22;
                      SPI_LOAD <= 1'b1;
                      oled_dc_n<= 1'b0;
                        if(SPI_DONE)
                       begin
                           SPI_LOAD    <= 1'b0;
                           state       <=  WAIT_SPI;
                           NextState   <=  PAGEADRESS1;
                       end
                     end  
              PAGEADRESS1:
                    begin
                            SPI_DATA <= CURRENT_PAGE;
                            SPI_LOAD <= 1'b1;
                        if(SPI_DONE)
                       begin
                           SPI_LOAD    <= 1'b0;
                           state       <=  WAIT_SPI;
                           CURRENT_PAGE<= CURRENT_PAGE+1;
                           NextState   <=  PAGEADRESS2;
                       end
                     end
                     
               PAGEADRESS2:
                    begin
                      SPI_DATA <= CURRENT_PAGE;
                      SPI_LOAD <= 1'b1;
                        if(SPI_DONE)
                       begin
                           SPI_LOAD    <= 1'b0;
                           state       <=  WAIT_SPI;
                           NextState   <=  COLUMNADDR;
                       end
                     end  
             
                COLUMNADDR:
                    begin
                      SPI_DATA <= 'h10;
                      SPI_LOAD <= 1'b1;
                        if(SPI_DONE)
                       begin
                           SPI_LOAD    <= 1'b0;
                           state       <=  WAIT_SPI;
                           NextState   <= DONE;
                       end
                     end    
               
                     
               DONE:
                     
                   begin
                        SendDone <= 1'b0;
                     if(SendDataValid  & COLUMNCOUNTER != 128 &  !SendDone)
                      begin
                          state      <= SEND_DATA;
                          ByteCounter <= 8;
                      end
                     else if(COLUMNCOUNTER == 128 & SendDataValid &  !SendDone)
                       begin
                           state         <= PAGEADRESS;
                           COLUMNCOUNTER <=0;
                          ByteCounter    <= 8;
                       end  
                   end  
              SEND_DATA:
                   begin
                        SPI_DATA <= CharBitMap[(ByteCounter*8-1)-:8];
                        SPI_LOAD    <= 1'b1;
                        oled_dc_n   <= 1'b1;
                            if(SPI_DONE)
                       begin
                           COLUMNCOUNTER <= COLUMNCOUNTER+1;
                           SPI_LOAD     <= 1'b0;
                           state        <=  WAIT_SPI;
                              if(ByteCounter != 1)
                               begin 
                                   ByteCounter <= ByteCounter -1;
                                   NextState   <= SEND_DATA;
                               end 
                               else 
                                begin  
                                   NextState   <= DONE;
                                   SendDone    <= 1'b1;
                                end
                       end
                        
                   end   
                   
                   
                   
                   /*   FULL_DISPLAY:
                    begin
                      SPI_DATA <= 'hA5;
                      SPI_LOAD <= 1'b1;
                        if(SPI_DONE)
                       begin
                           SPI_LOAD    <= 1'b0;
                           state       <=  WAIT_SPI;
                           NextState  <=  DONE;
                       end
                     end*
                      DONE:
                    begin
                        state   <= DONE;
                    end  */ 
       endcase
        
        
        end 
   
   
   end 
   DELAY_GENERATOR  D_G
   (
       .clock(clock),
       .Delay_Enable(StartDelay),
       .Delay_Done(DelayDone)
   );
   
   SPI_INTERFACE   SPI_Control(
  
                  .clock(clock),                               //on board zynq clock(100 MHz ) 
                  .reset(reset),
                  .data_in(SPI_DATA),
                  .load_data(SPI_LOAD),                        //signal indicates new dara for transmission
 
                 .Done_Send(SPI_DONE),                         // signal indicates data has been sent over  spi_interface
                 .Spi_Clock(oled_spi_clk),                     //10MHz clock 
                 .Spi_Data (oled_spi_data)
                    
                     );
                     
   CHARACTER_ROM   CHAR   (
                               .addr(SendData),
                               .data(CharBitMap) 
                            );
                     
endmodule

