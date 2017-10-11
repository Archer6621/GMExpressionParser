var structure = argument0;

if is_array(structure) {
	var operator = structure[0];
	var left = structure[1];
	var right = structure[2];
	
	// Perform necessary operations on structures
	switch (operator) {
		case "+":	return real(eval(left)) + real(eval(right));	
		case "-":	return real(eval(left)) - real(eval(right));
		case "/":	return real(eval(left)) / real(eval(right));
		case "*":	return real(eval(left)) * real(eval(right));
	}
} else {
	return structure
}

