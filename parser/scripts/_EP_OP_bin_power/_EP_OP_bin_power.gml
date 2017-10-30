// Operator description
// Ouputs the real value of the first token to the power of the real value of the second token
// Beware: will return NaN when the real value of the first token is negative, which is a limitation of GM's power function
//	E: 3 ^ 2
//	R: 9


// The operator's definition is returned when still initializing
if (self.object_index==_EP_obj_storage) {
	
	// Configure operator here
	var token_in_text		= "^";
	var token_in_parser		= "^";
	var precedence			= 3;
	var association			= "r";
	var arity				= 2;
	var operation			= argument[0];
	
	return [token_in_parser, token_in_text, precedence, association, arity, operation];
} else {
	// The operation to perform
	return power(real(argument[0]), real(argument[1]));
}