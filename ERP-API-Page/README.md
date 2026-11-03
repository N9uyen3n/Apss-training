# Bài tập API Page và Page Inspection

## Yêu cầu

- Tạo API Page cho bảng training, hỗ trợ GET và POST.
- Dùng Page Inspection trên Customer List để tìm Page ID, source table và Field ID của Customer Name.

## Mô tả code

Bảng `Training Entry` lưu mã, mô tả, số lượng, đơn giá và thành tiền. Khi thêm dữ liệu, code kiểm tra mã và mô tả không trống, số lượng lớn hơn 0, đơn giá không âm. Thành tiền được tính bằng số lượng nhân đơn giá, làm tròn đến 0.01.

File `TrainingEntries.ApiPage.al` cung cấp API `trainingEntries`: GET để đọc dữ liệu, POST để tạo bản ghi. API dùng `SystemId` để định danh bản ghi và không cho sửa hoặc xóa.

Từ bài gốc, em mở rộng API Page để tìm hiểu thêm các bảng:

| Bảng | Nội dung tìm hiểu | API |
| --- | --- | --- |
| Training Entry (80201) | Tạo bảng riêng và xử lý dữ liệu đầu vào | `trainingEntries` |
| Customer (18) | Lưu thông tin khách hàng như mã và tên | `customerExamples` |
| Vendor (23) | Lưu thông tin nhà cung cấp như mã và tên | `vendorExamples` |
| Item (27) | Lưu thông tin mặt hàng và đơn vị tính cơ bản; tạo mặt hàng chưa làm tăng tồn kho | `itemExamples` |
| Purchase Header (38) | Lưu phần đầu chứng từ mua hàng; API chỉ xử lý loại Order, chưa tạo dòng đơn | `purchaseOrderExamples` |

Mỗi bảng có một API Page hỗ trợ GET/POST. File `TrainingApi.PermissionSet.al` khai báo quyền cho phần training và các API Page.

## Giả lập GET/POST trong BC

Theo hướng dẫn bổ sung, em tạo page **Training API Demo (80207)** với hai action GET và POST, không cần Entra App ID hay Postman. Đây là mô phỏng bằng AL, không gọi HTTP đến API Page.

1. Publish lại extension bằng `Ctrl+F5` trong VS Code.
2. Trong BC, nhấn `Alt+Q`, tìm **Training API Demo**.
3. Trang điền sẵn mã mẫu, mô tả, số lượng 2 và đơn giá 125.5. Bấm **POST** để lưu vào Training Entry và xem JSON với amount = 251.
4. Giữ nguyên mã và bấm **GET** để đọc lại bản ghi. Xóa Number nếu muốn đọc tối đa 50 bản ghi.
5. POST lại cùng mã sẽ báo trùng; số lượng không hợp lệ hoặc giá âm sẽ bị từ chối. Muốn tạo bản ghi khác, đổi mã hoặc mở lại trang để có mã mẫu mới.

GET chỉ đọc; POST lưu dữ liệu thật vào bảng training, không tạo khách hàng, mặt hàng hay chứng từ mua hàng. Có thể chụp phần Simulation Result làm kết quả thực hành.

## Kết quả Page Inspection

Mở Customer List và nhấn `Ctrl+Alt+F1`, em ghi nhận:

| Thông tin | Kết quả |
| --- | --- |
| Page | Customer List — **22** |
| Source table | Customer — **18** |
| Customer Name | Name — Field ID **2**, kiểu `Text[100]` |

Qua phần này, em hiểu thêm cách xác định page đang sử dụng bảng nào và phân biệt tên field hiển thị với Field ID trong bảng.

## Tiến độ

- Code đã build và publish thành công lên sandbox.
- Đã thực hiện Page Inspection và chụp ảnh kết quả.
- Đã bổ sung hai action giả lập GET/POST; cần publish bản cập nhật và bấm thử trên sandbox để chụp kết quả. API HTTP chưa được kiểm thử.
