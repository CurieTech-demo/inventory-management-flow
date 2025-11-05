%dw 2.0

fun isValidCategory(category: String, validCategories: Array<String>): Boolean =
	validCategories contains category

fun isValidName(name: String): Boolean =
	(name != null) and (sizeOf(trim(name)) > 0)

fun isValidQuantity(quantity: Number): Boolean =
	(quantity != null) and (quantity >= 0) and (quantity is Number)

fun isValidPrice(price: Number): Boolean =
	(price != null) and (price > 0) and (price is Number)

fun validateItem(item: Object, validCategories: Array<String>): Object =
{
	isValid: isValidName(item.name) and 
			 isValidQuantity(item.quantity) and 
			 isValidPrice(item.price) and 
			 isValidCategory(item.category, validCategories),
	errors: [
		(if (!isValidName(item.name)) "Name is required and cannot be empty" else null),
		(if (!isValidQuantity(item.quantity)) "Quantity must be a non-negative number" else null),
		(if (!isValidPrice(item.price)) "Price must be a positive number" else null),
		(if (!isValidCategory(item.category, validCategories)) "Category must be one of: " ++ (validCategories joinBy ", ") else null)
	] filter ($ != null)
}