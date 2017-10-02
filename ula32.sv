module ula(input logic [31:0] a, b,
	   input logic [1:0] controle,
	   output logic [31:0] result,
	   output logic  zero , overflow );
	logic [31:0] sum, bout;

	assign bout = controle[0] ? ~b : b;
	assign sum = a + bout + controle[0];

	always_comb
	   case(controle[1:0])
		2'b00: result = sum;           //soma 
		2'b01: result = sum;           //subtracao
		2'b10: result = a & b;         //AND
		2'b11: result = a | b;         //OR
	   endcase

	assign zero = (result == 32'b0);        //zero

	always_comb                             //overflow
	   case(controle [1:0])
		2'b00: overflow = a[31] & b[31] & ~result[31]|
		                  ~a[31] & ~b[31] & result[31];
		2'b01: overflow = ~a[31] & b[31] & result[31]|
		                  a[31] & ~b[31] & ~result[31];
	        default: overflow = 1'b0;
	   endcase
endmodule


module test();
	logic clk;
	logic [31:0] a, b, result, result_esperado;
	logic [1:0] controle;
	logic  zero_esperado, overflow_esperado;
	logic [31:0] vectornum, errors;
	logic [99:0] testvectors[10000:0];
	
	ula dut( a, b,controle, result,zero,overflow);      //escolhe arquivo DUT
	
	always begin					    //gerar clock
		clk = 1; #50; clk = 0; #50;
	end

	initial begin			 		    //carregar o vetor de dados
		$readmemh("alu32.tv.txt", testvectors);
		vectornum = 0; errors = 0;
	end

	always @(posedge clk)     			    //aplicar o teste na subida de clock
		begin
			#1;
			zero_esperado = testvectors[vectornum][99];
			overflow_esperado = testvectors[vectornum][98];
			controle = testvectors[vectornum][97:96];
			a = testvectors[vectornum][95:64];
			b = testvectors[vectornum][63:32];
			result_esperado = testvectors[vectornum][31:0];
		end

	always @(negedge clk)				//verificar resultados na descida de clock
		begin
			if (result !== result_esperado) begin
			$display("Error in vector %d", vectornum);
			$display(" Inputs : a = %h, b = %h, controle = %b", a, b, controle);
			$display(" Outputs: result = %h (%h esperado)",result, result_esperado);
			errors = errors+1;
			end
	vectornum = vectornum + 1;
	if (testvectors[vectornum][0] === 1'bx) begin
		$display("%d tests completed with %d errors", vectornum, errors);
		$stop;
	end
	end
endmodule
