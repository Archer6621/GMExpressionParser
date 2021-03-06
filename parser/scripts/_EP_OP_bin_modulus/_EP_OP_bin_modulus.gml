// Operator description
// Obtains the remainder of the integer division of the real value of the first token by the real value of the second token.
//	E: 3 % 2
//	R: 1

// The operator's definition is returned when still initializing
if (self.object_index==_EP_obj_storage) {
	
	// Configure operator here
	var token_in_text		= "%";
	var token_in_parser		= "%";
	var precedence			= 2;
	var association			= "l";
	var arity				= 2;
	var operation			= argument[0];
	
	return [token_in_parser, token_in_text, precedence, association, arity, operation];
} else {
	// The operation to perform
	return real(argument[0]) mod real(argument[1]);
}