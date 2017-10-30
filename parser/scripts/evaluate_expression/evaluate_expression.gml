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

// Config
var debug = false;


// Variable initialization
var input = argument0;
var op_stack = ds_stack_create();		// The operator stack
var output = ds_list_create();			// The output list


var tag = "[PARSER]"
var error_message = "Warning, expression contains mismatched brackets!";

// Find storage instance. If not present, create it.
var storage = instance_find(_EP_obj_storage, 0);
if (!instance_exists(storage)) {
	storage = instance_create_depth(0, 0, 0, _EP_obj_storage);
}

if (debug) {
	show_debug_message("OPERATOR ARRAY:")
	show_debug_message(storage.operator_array);
}


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
		if (_EP_prefixes(storage.operator_array, buffer)==1 and _EP_array_contains(storage.operator_array, buffer))	
		// 2.) No operator exists that starts with the next symbol
		or (_EP_prefixes(storage.operator_array, buffer)>0  and _EP_prefixes(storage.operator_array, symbol)==0)				
		// 3.) An operator exists that starts with next symbol while no operator starts with the current buffer
		or (_EP_prefixes(storage.operator_array, buffer)==0 and _EP_prefixes(storage.operator_array, symbol)>0)	
		// 4.) Transitioning from digit to non-digit, this disallows non-digit tokens that start with a digit
		or (_EP_array_contains(storage.digits, buffer_end) and _EP_prefixes(storage.operator_array, symbol)==0 and not _EP_array_contains(storage.digits, symbol)) {				
			// Flush buffer
			ds_list_add(tokens, buffer);
			buffer = "";
		}
	}
	
	// Double meaning (unary/binary) operator treatment below, for this we check whether we have repeated operators, which allows us to find unary operators
	var last_symbol = ds_list_find_value(tokens, ds_list_size(tokens)-1);
	// For convenience, brackets are excluded
	if (ds_list_size(tokens)==0 or _EP_array_contains(storage.operator_array, last_symbol) and !_EP_array_contains(storage.brackets, last_symbol)) {
		
		// Iterate through operators to determine which one we're dealing with here
		// The brackets are excluded as stated above, this is temporary until they are properly supported
		for (var t = 0 ; t < array_length_1d(storage.operator_array) - 2 ; t++) {
			var op_data = ds_map_find_value(storage.operators, storage.operator_array[t]);
			
			// It must be one of the unary operators, hence op_data[4] must be 1
			if (symbol == op_data[1] and op_data[4] == 1) {
				symbol = op_data[0];	
			}
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
	if (ds_map_exists(storage.operators, token)) { 
		var op = token;
		
		// We first check whether the top of the operator stack has a token with larger precedence and is left associative, and we pop such operators into the output
		while (!ds_stack_empty(op_stack) and ds_stack_top(op_stack) != "(") { 
			var stack_top_data = ds_map_find_value(storage.operators, ds_stack_top(op_stack));
			var op_data = ds_map_find_value(storage.operators, op);
			if (
			(stack_top_data[2] >= op_data[2] and op_data[3] == "l") or 
			(stack_top_data[2] > op_data[2] and op_data[3] == "r") or
			(stack_top_data[3] == "r" and op_data[3] == "l"))  {
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
	if ds_map_exists(storage.operators, token) {
		if (debug) {
			show_debug_message(tag + " " + "  Found operator: " + token);
		}
		var operator = token;
		var op_data = ds_map_find_value(storage.operators, operator);
		var arity = op_data[4];

		switch (arity) {
			
			// Unary operators
			case 1:					var op = real(ds_stack_pop(operand_stack));
									if (debug) {
										show_debug_message(tag + " " + "  Operand: " + string(op));
									}
									ds_stack_push(operand_stack, script_execute(op_data[5], op));
									break;
			
			// Binary operators
			case 2:					// The operand order on the stack is inverted, hence the inverted assignment
									var op2 = real(ds_stack_pop(operand_stack));
									var op1 = real(ds_stack_pop(operand_stack));
									if (debug) {
										show_debug_message(tag + " " + "  Operand (1): " + string(op1));
										show_debug_message(tag + " " + "  Operand (2): " + string(op2));
									}
									ds_stack_push(operand_stack, script_execute(op_data[5], op1, op2));
									break;
		}
	} else {
		var operand = token;
		ds_stack_push(operand_stack, operand);	
	}
}




// The last thing on the stack will be the result of the calculation
var result = ds_stack_pop(operand_stack);

// Clean up before returning
ds_stack_destroy(operand_stack);
ds_stack_destroy(op_stack);
ds_list_destroy(output);
ds_list_destroy(tokens);

return result;