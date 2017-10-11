var str = argument0;


// The further the symbol is in the list, the higher its priority
var symbols = ["-", "+", "*", "/"];

// Create parse tree
for (var i = 0 ; i < array_length_1d(symbols) ; i++) {
	var position = string_pos(symbols[i], str);
	if (position==0) { continue;};
	var left = string_copy(str,1,position-1)
	var right = string_copy(str,position+1,string_length(str)-position+1)
	return [symbols[i], read(left), read(right)]; 
}
return str;
