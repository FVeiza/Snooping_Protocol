/*
	CEFET-MG
	Disciplina de Laboratório de Arquitetura e Organização de Computadores II
	Data: 06/02/2022
	Aluno: Fernando Veizaga e Alanis Castro
*/

module barramento(clock);

	input clock;
	
	//sinais do barramento
	reg [31:0] instrucoes[8:0];
	reg [31:0] instruction;
	reg [11:0] tagMem;
	reg [15:0] dataInMem;
	reg busReadMiss, busWriteMiss, busInvalidate, barramentoDone;
	reg [11:0] tagBus, tagB;
	reg resetP0, resetP1, resetP3;
	wire instrDone, step1Done, step2Done, step3Done, step4Done, step5Done, sharedIn, writeEn;
	
	//sinais da cache de P0
	wire writeOutP0, readOutP0;
	wire [11:0] tagOutCPUP0;
	wire [15:0] dataOutP0;
	reg [2:0] stepP0;
	reg [27:0] blockInP0;
	
	wire [2:0] estadoAnteriorM1P0, estadoAnteriorM2P0;
	wire writeHitP0, writeMissP0, readHitP0, readMissP0, sharedOutP0, writeEnP0, step1DoneP0, step2DoneP0, step3DoneP0, step4DoneP0, step5DoneP0, instrDoneP0;
	wire [30:0] resultOutP0, cB0P0, cB2P0;
	wire [11:0] tagOutP0;
	wire [27:0] blockOutP0;	
	wire sendReadMissP0, sendWriteMissP0, sendWriteBackM1P0, sendWriteBackM2P0, sendInvalidateP0, sendAbortMemoryAccessP0;
	wire [2:0] proximoEstadoM1P0, proximoEstadoM2P0;	
	
	//sinais da cache de P1
	wire writeOutP1, readOutP1;
	wire [11:0] tagOutCPUP1;
	wire [15:0] dataOutP1;
	reg [2:0] stepP1;
	reg [27:0] blockInP1;
	
	wire [2:0] estadoAnteriorM1P1, estadoAnteriorM2P1;
	wire writeHitP1, writeMissP1, readHitP1, readMissP1, sharedOutP1, writeEnP1, step1DoneP1, step2DoneP1, step3DoneP1, step4DoneP1, step5DoneP1, instrDoneP1;
	wire [30:0] resultOutP1, cB0P1, cB2P1;
	wire [11:0] tagOutP1;
	wire [27:0] blockOutP1;	
	wire sendReadMissP1, sendWriteMissP1, sendWriteBackM1P1, sendWriteBackM2P1, sendInvalidateP1, sendAbortMemoryAccessP1;
	wire [2:0] proximoEstadoM1P1, proximoEstadoM2P1;
	
	//sinais da cache P3
	wire writeOutP3, readOutP3;
	wire [11:0] tagOutCPUP3;
	wire [15:0] dataOutP3;
	reg [2:0] stepP3;
	reg [27:0] blockInP3;
	
	wire [2:0] estadoAnteriorM1P3, estadoAnteriorM2P3;
	wire writeHitP3, writeMissP3, readHitP3, readMissP3, sharedOutP3, writeEnP3, step1DoneP3, step2DoneP3, step3DoneP3, step4DoneP3, step5DoneP3, instrDoneP3;
	wire [30:0] resultOutP3, cB0P3, cB2P3;
	wire [11:0] tagOutP3;
	wire [27:0] blockOutP3;	
	wire sendReadMissP3, sendWriteMissP3, sendWriteBackM1P3, sendWriteBackM2P3, sendInvalidateP3, sendAbortMemoryAccessP3;
	wire [2:0] proximoEstadoM1P3, proximoEstadoM2P3;
	
	
	wire [15:0] dataOutMem, MEM100, MEM110;
	
	assign instrDone = instrDoneP0 | instrDoneP1 | instrDoneP3;
	assign step1Done = step1DoneP0 | step1DoneP1 | step1DoneP3;
	assign step2Done = step2DoneP0 | step2DoneP1 | step2DoneP3;
	assign step3Done = step3DoneP0 | step3DoneP1 | step3DoneP3;
	assign step4Done = step4DoneP0 | step4DoneP1 | step4DoneP3;
	assign step5Done = step5DoneP0 | step5DoneP1 | step5DoneP3;
	assign sharedIn = sharedOutP0 | sharedOutP1 | sharedOutP3;
	assign writeEn = writeEnP0 | writeEnP1 | writeEnP3;
	
	integer counter;
	
	initial begin
		counter = 0;
		stepP0 = 3'b000;
		stepP1 = 3'b001;
		stepP3 = 3'b001;
		tagMem = 12'b0;
		dataInMem = 16'b0;
		busReadMiss = 1'b0; 
		busWriteMiss = 1'b0;
		busInvalidate = 1'b0;
		barramentoDone = 1'b0;
		resetP0 = 1'b0;
		resetP1 = 1'b0;
		resetP3 = 1'b0;
		
		instrucoes[0] = 32'b00010001000000000000000000000000;
		instrucoes[1] = 32'b01010001000000000000000000000000;
		instrucoes[2] = 32'b01100001000000000000000000110000;
		instrucoes[3] = 32'b00100001000000000000000001000000;
		instrucoes[4] = 32'b01010001000000000000000000000000;
		instrucoes[5] = 32'b01010001000100000000000000000000;
		instrucoes[6] = 32'b11100001000100000000000001100000;
		instrucoes[7] = 32'b01010001001100000000000000000000;
		instrucoes[8] = 32'b01100001001100000000000001000000;
		
		instruction = instrucoes[counter];
		tagB = instruction[27:16];
	end
	
	always@(posedge clock)
	begin
		if(instrDone == 1'b1)
		begin
			resetP0 = 1'b1;
			resetP1 = 1'b1;
			resetP3 = 1'b1;		
			barramentoDone = 1'b1;
		end
	
		else if(barramentoDone == 1'b1)
		begin
			counter = counter + 1;
			instruction = instrucoes[counter];
			tagB = instruction[27:16];
			tagMem = 12'b0;
			dataInMem = 16'b0;
			busReadMiss = 1'b0; 
			busWriteMiss = 1'b0;
			busInvalidate = 1'b0;
			barramentoDone = 1'b0;
			resetP0 = 1'b0;
			resetP1 = 1'b0;
			resetP3 = 1'b0;
			
			if(instruction[31:30] == 2'b00)
			begin
				stepP0 = 3'b000;
				stepP1 = 3'b001;
				stepP3 = 3'b001;
			end
			else if(instruction[31:30] == 2'b01)
			begin
				stepP0 = 3'b001;
				stepP1 = 3'b000;
				stepP3 = 3'b001;
			end
			else if(instruction[31:30] == 2'b11)
			begin
				stepP0 = 3'b001;
				stepP1 = 3'b001;
				stepP3 = 3'b000;
			end
		end
		
		else if(step5Done == 1'b1)
		begin
			if(instruction[31:30] == 2'b00)
			begin
				if(writeEnP0 == 1'b1)
				begin
					tagMem = blockOutP0[27:16];
					dataInMem = blockOutP0[15:0];
				end
				stepP0 = 3'b110;
			end
			
			else if(instruction[31:30] == 2'b01)
			begin
				if(writeEnP1 == 1'b1)
				begin
					tagMem = blockOutP1[27:16];
					dataInMem = blockOutP1[15:0];
				end
				stepP1 = 3'b110;
			end
			
			else if(instruction[31:30] == 2'b11)
			begin
				if(writeEnP3 == 1'b1)
				begin
					tagMem = blockOutP3[27:16];
					dataInMem = blockOutP3[15:0];
				end
				stepP3 = 3'b110;
			end
			
		end
		
		else if(step4Done == 1'b1)
		begin
			if(instruction[31:30] == 2'b00)
			begin
				if(writeEnP1 == 1'b1)
				begin
					tagMem = blockOutP1[27:16];
					dataInMem = blockOutP1[15:0];
				end
				
				else if(writeEnP3 == 1'b1)
				begin
					tagMem = blockOutP3[27:16];
					dataInMem = blockOutP3[15:0];
				end
				stepP0 = 3'b101;
			end
			
			else if(instruction[31:30] == 2'b01)
			begin
				if(writeEnP0 == 1'b1)
				begin
					tagMem = blockOutP0[27:16];
					dataInMem = blockOutP0[15:0];
				end
				
				else if(writeEnP3 == 1'b1)
				begin
					tagMem = blockOutP3[27:16];
					dataInMem = blockOutP3[15:0];
				end
				stepP1 = 3'b101;
			end
			
			else if(instruction[31:30] == 2'b11)
			begin
				if(writeEnP0 == 1'b1)
				begin
					tagMem = blockOutP0[27:16];
					dataInMem = blockOutP0[15:0];
				end
				
				else if(writeEnP1 == 1'b1)
				begin
					tagMem = blockOutP1[27:16];
					dataInMem = blockOutP1[15:0];
				end
				stepP3 = 3'b101;
			end
			
		end
		
		else if(step3Done == 1'b1)
		begin
			if(instruction[31:30] == 2'b00)
			begin
				if(sendAbortMemoryAccessP1 == 1'b1)
				begin
					blockInP0 = blockOutP1;
				end
				else if(sendAbortMemoryAccessP3 == 1'b1)
				begin
					blockInP0 = blockOutP3;
				end
				else begin
					tagMem = tagBus;
					blockInP0 = {tagBus,dataOutMem};
				end
				
				stepP1 = 3'b100;
				stepP3 = 3'b100;
			end
			
			else if(instruction[31:30] == 2'b01)
			begin
				if(sendAbortMemoryAccessP0 == 1'b1)
				begin
					blockInP1 = blockOutP0;
				end
				else if(sendAbortMemoryAccessP3 == 1'b1)
				begin
					blockInP1 = blockOutP3;
				end
				else begin
					tagMem = tagBus;
					blockInP1 = {tagBus,dataOutMem};
				end
				
				stepP0 = 3'b100;
				stepP3 = 3'b100;
			end
			
			else if(instruction[31:30] == 2'b11)
			begin
				if(sendAbortMemoryAccessP0 == 1'b1)
				begin
					blockInP3 = blockOutP0;
				end
				else if(sendAbortMemoryAccessP1 == 1'b1)
				begin
					blockInP3 = blockOutP1;
				end
				else begin
					tagMem = tagBus;
					blockInP3 = {tagBus,dataOutMem};
				end
				
				stepP0 = 3'b100;
				stepP1 = 3'b100;
			end
		end
		
		else if(step2Done == 1'b1)
		begin
			if(instruction[31:30] == 2'b00)
			begin
				busReadMiss = sendReadMissP0;
				busWriteMiss = sendWriteMissP0;
				busInvalidate = sendInvalidateP0;
				tagBus = tagOutP0;
				stepP1 = 3'b011;
				stepP3 = 3'b011;
			end
			
			else if(instruction[31:30] == 2'b01)
			begin
				busReadMiss = sendReadMissP1;
				busWriteMiss = sendWriteMissP1;
				busInvalidate = sendInvalidateP1;
				tagBus = tagOutP1;
				stepP0 = 3'b011;
				stepP3 = 3'b011;
			end
			
			else if(instruction[31:30] == 2'b11)
			begin
				busReadMiss = sendReadMissP3;
				busWriteMiss = sendWriteMissP3;
				busInvalidate = sendInvalidateP3;
				tagBus = tagOutP3;
				stepP0 = 3'b011;
				stepP1 = 3'b011;
			end
		end
		
		else if(step1Done == 1'b1)
		begin
			if(instruction[31:30] == 2'b00)
			begin
				stepP0 = 3'b010;
			end
			
			else if(instruction[31:30] == 2'b01)
			begin
				stepP1 = 3'b010;
			end
			
			else if(instruction[31:30] == 2'b11)
			begin
				stepP3 = 3'b010;
			end
		end

	end
	
	CPU p0(clock, instruction, resultOutP0, writeOutP0, readOutP0, tagOutCPUP0, dataOutP0);
	cacheP0 c0(clock, stepP0, writeOutP0, readOutP0, tagOutCPUP0, dataOutP0, estadoAnteriorM1P0, estadoAnteriorM2P0, writeHitP0, writeMissP0, readHitP0, readMissP0, busReadMiss, 
		busWriteMiss, busInvalidate, tagBus, tagB, sharedIn, blockInP0, sharedOutP0, writeEnP0, tagOutP0, blockOutP0, sendReadMissP0, sendWriteMissP0, sendWriteBackM1P0, sendWriteBackM2P0, 
		sendInvalidateP0, sendAbortMemoryAccessP0, proximoEstadoM1P0, proximoEstadoM2P0, step1DoneP0, step2DoneP0, step3DoneP0, step4DoneP0, step5DoneP0, instrDoneP0, resultOutP0, resetP0, 
		cB0P0, cB2P0);
	
	CPU1 p1(clock, instruction, resultOutP1, writeOutP1, readOutP1, tagOutCPUP1, dataOutP1);
	cacheP1 c1(clock, stepP1, writeOutP1, readOutP1, tagOutCPUP1, dataOutP1, estadoAnteriorM1P1, estadoAnteriorM2P1, writeHitP1, writeMissP1, readHitP1, readMissP1, busReadMiss, 
		busWriteMiss, busInvalidate, tagBus, tagB, sharedIn, blockInP1, sharedOutP1, writeEnP1, tagOutP1, blockOutP1, sendReadMissP1, sendWriteMissP1, sendWriteBackM1P1, sendWriteBackM2P1, 
		sendInvalidateP1, sendAbortMemoryAccessP1, proximoEstadoM1P1, proximoEstadoM2P1, step1DoneP1, step2DoneP1, step3DoneP1, step4DoneP1, step5DoneP1, instrDoneP1, resultOutP1, resetP1, 
		cB0P1, cB2P1);
		
	CPU3 p3(clock, instruction, resultOutP3, writeOutP3, readOutP3, tagOutCPUP3, dataOutP3);
	cacheP3 c3(clock, stepP3, writeOutP3, readOutP3, tagOutCPUP3, dataOutP3, estadoAnteriorM1P3, estadoAnteriorM2P3, writeHitP3, writeMissP3, readHitP3, readMissP3, busReadMiss, 
		busWriteMiss, busInvalidate, tagBus, tagB, sharedIn, blockInP3, sharedOutP3, writeEnP3, tagOutP3, blockOutP3, sendReadMissP3, sendWriteMissP3, sendWriteBackM1P3, sendWriteBackM2P3, 
		sendInvalidateP3, sendAbortMemoryAccessP3, proximoEstadoM1P3, proximoEstadoM2P3, step1DoneP3, step2DoneP3, step3DoneP3, step4DoneP3, step5DoneP3, instrDoneP3, resultOutP3, resetP3, 
		cB0P3, cB2P3);
	
	memory mem(writeEn, tagMem, dataInMem, dataOutMem, MEM100, MEM110);

endmodule
