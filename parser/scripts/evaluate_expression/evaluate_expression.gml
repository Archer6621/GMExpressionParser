// Using Dijkstra's shunting yard algorithm to create an RPN expression
// Shunting yard:	https://en.wikipedia.org/wiki/Shunting-yard_algorithm
// RPN:				https://en.wikipedia.org/wiki/Reverse_Polish_notation

// Init
var input = argument0;

var operators  = ds_map_create();		// Operator values in map: [Precedence, Association], where l is left-associative, and r is right-associative
ds_map_add(operators, "+", [1, "l"]);	// Plus
ds_map_add(operators, "-", [1, "l"]);	// Minus
ds_map_add(operators, "*", [2, "l"]);	// Multiplication
ds_map_add(operators, "/", [2, "l"]);	// Division
ds_map_add(operators, "^", [3, "r"]);	// Power

var op_stack = ds_stack_create();		// The operator stack
var output = ds_list_create();			// The output list
var part_of_previous = false;			// Boolean to check what parts of the tokens belong together

var tag = "[PARSER]"
var error_message = "Warning, expression contains mismatched brackets!";


for (var i = 1 ; i <= string_length(input) ; i++) {
	var symbol = string_char_at(input, i);
	
	// If our symbol is an operator
	if (ds_map_exists(operators, symbol)) { 
		var op = symbol;
		
		// We first check whether the top of the operator stack has a symbol with larger precedence and is left associative, and we pop such operators into the output
		while (!ds_stack_empty(op_stack) and ds_stack_top(op_stack) != "(") { 
			var stack_top_data = ds_map_find_value(operators, ds_stack_top(op_stack));
			var op_data = ds_map_find_value(operators, op);
			if (stack_top_data[0] >= op_data[0] and stack_top_data[1] == "l") {
				ds_list_add(output, ds_stack_pop(op_stack));	
			} else {
				break;	
			}
		}
		// If none found anymore, we push the found operator onto the stack
		ds_stack_push(op_stack, op);
		part_of_previous = false;
		
	// Ignore spaces
	} else if (symbol == " ") {
		continue;
		
	// Push left brackets onto the operator stack
	} else if (symbol == "(") {
		ds_stack_push(op_stack, symbol);
		part_of_previous = false;
		
	// Pop every operator onto the output until a left bracket is found again
	} else if (symbol == ")") {
		while (!ds_stack_empty(op_stack) and ds_stack_top(op_stack) != "(") {
				ds_list_add(output, ds_stack_pop(op_stack));
		}
		// If the stack runs out before a left bracket was found, there's a mismatch somewhere
		if (ds_stack_empty(op_stack)) {
			show_debug_message(tag + " " + error_message);
			return 0;	
		}
		ds_stack_pop(op_stack);	// Pop the left bracket that was still left over
		part_of_previous = false;
		
 	// Whatever is not a whitespace, bracket or operator is considered to be a valid symbol and is either concatenated to the previous token or added as a new token
	} else {
		var last = ds_list_size(output)-1;
		if (last == -1 or !part_of_previous) {
			ds_list_add(output, symbol);
			part_of_previous = true;	// If the next symbol is not a bracket or operator, it will simply be concatenated with the last token
		} else {
			ds_list_replace(output, last, ds_list_find_value(output, last) + symbol);
		}
	}
}

// When all input has been read, we can pop the remaining operators onto the output and obtain an RPN expression equivalent to the original
while !ds_stack_empty(op_stack) {
	var op = ds_stack_pop(op_stack);
	// If there's still somehow a bracket on the stack, then there's a mismatch somewhere
	if (op == "(") {
		show_debug_message(tag + " " + error_message);
		return 0;
	}
	ds_list_add(output, op);
}

// Now we can actually evaluate the expression

// init
var operand_stack = ds_stack_create();

for (var j = 0 ; j < ds_list_size(output) ; j++) {
	var token = ds_list_find_value(output, j);
	
	// If we're dealing with an operator, we pop the two top operands on the operand_stack, and perform the specified operation
	if ds_map_exists(operators, token) {
		var operator = token;
		// The order on the stack is inverted, hence the inverted assignment
		var op2 = real(ds_stack_pop(operand_stack));
		var op1 = real(ds_stack_pop(operand_stack));
		switch (operator) {
			case "+":	ds_stack_push(operand_stack, op1 + op2);
						break;
			case "-":	ds_stack_push(operand_stack, op1 - op2);
						break;
			case "*":	ds_stack_push(operand_stack, op1 * op2);
						break;
			case "/":	ds_stack_push(operand_stack, op1 / op2);
						break;
			case "^":	ds_stack_push(operand_stack, power(op1, op2));
						break;
		}
	} else {
		var operand = token;
		ds_stack_push(operand_stack, operand);	
	}
}


return ds_stack_pop(operand_stack);