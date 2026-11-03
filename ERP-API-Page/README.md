# Bài tập API page và Page Inspection

Yêu cầu của Nick: tạo API GET/POST cho bảng training; dùng Page Inspection trên Customer List; push code và gửi ảnh kết quả. Phần mở rộng áp dụng cho **5 bảng hiện có** trong dự án.

## API đã triển khai

Tất cả dùng publisher `neo`, group `training`, version `v1.0`, khóa URL `SystemId`. Cho phép GET/POST, tắt PATCH/DELETE; `id` chỉ đọc.

| Page ID | Source table | Entity set | POST bắt buộc | POST tùy chọn |
| --- | --- | --- | --- | --- |
| 80201 | 80201 Training Entry | `trainingEntries` | number, description, quantity > 0 | unitPrice >= 0, mặc định 0 |
| 80202 | 18 Customer | `customerExamples` | number, name | — |
| 80203 | 23 Vendor | `vendorExamples` | number, name | — |
| 80204 | 27 Item | `itemExamples` | number, description | baseUnitOfMeasure |
| 80206 | 38 Purchase Header, chỉ Order | `purchaseOrderExamples` | vendorNumber | number, orderDate |

Các URL `*Examples` giữ tên cũ; file/caption đã bỏ chữ Read vì hỗ trợ cả POST.

Training Entry là bảng mẫu của dự án. `amount = Round(quantity * unitPrice, 0.01)` là quy ước học tập. Table OnInsert/OnModify kiểm tra và tính tiền khi đường ghi chạy trigger (`Insert(true)`/`Modify(true)`); code AL bỏ trigger vẫn có thể bỏ qua quy tắc. API không cho ghi amount.

Customer/Vendor tạo danh mục tối thiểu, chưa đủ cấu hình giao dịch. Item tạo danh mục, không tạo tồn kho. API chèn Item trước rồi Validate UOM để tránh trigger chuẩn chèn sớm khi chưa nhận đủ JSON. Purchase Order chỉ tạo header, chưa có dòng hay posting: Insert(true) khởi tạo số/ngày, Validate vendor, rồi áp dụng orderDate và Modify(true). Các API không gọi COMMIT.

## Build và publish

1. Mở thư mục **Code** bằng VS Code, cài AL Language.
2. Tạo/cấu hình `.vscode/launch.json` cho sandbox, đăng nhập và chạy **AL: Download Symbols**. Launch là cấu hình cá nhân, không push.
3. Manifest hiện dùng runtime **17.1**, kiểm tra với symbols **BC 28.5**. Nếu dùng BC cũ hơn, đối chiếu runtime và dependencies. Giữ App ID khi cập nhật extension đã cài.
4. Chạy **AL: Package** rồi Ctrl+F5 (hoặc F5 để debug). Máy hiện có symbols ở thư mục cha: có thể đặt VS Code setting `al.packageCachePath` là `../.alpackages`, hoặc tải lại vào cache của project.
5. Gán permission set **NEO TRAINING API** cho tài khoản gọi API. Set này cấp đọc/thêm Training Entry và chạy API page. Quyền bảng chuẩn và bảng liên quan phải có từ permission set nghiệp vụ của tài khoản.

## Chạy bằng Postman

Import [collection](postman/TrainingAPI.postman_collection.json) và [environment mẫu](postman/Sandbox.postman_environment.json). Điền các biến local:

| Biến | Giá trị |
| --- | --- |
| tenantId | Tenant của sandbox |
| environmentName | Tên sandbox |
| companyId | GUID công ty từ request Companies |
| accessToken | OAuth 2.0 token có audience Business Central, chỉ lưu local |
| baseUnitOfMeasure | Mã UOM đã tồn tại, ví dụ PCS nếu sandbox có mã đó |
| existingVendorNumber | Vendor đã có posting groups, không blocked, dùng được cho đơn mua |

Dùng Postman OAuth 2.0 hoặc lấy token theo cấu hình Entra ID của quản trị viên. Scope delegated thường dùng `https://api.businesscentral.dynamics.com/user_impersonation`; client credentials dùng `https://api.businesscentral.dynamics.com/.default` và application cần được cấp quyền trong BC. Collection không chứa client secret hay tự tạo cấu hình Entra ID.

Chạy **Companies** để xác nhận token, lấy company ID và tạo tiền tố mã mới. Điền companyId, UOM, vendor rồi chạy các folder theo thứ tự. GET/test lỗi sau POST cần POST thành công trước để có id/body trong collection variables. Chạy Companies lại nếu muốn bắt đầu lượt mới với mã mới.

```text
https://api.businesscentral.dynamics.com/v2.0/{{tenantId}}/{{environmentName}}/api/neo/training/v1.0/companies({{companyId}})/trainingEntries
```

Body mẫu theo thứ tự Training Entry, Customer, Vendor, Item, Purchase Order:

```json
{"number":"TRAIN001","description":"Training keyboard","quantity":2,"unitPrice":125.5}
```

```json
{"number":"TR-CUST001","name":"Training Customer"}
```

```json
{"number":"TR-VEND001","name":"Training Vendor"}
```

```json
{"number":"TR-ITEM001","description":"Training Item","baseUnitOfMeasure":"PCS"}
```

```json
{"vendorNumber":"EXISTING-VENDOR","orderDate":"2026-11-03"}
```

POST dự kiến **201**, GET danh sách hoặc `entitySet(id)` dự kiến **200**. Không gửi id, amount, vendorName, status.

Khi gửi number cho bảng chuẩn, No. Series tương ứng phải cho **Manual Nos.**. Purchase Order nên bỏ number để BC cấp số từ **Order Nos.**; các test trùng mã và rollback có gửi number nên cần bật Manual Nos. cho Order Nos. nếu chạy toàn bộ collection. Vendor vừa tạo qua API chưa có posting groups: dùng vendor đã cấu hình cho đơn mua, hoặc cấu hình vendor mới trên Vendor Card trước. UOM phải tồn tại.

Collection có assertions cho GET/POST, GET theo id, trùng mã, thiếu field và chặn PATCH/DELETE ở cả 5 API. Có thêm quantity không hợp lệ, giá âm, JSON đảo thứ tự, UOM/vendor không tồn tại và GET xác nhận không có bản ghi sau lỗi. Lỗi xác thực 401/403 không được coi là test nghiệp vụ đạt.

## Page Inspection trên Customer List

1. Mở **Customers**, chọn một dòng dữ liệu thử.
2. Nhấn **Ctrl+Alt+F1**, hoặc Help & Support → Inspect pages and data.
3. Chọn vùng danh sách chính; đọc Page và Table.
4. Trong Table Fields, tìm Name và xem Field No.

| Thông tin | Đối chiếu source trong symbols BC 28.5 |
| --- | --- |
| Page ID | **22 — Customer List** |
| Source table | **18 — Customer** |
| Customer Name field ID | **2 — Name**, Text[100] |

Đây là kết quả đọc source, **chưa phải bằng chứng thao tác Page Inspection trên sandbox**. Nếu thiếu Table Fields, nhờ quản trị viên kiểm tra quyền Page Inspection.

## Ảnh và nộp bài

Ảnh cần nộp: POST Training Entry (body, HTTP 201, id, amount = 251), GET lại cùng id (HTTP 200), Page Inspection Customer List thấy Page 22 / table 18 / Name field 2. Phần mở rộng chụp thêm GET/POST Customer, Vendor, Item và Purchase Order. Dùng dữ liệu thử và không chụp token.

Push source và ảnh rồi gửi link commit cùng ảnh cho Nick. Không push .app, cache, launch cá nhân hoặc token.

## Trạng thái kiểm tra

Đã build với AL compiler 18.1.43.24897, .NET 10 và symbols BC 28.5.54976.57206: **0 lỗi, 0 cảnh báo**, bật warnings as errors. Postman có 65 request và 82 script đã kiểm tra cú pháp JavaScript. Chưa publish, chạy API hoặc chụp Page Inspection trên sandbox; các status code và kết quả ở trên là kỳ vọng cần xác nhận khi chạy thật.

## Tham khảo Microsoft

- [Custom API, SystemId và DelayedInsert](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-develop-custom-api)
- [Cấu trúc endpoint](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/webservices/api-endpoint-structure)
- [Page Inspection](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-inspecting-pages)
- [OAuth cho BC](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/webservices/authenticate-web-services-using-oauth)
