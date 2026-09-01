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

## ⚠ Kỹ thuật viên: đọc mục này trước

**File APK trong kho này KHÔNG chạy một mình.** Ảnh, video, giọng đọc và cấu hình đều
nằm ngoài APK — cài mỗi APK thì robot mở lên chỉ hiện một trang báo *"chưa nạp nội dung"*.

Để cài được robot, cần **bộ cài đầy đủ** do Roboworld gửi riêng qua Drive hoặc USB:

```
Cai-dat-Sourcing-2026/       (khoảng 300 MB)
  DOC-TRUOC.txt              đọc file này đầu tiên
  KIEM-TRA.bat               nháy đúp — xem robot đang có gì
  CAI-DAT.bat                nháy đúp — cài tất cả lên robot
  DOI-NOI-DUNG.bat           nháy đúp — chỉ đẩy lại ảnh/video
  Huong-dan-...-2026.pdf     hướng dẫn đầy đủ
  cai-len-robot.ps1 · adb\ · app\ · noi-dung\
```

Không cần cài Python, không cần cài Android SDK — **bộ cài kèm sẵn công cụ**.

**Chưa có bộ cài → gọi 0866 153 946.**

Kho công khai này chỉ giữ **APK và hướng dẫn**. Nội dung 24 doanh nghiệp không đưa lên
đây: trong đó có số điện thoại người đại diện, do Trung tâm Khuyến công và Xúc tiến
thương mại tỉnh Tây Ninh cung cấp để robot trưng bày tại hội chợ.

---

## Tải về

| Tệp | Dùng để làm gì |
|---|---|
| [`Huong-dan-trien-khai-robot-Sourcing-2026.pdf`](Huong-dan-trien-khai-robot-Sourcing-2026.pdf) | Hướng dẫn đầy đủ: cài app · đặt điểm bản đồ · tự kiểm · xử lý sự cố — 8 trang |
| [`su-kien-sourcing-2026-v1.1.apk`](su-kien-sourcing-2026-v1.1.apk) | Bản APK dự phòng, 11,1 MB. Bộ cài đã có sẵn file này — chỉ tải riêng khi cần cài lại mỗi app |

---

## ⚠ BellaBot Pro cài phần mềm QUA MẠNG, không cắm cáp USB

Máy tính và robot phải nối **chung một mạng Wi-Fi**. Bộ cài **tự dò tìm robot** trên
mạng, không phải đi tìm địa chỉ IP.

Đây là điểm khác với robot lễ tân GreetingBot Nova (nối bằng cáp USB ở đầu máy).

Robot cũng phải đã bật **“Gỡ lỗi lâu dài”** và **khởi động lại** — Roboworld bật sẵn
trước khi giao máy.

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

Doanh nghiệp gửi thêm ảnh hoặc đổi giá → Roboworld gửi thư mục `noi-dung` mới, kỹ thuật
viên chép đè vào bộ cài rồi nháy đúp **`DOI-NOI-DUNG.bat`**.

Mất khoảng một phút. **Không** phải cài lại APK, **không** phải chọn lại mô-đun,
**không** phải đặt lại điểm bản đồ.
