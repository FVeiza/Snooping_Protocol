/*
	CEFET-MG
	Disciplina de Laboratório de Arquitetura e Organização de Computadores II
	Data: 06/02/2022
	Aluno: Fernando Veizaga e Alanis Castro
*/

module memory(writeEn, tagIn, dataIn, dataOut, MEM100, MEM110);

	input writeEn;
	input [11:0] tagIn;
	input [15:0] dataIn;
	
	output reg [15:0] dataOut, MEM100, MEM110;
	
	reg [15:0] mem['h130:'h0];
	
	initial begin
		dataOut = 16'b0;
		mem['h100] = 16'b0000000000010000;	//0000 0000 0001 0000 -> 0010
		mem['h108] = 16'b0000000000001000;	//0000 0000 0000 1000 -> 0008
		mem['h110] = 16'b0000000000010000;	//0000 0000 0001 0000 -> 0010
		mem['h118] = 16'b0000000000011000;	//0000 0000 0001 1000 -> 0018
		mem['h120] = 16'b0000000000100000;	//0000 0000 0010 0000 -> 0020
		mem['h128] = 16'b0000000000101000;	//0000 0000 0010 1000 -> 0028
		mem['h130] = 16'b0000000000110000;	//0000 0000 0011 0000 -> 0030
		MEM100 = mem['h100];
		MEM110 = mem['h110];
	end
	
	always@(*)
	begin
		MEM100 = mem['h100];
		MEM110 = mem['h110];
		
		dataOut = 16'b0;
		if(writeEn == 1'b1)
		begin
			mem[tagIn] = dataIn;
		end
		else begin
			dataOut = mem[tagIn];
		end
	end

endmodule
