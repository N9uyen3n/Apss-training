// Bảng tạm để minh họa API vì chưa xác định được bảng training thực tế.
table 80201 "Training Entry"
{
    Caption = 'Training Entry';
    DataClassification = CustomerContent;

    fields
    {
        // Mã bản ghi do người gọi API cung cấp; không được để trống.
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        // Nội dung mô tả của bản ghi.
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        // Trường minh họa dữ liệu số; đề bài không yêu cầu riêng các trường này.
        field(3; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(4; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DecimalPlaces = 0 : 5;
        }
        // Thành tiền được API tính khi tạo, không nhận trực tiếp từ client.
        field(5; Amount; Decimal)
        {
            Caption = 'Amount';
        }
    }

    keys
    {
        // Khóa chính giúp mỗi mã bản ghi là duy nhất.
        key(PK; "No.")
        {
            Clustered = true;
        }
    }
}
