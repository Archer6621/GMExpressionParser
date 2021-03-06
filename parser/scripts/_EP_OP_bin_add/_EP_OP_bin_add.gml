// Operator description
// Performs addition between two tokens that are converted to real numbers.
//	E: 1 + 2
//	R: 3

// The operator's definition is returned when still initializing
if (self.object_index==_EP_obj_storage) {
	
	// Configure operator here
	var token_in_parser		= "+";
	var token_in_text		= "+";
	var precedence			= 1;
	var association			= "l";
	var arity				= 2;
	var operation			= argument[0];
	
	return [token_in_parser, token_in_text, precedence, association, arity, operation];
} else {
	// The operation to perform
	return real(argument[0]) + real(argument[1]);
}