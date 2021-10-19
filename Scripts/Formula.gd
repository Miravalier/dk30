var variables = null
var terms = []
var operators = ["+", "-", "*", "/", "%", "^"]
var parens = ["(", ")"]

func _init(_variables):
	variables = _variables

func _to_string():
	var result = ""
	for i in range(0, terms.size()):
		result += str(terms[i])
	return result

func is_variable(term):
	return typeof(term) == TYPE_STRING and (not operators.has(term)) and term != "(" and term != ")"

func is_operator(term):
	return typeof(term) == TYPE_STRING and operators.has(term)

func is_open_paren(term):
	return typeof(term) == TYPE_STRING and term == "("

func is_close_paren(term):
	return typeof(term) == TYPE_STRING and term == ")"

func is_constant(term):
	return typeof(term) == TYPE_REAL or typeof(term) == TYPE_INT

func resolve(term):
	if is_variable(term):
		return resolve(variables.get(term))
	elif typeof(term) == TYPE_INT:
		return float(term)
	elif typeof(term) == TYPE_REAL:
		return term
	else:
		# If you're getting this, something probably ended up in the
		# formula variables that shouldn't be there.
		push_error("Invalid resolve() term: " + str(term))

func validate():
	# All "(" must be matched with ")"
	var paren_level = 0
	for term in terms:
		if term == "(":
			paren_level += 1
		elif term == ")":
			paren_level -= 1
	if paren_level != 0:
		return false
	# Validate terms
	for i in range(0, terms.size()):
		# Get current, previous, and next
		var current = terms[i]
		var previous = null
		var next = null
		if i > 0:
			previous = terms[i-1]
		if i < terms.size() - 1:
			next = terms[i+1]
		# Open parens
		if is_open_paren(current):
			# Open parens can't be followed by a close paren
			if is_close_paren(next):
				return false
			# Open parens can't be followed by an operator
			elif is_operator(next):
				return false
		# Close parens
		elif is_close_paren(current):
			# Close parens can't be preceeded by an operator
			if is_operator(previous):
				return false
		# Operators
		elif is_operator(current):
			# Operators can't be the first term
			if previous == null:
				return false
			# Operators can't be the last term
			if next == null:
				return false
			# Operators can't be followed by other operators
			if is_operator(next):
				return false
		# Variables
		elif is_variable(current):
			# Variables can't be followed by a constant
			if is_constant(next):
				return false
			# Variables must exist in the map
			if not variables.has(current):
				return false
		# Constants
		elif is_constant(current):
			# Constants can't be followed by a constant
			if is_constant(next):
				return false
		# Unrecognized terms
		else:
			return false
	return true

func _evaluate_implicit_operators(expr_terms):
	if expr_terms.size() == 1:
		return _evaluate_parens(expr_terms)
	for i in range(0, expr_terms.size() - 1):
		if is_variable(expr_terms[i]) or is_constant(expr_terms[i]) or is_close_paren(expr_terms[i]):
			if is_variable(expr_terms[i+1]) or is_constant(expr_terms[i+1]) or is_open_paren(expr_terms[i+1]):
				# Get terms before the implicit operator
				var remaining_terms = expr_terms.slice(0, i)
				# Add the implicit operator
				remaining_terms.append("*")
				# Get the terms after the operator
				remaining_terms.append_array(expr_terms.slice(i+1, expr_terms.size()))
				# Evaluate the remaining terms
				return _evaluate_implicit_operators(remaining_terms)
	return _evaluate_parens(expr_terms)

func _evaluate_parens(expr_terms):
	for i in range(0, expr_terms.size()):
		if is_open_paren(expr_terms[i]):
			var ending_index = null
			var paren_level = 1
			for j in range(i+1, expr_terms.size()):
				if is_open_paren(expr_terms[j]):
					paren_level += 1
				elif is_close_paren(expr_terms[j]):
					paren_level -= 1
				if paren_level == 0:
					ending_index = j
					break
			# Get terms before the parenthetical
			var remaining_terms = expr_terms.slice(0, i-1)
			# Evaluate the parenthetical
			remaining_terms.append(_evaluate_parens(expr_terms.slice(i+1, ending_index-1)))
			# Get the terms after the parenthetical
			remaining_terms.append_array(expr_terms.slice(ending_index+1, expr_terms.size()))
			# Evaluate what is left
			return _evaluate_parens(remaining_terms)
	return _evaluate_exponents(expr_terms)

func _evaluate_exponents(expr_terms):
	for i in range(0, expr_terms.size()):
		if is_operator(expr_terms[i]) and expr_terms[i] == "^":
			# Get the terms before the operator
			var remaining_terms
			if i > 2:
				remaining_terms = expr_terms.slice(0, i-2)
			else:
				remaining_terms = []
			# Evaluate the ^ operator
			remaining_terms.append(pow(
				resolve(expr_terms[i-1]),
				resolve(expr_terms[i+1])
			))
			# Get the terms after the operator
			remaining_terms.append_array(expr_terms.slice(i+2, expr_terms.size()))
			# Evaluate what is left
			return _evaluate_exponents(remaining_terms)
	return _evaluate_multiplication_and_division(expr_terms)

func _evaluate_multiplication_and_division(expr_terms):
	for i in range(0, expr_terms.size()):
		if is_operator(expr_terms[i]):
			# Evaluate the operator
			var result = null
			if expr_terms[i] == "*":
				result = resolve(expr_terms[i-1]) * resolve(expr_terms[i+1])
			elif expr_terms[i] == "/":
				result = resolve(expr_terms[i-1]) / resolve(expr_terms[i+1])
			elif expr_terms[i] == "%":
				result = resolve(expr_terms[i-1]) % resolve(expr_terms[i+1])
			else:
				continue
			# Get the terms before the operator
			var remaining_terms
			if i > 2:
				remaining_terms = expr_terms.slice(0, i-2)
			else:
				remaining_terms = []
			# Add the result
			remaining_terms.append(result)
			# Get the terms after the operator
			remaining_terms.append_array(expr_terms.slice(i+2, expr_terms.size()))
			# Evaluate what is left
			return _evaluate_multiplication_and_division(remaining_terms)
	return _evaluate_addition_and_substraction(expr_terms)

func _evaluate_addition_and_substraction(expr_terms):
	for i in range(0, expr_terms.size()):
		if is_operator(expr_terms[i]):
			# Evaluate the operator
			var result = null
			if expr_terms[i] == "+":
				result = resolve(expr_terms[i-1]) + resolve(expr_terms[i+1])
			elif expr_terms[i] == "-":
				result = resolve(expr_terms[i-1]) - resolve(expr_terms[i+1])
			else:
				continue
			# Get the terms before the operator
			var remaining_terms
			if i > 2:
				remaining_terms = expr_terms.slice(0, i-2)
			else:
				remaining_terms = []
			# Add the result
			remaining_terms.append(result)
			# Get the terms after the operator
			remaining_terms.append_array(expr_terms.slice(i+2, expr_terms.size()))
			# Evaluate what is left
			return _evaluate_addition_and_substraction(remaining_terms)
	return resolve(expr_terms[0])

func evaluate():
	if terms.size() == 0:
		return 0
	return _evaluate_implicit_operators(terms)
