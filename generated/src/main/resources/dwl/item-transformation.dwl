%dw 2.0
output application/json
---
{
	id: uuid(),
	name: payload.name,
	quantity: payload.quantity,
	price: payload.price,
	category: payload.category,
	stockValue: payload.quantity * payload.price,
	status: if (payload.quantity > 0) "in-stock" else "out-of-stock",
	createdAt: now() as String {format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"},
	updatedAt: now() as String {format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"}
}