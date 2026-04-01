#!/bin/bash
set -e

echo "==> Initializing database with sample data..."

# Wait for MySQL to be ready
kubectl wait --for=condition=available --timeout=60s deployment/mysql -n shopizer-local

# Wait a bit more for MySQL to fully initialize
sleep 5

# Fix NULL boolean fields and add sample data
kubectl exec -n shopizer-local deployment/mysql -- mysql -uroot -ppassword SALESMANAGER <<'EOF'
-- Fix NULL boolean fields in existing data
UPDATE PRODUCT SET 
  PREORDER = COALESCE(PREORDER, 0),
  AVAILABLE = COALESCE(AVAILABLE, 1),
  PRODUCT_VIRTUAL = COALESCE(PRODUCT_VIRTUAL, 0),
  PRODUCT_SHIP = COALESCE(PRODUCT_SHIP, 1),
  PRODUCT_FREE = COALESCE(PRODUCT_FREE, 0),
  REVIEW_AVG = COALESCE(REVIEW_AVG, 0),
  REVIEW_COUNT = COALESCE(REVIEW_COUNT, 0),
  QUANTITY_ORDERED = COALESCE(QUANTITY_ORDERED, 0);

UPDATE PRODUCT_AVAILABILITY SET 
  FREE_SHIPPING = COALESCE(FREE_SHIPPING, 0),
  AVAILABLE = COALESCE(AVAILABLE, 1),
  STATUS = COALESCE(STATUS, 1);

UPDATE CUSTOMER SET 
  CUSTOMER_ANONYMOUS = COALESCE(CUSTOMER_ANONYMOUS, 0);

-- Insert sample customers for reviews
INSERT IGNORE INTO CUSTOMER (CUSTOMER_ID, MERCHANT_ID, CUSTOMER_EMAIL_ADDRESS, CUSTOMER_NICK, CUSTOMER_PASSWORD, CUSTOMER_GENDER, BILLING_FIRST_NAME, BILLING_LAST_NAME, DATE_CREATED, LANGUAGE_ID, BILLING_COUNTRY_ID, DELIVERY_COUNTRY_ID, CUSTOMER_ANONYMOUS)
VALUES 
(10, 1, 'customer1@example.com', 'john_doe', '\$2a\$10\$XQjhT8W8jcXdPQvwpbLOxe5Z9X7V8kY9vZ8X7V8kY9vZ8X7V8kY9v', 'M', 'John', 'Doe', NOW(), 1, 38, 38, 0),
(11, 1, 'customer2@example.com', 'jane_smith', '\$2a\$10\$XQjhT8W8jcXdPQvwpbLOxe5Z9X7V8kY9vZ8X7V8kY9vZ8X7V8kY9v', 'F', 'Jane', 'Smith', NOW(), 1, 38, 38, 0),
(12, 1, 'customer3@example.com', 'bob_wilson', '\$2a\$10\$XQjhT8W8jcXdPQvwpbLOxe5Z9X7V8kY9vZ8X7V8kY9vZ8X7V8kY9v', 'M', 'Bob', 'Wilson', NOW(), 1, 38, 38, 0);

-- Insert product reviews (only if products exist)
INSERT IGNORE INTO PRODUCT_REVIEW (PRODUCT_REVIEW_ID, PRODUCT_ID, CUSTOMERS_ID, REVIEWS_RATING, REVIEWS_READ, REVIEW_DATE, STATUS, DATE_CREATED)
SELECT 1, 1, 10, 5.0, 0, NOW(), 1, NOW() FROM DUAL WHERE EXISTS (SELECT 1 FROM PRODUCT WHERE PRODUCT_ID = 1)
UNION ALL
SELECT 2, 1, 11, 4.0, 0, NOW(), 1, NOW() FROM DUAL WHERE EXISTS (SELECT 1 FROM PRODUCT WHERE PRODUCT_ID = 1)
UNION ALL
SELECT 3, 2, 10, 5.0, 0, NOW(), 1, NOW() FROM DUAL WHERE EXISTS (SELECT 1 FROM PRODUCT WHERE PRODUCT_ID = 2)
UNION ALL
SELECT 4, 2, 12, 4.0, 0, NOW(), 1, NOW() FROM DUAL WHERE EXISTS (SELECT 1 FROM PRODUCT WHERE PRODUCT_ID = 2)
UNION ALL
SELECT 5, 3, 11, 5.0, 0, NOW(), 1, NOW() FROM DUAL WHERE EXISTS (SELECT 1 FROM PRODUCT WHERE PRODUCT_ID = 3);

-- Insert review descriptions
INSERT IGNORE INTO PRODUCT_REVIEW_DESCRIPTION (DESCRIPTION_ID, PRODUCT_REVIEW_ID, LANGUAGE_ID, NAME, DESCRIPTION, DATE_CREATED)
VALUES 
(1, 1, 1, 'Excellent Laptop!', 'This laptop exceeded my expectations. Fast, reliable, and great build quality.', NOW()),
(2, 2, 1, 'Great value', 'Very good laptop for the price. Highly recommend for everyday use.', NOW()),
(3, 3, 1, 'Best phone ever!', 'Amazing camera quality and battery lasts all day. Love it!', NOW()),
(4, 4, 1, 'Solid phone', 'Good performance and features. Minor issues with software updates.', NOW()),
(5, 5, 1, 'Perfect tablet', 'Lightweight and powerful. Perfect for reading and browsing.', NOW());
EOF

echo "==> Database initialization complete!"
echo "Sample reviews added for products."
