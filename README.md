# Robot BellaBot Pro — Vietnam Sourcing 2026

Phần mềm robot giới thiệu sản phẩm cho **gian A12 — khu Tây Ninh**, Triển lãm Kết nối
Chuỗi cung ứng Hàng hoá Quốc tế 2026 tại **SECC**, TP.HCM.

Robot giới thiệu sản phẩm của **24 doanh nghiệp Tây Ninh** và dẫn khách tới tận gian hàng.

| | |
|---|---|
| Khách hàng | Trung tâm Khuyến công và Xúc tiến thương mại tỉnh Tây Ninh |
| Máy | PUDU **BellaBot Pro** |
| Phần mềm | Công ty Cổ phần Tập đoàn **Roboworld** |
| Hỗ trợ kỹ thuật | **0866 153 946** |

---

## Tải về

| Tệp | Dùng để làm gì |
|---|---|
| [`su-kien-sourcing-2026-v1.1.apk`](su-kien-sourcing-2026-v1.1.apk) | Phần mềm cài lên robot — 11,1 MB |
| [`Huong-dan-trien-khai-robot-Sourcing-2026.pdf`](Huong-dan-trien-khai-robot-Sourcing-2026.pdf) | Hướng dẫn đầy đủ: cài app · đặt điểm bản đồ · tự kiểm · xử lý sự cố — 8 trang |

**Đọc PDF trước khi cài.** Cài APK không thôi là chưa đủ: ảnh, video, giọng đọc và
cấu hình đều nằm ngoài APK và phải đẩy riêng.

---

## Robot làm gì

```
KHÔNG CÓ AI  →  đi vòng qua Diem 1…Diem 5 không nghỉ
                màn chính  : mặt robot biểu cảm
                màn 18,5"  : video giới thiệu sản phẩm doanh nghiệp

KHÁCH CHẠM   →  DỪNG ĐI NGAY, hiện 9 nhóm hàng
                   ↓ chọn nhóm  →  chọn đơn vị  →  xem chi tiết
                   ↓
                ① Đến gian hàng  → báo Telegram + robot dẫn tới tận nơi
                ② Để lại số ĐT   → báo Telegram cho người trực

30 GIÂY KHÔNG AI CHẠM  →  tự về màn chờ và đi tiếp
PIN DƯỚI 15%           →  tự về "Diem Xuat Phat"
```

---

## Cài nhanh

Máy tính Windows, cáp USB cắm vào cổng ở **phần đầu robot**:

```powershell
powershell tools\cai-len-robot.ps1
```

Một lệnh làm hết: cài APK → đẩy giao diện → đẩy 60 ảnh + 8 video sản phẩm +
4 clip biểu cảm → đẩy 49 câu giọng đọc → đẩy cấu hình.

Rồi trên robot: **Cài đặt → Chức năng robot → Cài đặt mô-đun → Chọn mô-đun tự khởi
động → "Hội chợ Tây Ninh"**.

> ⚠ Phải dùng **adb 1.0.41** của Android SDK. `C:\Windows\adb.exe` là bản 1.0.39 của
> PUDU và nằm sẵn trên PATH — gõ `adb` trần là trúng nó, hai bản giết tiến trình của
> nhau rồi rớt liên tục.

---

## 14 điểm phải đặt trên bản đồ

Tên phải **trùng từng ký tự**, **không dấu tiếng Việt**:

| Tên điểm | Dùng cho |
|---|---|
| `Diem 1` `Diem 2` `Diem 3` `Diem 4` `Diem 5` | Robot đi vòng chào khách — đặt trên **lối đi** |
| `Vi tri 1` … `Vi tri 8` | 8 vị trí gian hàng trong khu A12 |
| `Diem Xuat Phat` | Pin dưới 15% robot tự về đây — đặt cạnh **trạm sạc** |

Đặt sai tên thì robot **không báo lỗi gì**, nó chỉ đứng im khi có khách bấm nút.
Vì vậy phải chạy bước tự kiểm: **bấm giữ góc dưới bên trái màn hình chờ 1,5 giây**.

Màn hình sửa bản đồ **hỏi mật khẩu kỹ thuật của PUDU** — Roboworld gửi riêng cho kỹ
thuật viên, chưa có thì gọi **0866 153 946**.

---

## Sửa nội dung — không phải cài lại app

Ảnh, video, chữ và giá nằm trên thẻ nhớ robot, không nằm trong APK:

```
/sdcard/Android/data/com.pudutech.business.sourcing/files/web/
```

Doanh nghiệp gửi thêm ảnh hoặc đổi giá thì chỉ cần:

```powershell
python dung-app.py
powershell tools\cai-len-robot.ps1 -ChiGiaoDien
```

Mất khoảng một phút. **Không** phải cài lại APK, **không** phải chọn lại mô-đun.

---

## Kho này chứa gì

Chỉ **APK và hướng dẫn**, để kỹ thuật viên tải về cài. Mã nguồn và dữ liệu doanh
nghiệp không đưa lên đây — nội dung 24 doanh nghiệp do Trung tâm Khuyến công và Xúc
tiến thương mại tỉnh Tây Ninh cung cấp, chưa được công bố.
