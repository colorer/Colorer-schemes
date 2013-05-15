// 5.02.98      - date of creation
// Verilog HDL for "btx3_v3", "DMA" "functional"

module DMA(InSysClk, DMA_BusReq, BusGnt, DMA_Sel, DMA_Ack, DMA_IntReq, DMA_IntAck, ADInput, DMA_ADOutput, DMA_ADOutEn, SRd, SWr, InRun, InAdr, SysReset, Ack, Berr, DMA_Rd, DMA_Wr, DMA_Burst, DMA_ALE, DMA_DataEn, DMA_Cycle, DMA_Adr3_2, ADPInput, DMA_ADPOutput, DMA_ADPOutEn) ;
input   InSysClk;
output  DMA_BusReq;
reg     DMA_BusReq;
input   BusGnt;
input   DMA_Sel;
output  DMA_Ack;
output  DMA_IntReq;
input   DMA_IntAck;
input   [31:0]  ADInput;
output  [31:0]  DMA_ADOutput;
output  DMA_ADOutEn;
input   SRd, SWr, InRun;
input   [5:2]   InAdr;
input   SysReset;
input   Ack, Berr;
output  DMA_Rd, DMA_Wr, DMA_ALE, DMA_DataEn, DMA_Burst;
output  DMA_Cycle;
output  [1:0]   DMA_Adr3_2;
input   [3:0]   ADPInput;
output  [3:0]   DMA_ADPOutput;
output          DMA_ADPOutEn;

reg     [31:0]  InitAdr_A, InitAdr_B, InitTransfLengh;
wire    [31:0]  CurrentAdr_A, CurrentAdr_B, CurrentTransfLengh;
reg     [7:0]   BurstLengh, TimeOutLengh;
wire    [31:0]  RegOut;
wire    [31:0]  StatusRegOut;
reg     [31:0]  StoreReg, DataOut;
reg     [3:0]   StoreParReg;
wire    WrReg;
reg     DMA_Ack, SDMA_DataEn, DMA_Burst, DMA_IntReq;
reg     SAck, SBerr, SEnd;
reg     [3:0]   state;
wire    AtoB, BtoA, DMAReg_Out, DelAfterRead, WordFill;
reg     WrState, RdState,  LoadTimeOut;
reg     LoadCounter, DMA_InProgress, TimeOutDone;
wire    Burst_Done,LoadBurst, BurstLengh_En, ParError, DMA_Done;
reg     BusErrFlag;

//
//********* state
parameter       IDLE            = 4'h0;
parameter       READ            = 4'h1;
parameter       WRITE           = 4'h2;
parameter       WAIT_ACK_Read   = 4'h3;
parameter       WAIT_ACK_Write  = 4'h4;
parameter       TIME_OUT        = 4'h5;
parameter       ERROR           = 4'h6;
parameter       STOP            = 4'h7;
parameter       DEL_AFTER_READ  = 4'h8;
parameter       BUS_REQ         = 4'h9;
//***********
wire    InitAdr_ASel    = (InAdr[5:2] == 4'h1) ; //0x4
wire    InitAdr_BSel    = (InAdr[5:2] == 4'h2) ; //0x8
wire    CurrentAdr_ASel = (InAdr[5:2] == 4'h3) ; //0xc
wire    CurrentAdr_BSel = (InAdr[5:2] == 4'h4) ; //0x10
wire    InitTransfLenghSel      = (InAdr[5:2] == 4'h5) ;//0x14
wire    CurrentTransfLenghSel   = (InAdr[5:2] == 4'h6) ;//0x18
wire    BurstLenghSel           = (InAdr[5:2] == 4'h7) ;//0x1c
wire    TimeOutLenghSel         = (InAdr[5:2] == 4'h8) ;//0x20
wire    StatusRegSel            = (InAdr[5:2] == 4'h0) ;//0x0

// read/write registers
// initAdrA
always @(posedge InSysClk)
        if(SysReset)    InitAdr_A       <= 32'h00000000;
        else
        if(WrReg & InitAdr_ASel)        InitAdr_A       <= {ADInput[31:2], 2'b00};
// initAdrB
always @(posedge InSysClk)
        if(SysReset)    InitAdr_B       <= 32'h00000000;
        else
        if(WrReg & InitAdr_BSel)        InitAdr_B       <= {ADInput[31:2], 2'b00};
//
// initTransfLengh
always @(posedge InSysClk)
        if(SysReset)    InitTransfLengh <= 32'h00000000;
        else
        if(WrReg & InitTransfLenghSel)  InitTransfLengh <= {ADInput[31:2], 2'b0};
//
// BurstLengh
always @(posedge InSysClk)
        if(SysReset)    BurstLengh      <= 8'h00;
        else
        if(WrReg & BurstLenghSel)       BurstLengh      <= ADInput[7:0];
// TimeOutLengh
always @(posedge InSysClk)
        if(SysReset)    TimeOutLengh    <= 8'h00;
        else
        if(WrReg & TimeOutLenghSel)     TimeOutLengh    <= ADInput[7:0];
//
reg     Status0,Status1,Status2,Status3,Status4,Status5,Status6, Status7,Status8,Status9, Status10,Status14,Status15;
always @(posedge InSysClk)
        if(SysReset)    begin                   
                        Status3 <= 0;
                        Status4 <= 0;
                        Status5 <= 0;
                        Status6 <= 0;
                        Status7 <= 0;
                        Status8 <= 0;
                        Status9 <= 0;
                        Status14        <= 0;
                        end
        else    
        if(WrReg & StatusRegSel)
                        begin   
                                Status3         <= ADInput[3];
                                Status4         <= ADInput[4];
                                Status5         <= ADInput[5];
                                Status6         <= ADInput[6];
                                Status7         <= ADInput[7];
                                Status8         <= ADInput[8];
                                Status9         <= ADInput[9];
                                Status14        <= ADInput[14];
                end
always @(posedge InSysClk)
        if(SysReset)    Status0 <= 0;
        else
        if(WrReg & StatusRegSel)        Status0 <= ADInput[0];
        else
        if((state == STOP) | (state == ERROR))  Status0 <= 0;
//
always @(posedge InSysClk)
        if(SysReset)    Status1 <= 0;
        else
        if(WrReg & StatusRegSel & ~ADInput)     Status1 <= 0;
        else
        if(BusErrFlag & (state == ERROR) & ((BtoA & RdState) | (AtoB & WrState)))       Status1 <= 1;
//
always @(posedge InSysClk)
        if(SysReset)    Status2 <= 0;
        else
        if(WrReg & StatusRegSel & ~ADInput)     Status2 <= 0;
        else
        if(BusErrFlag & (state == ERROR) & ((AtoB & RdState) | (BtoA & WrState)))       Status2 <= 1;
//
always @(posedge InSysClk)
        if(SysReset)    Status10        <= 0;
        else
        if(WrReg & StatusRegSel & ~ADInput)     Status10        <= 0;
        else
        if(ParError)    Status10        <= 1;
//
always @(posedge InSysClk)
        if(SysReset)    Status15        <= 0;
        else
        if(WrReg & StatusRegSel & ~ADInput)     Status15        <= 0;
        else
        if(DMA_IntAck)                          Status15        <= 0;
        else
        if(state == STOP)       Status15        <= 1;

assign  StatusRegOut = {Status15, Status14, 3'h0, Status10, Status9, Status8, Status7, Status6, Status5, Status4, Status3, Status2, Status1, Status0};          

assign  RegOut  = (DMAReg_Out & InitAdr_ASel) ? InitAdr_A : 32'hzzzzzzzz;
assign  RegOut  = (DMAReg_Out & InitAdr_BSel) ? InitAdr_B : 32'hzzzzzzzz;
assign  RegOut  = (DMAReg_Out & CurrentAdr_ASel) ? CurrentAdr_A : 32'hzzzzzzzz;
assign  RegOut  = (DMAReg_Out & CurrentAdr_BSel) ? CurrentAdr_B : 32'hzzzzzzzz;
assign  RegOut  = (DMAReg_Out & InitTransfLenghSel) ? InitTransfLengh : 32'hzzzzzzzz;
assign  RegOut  = (DMAReg_Out & CurrentTransfLenghSel) ? CurrentTransfLengh : 32'hzzzzzzzz;
assign  RegOut  = (DMAReg_Out & BurstLenghSel) ? {24'h000000, BurstLengh} : 32'hzzzzzzzz;
assign  RegOut  = (DMAReg_Out & TimeOutLenghSel) ? {24'h000000, TimeOutLengh} : 32'hzzzzzzzz;
assign  RegOut  = (DMAReg_Out & StatusRegSel) ? {16'h0000, StatusRegOut} : 32'hzzzzzzzz;
wire    BusPullDown     = ~DMAReg_Out;
assign  RegOut  = (BusPullDown) ? 32'h0 : 32'hz;
//************
assign  DMAReg_Out      = SRd & DMA_Sel;

//****************
assign  WrReg   = SWr & DMA_Sel & ~DMA_Ack;
always @(posedge InSysClk)
        DMA_Ack <= DMA_Sel;
//
//********
always @(InRun)
        if(~InRun)
                begin
                assign  DMA_Ack = 0;    
                end
        else    begin
                deassign        DMA_Ack;
                end
//******************************************************************
always @(posedge InSysClk)
if(SysReset)    state <= IDLE;
else
case(state)
IDLE:   begin
        if(Status0) state <= BUS_REQ;
        else state      <= IDLE;
        end
BUS_REQ:        
        if(~BusGnt | ~DMA_BusReq)       state   <= BUS_REQ;
        else
        if(RdState)     state <= READ;
        else                    state <= WRITE;  

READ:   if(ParError)    state   <= ERROR;
        else    state <= WAIT_ACK_Read;
WAIT_ACK_Read:
        if(SBerr)       state   <= ERROR;
        else
        if(~SAck)       state   <= WAIT_ACK_Read;
        else
        if(~WordFill)           
                if(DelAfterRead)        state   <= DEL_AFTER_READ;
                else                    state   <= READ;
        else    
                if(DelAfterRead)        state   <= DEL_AFTER_READ;
                else                    state   <= WRITE;
DEL_AFTER_READ: if(ParError)    state   <= ERROR;
                else
                if(WordFill)    state   <= WRITE;
                else            state   <= READ;

WRITE:  if(ParError)    state   <= ERROR;
        else    state   <= WAIT_ACK_Write;
WAIT_ACK_Write:
        if(SBerr)       state   <= ERROR;
        else
        if(~SAck)       state   <= WAIT_ACK_Write;
        else    
        if(~WordFill)
                state   <= WRITE;
        else                    
        if(~DMA_Done)   
                if(Burst_Done)  state   <= TIME_OUT;
                else
                state   <= READ;
        else
        state   <= STOP;                                                                                        
STOP:   state   <= IDLE;
ERROR:  state   <= STOP;
TIME_OUT:
        if(TimeOutDone) state   <= BUS_REQ;                             
        else            state   <= TIME_OUT;
endcase

//
assign  DelAfterRead    = ~Status8;

//********* counters
reg     LoadAdrCounters, IncAdrA_En, IncAdrB_En;
wire     TransfLengh_En;
wire    LoadAll = (Status0 & (state == IDLE) | SysReset);
always @(posedge InSysClk)
        begin
        LoadAdrCounters         <= LoadAll;
        DMA_InProgress          <= Status0 & BusGnt;
        IncAdrA_En      <= ~ParError & (AtoB & (state == READ)) | (BtoA & (state == WRITE)) | LoadAll;
        IncAdrB_En      <= (~ParError & ~Status4 & (BtoA & (state == READ))) | (~Status4 & (AtoB & (state == WRITE))) | LoadAll;
        end
assign          TransfLengh_En  = (~ParError & (state == READ) & AtoB) | ((state == WRITE) & BtoA & ~ParError) | LoadAdrCounters;

wire    EnAdr1  = Status6 & ~Status7;
wire    EnAdr0  = Status6 & Status5 & ~Status7;
wire    [7:0]   CurrentBurstLengh, CurrentTimeOut;

bt83DMAcounter32        IncAdr_ACounter(InSysClk, IncAdrA_En, LoadAdrCounters, InitAdr_A, CurrentAdr_A, 1'b0, 1'b0);
bt83DMAcounter32        IncAdr_BCounter(InSysClk, IncAdrB_En, LoadAdrCounters, InitAdr_B, CurrentAdr_B, EnAdr1, EnAdr0);

bt83DMAcounter32        TransfLenghCounter(InSysClk, TransfLengh_En, LoadAdrCounters, 32'h00000000, CurrentTransfLengh, 1'b0, 1'b0);

bt83DMAcounter8 BurstLenghCounter(InSysClk, BurstLengh_En, LoadBurst, 8'h00, CurrentBurstLengh);

bt83DMAcounter8 TimeOutCounter(InSysClk, 1'b1, LoadTimeOut, 8'h00, CurrentTimeOut);

assign  Burst_Done      = (CurrentBurstLengh == BurstLengh);
assign  LoadBurst       = LoadAll | ((state == TIME_OUT) & TimeOutDone) ;
assign  BurstLengh_En   = LoadAll | ((state == TIME_OUT) & TimeOutDone) 
                        | ((state == READ)& AtoB) | (BtoA & (state == WRITE));
assign  DMA_Done        = (CurrentTransfLengh[31:2] == InitTransfLengh[31:2]); 

always @(posedge InSysClk)
        begin
        TimeOutDone     <= (CurrentTimeOut == TimeOutLengh);
        end
// Count En
always @(posedge InSysClk)
        begin
        LoadTimeOut     <= SysReset 
                        | (state != TIME_OUT);
        end
// ****** WordFill
reg     [1:0]   BtCounter;
assign  AtoB    = ~Status3;
assign  BtoA    = Status3;
assign  WordFill = (RdState & AtoB) | (WrState & BtoA) 
                | (RdState & BtoA & (BtCounter == 0))
                | (WrState & AtoB & (BtCounter == 0));

always @(posedge InSysClk)
        begin
        if(SysReset | (state == IDLE) | ParError)       BtCounter <= 2'b00;
        if (((state == READ) & BtoA) | ((state == WRITE) & AtoB))
         case({Status6, Status5})
                2'b00:  BtCounter       <= 0;
                2'b10:  BtCounter       <= BtCounter + 2;
                2'b11:  BtCounter       <= BtCounter + 1;
                2'b01:  BtCounter       <= BtCounter;   
         endcase
        end
//******
always @(posedge InSysClk)
        begin
        if ((state == IDLE) | (state == WAIT_ACK_Read) | (state == WAIT_ACK_Write) | (state == READ) | (state == WRITE))
                begin
                RdState <= (state == IDLE) | (state == READ) | (state == WAIT_ACK_Read & (~SEnd | ~WordFill)) | (state == WAIT_ACK_Write & SEnd & WordFill) ;
                WrState <= (state == WRITE) | (state == WAIT_ACK_Read & SEnd & WordFill) | (state == WAIT_ACK_Write & (~SEnd | ~WordFill)) ;
                end
        end
//******* Data Path
//read
always @(posedge InSysClk)
        begin
        if(state == IDLE)       begin   StoreReg        <= 32'h0;
                                        StoreParReg     <= 4'h0;
                                end
        else
        if((state == WAIT_ACK_Read) & SAck)
                if(AtoB)
                        begin   StoreReg        <= ADInput;
                                StoreParReg     <= ADPInput;
                        end     
                else
        case({Status6, Status5})
2'b00:          begin   StoreReg        <= ADInput;
                        StoreParReg     <= ADPInput;
                end
2'b10:          if(BtCounter == 2'h2)   
                    if(Status7|Status4) begin StoreReg[31:16]<= ADInput[31:16];
                                        StoreParReg[3:2]<= ADPInput[3:2];
                                end     
                    else        begin   StoreReg[31:16] <= ADInput[31:16];
                                        StoreParReg[3:2]<= ADPInput[3:2];
                                end
                else
                if(BtCounter == 2'h0)   
                   if(Status7|Status4)  begin StoreReg[15:0]<= ADInput[31:16];
                                        StoreParReg[1:0]<= ADPInput[3:2];
                                end
                    else        begin   StoreReg[15:0]  <= ADInput[15:0];
                                        StoreParReg[1:0]<= ADPInput[1:0];
                                end
2'b11:          case(BtCounter)
        2'b01:  if(Status7|Status4)     begin StoreReg[31:24]<=ADInput[31:24];
                                        StoreParReg[3]  <= ADPInput[3];
                                end
                else            begin   StoreReg[31:24] <= ADInput[31:24];
                                        StoreParReg[3]  <= ADPInput[3];
                                end
        2'b10:  if(Status7|Status4)     begin StoreReg[23:16] <= ADInput[31:24];
                                        StoreParReg[2]  <= ADPInput[3];
                                end     
                else            begin   StoreReg[23:16] <= ADInput[23:16];
                                        StoreParReg[2]  <= ADPInput[2];
                                end
        2'b11:  if(Status7|Status4)     begin StoreReg[15:8] <= ADInput[31:24];
                                        StoreParReg[1]  <= ADPInput[3];
                                end
                else            begin   StoreReg[15:8]  <= ADInput[15:8];
                                        StoreParReg[1]  <= ADPInput[1];
                                end
        2'b00:  if(Status7|Status4)     begin StoreReg[7:0] <= ADInput[31:24];
                                        StoreParReg[0]  <= ADPInput[3];
                                end
                else            begin   StoreReg[7:0]   <= ADInput[7:0];
                                        StoreParReg[0]  <= ADPInput[0];
                                end
                endcase
        endcase
        end
//*** BE
wire    [3:0]   BE;
assign  BE[0] = (AtoB & (state == READ)) |
                (BtoA & (state == WRITE)) |
                (
                ((AtoB & (state == WRITE)) | (BtoA & (state == READ))) 
                & ((~Status6 & ~Status5) 
                | (Status6 & ~Status5 & ~Status4 & ~Status7 & (BtCounter == 2'h2)) 
                | (Status6 & Status5 & ~Status4 & ~Status7 & (BtCounter == 2'h3)))
                );
assign  BE[1] = (AtoB & (state == READ)) |
                (BtoA & (state == WRITE)) |
                (
                ((AtoB & (state == WRITE)) | (BtoA & (state == READ))) 
                & ((~Status6 & ~Status5) 
                | (Status6 & ~Status5 & ~Status4 & ~Status7 & (BtCounter == 2'h2)) 
                | (Status6 & Status5 & ~Status4 & ~Status7 & (BtCounter == 2'h2)))
                );
assign  BE[2] = (AtoB & (state == READ)) |
                (BtoA & (state == WRITE)) |
                (
                ((AtoB & (state == WRITE)) | (BtoA & (state == READ))) 
                & ((~Status6 & ~Status5) | (Status6 & ~Status5 & (BtCounter == 2'h0)) | (Status6 & Status5 & (BtCounter == 2'h1))
                | (Status6 & ~Status5 & Status4) 
                | (Status6 & ~Status5 & Status7)));

assign  BE[3] = (AtoB & (state == READ)) |
                (BtoA & (state == WRITE)) |
                (
                ((AtoB & (state == WRITE)) | (BtoA & (state == READ))) 
                & ((~Status6 & ~Status5) | (Status6 & ~Status5 & (BtCounter == 2'h0)) | (Status6 & Status5 & (BtCounter == 2'h0))
                | (Status6 & ~Status5 & Status7)
                | (Status6 & ~Status5 & Status4)
                | (Status6 & Status5 & Status4)
                | (Status6 & Status5 & Status7)));

// write
always @(posedge InSysClk)
 if(SysReset)   DataOut <= 31'h0;
 else   
 if(state == WRITE)
 begin
        if(BtoA)
        DataOut <= StoreReg;
        else
 case({Status6, Status5})
2'b00:  DataOut <= StoreReg;
2'b10:  if(~Status7 & ~Status4) DataOut <= StoreReg;
        else            
        case(BtCounter)
                2'b00:  DataOut <= StoreReg;
                2'b10:  DataOut <= {StoreReg[15:0], StoreReg[15:0]};
        endcase
2'b11:  if(~Status7 & ~Status4)         DataOut <= StoreReg;
        else
        case(BtCounter)
                2'b00:  DataOut <= StoreReg;
                2'b01:  DataOut <= {StoreReg[23:16], StoreReg[23:0]};
                2'b10:  DataOut <= {StoreReg[15:0], StoreReg[15:0]};
                2'b11:  DataOut <= {StoreReg[7:0], StoreReg[23:0]};
        endcase         
 endcase         
 end
// BE

//
always @(negedge InSysClk)      
        begin
        SAck    <= Ack;
        SBerr   <= Berr;
        SEnd    <= Ack | Berr;
        if((state == IDLE) | SBerr)
        BusErrFlag      <= SBerr;
        end
//
reg     SDMA_Rd, SDMA_Wr, DMA_ALE, ResRead, ResWrite, ResALE;
always @(negedge InSysClk)
begin
SDMA_Rd <= ((state == READ) | (state == WAIT_ACK_Read)) & ~ParError;
SDMA_Wr <= ((state == WRITE) | (state == WAIT_ACK_Write)) & ~ParError;
DMA_ALE <= ((state == READ) | (state == WRITE)) & ~ParError ;

end
//
reg     DMA_DataOutEn;
always  @(posedge InSysClk)
        begin
        ResRead         <= (state == WAIT_ACK_Read) & SEnd;
        ResWrite        <= (state == WAIT_ACK_Write) & SEnd;
        ResALE          <= (state == READ) | (state == WRITE);
        SDMA_DataEn     <= ((state == READ) & ~ParError) | ((state == WAIT_ACK_Read) & ~SEnd);
        DMA_Burst       <= 0;
        DMA_IntReq      <=  Status14 & Status15;

        end
assign  DMA_DataEn      = SDMA_DataEn & ~DMA_ALE;

/*
always @(ResRead)
        if(ResRead)     assign  DMA_Rd  = 0;
        else            deassign DMA_Rd;
always @(ResWrite)
        if(ResWrite)    assign  DMA_Wr  = 0;
        else            deassign DMA_Wr;
*/
always @(ResALE)
        if(ResALE)      assign  DMA_ALE = 0;
        else            deassign        DMA_ALE;
//
wire    DMA_Rd, DMA_Wr, ResReadAsync, ResWriteAsync;
assign  ResWriteAsync   = ResWrite & SEnd;
assign  ResReadAsync    = ResRead & SEnd;
assign  DMA_Rd  = SDMA_Rd & ~ResReadAsync;
assign  DMA_Wr  = SDMA_Wr & ~ResWriteAsync;

//
wire    [31:0]  AdrOut;
assign  AdrOut  = (AtoB & (state== READ)) | (BtoA & (state == WRITE)) ? CurrentAdr_A : CurrentAdr_B;
assign  DMA_ADOutput    = (DMA_ALE) ? {AdrOut[31:4], ~BE} : (DMAReg_Out) ? RegOut : DataOut;
assign  DMA_ADOutEn     = DMA_ALE | DMA_DataOutEn | DMAReg_Out; 
//
reg     [1:0]   DMA_Adr3_2;
always @(negedge InSysClk)
        begin
        if((state == READ) | (state == WRITE))
        DMA_Adr3_2      <=  AdrOut[3:2];

        DMA_DataOutEn   <= (((state == WRITE) & ~ParError) | (state == WAIT_ACK_Write));

        end
//
assign  DMA_Cycle       = (DMA_BusReq & BusGnt);
always @(posedge InSysClk)
        DMA_BusReq      <= (state == BUS_REQ) | (state == READ) | (state == WAIT_ACK_Read) | (state == WRITE) | (state == WAIT_ACK_Write) | (state == DEL_AFTER_READ) | (state == ERROR);

//*********** parity section
wire    DMA_ParErr0, DMA_ParErr1, DMA_ParErr2, DMA_ParErr3;
assign  DMA_ADPOutEn    = DMA_DataOutEn & ~DMA_ALE;

assign  DMA_ADPOutput[0]        = ^DataOut[7:0];
assign  DMA_ADPOutput[1]        = ^DataOut[15:8];
assign  DMA_ADPOutput[2]        = ^DataOut[23:16];
assign  DMA_ADPOutput[3]        = ^DataOut[31:24];
//
assign  DMA_ParErr3     = ^({StoreReg[31:24], StoreParReg[3]});
assign  DMA_ParErr2     = ^({StoreReg[23:16], StoreParReg[2]});
assign  DMA_ParErr1     = ^({StoreReg[15:8], StoreParReg[1]});
assign  DMA_ParErr0     = ^({StoreReg[7:0], StoreParReg[0]});

assign  ParError        = Status9 & (DMA_ParErr0 | DMA_ParErr1 | DMA_ParErr2 | DMA_ParErr3);

endmodule
