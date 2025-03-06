-- Create Database
CREATE DATABASE retail_inventory;
USE retail_inventory;

-- Create Tables with Schema

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10, 2) NOT NULL
);

-- Insert Data into table Products
INSERT INTO products (product_name, category, price) VALUES
('Laptop', 'Electronics', 800.00),
('Smartphone', 'Electronics', 500.00),
('Shampoo', 'Personal Care', 5.50),
('T-Shirt', 'Clothing', 15.00);

-- Suppliers-Stores supplier information
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    supplier_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100)
);

-- Insert Data into table suppliers
INSERT INTO suppliers (supplier_name, contact_email) VALUES
('TechSupplies Inc.', 'contact@techsupplies.com'),
('Care Essentials', 'info@careessentials.com');

-- Inventory-- Tracks stock levels
CREATE TABLE inventory (
    product_id INT,
    supplier_id INT,
    stock_quantity INT DEFAULT 0,
    last_restocked DATE,
    PRIMARY KEY (product_id, supplier_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- Insert into tables inventory
INSERT INTO inventory (product_id, supplier_id, stock_quantity, last_restocked) VALUES
(1, 1, 50, '2025-02-20'),
(2, 1, 30, '2025-02-18'),
(3, 2, 100, '2025-02-15');

-- Orders -- Records customer orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    order_date DATE,
    quantity INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Insert into table orders
INSERT INTO orders (product_id, order_date, quantity, total_amount) VALUES
(1, '2025-02-21', 2, 1600.00),
(2, '2025-02-22', 1, 500.00),
(3, '2025-02-23', 5, 27.50);

-- demand_forecast --predicts product demand
CREATE TABLE demand_forecast (
    product_id INT,
    forecast_month DATE,
    predicted_demand INT,
    PRIMARY KEY (product_id, forecast_month),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Insert into table demand_forecast
INSERT INTO demand_forecast (product_id, forecast_month, predicted_demand) VALUES
(1, '2025-03-01', 40),
(2, '2025-03-01', 20),
(3, '2025-03-01', 50);

-- Verify Tables and Data
SHOW TABLES;

SELECT * FROM products;
SELECT * FROM suppliers;
SELECT * FROM inventory;
SELECT * FROM orders;
SELECT * FROM demand_forecast;

-- Finding the product with low stock level which is less than 20 items in stock
SELECT p.product_name, i.stock_quantity
FROM products p
INNER JOIN inventory i ON p.product_id = i.product_id
WHERE i.stock_quantity < 20;

-- Calculating the total sales per product
SELECT p.product_name, 
       SUM(o.quantity) AS total_quantity_sold, 
       SUM(o.total_amount) AS total_sales
FROM products p
INNER JOIN orders o ON p.product_id = o.product_id
GROUP BY p.product_name
ORDER BY total_sales DESC;

-- Forecast vs. Actual Sales Comparision
SELECT p.product_name, 
       df.predicted_demand AS forecasted_demand,
       COALESCE(SUM(o.quantity), 0) AS actual_sales
FROM products p
LEFT JOIN demand_forecast df ON p.product_id = df.product_id
LEFT JOIN orders o ON p.product_id = o.product_id 
AND MONTH(o.order_date) = MONTH(df.forecast_month)
GROUP BY p.product_name, df.predicted_demand;

-- Restocking Recommendation CTE
WITH stock_analysis AS (
    SELECT p.product_id, 
           p.product_name,
           i.stock_quantity,
           df.predicted_demand
    FROM products p
    INNER JOIN inventory i ON p.product_id = i.product_id
    INNER JOIN demand_forecast df ON p.product_id = df.product_id
)
SELECT product_name, stock_quantity, predicted_demand
FROM stock_analysis
WHERE stock_quantity < (predicted_demand * 0.5);

-- Top suppliers by Sales Volume
SELECT s.supplier_name, 
       SUM(o.total_amount) AS total_sales
FROM suppliers s
INNER JOIN inventory i ON s.supplier_id = i.supplier_id
INNER JOIN orders o ON i.product_id = o.product_id
GROUP BY s.supplier_name
ORDER BY total_sales DESC;

-- Monthly sales Trend
SELECT category, 
       MONTH(order_date) AS month,
       SUM(total_amount) AS monthly_sales
FROM products p
INNER JOIN orders o ON p.product_id = o.product_id
GROUP BY category, month
ORDER BY category, month;