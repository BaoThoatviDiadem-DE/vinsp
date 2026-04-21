USE QLbanhangquanao;
GO

/* =========================================================
   1) VIEW DANH SÁCH SẢN PHẨM TỔNG HỢP
   - Dùng cho trang sản phẩm / admin sản phẩm
   ========================================================= */
DROP VIEW IF EXISTS vw_ProductSummary;
GO

CREATE VIEW vw_ProductSummary AS
SELECT
    p.product_id,
    p.name AS product_name,
    p.description,
    b.brand_id,
    b.name AS brand_name,
    c.category_id,
    c.name AS category_name,
    ISNULL(img.image_url, N'') AS thumbnail,
    ISNULL(v.total_variants, 0) AS total_variants,
    ISNULL(v.total_stock, 0) AS total_stock,
    v.min_price,
    v.max_price,
    ISNULL(r.avg_rating, 0) AS avg_rating,
    ISNULL(r.review_count, 0) AS review_count,
    p.created_at
FROM Products p
LEFT JOIN Brands b
    ON p.brand_id = b.brand_id
LEFT JOIN Categories c
    ON p.category_id = c.category_id
LEFT JOIN (
    SELECT
        product_id,
        COUNT(*) AS total_variants,
        SUM(stock) AS total_stock,
        MIN(price) AS min_price,
        MAX(price) AS max_price
    FROM ProductVariants
    GROUP BY product_id
) v
    ON p.product_id = v.product_id
LEFT JOIN (
    SELECT
        product_id,
        CAST(AVG(CAST(rating AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS avg_rating,
        COUNT(*) AS review_count
    FROM Reviews
    GROUP BY product_id
) r
    ON p.product_id = r.product_id
OUTER APPLY (
    SELECT TOP 1 image_url
    FROM ProductImages pi
    WHERE pi.product_id = p.product_id
    ORDER BY pi.image_id
) img;
GO


/* =========================================================
   2) VIEW CHI TIẾT BIẾN THỂ SẢN PHẨM
   - Dùng cho trang chi tiết sản phẩm / chọn size màu / admin
   ========================================================= */
DROP VIEW IF EXISTS vw_ProductVariantDetail;
GO

CREATE VIEW vw_ProductVariantDetail AS
SELECT
    pv.variant_id,
    p.product_id,
    p.name AS product_name,
    p.description,
    b.name AS brand_name,
    c.name AS category_name,
    s.name AS size_name,
    co.name AS color_name,
    co.hex_code,
    pv.price AS original_price,
    ISNULL(sa.discount_percent, 0) AS discount_percent,
    CAST(
        pv.price * (100 - ISNULL(sa.discount_percent, 0)) / 100.0
        AS DECIMAL(10,2)
    ) AS final_price,
    pv.stock,
    ISNULL(img.image_url, N'') AS image_url,
    pv.created_at
FROM ProductVariants pv
INNER JOIN Products p
    ON pv.product_id = p.product_id
LEFT JOIN Brands b
    ON p.brand_id = b.brand_id
LEFT JOIN Categories c
    ON p.category_id = c.category_id
INNER JOIN Sizes s
    ON pv.size_id = s.size_id
INNER JOIN Colors co
    ON pv.color_id = co.color_id
OUTER APPLY (
    SELECT MAX(sa.discount_percent) AS discount_percent
    FROM ProductSales ps
    INNER JOIN Sales sa
        ON ps.sale_id = sa.sale_id
    WHERE ps.product_id = p.product_id
      AND GETDATE() BETWEEN sa.start_date AND sa.end_date
) sa
OUTER APPLY (
    SELECT TOP 1 image_url
    FROM ProductImages pi
    WHERE pi.product_id = p.product_id
    ORDER BY pi.image_id
) img;
GO


/* =========================================================
   3) VIEW TỔNG HỢP ĐƠN HÀNG
   - Dùng cho admin quản lý đơn hàng
   ========================================================= */
DROP VIEW IF EXISTS vw_OrderSummary;
GO

CREATE VIEW vw_OrderSummary AS
SELECT
    o.order_id,
    u.user_id,
    u.name AS customer_name,
    u.email,
    u.phone,
    o.order_date,
    o.status AS order_status,
    o.total_amount,
    ISNULL(pay.method, N'') AS payment_method,
    ISNULL(pay.status, N'') AS payment_status,
    ISNULL(ship.address, u.address) AS shipping_address,
    ISNULL(ship.status, N'') AS shipping_status
FROM Orders o
INNER JOIN Users u
    ON o.user_id = u.user_id
OUTER APPLY (
    SELECT TOP 1
        p.method,
        p.status
    FROM Payments p
    WHERE p.order_id = o.order_id
    ORDER BY p.payment_id DESC
) pay
OUTER APPLY (
    SELECT TOP 1
        s.address,
        s.status
    FROM Shipping s
    WHERE s.order_id = o.order_id
    ORDER BY s.shipping_id DESC
) ship;
GO


/* =========================================================
   4) VIEW CHI TIẾT TỪNG DÒNG ĐƠN HÀNG
   - Dùng cho trang chi tiết đơn hàng / hóa đơn / admin
   ========================================================= */
DROP VIEW IF EXISTS vw_OrderItemDetail;
GO

CREATE VIEW vw_OrderItemDetail AS
SELECT
    od.order_detail_id,
    o.order_id,
    o.order_date,
    o.status AS order_status,
    u.user_id,
    u.name AS customer_name,
    u.email,
    p.product_id,
    p.name AS product_name,
    pv.variant_id,
    sz.name AS size_name,
    co.name AS color_name,
    od.quantity,
    od.price AS unit_price,
    CAST(od.quantity * od.price AS DECIMAL(12,2)) AS line_total,
    ISNULL(img.image_url, N'') AS image_url
FROM OrderDetails od
INNER JOIN Orders o
    ON od.order_id = o.order_id
INNER JOIN Users u
    ON o.user_id = u.user_id
INNER JOIN ProductVariants pv
    ON od.variant_id = pv.variant_id
INNER JOIN Products p
    ON pv.product_id = p.product_id
INNER JOIN Sizes sz
    ON pv.size_id = sz.size_id
INNER JOIN Colors co
    ON pv.color_id = co.color_id
OUTER APPLY (
    SELECT TOP 1 image_url
    FROM ProductImages pi
    WHERE pi.product_id = p.product_id
    ORDER BY pi.image_id
) img;
GO
/* =========================================================
   5) VIEW TỒN KHO SẢN PHẨM
   - Dùng cho admin kiểm tra hàng tồn
   ========================================================= */
DROP VIEW IF EXISTS vw_ProductStockStatus;
GO

CREATE VIEW vw_ProductStockStatus AS
SELECT
    p.product_id,
    p.name AS product_name,
    b.name AS brand_name,
    c.name AS category_name,
    COUNT(pv.variant_id) AS total_variants,
    ISNULL(SUM(pv.stock), 0) AS total_stock,
    CASE
        WHEN ISNULL(SUM(pv.stock), 0) = 0 THEN N'Hết hàng'
        WHEN ISNULL(SUM(pv.stock), 0) <= 5 THEN N'Sắp hết hàng'
        ELSE N'Còn hàng'
    END AS stock_status
FROM Products p
LEFT JOIN Brands b
    ON p.brand_id = b.brand_id
LEFT JOIN Categories c
    ON p.category_id = c.category_id
LEFT JOIN ProductVariants pv
    ON p.product_id = pv.product_id
GROUP BY
    p.product_id,
    p.name,
    b.name,
    c.name;
GO

/* =========================================================
   1) VIEW DANH SÁCH SẢN PHẨM CHO KHÁCH HÀNG
   - Dùng cho trang shop / products
   ========================================================= */
DROP VIEW IF EXISTS vw_CustomerProductList;
GO

CREATE VIEW vw_CustomerProductList AS
SELECT
    p.product_id,
    p.name AS product_name,
    p.description,
    b.name AS brand_name,
    c.name AS category_name,
    ISNULL(img.image_url, N'') AS thumbnail,
    ISNULL(v.total_stock, 0) AS total_stock,
    v.min_price AS original_price_from,
    CAST(
        v.min_price * (100 - ISNULL(sale.max_discount_percent, 0)) / 100.0
        AS DECIMAL(10,2)
    ) AS final_price_from,
    ISNULL(sale.max_discount_percent, 0) AS discount_percent,
    ISNULL(rv.avg_rating, 0) AS avg_rating,
    ISNULL(rv.review_count, 0) AS review_count,
    CASE
        WHEN ISNULL(v.total_stock, 0) > 0 THEN N'Còn hàng'
        ELSE N'Hết hàng'
    END AS stock_status
FROM Products p
LEFT JOIN Brands b
    ON p.brand_id = b.brand_id
LEFT JOIN Categories c
    ON p.category_id = c.category_id
LEFT JOIN (
    SELECT
        product_id,
        MIN(price) AS min_price,
        SUM(stock) AS total_stock
    FROM ProductVariants
    GROUP BY product_id
) v
    ON p.product_id = v.product_id
LEFT JOIN (
    SELECT
        ps.product_id,
        MAX(s.discount_percent) AS max_discount_percent
    FROM ProductSales ps
    INNER JOIN Sales s
        ON ps.sale_id = s.sale_id
    WHERE GETDATE() BETWEEN s.start_date AND s.end_date
    GROUP BY ps.product_id
) sale
    ON p.product_id = sale.product_id
LEFT JOIN (
    SELECT
        product_id,
        CAST(AVG(CAST(rating AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS avg_rating,
        COUNT(*) AS review_count
    FROM Reviews
    GROUP BY product_id
) rv
    ON p.product_id = rv.product_id
OUTER APPLY (
    SELECT TOP 1 image_url
    FROM ProductImages pi
    WHERE pi.product_id = p.product_id
    ORDER BY pi.image_id
) img;
GO


/* =========================================================
   2) VIEW CHI TIẾT SẢN PHẨM CHO KHÁCH HÀNG
   - Dùng cho trang product detail
   - Mỗi dòng là 1 biến thể size + màu
   ========================================================= */
DROP VIEW IF EXISTS vw_CustomerProductDetail;
GO

CREATE VIEW vw_CustomerProductDetail AS
SELECT
    p.product_id,
    p.name AS product_name,
    p.description,
    b.name AS brand_name,
    c.name AS category_name,
    pv.variant_id,
    sz.name AS size_name,
    co.name AS color_name,
    co.hex_code,
    pv.price AS original_price,
    ISNULL(sale.max_discount_percent, 0) AS discount_percent,
    CAST(
        pv.price * (100 - ISNULL(sale.max_discount_percent, 0)) / 100.0
        AS DECIMAL(10,2)
    ) AS final_price,
    pv.stock,
    CASE
        WHEN pv.stock > 0 THEN N'Còn hàng'
        ELSE N'Hết hàng'
    END AS stock_status,
    ISNULL(img.image_url, N'') AS image_url,
    ISNULL(rv.avg_rating, 0) AS avg_rating,
    ISNULL(rv.review_count, 0) AS review_count
FROM ProductVariants pv
INNER JOIN Products p
    ON pv.product_id = p.product_id
LEFT JOIN Brands b
    ON p.brand_id = b.brand_id
LEFT JOIN Categories c
    ON p.category_id = c.category_id
INNER JOIN Sizes sz
    ON pv.size_id = sz.size_id
INNER JOIN Colors co
    ON pv.color_id = co.color_id
LEFT JOIN (
    SELECT
        ps.product_id,
        MAX(s.discount_percent) AS max_discount_percent
    FROM ProductSales ps
    INNER JOIN Sales s
        ON ps.sale_id = s.sale_id
    WHERE GETDATE() BETWEEN s.start_date AND s.end_date
    GROUP BY ps.product_id
) sale
    ON p.product_id = sale.product_id
LEFT JOIN (
    SELECT
        product_id,
        CAST(AVG(CAST(rating AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS avg_rating,
        COUNT(*) AS review_count
    FROM Reviews
    GROUP BY product_id
) rv
    ON p.product_id = rv.product_id
OUTER APPLY (
    SELECT TOP 1 image_url
    FROM ProductImages pi
    WHERE pi.product_id = p.product_id
    ORDER BY pi.image_id
) img;
GO


/* =========================================================
   3) VIEW SẢN PHẨM ĐANG GIẢM GIÁ
   - Dùng cho trang khuyến mãi / sale
   ========================================================= */
DROP VIEW IF EXISTS vw_CustomerSaleProducts;
GO

CREATE VIEW vw_CustomerSaleProducts AS
SELECT
    p.product_id,
    p.name AS product_name,
    b.name AS brand_name,
    c.name AS category_name,
    s.name AS sale_name,
    s.discount_percent,
    s.start_date,
    s.end_date,
    MIN(pv.price) AS original_price_from,
    CAST(
        MIN(pv.price) * (100 - s.discount_percent) / 100.0
        AS DECIMAL(10,2)
    ) AS final_price_from,
    ISNULL(img.image_url, N'') AS thumbnail
FROM Products p
INNER JOIN ProductVariants pv
    ON p.product_id = pv.product_id
INNER JOIN ProductSales ps
    ON p.product_id = ps.product_id
INNER JOIN Sales s
    ON ps.sale_id = s.sale_id
LEFT JOIN Brands b
    ON p.brand_id = b.brand_id
LEFT JOIN Categories c
    ON p.category_id = c.category_id
OUTER APPLY (
    SELECT TOP 1 image_url
    FROM ProductImages pi
    WHERE pi.product_id = p.product_id
    ORDER BY pi.image_id
) img
WHERE GETDATE() BETWEEN s.start_date AND s.end_date
GROUP BY
    p.product_id,
    p.name,
    b.name,
    c.name,
    s.name,
    s.discount_percent,
    s.start_date,
    s.end_date,
    img.image_url;
GO


/* =========================================================
   4) VIEW CHI TIẾT GIỎ HÀNG CHO KHÁCH HÀNG
   - Dùng cho trang cart
   ========================================================= */
DROP VIEW IF EXISTS vw_CustomerCartDetail;
GO

CREATE VIEW vw_CustomerCartDetail AS
SELECT
    u.user_id,
    u.name AS customer_name,
    c.cart_id,
    ci.cart_item_id,
    p.product_id,
    p.name AS product_name,
    pv.variant_id,
    sz.name AS size_name,
    co.name AS color_name,
    ISNULL(img.image_url, N'') AS image_url,
    pv.price AS original_price,
    ISNULL(sale.max_discount_percent, 0) AS discount_percent,
    CAST(
        pv.price * (100 - ISNULL(sale.max_discount_percent, 0)) / 100.0
        AS DECIMAL(10,2)
    ) AS final_price,
    ci.quantity,
    CAST(
        ci.quantity * (pv.price * (100 - ISNULL(sale.max_discount_percent, 0)) / 100.0)
        AS DECIMAL(12,2)
    ) AS line_total,
    pv.stock
FROM Cart c
INNER JOIN Users u
    ON c.user_id = u.user_id
INNER JOIN CartItems ci
    ON c.cart_id = ci.cart_id
INNER JOIN ProductVariants pv
    ON ci.variant_id = pv.variant_id
INNER JOIN Products p
    ON pv.product_id = p.product_id
INNER JOIN Sizes sz
    ON pv.size_id = sz.size_id
INNER JOIN Colors co
    ON pv.color_id = co.color_id
LEFT JOIN (
    SELECT
        ps.product_id,
        MAX(s.discount_percent) AS max_discount_percent
    FROM ProductSales ps
    INNER JOIN Sales s
        ON ps.sale_id = s.sale_id
    WHERE GETDATE() BETWEEN s.start_date AND s.end_date
    GROUP BY ps.product_id
) sale
    ON p.product_id = sale.product_id
OUTER APPLY (
    SELECT TOP 1 image_url
    FROM ProductImages pi
    WHERE pi.product_id = p.product_id
    ORDER BY pi.image_id
) img;
GO


/* =========================================================
   5) VIEW THEO DÕI ĐƠN HÀNG CHO KHÁCH HÀNG
   - Dùng cho trang "Đơn hàng của tôi"
   ========================================================= */
DROP VIEW IF EXISTS vw_CustomerOrderTracking;
GO

CREATE VIEW vw_CustomerOrderTracking AS
SELECT
    o.order_id,
    u.user_id,
    u.name AS customer_name,
    o.order_date,
    o.status AS order_status,
    o.total_amount,
    ISNULL(pay.method, N'') AS payment_method,
    ISNULL(pay.status, N'') AS payment_status,
    ISNULL(ship.address, u.address) AS shipping_address,
    ISNULL(ship.status, N'') AS shipping_status
FROM Orders o
INNER JOIN Users u
    ON o.user_id = u.user_id
OUTER APPLY (
    SELECT TOP 1
        p.method,
        p.status
    FROM Payments p
    WHERE p.order_id = o.order_id
    ORDER BY p.payment_id DESC
) pay
OUTER APPLY (
    SELECT TOP 1
        s.address,
        s.status
    FROM Shipping s
    WHERE s.order_id = o.order_id
    ORDER BY s.shipping_id DESC
) ship;
GO


/* =========================================================
   6) VIEW REVIEW CHO KHÁCH HÀNG
   - Dùng cho phần đánh giá sản phẩm
   ========================================================= */
DROP VIEW IF EXISTS vw_CustomerProductReviews;
GO

CREATE VIEW vw_CustomerProductReviews AS
SELECT
    r.review_id,
    p.product_id,
    p.name AS product_name,
    u.user_id,
    u.name AS customer_name,
    r.rating,
    r.comment,
    r.review_date
FROM Reviews r
INNER JOIN Users u
    ON r.user_id = u.user_id
INNER JOIN Products p
    ON r.product_id = p.product_id;
GO