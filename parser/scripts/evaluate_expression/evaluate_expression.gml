/// evaluate_expression(expression)
///
/// Evaluates the mathematical operation represented by the given string. It uses
/// Dijkstra's shunting yard algorithm to create an RPN/post-fix representation of
/// the expression, which can then be evaluated easily. Its time complexity is O(n).
///
/// Operators with duplicate identities (e.g. minus) are dealt with during pre-processing,
/// where they are replaced by something else.
///
/// Will warn on mismatched parentheses and return 0. Any token that is not an operator
/// or a number will be parsed as 0 as well.
///
/// Example: evaluate_expression("(1+2)^3");
/// Returns: 27
///
/// @param {string} expression The string containing the expression to evaluate
/// @return {real} the result of the evaluation
/// @author Shaad Alaka

// Uses Dijkstra's shunting yard algorithm to create an RPN expression
// Shunting yard:	https://en.wikipedia.org/wiki/Shunting-yard_algorithm
// RPN:				https://en.wikipedia.org/wiki/Reverse_Polish_notation

// Init
var input = argument0;

var operators  = ds_map_create();				// Operator values in map: [Precedence, Association, Arity], where l is left-associative, r is right-associative. Arity determines how many operands it takes.
ds_map_add(operators, "+", [1, "l", 2]);		// Plus
ds_map_add(operators, "-", [1, "l", 2]);		// Minus
ds_map_add(operators, "~", [100, "r", 1]);		// Unary minus (special case that is treated during pre-processing)
ds_map_add(operators, "*", [2, "l", 2]);		// Multiplication
ds_map_add(operators, "/", [2, "l", 2]);		// Division
ds_map_add(operators, "^", [3, "r", 2]);		// Power

var op_stack = ds_stack_create();		// The operator stack
var output = ds_list_create();			// The output list
var part_of_previous = false;			// Boolean to check what parts of the tokens belong together

var tag = "[PARSER]"
var error_message = "Warning, expression contains mismatched brackets!";
var debug = false;

// Pre-processing, not using replace_all for spaces to prevent redundant iteration
var pre_processed = "";
for (var i = 1 ; i <= string_length(input) ; i++) {
	var symbol = string_char_at(input, i);
	
	// Skip spaces
	if (symbol == " ") {
		continue
	}
	
	// Duplicate unary operator treatment below
	if (ds_map_exists(operators, string_char_at(pre_processed, string_length(pre_processed))) or i==1) {
		switch (symbol) {
			case "-": 		symbol = "~"; break;
			// More cases may be added as above for other duplicate unary operators
		}
	}
	
	pre_processed += symbol;
}

if (debug) {
	show_debug_message(tag + " " + "Pre-processed string:");
	show_debug_message(tag + " " + pre_processed);
}

// Start reading the pre_processed string
for (var i = 1 ; i <= string_length(pre_processed) ; i++) {
	var symbol = string_char_at(pre_processed, i);
	
	// If our symbol is an operator
	if (ds_map_exists(operators, symbol)) { 
		var op = symbol;
		
		// We first check whether the top of the operator stack has a symbol with larger precedence and is left associative, and we pop such operators into the output
		while (!ds_stack_empty(op_stack) and ds_stack_top(op_stack) != "(") { 
			var stack_top_data = ds_map_find_value(operators, ds_stack_top(op_stack));
			var op_data = ds_map_find_value(operators, op);
			if (stack_top_data[0] >= op_data[0] and op_data[1] == "l") {
				ds_list_add(output, ds_stack_pop(op_stack));	
			} else {
				break;	
			}
		}
		// If none found anymore, we push the found operator onto the stack
		ds_stack_push(op_stack, op);
		part_of_previous = false;
		
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

if (debug) {
	show_debug_message(tag + " " + "After applying shunting yard algorithm:");
	var print = "["
	for (var q = 0 ; q < ds_list_size(output) ; q++) {
		print += string(ds_list_find_value(output, q));
		if (ds_list_size(output)-q !=1) {
			print += ", ";
		}	
	}
	show_debug_message(tag + " " + print + "]");
}

// Now we can actually evaluate the expression

// Init
var operand_stack = ds_stack_create();

// Start iterating over the list with tokens
for (var j = 0 ; j < ds_list_size(output) ; j++) {
	var token = ds_list_find_value(output, j);
	
	if (debug) {
		show_debug_message(tag + " " + "Operand stack at iteration " + string(j));
		var temp = ds_stack_create();
		ds_stack_copy(temp, operand_stack);
		var print = "[";
		while (!ds_stack_empty(temp)) {
			print += string(ds_stack_pop(temp));
			if (ds_stack_size(temp)>0) {
				print += ", ";
			}	
		}
		show_debug_message(tag + "   " + print + "]");
	}
	
	// If we're dealing with an operator, we check its "arity" to determine how many operands to pop, and then perform the operation
	if ds_map_exists(operators, token) {
		if (debug) {
			show_debug_message(tag + " " + "  Found operator: " + token);
		}
		var operator = token;
		var op_data = ds_map_find_value(operators, operator);
		var arity = op_data[2];

		// Unary operators
		if (arity == 1) {
			var op = real(ds_stack_pop(operand_stack));
			if (debug) {
				show_debug_message(tag + " " + "  Popped operand: " + string(op));
			}
			switch (operator) {
				case "~":	ds_stack_push(operand_stack, -1 * op);
							break;
			}
		}

		// Binary operators
		if (arity == 2) {
			// The operand order on the stack is inverted, hence the inverted assignment
			var op2 = real(ds_stack_pop(operand_stack));
			var op1 = real(ds_stack_pop(operand_stack));
			if (debug) {
				show_debug_message(tag + " " + "  Popped operand: " + string(op2));
				show_debug_message(tag + " " + "  Popped operand: " + string(op1));
			}
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
		}
	} else {
		var operand = token;
		ds_stack_push(operand_stack, operand);	
	}
}

// The last thing on the stack will be the result of the calculation
return ds_stack_pop(operand_stack);