/*
	CEFET-MG
	Disciplina de Laboratório de Arquitetura e Organização de Computadores II
	Data: 06/02/2022
	Aluno: Fernando Veizaga e Alanis Castro
*/

module cacheP1(clock, step, writeIn, readIn, tagIn, dataIn, estadoAnteriorM1, estadoAnteriorM2, writeHit, writeMiss, readHit, readMiss, busReadMiss, busWriteMiss, busInvalidate, 
tagBus, tagB, sharedIn, blockIn, sharedOut, writeEn, tagOut, blockOut, sendReadMiss,sendWriteMiss, sendWriteBackM1, sendWriteBackM2, sendInvalidate, sendAbortMemoryAccess, 
proximoEstadoM1, proximoEstadoM2, step1Done, step2Done, step3Done, step4Done, step5Done, instrDone, resultOut, reset, cB0, cB2);
	
	input clock, writeIn, readIn, busReadMiss, busWriteMiss, busInvalidate, sharedIn, reset;
	input [11:0] tagIn, tagBus, tagB;
	input [15:0] dataIn;
	input [2:0] step;
	input [27:0] blockIn;
	
	output reg [2:0] estadoAnteriorM1, estadoAnteriorM2;
	output reg writeHit, writeMiss, readHit, readMiss, sharedOut, writeEn, step1Done, step2Done, step3Done, step4Done, step5Done, instrDone;
	output reg [30:0] resultOut, cB0, cB2;
	output reg [11:0] tagOut;
	output reg [27:0] blockOut;
	
	output wire sendReadMiss, sendWriteMiss, sendWriteBackM1, sendWriteBackM2, sendInvalidate, sendAbortMemoryAccess;
	
	output wire [2:0] proximoEstadoM1, proximoEstadoM2;
	
	integer i;
	
	reg [30:0] cache[3:0];
	
	initial begin
		//$display("entrou no initial");
		writeHit = 1'b0;
		writeMiss = 1'b0;
		readHit = 1'b0;
		readMiss = 1'b0;
		sharedOut = 1'b0;
		writeEn = 1'b0;
		blockOut = 28'b0;
		step1Done = 1'b0;
		step2Done = 1'b0;
		step3Done = 1'b0;
		step4Done = 1'b0;
		step5Done = 1'b0;
		instrDone = 1'b0; 
		resultOut = 31'b0;
		cache[0] = 31'b0000001000000000000000000010000;	//000 | 0001 0000 0000 | 0000 0000 0001 0000 -> B0, I, 100, 00 10
		cache[1] = 31'b0010001000010000000000001101000;	//001 | 0001 0000 1000 | 0000 0000 0110 1000 -> B1, M, 128, 00 68
		cache[2] = 31'b0000001000100000000000000010000;	//000 | 0001 0001 0000 | 0000 0000 0001 0000 -> B2, I, 110, 00 10
		cache[3] = 31'b0100001000110000000000000011000;	//010 | 0001 0001 1000 | 0000 0000 0001 1000 -> B3, S, 118, 00 18
	end
	
	always@(posedge clock)
	begin
		
		cB0 = cache[0];
		cB2 = cache[2];
		
		$display("entrou no always");
		
		if(reset == 1'b1)
		begin
			writeHit = 1'b0;
			writeMiss = 1'b0;
			readHit = 1'b0;
			readMiss = 1'b0;
			sharedOut = 1'b0;
			writeEn = 1'b0;
			blockOut = 28'b0;
			step1Done = 1'b0;
			step2Done = 1'b0;
			step3Done = 1'b0;
			step4Done = 1'b0;
			step5Done = 1'b0;
			instrDone = 1'b0;
		end
		
		else if(step == 3'b001)
		begin
			for(i = 0; i < 4; i = i + 1)
			begin
				if(cache[i][27:16] == tagB && cache[i][30:28] != 3'b000)
				begin
					sharedOut = 1'b1;
				end
			end
			step1Done = 1'b1;
		end
		
		
		
		else if(step == 3'b010)
		begin
			$display("entrou no step = 1");
			if(readIn == 1'b1)
			begin
				$display("entrou no if read in");
				
				if(tagIn == 12'b000100010000 || tagIn == 12'b000100110000)
				begin
					if(cache[2][27:16] == tagIn && cache[2][30:28] != 3'b000)
					begin
						readHit = 1'b1;
						resultOut = cache[2];
						instrDone = 1'b1;
					end
					
					else if(cache[2][27:16] != tagIn)
					begin
						readMiss = 1'b1;
						estadoAnteriorM1 = cache[2][30:28];
						tagOut = tagIn;
					end
					
					else if(cache[2][27:16] == tagIn && cache[2][30:28] == 3'b000)
					begin
						readMiss = 1'b1;
						estadoAnteriorM1 = 3'b000;
						tagOut = tagIn;
					end
				end
				
				for(i = 0; i < 4; i = i + 1)
				begin
					if(cache[i][27:16] == tagIn && cache[i][30:28] != 3'b000)
					begin
						$display("entrou no if read hit");
						readHit = 1'b1;
						resultOut = cache[i];
						instrDone = 1'b1;
					end
					
					else if(cache[i][27:16] == tagIn && cache[i][30:28] == 3'b000)
					begin
						readMiss = 1'b1;
						estadoAnteriorM1 = 3'b000;
						tagOut = tagIn;
					end
				end
			end
			
			else if(writeIn == 1'b1)
			begin
			
				if(tagIn == 12'b000100010000 || tagIn == 12'b000100110000)
				begin
					if(cache[2][27:16] == tagIn && cache[2][30:28] != 3'b000)
					begin
						writeHit = 1'b1;
						estadoAnteriorM1 = cache[2][30:28];
					end
						
					else if(cache[2][27:16] != tagIn)
					begin
						writeMiss = 1'b1;
						estadoAnteriorM1 = cache[2][30:28];
						tagOut = tagIn;
					end
						
					else if(cache[2][27:16] == tagIn && cache[2][30:28] == 3'b000)
					begin
						writeMiss = 1'b1;
						estadoAnteriorM1 = 3'b000;
						tagOut = tagIn;
					end
				end
				
				for(i = 0; i < 4; i = i + 1)
				begin
				
					if(cache[i][27:16] == tagIn && cache[i][30:28] != 3'b000)
					begin
						writeHit = 1'b1;
						estadoAnteriorM1 = cache[i][30:28];
					end
					
					else if(cache[i][27:16] == tagIn && cache[i][30:28] == 3'b000)
					begin
						writeMiss = 1'b1;
						estadoAnteriorM1 = 3'b000;
						tagOut = tagIn;
					end
				end

			end
			step2Done = 1'b1;
		end
		
		else if(step == 3'b011)
		begin
			for(i = 0; i < 4; i = i + 1)
			begin
				if(cache[i][27:16] == tagBus && cache[i][30:28] != 3'b000)
				begin
					blockOut = cache[i][27:0];
					estadoAnteriorM2 = cache[i][30:28];
				end
			end
			step3Done = 1'b1;
		end
		
		else if(step == 3'b100)
		begin
			if(sendAbortMemoryAccess == 1'b1)
			begin
				writeEn = 1'b1;
			end
			
			for(i = 0; i < 4; i = i + 1)
			begin
				if(cache[i][27:16] == tagBus)
				begin
					if(busInvalidate == 1'b1)
					begin
						cache[i][30:28] = proximoEstadoM2;
					end
					else begin
						cache[i][30:28] = proximoEstadoM2;
					end
				end
			end
			step4Done = 1'b1;
		end

	
		else if(step == 3'b101)
		begin
			if(sendWriteBackM1 == 1'b1)
			begin
				writeEn = 1'b1;
				for(i = 0; i < 4; i = i + 1)
				begin
					if(cache[i][27:16] == tagIn)
					begin
						blockOut = cache[i][27:0];
					end
				end
			end
			
			if(writeMiss == 1'b1)
			begin
				if(tagIn == 12'b000100010000 || tagIn == 12'b000100110000)
				begin
					cache[2] = {proximoEstadoM1, tagIn, dataIn};
					resultOut = {proximoEstadoM1, tagIn, dataIn};
				end
				
				else begin
					for(i = 0; i < 4; i = i + 1)
					begin
						if(cache[i][27:16] == blockIn[27:16])
						begin
							$display("alterou cache com write");
							cache[i] = {proximoEstadoM1, tagIn, dataIn};
							resultOut = {proximoEstadoM1, tagIn, dataIn};
						end
					end
				end
			end
			
			else if(writeHit == 1'b1)
			begin
				if(tagIn == 12'b000100010000 || tagIn == 12'b000100110000)
				begin
					cache[2] = {proximoEstadoM1, tagIn, dataIn};
					resultOut = {proximoEstadoM1, tagIn, dataIn};
				end
				
				else begin
					for(i = 0; i < 4; i = i + 1)
					begin
						if(cache[i][27:16] == tagIn)
						begin
							$display("alterou cache com write");
							cache[i] = {proximoEstadoM1, tagIn, dataIn};
							resultOut = {proximoEstadoM1, tagIn, dataIn};
						end
					end
				end
			end
			
			else if(readIn == 1'b1)
			begin
				if(tagIn == 12'b000100010000 || tagIn == 12'b000100110000)
				begin
					cache[2] = {proximoEstadoM1, blockIn};
					resultOut = {proximoEstadoM1, blockIn};
				end
				
				else begin
					for(i = 0; i < 4; i = i + 1)
					begin
						if(cache[i][27:16] == blockIn[27:16])
						begin
							$display("alterou cache com read, P0");
							cache[i] = {proximoEstadoM1, blockIn};
							resultOut = {proximoEstadoM1, blockIn};
						end
					end
				end
			end
			
			step5Done = 1'b1;
		end
		
		else if(step == 3'b110)
		begin
			instrDone = 1'b1;
		end
	end
	
	maquinaMESIcpu maquina1(estadoAnteriorM1, writeHit, readHit, writeMiss, readMiss, proximoEstadoM1, sendReadMiss, sendWriteMiss, sendInvalidate, sharedIn, sendWriteBackM1, reset);
	
	maquinaMESIbus maquina2(estadoAnteriorM2, busReadMiss, busWriteMiss, busInvalidate, sendAbortMemoryAccess, proximoEstadoM2, reset);
	
endmodule
