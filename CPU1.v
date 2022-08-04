/*
	CEFET-MG
	Disciplina de Laboratório de Arquitetura e Organização de Computadores II
	Data: 06/02/2022
	Aluno: Fernando Veizaga e Alanis Castro
*/

module CPU1(clock, instruction, result, writeOut, readOut, tagOut, dataOut);

	input clock;
	input [31:0] instruction;
	input [30:0] result;
	
	output reg writeOut, readOut; 
	output reg [11:0] tagOut;
	output reg [15:0] dataOut;
	
	initial begin
		writeOut = 1'b0;
		readOut = 1'b0;
		tagOut = 12'b0;
		dataOut = 16'b0;
	end
	
	always@(clock)
	begin
		if(instruction[31:30] == 2'b01)
		begin
			writeOut <= instruction[29];
			readOut <= instruction[28];
			tagOut <= instruction[27:16];
			dataOut <= instruction[15:0];
		end
		
		else begin
			writeOut = 1'b0;
			readOut = 1'b0;
			tagOut = 12'b0;
			dataOut = 16'b0;
		end
	end

endmodule
