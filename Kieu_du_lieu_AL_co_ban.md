# Các kiểu dữ liệu AL cơ bản trong Business Central

Tài liệu này giới thiệu cách khai báo và thao tác với một số kiểu dữ liệu thường gặp trong ngôn ngữ AL của Microsoft Dynamics 365 Business Central. Các đoạn mã là ví dụ độc lập; đặt phần khai báo trong `var` và phần xử lý trong `begin ... end` của một procedure hoặc trigger.

## 1. Khai báo biến

```al
var
    CustomerName: Text[100];
    Quantity: Integer;
    UnitPrice: Decimal;
    IsActive: Boolean;
begin
    CustomerName := 'Công ty ABC';
    Quantity := 3;
    UnitPrice := 125.50;
    IsActive := true;
    Message('%1 - Số lượng: %2', CustomerName, Quantity);
end;
```

AL dùng `:=` để gán, `=` để so sánh và `;` để kết thúc câu lệnh. `Message` dùng `%1`, `%2` làm vị trí chèn giá trị.

## 2. Văn bản: Text và Code

`Text` lưu chuỗi. `Code` thường dùng cho mã định danh: giá trị được chuyển thành chữ hoa và bỏ khoảng trắng ở đầu, cuối. Độ dài trong ngoặc vuông giới hạn số ký tự.

```al
var
    FullName: Text[100];
    CustomerCode: Code[20];
    ShortName: Text;
begin
    FullName := 'Nguyen Van An';
    CustomerCode := '  kh001  '; // Kết quả: KH001
    ShortName := CopyStr(FullName, 1, 6); // Nguyen; vị trí bắt đầu từ 1
    Message('Tên: %1; số ký tự: %2', UpperCase(ShortName), StrLen(FullName));
end;
```

Dùng `+` để nối chuỗi, `LowerCase`/`UpperCase` để đổi chữ hoa thường. Khi gán vào biến có độ dài giới hạn, cần bảo đảm giá trị không vượt giới hạn; có thể dùng `CopyStr` nếu việc cắt là phù hợp.

## 3. Số và Boolean

- `Integer`: số nguyên; `BigInteger`: số nguyên có phạm vi lớn hơn.
- `Decimal`: số thập phân, thường dùng cho số lượng, đơn giá và tiền.
- `Boolean`: `true` hoặc `false`.

```al
var
    Quantity: Integer;
    Price: Decimal;
    Total: Decimal;
    HasDiscount: Boolean;
begin
    Quantity := 3;
    Price := 125.50;
    Total := Quantity * Price;
    HasDiscount := Total > 300;
    if HasDiscount then
        Total := Round(Total * 0.9, 0.01);
    Message('Thành tiền: %1', Total);
end;
```

Các phép toán quen thuộc gồm `+`, `-`, `*`, `/`; `div` chia lấy phần nguyên và `mod` lấy phần dư. `Round` làm tròn theo độ chính xác được chỉ định. Với tiền tệ thực tế, hãy áp dụng quy tắc làm tròn của nghiệp vụ và tiền tệ liên quan.

## 4. Ngày và giờ

`Date` lưu ngày, `Time` lưu giờ, `DateTime` lưu cả ngày và giờ. `0D`, `0T`, `0DT` lần lượt biểu thị giá trị chưa xác định của các kiểu này.

```al
var
    PostingDate: Date;
    DueDate: Date;
    AtTime: Time;
    Moment: DateTime;
begin
    PostingDate := WorkDate();
    DueDate := CalcDate('<1M>', PostingDate);
    AtTime := Time();
    Moment := CreateDateTime(PostingDate, AtTime);
    Message('Ngày làm việc: %1; sau một tháng: %2; thời điểm: %3',
        PostingDate, DueDate, Moment);
end;
```

`WorkDate()` lấy ngày làm việc của người dùng, không nhất thiết là ngày hiện tại; `Today()` lấy ngày hiện tại. `CalcDate` áp dụng công thức ngày, ví dụ `<1M>` là cộng một tháng.

## 5. Chuyển đổi và kiểm tra dữ liệu

`Format` chuyển giá trị thành văn bản hiển thị. `Evaluate` thử chuyển văn bản sang kiểu của biến đích; kiểm tra giá trị trả về để xử lý đầu vào không hợp lệ.

```al
var
    InputText: Text;
    Amount: Decimal;
    DisplayText: Text;
begin
    InputText := '125';
    if Evaluate(Amount, InputText) then begin
        DisplayText := Format(Amount);
        Message('Giá trị hợp lệ: %1', DisplayText);
    end else
        Message('Không thể chuyển "%1" thành số.', InputText);
end;
```

Định dạng và cách phân tích số/ngày có thể phụ thuộc vào thiết lập vùng. Không dùng văn bản hiển thị theo vùng làm định dạng trao đổi dữ liệu cố định nếu chưa quy định rõ định dạng.

## 6. List và Dictionary

`List` lưu danh sách có thứ tự, đánh chỉ số từ 1. `Dictionary` lưu các cặp khóa–giá trị và phù hợp để tra cứu theo khóa.

```al
var
    Names: List of [Text];
    Prices: Dictionary of [Code[20], Decimal];
    Name: Text;
    Price: Decimal;
begin
    Names.Add('An');
    Names.Add('Binh');
    foreach Name in Names do
        Message('Tên: %1', Name);

    Prices.Add('SP001', 150.00);
    if Prices.Get('SP001', Price) then
        Message('Giá: %1', Price);
end;
```

`List` và `Dictionary` là kiểu tham chiếu: gán một biến sang biến khác khiến hai biến cùng tham chiếu đến tập hợp; thay đổi qua một biến sẽ được thấy qua biến kia.

## 7. Record: đọc dữ liệu bảng

`Record` đại diện cho một bản ghi trong bảng Business Central. Ví dụ sau lọc và đọc khách hàng, không sửa dữ liệu:

```al
var
    Customer: Record Customer;
begin
    Customer.SetRange(Blocked, Customer.Blocked::" ");
    if Customer.FindSet() then
        repeat
            Message('%1 - %2', Customer."No.", Customer.Name);
        until Customer.Next() = 0;
end;
```

`SetRange` lọc theo giá trị; `FindSet` lấy tập bản ghi phù hợp; `Next` chuyển sang bản ghi kế tiếp. `Get` thường dùng để tìm theo khóa chính. Khi tạo hoặc sửa dữ liệu, tìm hiểu `Init`, `Validate`, `Insert` và `Modify` cùng các trigger nghiệp vụ trước khi áp dụng.

## 8. Enum

`Enum` biểu diễn tập giá trị được đặt tên. Ví dụ dùng enum có sẵn của trường `Blocked` trên bảng Customer trong mục trước: `Customer.Blocked::" "` là giá trị trống. Khi tự định nghĩa enum, khai báo các `value` trong một object `enum`, sau đó khai báo biến `Enum "Tên Enum"` và gán bằng cú pháp `Biến::GiáTrị`.

## Tài liệu tham khảo

- [Danh sách kiểu dữ liệu và phương thức AL — Microsoft Learn](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/library)
- [Text](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/text/text-data-type) · [Date](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type)
- [List](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/list/list-data-type) · [Dictionary](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/dictionary/dictionary-data-type)
- [Record](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-data-type)
