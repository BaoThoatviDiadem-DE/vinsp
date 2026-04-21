--1. BRANDS
INSERT INTO Brands (name)
VALUES 
(N'Nike'),
(N'Adidas'),
(N'Puma'),
(N'Reebok'),
(N'Under Armour');

--2. CATEGORIES
INSERT INTO Categories (name)
VALUES 
(N'Áo bóng đá'),
(N'Áo gym'),
(N'Quần short'),
(N'Quần dài thể thao'),
(N'Giày chạy bộ'),
(N'Áo khoác thể thao');

--3. COLORS
INSERT INTO Colors (name, hex_code)
VALUES 
(N'Đen', '#000000'),
(N'Trắng', '#FFFFFF'),
(N'Đỏ', '#FF0000'),
(N'Xanh dương', '#0000FF'),
(N'Xanh lá', '#00FF00'),
(N'Xám', '#808080');

--4. SIZES
INSERT INTO Sizes (name)
VALUES 
(N'S'),
(N'M'),
(N'L'),
(N'XL'),
(N'XXL'),
(N'40'),
(N'41'),
(N'42'),
(N'43'),
(N'44'),
(N'45');

--5. USERS
-- role không cần insert vì mặc định database sẽ gán là N'user'
INSERT INTO Users (name, email, password, phone, address)
VALUES 
(N'Nguyễn Văn A', 'a@gmail.com', '123456', '0901111111', N'Hà Nội'),
(N'Trần Thị B', 'b@gmail.com', '123456', '0901111112', N'Hà Nội'),
(N'Lê Văn C', 'c@gmail.com', '123456', '0901111113', N'Hồ Chí Minh'),
(N'Phạm Văn D', 'd@gmail.com', '123456', '0901111114', N'Đà Nẵng'),
(N'Hoàng Văn E', 'e@gmail.com', '123456', '0901111115', N'Hải Phòng'),
(N'Nguyễn Văn F', 'f@gmail.com', '123456', '0901111116', N'Hà Nội'),
(N'Trần Văn G', 'g@gmail.com', '123456', '0901111117', N'Hồ Chí Minh'),
(N'Lê Thị H', 'h@gmail.com', '123456', '0901111118', N'Cần Thơ'),
(N'Phạm Thị I', 'i@gmail.com', '123456', '0901111119', N'Huế'),
(N'Võ Văn K', 'k@gmail.com', '123456', '0901111120', N'Hà Nội'),
(N'Đặng Văn L', 'l@gmail.com', '123456', '0901111121', N'Hải Dương'),
(N'Bùi Văn M', 'm@gmail.com', '123456', '0901111122', N'Nghệ An'),
(N'Đỗ Văn N', 'n@gmail.com', '123456', '0901111123', N'Hà Nội'),
(N'Ngô Văn O', 'o@gmail.com', '123456', '0901111124', N'Hồ Chí Minh'),
(N'Huỳnh Văn P', 'p@gmail.com', '123456', '0901111125', N'Bình Dương');

--6. PRODUCTS
INSERT INTO Products (name, description, brand_id, category_id)
VALUES 
(N'Áo đá banh Nike 2024', N'Áo bóng đá thoáng khí', 1, 1),
(N'Áo gym Adidas Pro', N'Áo tập gym co giãn tốt', 2, 2),
(N'Quần short Puma Run', N'Quần chạy bộ nhẹ', 3, 3),
(N'Giày chạy Adidas Ultraboost', N'Giày chạy cao cấp', 2, 5),
(N'Áo khoác Nike Windrunner', N'Áo khoác chống gió', 1, 6), 
(N'Quần dài Reebok Training', N'Quần tập luyện', 4, 4),
(N'Áo gym Under Armour HeatGear', N'Áo thể thao ôm sát', 5, 2),
(N'Giày chạy Puma Velocity', N'Giày chạy nhẹ', 3, 5),
(N'Áo bóng đá Adidas Real Madrid', N'Áo CLB Real Madrid', 2, 1),
(N'Quần short Nike Flex', N'Quần short linh hoạt', 1, 3),
(N'Áo khoác Puma Sport', N'Áo khoác thể thao', 3, 6),
(N'Giày Reebok Nano', N'Giày training gym', 4, 5);

-- thêm sản phẩm
INSERT INTO Products (name, description, brand_id, category_id)
VALUES
(N'Áo bóng đá Puma Future 2026', N'Áo bóng đá thoáng khí, thiết kế trẻ trung', 3, 1),
(N'Áo gym Nike Dri-FIT Elite', N'Áo gym thấm hút mồ hôi, co giãn tốt', 1, 2),
(N'Quần short Adidas Runner', N'Quần short chạy bộ nhẹ, thoải mái khi vận động', 2, 3),
(N'Giày chạy Nike Air Zoom', N'Giày chạy bộ đệm êm, hỗ trợ bám đường tốt', 1, 5), --sai mau (den)
(N'Áo khoác Under Armour Storm', N'Áo khoác thể thao chống gió, chống nước nhẹ', 5, 6),
(N'Quần dài Puma Training Pro', N'Quần dài thể thao mềm mại, phù hợp tập luyện', 3, 4);

--7. PRODUCT VARIANTS
INSERT INTO ProductVariants (product_id, size_id, color_id, price, stock)
VALUES
(1, 1, 1, 450000, 20),
(1, 2, 2, 450000, 25),
(1, 3, 3, 450000, 15),

(2, 1, 1, 350000, 30),
(2, 2, 4, 350000, 35),
(2, 3, 2, 350000, 40),

(3, 2, 1, 280000, 50),
(3, 3, 2, 280000, 45),
(3, 4, 6, 280000, 20),

(4, 7, 1, 2500000, 10),
(4, 8, 1, 2500000, 8),
(4, 9, 3, 2500000, 5),

(5, 1, 1, 900000, 12),
(5, 2, 1, 900000, 18),

(6, 2, 6, 400000, 25),
(6, 3, 2, 400000, 20),

(7, 1, 2, 320000, 30),
(7, 2, 3, 320000, 28),

(8, 9, 1, 1500000, 15),
(8, 10, 2, 1500000, 10),

(9, 2, 3, 500000, 22),
(9, 3, 1, 500000, 18),

(10, 1, 5, 300000, 40),
(10, 2, 6, 300000, 35),

(11, 3, 1, 600000, 20),
(11, 4, 1, 600000, 15),

(12, 7, 2, 1200000, 12),
(12, 9, 3, 1200000, 10);

-- THÊM SẢN PHẨM
INSERT INTO ProductVariants (product_id, size_id, color_id, price, stock)
VALUES
-- 13. Áo bóng đá Puma Future 2026
(13, 1, 3, 480000, 20),
(13, 2, 2, 480000, 25),
(13, 3, 4, 480000, 18),

-- 14. Áo gym Nike Dri-FIT Elite
(14, 1, 1, 390000, 30),
(14, 2, 3, 390000, 28),
(14, 3, 2, 390000, 22),

-- 15. Quần short Adidas Runner
(15, 2, 1, 310000, 35),
(15, 3, 6, 310000, 30),
(15, 4, 2, 310000, 20),

-- 16. Giày chạy Nike Air Zoom
(16, 6, 1, 2200000, 12),
(16, 8, 1, 2200000, 10),
(16, 10, 4, 2200000, 8),

-- 17. Áo khoác Under Armour Storm
(17, 2, 1, 950000, 15),
(17, 3, 6, 950000, 12),
(17, 4, 2, 950000, 10),

-- 18. Quần dài Puma Training Pro
(18, 2, 1, 420000, 25),
(18, 3, 5, 420000, 20),
(18, 4, 6, 420000, 18);

--8. SALES
INSERT INTO Sales (name, discount_percent, start_date, end_date)
VALUES 
(N'Black Friday', 30, '2026-04-01', '2026-04-30'),
(N'Summer Sale', 20, '2026-05-01', '2026-05-31'),
(N'Flash Sale', 10, '2026-04-10', '2026-04-20');

--9. PRODUCT SALES
INSERT INTO ProductSales (product_id, sale_id)
VALUES 
(1,1),(2,1),(3,1),
(4,2),(5,2),(6,2),
(7,3),(8,3),(9,3);

--10. CART + CART ITEMS
INSERT INTO Cart (user_id)
VALUES (1),(2),(3),(4),(5);

INSERT INTO CartItems (cart_id, variant_id, quantity)
VALUES 
(1,1,2),
(1,3,1),
(2,5,1),
(3,10,2),
(4,15,1),
(5,20,3);

--11. ORDERS
INSERT INTO Orders (user_id, status, total_amount)
VALUES 
(1, N'Pending', 900000),
(2, N'Completed', 700000),
(3, N'Shipping', 2500000),
(4, N'Confirmed', 600000),
(5, N'Cancelled', 300000);

--12. ORDER DETAILS
INSERT INTO OrderDetails (order_id, variant_id, quantity, price)
VALUES 
(1,1,2,450000),
(2,2,2,350000),
(3,4,1,2500000),
(4,6,1,600000),
(5,10,1,300000);

--13. PAYMENTS
INSERT INTO Payments (order_id, method, status)
VALUES 
(1, N'COD', N'Paid'),
(2, N'Momo', N'Paid'),
(3, N'Bank', N'Pending'),
(4, N'COD', N'Paid'),
(5, N'Momo', N'Failed');

--14. SHIPPING
INSERT INTO Shipping (order_id, address, status)
VALUES 
(1, N'Hà Nội', N'Preparing'),
(2, N'Hồ Chí Minh', N'Delivered'),
(3, N'Đà Nẵng', N'Shipping'),
(4, N'Hải Phòng', N'Pending'),
(5, N'Huế', N'Cancelled');

--15. REVIEWS
INSERT INTO Reviews (user_id, product_id, rating, comment)
VALUES 
(1,1,5,N'Áo đẹp, chất lượng tốt'),
(2,2,4,N'Ok, mặc thoải mái'),
(3,3,5,N'Rất đáng tiền'),
(4,4,5,N'Giày chạy rất êm'),
(5,5,3,N'Bình thường');