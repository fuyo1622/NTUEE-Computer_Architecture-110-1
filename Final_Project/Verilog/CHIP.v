// Your code
module CHIP(clk,
            rst_n,
            // For mem_D
            mem_wen_D,
            mem_addr_D,
            mem_wdata_D,
            mem_rdata_D,
            // For mem_I
            mem_addr_I,
            mem_rdata_I);

    input         clk, rst_n ;
    // For mem_D
    output        mem_wen_D  ;
    output [31:0] mem_addr_D ;
    output [31:0] mem_wdata_D;
    input  [31:0] mem_rdata_D;
    // For mem_I
    output [31:0] mem_addr_I ;
    input  [31:0] mem_rdata_I;
    
    //---------------------------------------//
    // Do not modify this part!!!            //
    // Exception: You may change wire to reg //
    reg    [31:0] PC          ;              //
    wire   [31:0] PC_nxt      ;              //
    wire          regWrite    ;              //
    wire   [ 4:0] rs1, rs2, rd;              //
    wire   [31:0] rs1_data    ;              //
    wire   [31:0] rs2_data    ;              //
    wire   [31:0] rd_data     ;              //
    //---------------------------------------//

    assign rs1 = mem_rdata_I[19:15];
    assign rs2 = mem_rdata_I[24:20];
    assign rd = mem_rdata_I[11:7];
    assign mem_addr_I = PC;
    
    // Todo: other wire/reg
    reg [31:0] read_data;
    assign rd_data = mem_rdata_D;
    wire [31:0] imm;
    wire [31:0] addr_D;
    wire branch;
    wire mem_to_reg;
    wire [2:0] alu_op;
    wire alu_src;
    wire usepc_src;
    wire jump;
    wire jump_control;
    wire [3:0] alu_inst;
    wire [31:0] rs1_data_mux,rs2_data_mux;
    wire [31:0] imm_after_shift;
    wire [31:0] pc_next_0, pc_next_1,PC_normal,jump_data1,jump_src,rd_temp;
    wire [31:0] alu_out;
    wire alu_zero;
    wire pc_control;
    wire use_D;
    assign mem_addr_D = addr_D;
    integer next = 4;
    assign mem_wdata_D = rs2_data;
    wire mul_ready;
    wire [31:0] mul_output;
    wire [31:0] rd_data_1;
    wire doing_mul;
    wire mul_op;


    //---------------------------------------//
    // Do not modify this part!!!            //
    reg_file reg0(                           //
        .clk(clk),                           //
        .rst_n(rst_n),                       //
        .wen(regWrite),                      //
        .a1(rs1),                            //
        .a2(rs2),                            //
        .aw(rd),                             //
        .d(rd_data),                         //
        .q1(rs1_data),                       //
        .q2(rs2_data));                      //
    //---------------------------------------//
    
    // Todo: any combinational/sequential circuit
    Control Control(
        .inst_i(mem_rdata_I[6:0]), 
        .branch(branch),
        .wen(mem_wen_D),
        .mem_to_reg(mem_to_reg), 
        .alu_op(alu_op), 
        .alu_src(alu_src),
        .usepc_src(usepc_src), 
        .reg_w(regWrite),
        .jump(jump),
        .jump_control(jump_control),
        .use_D(use_D)
        );


    ALU_Control ALU_Control(
        .inst_i(mem_rdata_I), 
        .alu_op(alu_op),
        .alu_inst(alu_inst), 
        .mul_op(mul_op)       
        );

    imm_gen imm_gen(
        .inst_i(mem_rdata_I),
        .imm_o(imm)
        );

    BasicALU BasicALU(
        .data1_i(rs1_data_mux), 
        .data2_i(rs2_data_mux), 
        .alu_inst(alu_inst), 
        .data_o(alu_out), 
        .zero_o(alu_zero)
        );

    MUX32 r2(
        .data1_i(rs2_data), 
        .data2_i(imm), 
        .select_i(alu_src), 
        .data_o(rs2_data_mux)
        );

    MUX32 r1(
        .data1_i(rs1_data), 
        .data2_i(PC), 
        .select_i(usepc_src),
        .data_o(rs1_data_mux)
        );

    Shift_Left_One_32 imm_shift(
        .data_i(imm),
        .data_o(imm_after_shift)
        );

    Adder pc_and_4(
        .src1_i(PC),
        .src2_i(next),
        .sum_o(pc_next_0)
        );

    Adder pc_and_imm(
        .src1_i(PC),
        .src2_i(imm_after_shift),
        .sum_o(pc_next_1)
        );

    and_gate branch_and_zero(
        .data1_i(branch),
        .data2_i(alu_zero),
        .data_o(pc_control)
        );

    MUX32 pc_mux1(
        .data1_i(pc_next_0), 
        .data2_i(pc_next_1), 
        .select_i(pc_control), 
        .data_o(PC_normal)        
        );

    MUX32 pc_rs(
        .data1_i(PC),
        .data2_i(rs1_data),
        .select_i(jump_control),
        .data_o(jump_data1)
        );

    Adder jump_and_imm(
        .src1_i(jump_data1),
        .src2_i(imm),
        .sum_o(jump_src)
        );

    MUX32 pc_mux2(
        .data1_i(PC_normal), 
        .data2_i(jump_src), 
        .select_i(jump), 
        .data_o(PC_nxt)        
        );


    MUX32 alu_or_memory(
        .data1_i(alu_out), 
        .data2_i(mem_rdata_D), 
        .select_i(mem_to_reg), 
        .data_o(rd_temp)
        );

    MUX32 jump_or_not(
        .data1_i(rd_temp), 
        .data2_i(pc_next_0), 
        .select_i(jump), 
        .data_o(rd_data_1)
        );

    MUX32 before_D(
        .data1_i({32{1'b0}}), 
        .data2_i(alu_out), 
        .select_i(use_D), 
        .data_o(addr_D)
        );

    mul mul(
        .clk(clk),
        .rst_n(rst_n),
        .valid(mul_op),
        .ready(mul_ready),
        .in_A(rs1_data_mux),
        .in_B(rs2_data_mux),
        .doing_mul(doing_mul),
        .out(mul_output)
        );

    MUX32 rd_final(
        .data1_i(rd_data_1), 
        .data2_i(mul_output), 
        .select_i(mul_op), 
        .data_o(rd_data)
        );







    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            PC <= 32'h00010000; // Do not modify this value!!!
            
        end
        else begin
            if (!doing_mul) begin
                PC <= PC_nxt;
            end
            else begin
                PC <= PC;
            end
            
        end
    end
endmodule

module imm_gen(inst_i, imm_o);

    input  [31:0] inst_i;
    output [31:0] imm_o;

    reg [31:0] imm_o;

    always @(inst_i)
    begin
        if (inst_i[6:0] == 7'b0010011 || inst_i[6:0] == 7'b1100111)
        begin
            imm_o[11:0] = inst_i[31:20];
            imm_o = {{20{imm_o[11]}},imm_o[11:0]};
        end
        else if (inst_i[6:0] == 7'b0100011)
        begin
            imm_o[4:0] = inst_i[11:7];
            imm_o[11:5] = inst_i[31:25];
            imm_o = {{20{imm_o[11]}},imm_o[11:0]};
        end
        else if (inst_i[6:0] == 7'b0000011)
        begin
            imm_o[11:0] = inst_i[31:20];
            imm_o = {{20{imm_o[11]}},imm_o[11:0]};            
        end
        else if (inst_i[6:0] == 7'b1100011)
        begin
            imm_o[4:1] = inst_i[11:8];
            imm_o[10:5] = inst_i[30:25];
            imm_o[11] = inst_i[7];
            imm_o[12] = inst_i[31];
            imm_o = {{20{imm_o[12]}},imm_o[12:1]};
        end
        else if (inst_i[6:0] == 7'b0010111)
        begin 
            imm_o[31:12] = inst_i[31:12];
            imm_o = {imm_o[31:12],{12{1'b0}}};
        end
        else if (inst_i[6:0] == 7'b1101111)
        begin
            imm_o[10:1] = inst_i[30:21];
            imm_o[11] = inst_i[20];
            imm_o[19:12] = inst_i[19:12];
            imm_o[20] = inst_i[31];
            imm_o = {{11{imm_o[20]}},imm_o[20:1],1'b0};
        end
        else imm_o = {32{1'b0}};
    end

endmodule

module Control(inst_i, branch, wen, mem_to_reg, alu_op, alu_src, usepc_src, reg_w, jump,jump_control, use_D);
    input [6:0] inst_i;
    output branch, wen, mem_to_reg, alu_src, reg_w, usepc_src,jump,jump_control,use_D;
    output [2:0] alu_op;

    reg branch, wen, mem_to_reg,alu_src,reg_w,usepc_src,jump,jump_control,use_D;
    reg [2:0] alu_op;

    always @(inst_i)
    begin
        if (inst_i[6:0] == 7'b0010011) // i without lw and jalr
        begin
            branch = 1'b0;
            wen = 1'bx;
            mem_to_reg = 1'b0;
            alu_src = 1'b1;
            usepc_src = 1'b0;
            reg_w = 1'b1;
            alu_op = 3'b011;
            jump = 1'b0;
            jump_control = 1'b0;
            use_D = 1'b0;
        end
        else if (inst_i[6:0] == 7'b0110011) // r
        begin
            branch = 1'b0;
            wen = 1'bx;
            mem_to_reg = 1'b0;
            alu_src = 1'b0;
            usepc_src = 1'b0;
            reg_w = 1'b1;
            alu_op = 3'b010;
            jump = 1'b0;
            jump_control = 1'b0;
            use_D = 1'b0;
        end
        else if (inst_i[6:0] == 7'b1100011) // beq
        begin
            branch = 1'b1;
            wen = 1'bx;
            mem_to_reg = 1'b0;
            alu_src = 1'b0;
            usepc_src = 1'b0;
            reg_w = 1'b0;
            alu_op = 3'b001;
            jump = 1'b0;
            jump_control = 1'b0;
            use_D = 1'b0;
        end
        else if (inst_i[6:0] == 7'b0000011) // lw
        begin
            branch = 1'b0;
            wen = 1'b0;
            mem_to_reg = 1'b1;
            alu_src = 1'b1;
            usepc_src = 1'b0;
            reg_w = 1'b1;
            alu_op = 3'b000;
            jump = 1'b0;
            jump_control = 1'b0;
            use_D = 1'b1;
        end
        else if (inst_i[6:0] == 7'b0100011) // sw
        begin
            branch = 1'b0;
            wen = 1'b1;
            mem_to_reg = 1'bx;
            alu_src = 1'b1;
            usepc_src = 1'b0;
            reg_w = 1'b0;
            alu_op = 3'b000;
            jump = 1'b0;
            jump_control = 1'b0;
            use_D = 1'b1;
        end
        else if (inst_i[6:0] == 7'b0010111) // auipc
        begin 
            branch = 1'b0;
            wen = 1'bx;
            mem_to_reg = 1'b0;
            alu_src = 1'b1;
            usepc_src = 1'b1;
            reg_w = 1'b1;
            alu_op = 3'b011;
            jump = 1'b0;
            jump_control = 1'b0;
            use_D = 1'b0;
        end
        else if (inst_i[6:0] == 7'b1100111) // jalr
        begin
            branch = 1'b0;
            wen = 1'bx;
            mem_to_reg = 1'b0;
            alu_src = 1'b1;
            usepc_src = 1'b0;
            reg_w = 1'b1;
            alu_op = 3'b000;
            jump = 1'b1; // jump
            jump_control = 1'b1; // use rs
            use_D = 1'b0;
        end
        else if (inst_i[6:0] == 7'b1101111) // jal
        begin
            branch = 1'b0;
            wen = 1'bx;
            mem_to_reg = 1'b0;
            alu_src = 1'b1;
            usepc_src = 1'b0;
            reg_w = 1'b1;
            alu_op = 3'b000;
            jump = 1'b1; // jump
            jump_control = 1'b0; // not use rs
            use_D = 1'b0;
        end
        else begin
            branch = 1'bx;
            wen = 1'bx;
            mem_to_reg = 1'bx;
            alu_src = 1'bx;
            usepc_src = 1'bx;
            reg_w = 1'bx;
            alu_op = 3'bxxx;
            jump = 1'bx; // jump
            jump_control = 1'bx; // not use rs
            use_D = 1'bx;
        end
    end   

endmodule

module ALU_Control(inst_i, alu_op, alu_inst, mul_op);
    input [31:0] inst_i;
    input [2:0] alu_op;
    output [3:0] alu_inst;
    output mul_op;
    reg [3:0] alu_inst;
    reg mul_op;
    always@(*) begin
        case(alu_op)
            3'b001: alu_inst = 4'b0110; //beq
            3'b000: alu_inst = 4'b0010; //ld,sd
            3'b011: case(inst_i[14:12])
                3'b000: alu_inst = 4'b0010; //addi
                3'b010: alu_inst = 4'b0111; //slti
                3'b001: alu_inst = 4'b1001; //slli                
                3'b101: alu_inst = 4'b1000; //srli
                default: alu_inst = 4'b0000;
                endcase
            3'b010: case(inst_i[31:25])
                7'b0000000: alu_inst = 4'b0010; //add
                7'b0100000: alu_inst = 4'b0110; //sub
                7'b0000001: alu_inst = 4'b0000; //mul
                default: alu_inst = 4'b0000;
                endcase
            default: alu_inst = 4'b0000;
        endcase

        if (alu_op == 3'b010 && inst_i[31:25] == 7'b0000001) begin
            mul_op = 1'b1;
        end
        else begin
            mul_op = 1'b0;
        end

    end
endmodule

module MUX32(data1_i, data2_i, select_i, data_o);

    input [31:0] data1_i;
    input [31:0] data2_i;
    input select_i;
    output [31:0] data_o;

    assign data_o = (select_i == 1'b0)? data1_i : data2_i;

endmodule

module Adder(src1_i,src2_i,sum_o);
     

    input  [31:0]  src1_i;
    input  [31:0]  src2_i;
    output [31:0]  sum_o;
    wire    [31:0]     sum_o;
    assign sum_o = src1_i + src2_i;

endmodule

module Shift_Left_One_32(data_i,data_o);
                   
    input [31:0] data_i;
    output [31:0] data_o;
    assign data_o[31:1]= data_i[30:0] ;
    assign data_o[0]= 1'b0 ;
  
endmodule

module and_gate(data1_i,data2_i,data_o);
    input data1_i,data2_i;
    output data_o;
    assign data_o = data1_i && data2_i;

endmodule

module reg_file(clk, rst_n, wen, a1, a2, aw, d, q1, q2);
   
    parameter BITS = 32;
    parameter word_depth = 32;
    parameter addr_width = 5; // 2^addr_width >= word_depth
    
    input clk, rst_n, wen; // wen: 0:read | 1:write
    input [BITS-1:0] d;
    input [addr_width-1:0] a1, a2, aw;

    output [BITS-1:0] q1, q2;

    reg [BITS-1:0] mem [0:word_depth-1];
    reg [BITS-1:0] mem_nxt [0:word_depth-1];

    integer i;

    assign q1 = mem[a1];
    assign q2 = mem[a2];

    always @(*) begin
        for (i=0; i<word_depth; i=i+1)
            mem_nxt[i] = (wen && (aw == i)) ? d : mem[i];
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem[0] <= 0;
            for (i=1; i<word_depth; i=i+1) begin
                case(i)
                    32'd2: mem[i] <= 32'hbffffff0;
                    32'd3: mem[i] <= 32'h10008000;
                    default: mem[i] <= 32'h0;
                endcase
            end
        end
        else begin
            mem[0] <= 0;
            for (i=1; i<word_depth; i=i+1)
                mem[i] <= mem_nxt[i];
        end       
    end
endmodule

//module mulDiv(clk, rst_n, valid, ready, mode, in_A, in_B, out);
//endmodule

module BasicALU(data1_i, data2_i, alu_inst, data_o, zero_o);
    input [31:0] data1_i, data2_i;
    input [3:0] alu_inst;
    output [31:0] data_o;
    output zero_o;

    reg [31:0] data_reg;
    assign data_o = data_reg;

    assign zero_o = (data_reg == 32'b0)? 1'b1:1'b0;

    always @(data1_i or data2_i or alu_inst) begin
        case(alu_inst)
            4'b0010: data_reg = data1_i + data2_i;
            4'b0110: data_reg = data1_i - data2_i;
            4'b0111: data_reg = (data1_i < data2_i)? 1'b1:1'b0;
            4'b1000: data_reg = data1_i >> data2_i;
            4'b1001: data_reg = data1_i << data2_i;
            default: data_reg = {32{1'b0}};
        endcase
    end
endmodule

module mul(clk, rst_n, valid, ready, doing_mul, in_A, in_B, out);

    input         clk, rst_n;
    input         valid;
    output        ready,doing_mul;
    input  [31:0] in_A, in_B;
    output [31:0] out;

    // Definition of states
    parameter IDLE = 3'd0;
    parameter MUL  = 3'd1;
    parameter OUT  = 3'd2;

    // Todo: Wire and reg if needed
    reg  [ 2:0] state, state_nxt;
    reg  [ 4:0] counter, counter_nxt;
    reg  [63:0] shreg, shreg_nxt;
    reg  [31:0] alu_in, alu_in_nxt;
    reg  [32:0] alu_out;
    reg  [31:0] out;
    reg  [0:0] ready;
    reg [0:0] doing_mul;
    always @(*) begin
        if (state == 3'd2) begin
            out = shreg[31:0];
            ready = 1;
        end
        else begin
            out = 0;
            ready = 0;
        end
    end

    always @(*) begin
        case(state)
            IDLE: begin
                if (valid) begin
                    state_nxt = MUL;
                    doing_mul = 1;
                end
                else begin
                    state_nxt = IDLE;
                    doing_mul = 0;
                end
            end
            MUL : begin 
                if (counter != 5'd31) begin
                    state_nxt = MUL;
                    doing_mul = 1;
                end
                else begin
                    state_nxt = OUT;
                    doing_mul = 1;
                end
            end
            OUT : begin
                state_nxt = IDLE;
                doing_mul = 0;
            end
            default : begin
                state_nxt = IDLE;
                doing_mul = 0;
            end
        endcase
    end

    always @(*) begin
        case(state)
            MUL : begin
                counter_nxt = counter + 1;
            end
            default: begin
                counter_nxt = 0;
            end            
        endcase
    end

    always @(*) begin
        case(state)
            OUT : begin
                alu_in_nxt = 0;
            end
            default: begin           
                if (valid) begin
                    alu_in_nxt = in_B;
                end
                else begin
                    alu_in_nxt = alu_in;
                end
            end
        endcase
    end

    always @(*) begin
        case(state)
            MUL: begin
                if (shreg[0] == 1'b1) alu_out = alu_in;
                else alu_out = 0;
            end
            default: alu_out = 0;
        endcase
    end

    always @(*) begin
        case(state)
            IDLE: begin
                if (valid) begin
                    shreg_nxt = {32'b0,in_A};
                end
                else begin
                    shreg_nxt = 0;
                end
            end
            MUL: begin
                shreg_nxt = {shreg[63:32]+alu_out[31:0],shreg[31:0]} >> 1;
                if (shreg_nxt[62:31] < shreg[63:32]) shreg_nxt[63] = 1;
                else shreg_nxt[63] = 0;
            end
            default: begin
                shreg_nxt = 0;
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end
        else begin
            state <= state_nxt;
            counter <= counter_nxt;
            shreg <= shreg_nxt;
            alu_in <= alu_in_nxt;
        end
    end
endmodule