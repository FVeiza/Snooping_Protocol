/*
	CEFET-MG
	Disciplina de Laboratório de Arquitetura e Organização de Computadores II
	Data: 06/02/2022
	Aluno: Fernando Veizaga e Alanis Castro
*/

module maquinaMESIbus(estadoBUSanterior, readMiss, writeMiss, invalidate, abortMem, estadoBUSprox, reset);

	input [2:0] estadoBUSanterior;
	input readMiss, writeMiss, invalidate, reset;
	
	output reg [2:0] estadoBUSprox;
	output reg abortMem;
	
	//INVALID = 3'b000
	//MODIFIED = 3'b001
	//SHARED = 3'b010
	//EXCLUSIVE = 3'b011
	
	initial begin
		estadoBUSprox <= 3'b000;	//INVALID
		abortMem <= 1'b0;
	end

	always@(*)
	begin
		if(reset == 1'b1)
		begin
			estadoBUSprox <= 3'b000;	//INVALID
			abortMem <= 1'b0;
		end
	
		else begin
		
			case(estadoBUSanterior)
				3'b001:	//MODIFIED
				begin
					if(writeMiss == 1'b1)
					begin
						estadoBUSprox <= 3'b000;	//INVALID
						abortMem <= 1'b1;
					end
					
					else if(readMiss == 1'b1)
					begin
						estadoBUSprox <= 3'b010;	//SHARED
						abortMem <= 1'b1;
					end
				end
				
				3'b010:	//SHARED
				begin
					if(writeMiss == 1'b1 || invalidate == 1'b1)
					begin
						estadoBUSprox <= 3'b000;	//INVALID
						abortMem <= 1'b0;
					end
					
					else if(readMiss == 1'b1)
					begin
						estadoBUSprox <= 3'b010;	//SHARED
						abortMem <= 1'b0;
					end
				end
				
				3'b011:	//EXCLUSIVE
				begin
					if(writeMiss == 1'b1 || invalidate == 1'b1)
					begin
						estadoBUSprox <= 3'b000;	//INVALID
						abortMem <= 1'b0;
					end
					
					else if(readMiss == 1'b1)
					begin
						estadoBUSprox <= 3'b010;	//SHARED
						abortMem <= 1'b0;
					end
				end
			
			endcase
	
		end
		
	
	end

endmodule
