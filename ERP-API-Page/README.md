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

Mỗi bảng có một API Page hỗ trợ GET/POST. Thư mục `postman` chứa các request chuẩn bị cho việc kiểm thử. File `TrainingApi.PermissionSet.al` khai báo quyền cho phần training và các API Page.

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
- Chưa chạy GET/POST trực tiếp trên sandbox; cần cấu hình xác thực API từ người phụ trách.
