USE Dominos;

-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_order 
FROM 
    orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(a.Quantity * b.price), 2) AS total_sales
FROM
    order_details AS a
JOIN
    pizzas AS b ON a.pizza_id = b.pizza_id;
    
-- Identify the highest-priced pizza.
SELECT 
    MAX(pz.price)
FROM
    pizza_types AS p
JOIN
    pizzas AS pz ON p.pizza_type_id = pz.pizza_type_id;
    
-- Identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY 
    pizzas.size
ORDER BY 
    order_count DESC 
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    c.name, 
    SUM(a.Quantity) AS pizza_count
FROM
    order_details AS a
JOIN
    pizzas AS b ON a.pizza_id = b.pizza_id
JOIN
    pizza_types AS c ON b.pizza_type_id = c.pizza_type_id
GROUP BY 
    c.name
ORDER BY 
    pizza_count DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    c.category, 
    SUM(a.Quantity) AS pizza_category_count
FROM
    order_details AS a
JOIN
    pizzas AS b ON a.pizza_id = b.pizza_id
JOIN
    pizza_types AS c ON b.pizza_type_id = c.pizza_type_id
GROUP BY 
    c.category
ORDER BY 
    pizza_category_count DESC;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time), 
    COUNT(order_id)
FROM
    orders
GROUP BY 
    HOUR(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, 
    COUNT(name)
FROM
    pizza_types
GROUP BY 
    category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) AS Avg_pizzas_order 
FROM 
    (SELECT 
        a.order_date, 
        SUM(b.Quantity) AS quantity
     FROM 
        orders AS a
     JOIN
        order_details AS b ON a.order_id = b.order_id
     GROUP BY 
        a.order_date
    ) AS order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    c.name, 
    SUM(a.Quantity * b.price) AS revenue
FROM
    order_details AS a
JOIN
    pizzas AS b ON a.pizza_id = b.pizza_id
JOIN
    pizza_types AS c ON b.pizza_type_id = c.pizza_type_id
GROUP BY 
    c.name
ORDER BY 
    revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

-- 1st method
SELECT 
    revenue_per_pizza_type.name,
    (revenue_per_pizza_type.revenue / total_revenue.total_revenue_all) * 100 AS percentage_revenue
FROM 
    (SELECT 
        c.name, 
        SUM(a.Quantity * b.price) AS revenue
     FROM 
        order_details AS a
     JOIN 
        pizzas AS b ON a.pizza_id = b.pizza_id
     JOIN 
        pizza_types AS c ON b.pizza_type_id = c.pizza_type_id
     GROUP BY 
        c.name
    ) AS revenue_per_pizza_type
CROSS JOIN 
    (SELECT 
        SUM(a.Quantity * b.price) AS total_revenue_all
     FROM 
        order_details AS a
     JOIN 
        pizzas AS b ON a.pizza_id = b.pizza_id
    ) AS total_revenue
ORDER BY 
    percentage_revenue DESC
LIMIT 3;

-- 2nd method
SELECT 
    revenue_per_pizza_type.category, 
    (revenue / total_revenue_all) * 100 AS percentage_revenue
FROM 
    (SELECT 
        c.category, 
        SUM(a.Quantity * b.price) AS revenue
     FROM 
        order_details AS a
     JOIN 
        pizzas AS b ON a.pizza_id = b.pizza_id
     JOIN 
        pizza_types AS c ON b.pizza_type_id = c.pizza_type_id
     GROUP BY 
        c.category
    ) AS revenue_per_pizza_type,
    (SELECT 
        SUM(a.Quantity * b.price) AS total_revenue_all
     FROM 
        order_details AS a
     JOIN 
        pizzas AS b ON a.pizza_id = b.pizza_id
    ) AS total_revenue_subquery
ORDER BY 
    percentage_revenue DESC;

-- 3rd method
SELECT 
    revenue_per_pizza_type.category,
    (revenue / total_revenue_all) * 100 AS percentage_revenue
FROM 
    (SELECT 
        c.category, 
        SUM(a.Quantity * b.price) AS revenue,
        (SELECT SUM(a.Quantity * b.price)
         FROM order_details AS a
         JOIN pizzas AS b ON a.pizza_id = b.pizza_id
        ) AS total_revenue_all
     FROM 
        order_details AS a
     JOIN 
        pizzas AS b ON a.pizza_id = b.pizza_id
     JOIN 
        pizza_types AS c ON b.pizza_type_id = c.pizza_type_id
     GROUP BY 
        c.category
    ) AS revenue_per_pizza_type
ORDER BY 
    percentage_revenue DESC;

-- Analyze the cumulative revenue generated over time.
SELECT 
    revenue_table.order_date, 
    SUM(revenue) OVER (ORDER BY revenue_table.order_date) AS cum_revenue
FROM
    (SELECT 
        b.order_date, 
        SUM(a.Quantity * c.price) AS revenue
     FROM 
        order_details AS a
     JOIN 
        orders AS b ON a.order_id = b.order_id
     JOIN 
        pizzas AS c ON a.pizza_id = c.pizza_id
     GROUP BY 
        b.order_date
    ) AS revenue_table;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT 
    rank_table.category, 
    rank_table.name, 
    rank_table.revenue, 
    rn 
FROM
    (SELECT 
        revenue_table.category,
        revenue_table.name,
        revenue_table.revenue, 
        RANK() OVER (PARTITION BY revenue_table.category ORDER BY revenue_table.revenue DESC) AS rn
     FROM 
        (SELECT 
            d.name,
            d.category, 
            SUM(a.Quantity * c.price) AS revenue
         FROM 
            order_details AS a
         JOIN 
            orders AS b ON a.order_id = b.order_id
         JOIN 
            pizzas AS c ON a.pizza_id = c.pizza_id
         JOIN 
            pizza_types AS d ON c.pizza_type_id = d.pizza_type_id
         GROUP BY 
            d.name, d.category
        ) AS revenue_table
    ) AS rank_table
WHERE 
    rn <= 3;

    
    











