/*
	CEFET-MG
	Disciplina de Laboratório de Arquitetura e Organização de Computadores II
	Data: 06/02/2022
	Aluno: Fernando Veizaga e Alanis Castro
*/

module maquinaMESIcpu(estadoCPUanterior, CPUwhit, CPUrhit, CPUwmiss, CPUrmiss, estadoCPUprox, readMiss, writeMiss, invalidate, shared, writeBack, reset);

	input [2:0] estadoCPUanterior;
	input CPUwhit, CPUrhit, CPUwmiss, CPUrmiss, shared, reset;
	
	output reg [2:0] estadoCPUprox;
	output reg readMiss, writeMiss, invalidate, writeBack;
	
	//INVALID = 3'b000
	//MODIFIED = 3'b001
	//SHARED = 3'b010
	//EXCLUSIVE = 3'b011
	
	initial begin
		estadoCPUprox <= 3'b000;	//INVALID
		invalidate <= 1'b0;
		readMiss <= 1'b0;
		writeMiss <= 1'b0;
		writeBack <= 1'b0;
	end
	
	always@(*) 
	begin
		if(reset == 1'b1)
		begin
			estadoCPUprox <= 3'b000;	//INVALID
			invalidate <= 1'b0;
			readMiss <= 1'b0;
			writeMiss <= 1'b0;
			writeBack <= 1'b0;
		end
		else begin
			case(estadoCPUanterior)
				3'b001:	//MODIFIED
				begin
					if(CPUwhit == 1'b1)
					begin
						estadoCPUprox <= 3'b001;		//MODIFIED
						invalidate <= 1'b0;
						writeMiss <= 1'b0;
						readMiss <= 1'b0;
						writeBack <= 1'b1;
					end
					
					else if(CPUrhit == 1'b1)
					begin
						estadoCPUprox <= 3'b001;		//MODIFIED
						invalidate <= 1'b0;
						writeMiss <= 1'b0;
						readMiss <= 1'b0;
						writeBack <= 1'b0;
					end
					
					else if(CPUwmiss == 1'b1)
					begin
						estadoCPUprox <= 3'b001;		//MODIFIED
						invalidate <= 1'b0;
						writeMiss <= 1'b1;
						readMiss <= 1'b0;
						writeBack <= 1'b1;
					end
					
					else if(CPUrmiss == 1'b1)
					begin
						estadoCPUprox <= 3'b010;		//SHARED
						invalidate <= 1'b0;
						writeMiss <= 1'b0;
						readMiss <= 1'b1;
						writeBack <= 1'b1;
					end
					
				end
				
				3'b010:	//SHARED
				begin
					if(CPUwhit == 1'b1)
					begin
						estadoCPUprox = 3'b001; 	//MODIFIED
						invalidate = 1'b1;
						writeMiss <= 1'b0;
						readMiss <= 1'b0;
						writeBack <= 1'b0;
					end
					
					else if(CPUrhit == 1'b1)
					begin
						estadoCPUprox <= 3'b010;		//SHARED
						invalidate <= 1'b0;
						writeMiss <= 1'b0;
						readMiss <= 1'b0;
						writeBack <= 1'b0;
					end
					
					else if(CPUwmiss == 1'b1)
					begin
						estadoCPUprox <= 3'b001;		//MODIFIED
						invalidate <= 1'b0;
						writeMiss <= 1'b1;
						readMiss <= 1'b0;
						writeBack <= 1'b0;
					end
					
					else if(CPUrmiss == 1'b1)
					begin
						estadoCPUprox <= 3'b010;		//SHARED
						invalidate <= 1'b0;
						writeMiss <= 1'b0;
						readMiss <= 1'b1;
						writeBack <= 1'b0;
					end

				end
				
				3'b011:	//EXCLUSIVE
				begin
					if(CPUwhit == 1'b1)
					begin
						estadoCPUprox <= 3'b001;		//MODIFIED
						invalidate <= 1'b0;
						writeMiss <= 1'b0;
						readMiss <= 1'b0;
						writeBack <= 1'b0;
					end	
					
					else if(CPUrhit == 1'b1)
					begin
						estadoCPUprox <= 3'b011;		//EXCLUSIVE
						invalidate <= 1'b0;
						writeMiss <= 1'b0;
						readMiss <= 1'b0;
						writeBack <= 1'b0;
					end
					
					else if(CPUwmiss == 1'b1)
					begin
						estadoCPUprox <= 3'b001;		//MODIFIED
						invalidate <= 1'b0;
						writeMiss <= 1'b1;
						readMiss <= 1'b0;
						writeBack <= 1'b0;
					end
					
					else if(CPUrmiss == 1'b1 && shared == 1'b1)
					begin
						estadoCPUprox <= 3'b010;		//SHARED
						invalidate <= 1'b0;
						writeMiss <= 1'b0;
						readMiss <= 1'b1;
						writeBack <= 1'b0;
					end
					
					else if(CPUrmiss == 1'b1 && shared == 1'b0)
					begin
						estadoCPUprox <= 3'b011;		//EXCLUSIVE
						invalidate <= 1'b0;
						writeMiss <= 1'b0;
						readMiss <= 1'b1;
						writeBack <= 1'b0;
					end
				end
				
				3'b000:	//INVALID
				begin
					if(CPUwmiss == 1'b1)
					begin
						estadoCPUprox <= 3'b001;	//MODIFIED
						invalidate <= 1'b0;
						readMiss <= 1'b0;
						writeMiss <= 1'b1;
						writeBack <= 1'b0;
					end
					
					else if(CPUrmiss == 1'b1 && shared == 1'b1)
					begin
						estadoCPUprox <= 3'b010;	//SHARED
						invalidate <= 1'b0;
						writeMiss <= 1'b0;
						readMiss <= 1'b1;
						writeBack <= 1'b0;
					end
					
					else if(CPUrmiss == 1'b1 && shared == 1'b0)
					begin
						estadoCPUprox <= 3'b011;	//EXCLUSIVE
						invalidate <= 1'b0;
						writeMiss <= 1'b0;
						readMiss <= 1'b1;
						writeBack <= 1'b0;
					end
				end
			endcase

		end
		
	end

endmodule