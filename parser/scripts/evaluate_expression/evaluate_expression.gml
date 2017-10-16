/// evaluate_expression(expression)
///
/// Evaluates the mathematical operation represented by the given string. It uses
/// Dijkstra's shunting yard algorithm to create an RPN/post-fix representation of
/// the expression, which can then be evaluated easily. Its time complexity is O(n).
///
/// Operators with duplicate identities (e.g. minus) are dealt with during tokenization,
/// where they are usually replaced by something else.
///
/// Will warn on mismatched parentheses and return 0. Any token that is not an operator
/// or a number will be parsed as 0 as well at the end. Supports multi-character operators.
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

var operators_array = ["+", "-", "-u", "+u", "*", "/", "^", "++", "(", ")"]; 
var operators  = ds_map_create();				// Operator values in map: [Precedence, Association, Arity], where l is left-associative, r is right-associative. Arity determines how many operands it takes.
ds_map_add(operators, operators_array[0], [1, "l", 2]);		// Plus
ds_map_add(operators, operators_array[1], [1, "l", 2]);		// Minus
ds_map_add(operators, operators_array[2], [10, "r", 1]);	// Unary minus (duplicate case that is treated during pre-processing)
ds_map_add(operators, operators_array[3], [10, "r", 1]);	// Unary plus (duplicate case that is treated during pre-processing)
ds_map_add(operators, operators_array[4], [2, "l", 2]);		// Multiplication
ds_map_add(operators, operators_array[5], [2, "l", 2]);		// Division
ds_map_add(operators, operators_array[6], [3, "r", 2]);		// Power
ds_map_add(operators, operators_array[7], [10, "r", 1]);	// Pre-increment

// Brackets are treated as operators, but not included in the map, since shunting yard treats them specially for now

var digits = ["0","1","2","3","4","5","6","7","8","9","."];

var op_stack = ds_stack_create();		// The operator stack
var output = ds_list_create();			// The output list

var tag = "[PARSER]"
var error_message = "Warning, expression contains mismatched brackets!";
var debug = true;



// Tokenize
var buffer = "";
var tokens = ds_list_create();
for (var i = 1 ; i <= string_length(input) ; i++) {
	var symbol = string_char_at(input, i);
	
	// Of course, using separators (spaces) is the best way to prevent ambiguity and separate tokens
	if (symbol == " ") {
		// Flush buffer
		ds_list_add(tokens, buffer);
		buffer = "";
		continue
	}
	
	// When these are lacking, the following scheme is used
    
    // 4 Flush conditions, that is, if the buffer contains anything at all, it is flushed when...
	if (buffer != "") {
		var buffer_end = string_char_at(buffer, string_length(buffer));
		
		// 1.) The current buffer exactly matches an operator
		if (_EP_prefixes(operators_array, buffer)==1 and _EP_array_contains(operators_array, buffer))	
		// 2.) No operator exists that starts with the next symbol
		or (_EP_prefixes(operators_array, buffer)>0  and _EP_prefixes(operators_array, symbol)==0)				
		// 3.) An operator exists that starts with next symbol while no operator starts with the current buffer
		or (_EP_prefixes(operators_array, buffer)==0 and _EP_prefixes(operators_array, symbol)>0)	
		// 4.) Transitioning from digit to non-digit, this disallows non-digit tokens that start with a digit
		or (_EP_array_contains(digits, buffer_end) and _EP_prefixes(operators_array, symbol)==0 and not _EP_array_contains(digits, symbol)) {				
			// Flush buffer
			ds_list_add(tokens, buffer);
			buffer = "";
		}
	}
	
	// Double meaning (unary/binary) operator treatment below, for this we check whether we have repeated operators, which allows us to find unary operators
	if (ds_list_size(tokens)==0 or _EP_array_contains(operators_array, ds_list_find_value(tokens, ds_list_size(tokens)-1))) {
		switch (symbol) {
			// The symbol must be made equal to some operator in operators_array
			case "-": 		symbol = "-u"; break;
			case "+":		symbol = "+u"; break;
			// More cases may be added as above for other unary operators that have a binary counterpart
		}
	}
	buffer += symbol;
}
// Final flush
ds_list_add(tokens, buffer);
buffer = "";


if (debug) {
	show_debug_message(tag + " " + "Tokenized string:");
	show_debug_message(tag + " " + _EP_ds_list_to_string(tokens));
}

// Start reading the pre_processed string
for (var i = 0 ; i < ds_list_size(tokens) ; i++) {
	var token = ds_list_find_value(tokens, i);
	
	// If our token is an operator
	if (ds_map_exists(operators, token)) { 
		var op = token;
		
		// We first check whether the top of the operator stack has a token with larger precedence and is left associative, and we pop such operators into the output
		while (!ds_stack_empty(op_stack) and ds_stack_top(op_stack) != "(") { 
			var stack_top_data = ds_map_find_value(operators, ds_stack_top(op_stack));
			var op_data = ds_map_find_value(operators, op);
			if (stack_top_data[0] >= op_data[0] and op_data[1] == "l")  {
				ds_list_add(output, ds_stack_pop(op_stack));	
			} else {
				break;	
			}
		}
		// If none found anymore, we push the found operator onto the stack
		ds_stack_push(op_stack, op);
		
	// Push left brackets onto the operator stack
	} else if (token == "(") {
		ds_stack_push(op_stack, token);
		
	// Pop every operator onto the output until a left bracket is found again
	} else if (token == ")") {
		while (!ds_stack_empty(op_stack) and ds_stack_top(op_stack) != "(") {
				ds_list_add(output, ds_stack_pop(op_stack));
		}
		// If the stack runs out before a left bracket was found, there's a mismatch somewhere
		if (ds_stack_empty(op_stack)) {
			show_debug_message(tag + " " + error_message);
			return 0;	
		}
		ds_stack_pop(op_stack);	// Pop the left bracket that was still left over
		
 	// Whatever is not a whitespace, bracket or operator is considered to be a valid token and is either concatenated to the previous token or added as a new token
	} else {
		ds_list_add(output, token);
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
	show_debug_message(tag + " " + _EP_ds_list_to_string(output));
}

// Now we can actually evaluate the expression

// Init
var operand_stack = ds_stack_create();

// Start iterating over the list with tokens
for (var j = 0 ; j < ds_list_size(output) ; j++) {
	var token = ds_list_find_value(output, j);
	
	if (debug) {
		show_debug_message(tag + " " + "Operand stack at iteration " + string(j));
		show_debug_message(tag + "   " + _EP_ds_stack_to_string(operand_stack));
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
				show_debug_message(tag + " " + "  Operand: " + string(op));
			}
			switch (operator) {
				case "-u":	ds_stack_push(operand_stack, 0 - op);
							break;
				case "+u":	ds_stack_push(operand_stack, op);
							break;
				case "++":	ds_stack_push(operand_stack, op + 1);
							break;
			}
		}

		// Binary operators
		if (arity == 2) {
			// The operand order on the stack is inverted, hence the inverted assignment
			var op2 = real(ds_stack_pop(operand_stack));
			var op1 = real(ds_stack_pop(operand_stack));
			if (debug) {
				show_debug_message(tag + " " + "  Operand (1): " + string(op1));
				show_debug_message(tag + " " + "  Operand (2): " + string(op2));
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
var result = ds_stack_pop(operand_stack);

// Clean up before returning
ds_map_destroy(operators);
ds_stack_destroy(operand_stack);
ds_stack_destroy(op_stack);
ds_list_destroy(output);
ds_list_destroy(tokens);

return result