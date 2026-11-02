// API page cho phép ứng dụng bên ngoài đọc và tạo bản ghi training.
page 80201 "Training Entries API"
{
    PageType = API;
    Caption = 'Training Entries API';
    // Các thuộc tính này tạo đường dẫn neo/training/v1.0/trainingEntries.
    APIPublisher = 'neo';
    APIGroup = 'training';
    APIVersion = 'v1.0';
    EntityName = 'trainingEntry';
    EntitySetName = 'trainingEntries';
    // Bảng chứa dữ liệu; SystemId được dùng làm khóa trên URL OData.
    SourceTable = "Training Entry";
    ODataKeyFields = SystemId;
    // Chờ nhận dữ liệu các trường trước khi chèn bản ghi.
    DelayedInsert = true;
    InsertAllowed = true;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Entries)
            {
                // ID do hệ thống tạo, chỉ đọc qua API.
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                // Tên field bên trái là tên thuộc tính trong JSON.
                field(number; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price';
                }
                // Client đọc thành tiền nhưng không tự gán giá trị này.
                field(amount; Rec.Amount)
                {
                    Caption = 'Amount';
                    Editable = false;
                }
            }
        }
    }

    // Quy tắc minh họa, chưa được xác nhận là nghiệp vụ của tổ chức.
    // Chỉ áp dụng khi chèn qua API page này, không áp dụng cho mọi đường ghi bảng.
    // Kiểm tra sau khi nhận các trường, trước khi API chèn bản ghi.
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.TestField("No.");
        Rec.TestField(Description);
        if Rec.Quantity <= 0 then
            Error(QuantityErr);
        if Rec."Unit Price" < 0 then
            Error(UnitPriceErr);

        // 0.01 là quy ước của bài tập, không đại diện mọi loại tiền tệ.
        Rec.Amount := Round(Rec.Quantity * Rec."Unit Price", 0.01);
        exit(true);
    end;

    var
        QuantityErr: Label 'Quantity must be greater than zero.';
        UnitPriceErr: Label 'Unit price cannot be negative.';
}
