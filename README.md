# Inventory Management API

A comprehensive MuleSoft application for managing inventory items with REST API endpoints, automated stock status updates, and comprehensive testing.

## Project Overview

This MuleSoft project provides a complete inventory management system with the following capabilities:
- RESTful API for item management (POST, GET)
- Automated stock status monitoring via scheduler
- Environment-based configuration
- Comprehensive validation and error handling
- Full MUnit test coverage
- Local JSON file-based persistence

## Project Structure

```
inventory-management-api/
├── src/
│   ├── main/
│   │   ├── mule/
│   │   │   ├── global.xml                          # Global configurations and error handlers
│   │   │   └── inventory-management-flows.xml      # Main flows and subflows
│   │   └── resources/
│   │       ├── config-dev.yaml                     # Development environment config
│   │       ├── config-test.yaml                    # Test environment config
│   │       ├── config-prod.yaml                    # Production environment config
│   │       ├── data/
│   │       │   └── inventory.json                  # JSON storage file
│   │       └── dwl/
│   │           ├── item-transformation.dwl         # Item transformation logic
│   │           ├── stock-status-update.dwl         # Stock status update logic
│   │           └── validation-functions.dwl        # Validation functions
│   └── test/
│       ├── munit/
│       │   └── inventory-management-test-suite.xml # Comprehensive MUnit tests
│       └── resources/
│           └── data/
│               └── inventory-test.json             # Test data storage
├── pom.xml                                         # Maven dependencies and build config
├── mule-artifact.json                              # Mule application metadata
└── README.md                                       # This file
```

## API Endpoints

### POST /api/v1/items
Creates a new inventory item.

**Request Body:**
```json
{
  "name": "Gaming Mouse",
  "quantity": 10,
  "price": 79.99,
  "category": "Electronics"
}
```

**Response (201 Created):**
```json
{
  "message": "Item created successfully",
  "item": {
    "id": "uuid-generated",
    "name": "Gaming Mouse",
    "quantity": 10,
    "price": 79.99,
    "category": "Electronics",
    "stockValue": 799.9,
    "status": "in-stock",
    "createdAt": "2024-01-01T10:00:00.000Z",
    "updatedAt": "2024-01-01T10:00:00.000Z"
  },
  "timestamp": "2024-01-01T10:00:00.000Z"
}
```

### GET /api/v1/items/{id}
Retrieves an item by its ID.

**Response (200 OK):**
```json
{
  "id": "uuid",
  "name": "Gaming Mouse",
  "quantity": 10,
  "price": 79.99,
  "category": "Electronics",
  "stockValue": 799.9,
  "status": "in-stock",
  "createdAt": "2024-01-01T10:00:00.000Z",
  "updatedAt": "2024-01-01T10:00:00.000Z"
}
```

**Response (404 Not Found):**
```json
{
  "error": "NOT_FOUND",
  "message": "Item not found",
  "details": "No item found with ID: {id}",
  "timestamp": "2024-01-01T10:00:00.000Z"
}
```

## Data Model

### Item Structure
```json
{
  "id": "string (UUID)",
  "name": "string (required, non-empty)",
  "quantity": "number (required, non-negative)",
  "price": "number (required, positive)",
  "category": "string (required, from predefined list)",
  "stockValue": "number (calculated: quantity * price)",
  "status": "string (in-stock | out-of-stock)",
  "createdAt": "string (ISO 8601 timestamp)",
  "updatedAt": "string (ISO 8601 timestamp)"
}
```

### Valid Categories
- Electronics
- Clothing
- Books
- Home
- Sports
- Other

## Validation Rules

- **name**: Required, non-empty string
- **quantity**: Required, non-negative integer
- **price**: Required, positive number
- **category**: Required, must be from valid categories list

## Automated Features

### Stock Status Scheduler
- Runs every 5 minutes (configurable)
- Updates item status based on quantity:
  - `quantity > 0`: "in-stock"
  - `quantity = 0`: "out-of-stock"
- Updates `updatedAt` timestamp for modified items

## Configuration

### Environment Variables
Set the `mule.env` system property to switch between environments:
- `dev` (default): Uses config-dev.yaml
- `test`: Uses config-test.yaml  
- `prod`: Uses config-prod.yaml

### Configuration Properties

#### Development (config-dev.yaml)
```yaml
http:
  host: "0.0.0.0"
  port: "8081"
  basePath: "/api/v1"

file:
  storagePath: "src/main/resources/data"
  inventoryFile: "inventory.json"

scheduler:
  stockUpdateFrequency: "5"
```

#### Test (config-test.yaml)
```yaml
http:
  host: "0.0.0.0"
  port: "8082"
  basePath: "/api/v1"

file:
  storagePath: "src/test/resources/data"
  inventoryFile: "inventory-test.json"

scheduler:
  stockUpdateFrequency: "1"
```

#### Production (config-prod.yaml)
```yaml
http:
  host: "0.0.0.0"
  port: "8080"
  basePath: "/api/v1"

file:
  storagePath: "/opt/app/data"
  inventoryFile: "inventory.json"

scheduler:
  stockUpdateFrequency: "5"
```

## Subflows

### validate-item-subflow
- Validates incoming item data
- Checks required fields and data types
- Validates category against allowed values
- Throws VALIDATION:INVALID_INPUT error for invalid data

### transform-item-subflow
- Transforms validated item data
- Generates unique ID (UUID)
- Calculates stock value (quantity * price)
- Sets initial status based on quantity
- Adds creation and update timestamps

### store-item-subflow
- Reads existing inventory from JSON file
- Adds new item to inventory
- Writes updated inventory back to file
- Creates new file if it doesn't exist

### retrieve-item-subflow
- Reads inventory from JSON file
- Searches for item by ID
- Returns found item or null

### update-stock-status-subflow
- Reads current inventory
- Updates status for all items based on quantity
- Updates timestamps for modified items
- Writes updated inventory back to file

## Error Handling

### Global Error Handler
Provides consistent error responses for:
- **VALIDATION:INVALID_INPUT** (400): Invalid request data
- **FILE:FILE_NOT_FOUND** (404): Resource not found
- **FILE:ACCESS_DENIED** (403): Permission denied
- **ANY** (500): Internal server error

### Error Response Format
```json
{
  "error": "ERROR_TYPE",
  "message": "Human readable message",
  "details": "Detailed error information",
  "timestamp": "2024-01-01T10:00:00.000Z"
}
```

## Testing

### MUnit Test Coverage
The project includes comprehensive MUnit tests covering:

#### Flow Tests
- POST /items with valid payload
- POST /items with invalid payload
- POST /items with missing fields
- GET /items/{id} when item exists
- GET /items/{id} when item doesn't exist
- Stock status scheduler functionality

#### Subflow Tests
- validate-item-subflow (valid and invalid cases)
- transform-item-subflow
- store-item-subflow
- retrieve-item-subflow (found and not found)
- update-stock-status-subflow

### Running Tests
```bash
mvn clean test
```

## Build and Deployment

### Prerequisites
- Java 17+
- Maven 3.9+
- MuleSoft Runtime 4.9.3+

### Build
```bash
mvn clean compile
```

### Package
```bash
mvn clean package
```

### Deploy to Standalone Runtime
```bash
mvn clean deploy -DmuleDeploy
```

### Run Locally
```bash
mvn clean package mule:run
```

## Usage Examples

### Create an Item
```bash
curl -X POST http://localhost:8081/api/v1/items \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Wireless Headphones",
    "quantity": 15,
    "price": 199.99,
    "category": "Electronics"
  }'
```

### Get an Item
```bash
curl -X GET http://localhost:8081/api/v1/items/{item-id}
```

### Monitor Logs
The application provides detailed logging at various levels:
- INFO: Request/response logging, scheduler activities
- DEBUG: Detailed processing steps
- WARN: Non-critical issues (item not found, etc.)
- ERROR: Critical errors and exceptions

## Performance Considerations

- JSON file operations are optimized for small to medium datasets
- For production use with large datasets, consider database persistence
- Scheduler frequency can be adjusted based on business requirements
- File operations include proper error handling and recovery

## Security Features

- Input validation prevents malicious data
- Error responses don't expose sensitive information
- File operations are restricted to configured directories
- No hardcoded credentials or sensitive data

## Monitoring and Observability

- Comprehensive logging throughout all flows
- Error tracking with detailed context
- Performance metrics via standard Mule monitoring
- Health check capabilities through standard endpoints

## Future Enhancements

Potential improvements for production use:
- Database persistence (MySQL, PostgreSQL, etc.)
- Authentication and authorization
- Rate limiting and throttling
- Caching for improved performance
- Metrics and monitoring dashboards
- API versioning strategy
- Bulk operations support
- Advanced search and filtering
- Audit trail functionality
- Integration with external systems

## Support

For issues, questions, or contributions, please refer to the project documentation or contact the development team.