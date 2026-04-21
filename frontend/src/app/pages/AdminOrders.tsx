import React, { useEffect, useMemo, useState } from "react";
import api from "../api/api";

type PaymentMethod = "cod" | "banking" | "momo" | string;
type PaymentStatus = "pending" | "paid" | "failed" | string;
type OrderStatus =
  | "pending"
  | "confirmed"
  | "shipping"
  | "completed"
  | "cancelled"
  | string;

type AdminOrder = {
  id: number | string;
  order_id?: number | string;
  customerName: string;
  phone?: string;
  address?: string;
  totalAmount: number;
  paymentMethod: PaymentMethod;
  paymentStatus: PaymentStatus;
  orderStatus: OrderStatus;
  createdAt?: string;
};

const MOCK_ORDERS: AdminOrder[] = [
  {
    id: 7,
    customerName: "Chu Minh",
    phone: "0867788204",
    address: "Hà Nội",
    totalAmount: 950000,
    paymentMethod: "banking",
    paymentStatus: "pending",
    orderStatus: "pending",
    createdAt: new Date().toISOString(),
  },
  {
    id: 8,
    customerName: "Nguyễn An",
    phone: "0988123456",
    address: "Đà Nẵng",
    totalAmount: 420000,
    paymentMethod: "cod",
    paymentStatus: "pending",
    orderStatus: "confirmed",
    createdAt: new Date().toISOString(),
  },
];

function toArray(data: any): any[] {
  if (Array.isArray(data)) return data;
  if (Array.isArray(data?.orders)) return data.orders;
  if (Array.isArray(data?.data)) return data.data;
  return [];
}

function normalizeOrder(item: any): AdminOrder {
  return {
    id: item?.id ?? item?.order_id ?? item?.orderId ?? "",
    order_id: item?.order_id ?? item?.id ?? item?.orderId ?? "",
    customerName:
      item?.customerName ||
      item?.customer?.name ||
      item?.fullName ||
      item?.name ||
      "Khách hàng",
    phone: item?.phone || item?.customer?.phone || "",
    address: item?.address || item?.customer?.address || "",
    totalAmount: Number(item?.totalAmount ?? item?.total_amount ?? 0),
    paymentMethod: item?.paymentMethod || item?.payment_method || "cod",
    paymentStatus: item?.paymentStatus || item?.payment_status || "pending",
    orderStatus: item?.orderStatus || item?.order_status || "pending",
    createdAt: item?.createdAt || item?.created_at || "",
  };
}

function formatDate(value?: string) {
  if (!value) return "-";
  const d = new Date(value);
  if (Number.isNaN(d.getTime())) return value;
  return d.toLocaleString("vi-VN");
}

function formatPaymentMethod(method: string) {
  if (method === "banking") return "Chuyển khoản";
  if (method === "cod") return "COD";
  if (method === "momo") return "Momo";
  return method;
}

function formatPaymentStatus(status: string) {
  if (status === "pending") return "Chờ xác nhận";
  if (status === "paid") return "Đã thanh toán";
  if (status === "failed") return "Thất bại";
  return status;
}

function formatOrderStatus(status: string) {
  if (status === "pending") return "Chờ xử lý";
  if (status === "confirmed") return "Đã xác nhận";
  if (status === "shipping") return "Đang giao";
  if (status === "completed") return "Hoàn thành";
  if (status === "cancelled") return "Đã hủy";
  return status;
}

function paymentStatusClass(status: string) {
  if (status === "paid") return "bg-green-100 text-green-700";
  if (status === "pending") return "bg-orange-100 text-orange-700";
  if (status === "failed") return "bg-red-100 text-red-700";
  return "bg-slate-100 text-slate-700";
}

function orderStatusClass(status: string) {
  if (status === "completed") return "bg-green-100 text-green-700";
  if (status === "shipping") return "bg-blue-100 text-blue-700";
  if (status === "confirmed") return "bg-emerald-100 text-emerald-700";
  if (status === "cancelled") return "bg-red-100 text-red-700";
  return "bg-slate-100 text-slate-700";
}

export default function AdminOrders() {
  const [orders, setOrders] = useState<AdminOrder[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [keyword, setKeyword] = useState("");
  const [savingId, setSavingId] = useState<number | string | null>(null);

  const loadOrders = async () => {
    try {
      setIsLoading(true);

      try {
        const data = await api.get("/admin/orders");
        const normalized = toArray(data).map(normalizeOrder);
        setOrders(normalized.length > 0 ? normalized : MOCK_ORDERS);
      } catch {
        setOrders(MOCK_ORDERS);
      }
    } catch (error) {
      console.error("Lỗi tải đơn hàng:", error);
      setOrders(MOCK_ORDERS);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadOrders();
  }, []);

  const filteredOrders = useMemo(() => {
    const q = keyword.trim().toLowerCase();
    if (!q) return orders;

    return orders.filter((order) => {
      return (
        String(order.id).toLowerCase().includes(q) ||
        String(order.customerName).toLowerCase().includes(q) ||
        String(order.phone || "").toLowerCase().includes(q) ||
        String(order.address || "").toLowerCase().includes(q) ||
        String(order.paymentMethod).toLowerCase().includes(q) ||
        String(order.paymentStatus).toLowerCase().includes(q) ||
        String(order.orderStatus).toLowerCase().includes(q)
      );
    });
  }, [orders, keyword]);

  const handleOrderFieldChange = (
    id: number | string,
    field: "paymentStatus" | "orderStatus",
    value: string
  ) => {
    setOrders((prev) =>
      prev.map((order) =>
        order.id === id ? { ...order, [field]: value } : order
      )
    );
  };

  const handleSaveOrderStatus = async (order: AdminOrder) => {
    try {
      setSavingId(order.id);

      await api.put(`/admin/orders/${order.id}/status`, {
        status: order.orderStatus,
      });

      alert("Cập nhật trạng thái đơn hàng thành công");
      await loadOrders();
    } catch (error) {
      console.error("Lỗi cập nhật trạng thái đơn hàng:", error);
      alert("Không cập nhật được trạng thái đơn hàng");
    } finally {
      setSavingId(null);
    }
  };

  const handleSavePaymentStatus = async (order: AdminOrder) => {
    try {
      setSavingId(order.id);

      await api.put(`/admin/orders/${order.id}/payment-status`, {
        status: order.paymentStatus,
      });

      alert("Cập nhật trạng thái thanh toán thành công");
      await loadOrders();
    } catch (error) {
      console.error("Lỗi cập nhật trạng thái thanh toán:", error);
      alert("Không cập nhật được trạng thái thanh toán");
    } finally {
      setSavingId(null);
    }
  };

  return (
    <div className="max-w-7xl mx-auto p-6 space-y-6">
      <div>
        <h1 className="text-3xl font-bold text-slate-900">Quản lý đơn hàng</h1>
        <p className="text-slate-600 mt-2">
          Xem đơn hàng, cập nhật trạng thái đơn hàng và trạng thái thanh toán.
        </p>
      </div>

      <div className="bg-white rounded-2xl shadow-sm border p-5">
        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-3 mb-4">
          <div className="flex items-center gap-3 flex-wrap">
            <h2 className="text-xl font-semibold">Danh sách đơn hàng</h2>
            <span className="px-3 py-1 rounded-full bg-orange-100 text-orange-700 text-sm font-semibold">
              Tổng số: {orders.length}
            </span>
          </div>

          <input
            value={keyword}
            onChange={(e) => setKeyword(e.target.value)}
            placeholder="Tìm theo mã đơn, tên khách, SĐT..."
            className="w-full md:w-80 border rounded-xl px-4 py-3 outline-none focus:ring"
          />
        </div>

        {isLoading ? (
          <div className="py-10 text-center text-slate-500">
            Đang tải đơn hàng...
          </div>
        ) : filteredOrders.length === 0 ? (
          <div className="py-10 text-center text-slate-500">
            Không có đơn hàng nào.
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full min-w-[1500px] border-collapse">
              <thead>
                <tr className="bg-slate-100 text-left">
                  <th className="p-3 border-b">Mã đơn</th>
                  <th className="p-3 border-b">Khách hàng</th>
                  <th className="p-3 border-b">SĐT</th>
                  <th className="p-3 border-b">Địa chỉ</th>
                  <th className="p-3 border-b">Tổng tiền</th>
                  <th className="p-3 border-b">Phương thức</th>
                  <th className="p-3 border-b">TT thanh toán</th>
                  <th className="p-3 border-b">TT đơn hàng</th>
                  <th className="p-3 border-b">Ngày tạo</th>
                  <th className="p-3 border-b">Thao tác</th>
                </tr>
              </thead>

              <tbody>
                {filteredOrders.map((order) => (
                  <tr key={String(order.id)} className="hover:bg-slate-50">
                    <td className="p-3 border-b font-semibold">#{order.id}</td>
                    <td className="p-3 border-b">{order.customerName}</td>
                    <td className="p-3 border-b">{order.phone || "-"}</td>
                    <td className="p-3 border-b">{order.address || "-"}</td>
                    <td className="p-3 border-b font-medium">
                      {Number(order.totalAmount || 0).toLocaleString("vi-VN")} đ
                    </td>
                    <td className="p-3 border-b">
                      {formatPaymentMethod(order.paymentMethod)}
                    </td>

                    <td className="p-3 border-b">
                      <div className="flex flex-col gap-2">
                        <span
                          className={`inline-flex w-fit px-3 py-1 rounded-full text-sm font-semibold ${paymentStatusClass(
                            order.paymentStatus
                          )}`}
                        >
                          {formatPaymentStatus(order.paymentStatus)}
                        </span>
                        <select
                          value={order.paymentStatus}
                          onChange={(e) =>
                            handleOrderFieldChange(
                              order.id,
                              "paymentStatus",
                              e.target.value
                            )
                          }
                          className="border rounded-lg px-3 py-2"
                        >
                          <option value="pending">pending</option>
                          <option value="paid">paid</option>
                          <option value="failed">failed</option>
                        </select>
                      </div>
                    </td>

                    <td className="p-3 border-b">
                      <div className="flex flex-col gap-2">
                        <span
                          className={`inline-flex w-fit px-3 py-1 rounded-full text-sm font-semibold ${orderStatusClass(
                            order.orderStatus
                          )}`}
                        >
                          {formatOrderStatus(order.orderStatus)}
                        </span>
                        <select
                          value={order.orderStatus}
                          onChange={(e) =>
                            handleOrderFieldChange(
                              order.id,
                              "orderStatus",
                              e.target.value
                            )
                          }
                          className="border rounded-lg px-3 py-2"
                        >
                          <option value="pending">pending</option>
                          <option value="confirmed">confirmed</option>
                          <option value="shipping">shipping</option>
                          <option value="completed">completed</option>
                          <option value="cancelled">cancelled</option>
                        </select>
                      </div>
                    </td>

                    <td className="p-3 border-b">
                      {formatDate(order.createdAt)}
                    </td>

                    <td className="p-3 border-b">
                      <div className="flex flex-col gap-2">
                        <button
                          onClick={() => handleSaveOrderStatus(order)}
                          disabled={savingId === order.id}
                          className="px-4 py-2 rounded-lg bg-orange-500 text-white hover:bg-orange-600 disabled:opacity-60"
                        >
                          {savingId === order.id
                            ? "Đang lưu..."
                            : "Lưu trạng thái đơn"}
                        </button>

                        <button
                          onClick={() => handleSavePaymentStatus(order)}
                          disabled={savingId === order.id}
                          className="px-4 py-2 rounded-lg bg-green-600 text-white hover:bg-green-700 disabled:opacity-60"
                        >
                          {savingId === order.id
                            ? "Đang lưu..."
                            : "Lưu trạng thái thanh toán"}
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}