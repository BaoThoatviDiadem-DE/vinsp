const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");

dotenv.config();

const productRoutes = require("./routes/productRoutes");
const authRoutes = require("./routes/authRoutes");
const orderRoutes = require("./routes/orderRoutes");

const app = express();
const PORT = process.env.PORT || 5000;
const FRONTEND_URL = process.env.FRONTEND_URL || "http://localhost:5173";

app.use(cors());

app.use(express.json());

app.get("/", (req, res) => {
  res.json({
    message: "VinSport backend is running",
    api: "/api",
  });
});

app.use("/api/products", productRoutes);
app.use("/api", authRoutes);
app.use("/api", orderRoutes);

app.use((req, res) => {
  res.status(404).json({
    message: "Route không tồn tại",
    path: req.originalUrl,
  });
});

app.use((err, req, res, next) => {
  console.error("SERVER ERROR:", err);
  res.status(500).json({
    message: "Lỗi server",
  });
});

app.listen(PORT, () => {
  console.log(`Server chạy tại http://localhost:${PORT}`);
  console.log(`API base URL: http://localhost:${PORT}/api`);
});
