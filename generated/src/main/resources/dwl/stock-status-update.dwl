%dw 2.0
output application/json
---
{
	items: payload.items map (item, index) -> {
		id: item.id,
		name: item.name,
		quantity: item.quantity,
		price: item.price,
		category: item.category,
		stockValue: item.stockValue,
		status: if (item.quantity > 0) "in-stock" else "out-of-stock",
		createdAt: item.createdAt,
		updatedAt: now() as String {format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"}
	}
}