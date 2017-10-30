// Operator description
// Inverts the sign of real value of the given token
//	E: - 5
//	R: -5

// The operator's definition is returned when still initializing
if (self.object_index==_EP_obj_storage) {
	
	// Configure operator here
	var token_in_text		= "-";
	var token_in_parser		= "-u";
	var precedence			= 10;
	var association			= "r";
	var arity				= 1;
	var operation			= argument[0];
	
	return [token_in_parser, token_in_text, precedence, association, arity, operation];
} else {
	// The operation to perform
	return 0-real(argument[0]);
}