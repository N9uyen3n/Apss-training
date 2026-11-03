// API page cho phép ứng dụng bên ngoài đọc và tạo bản ghi training.
page 80201 "Training Entries API"
{
    PageType = API;
    Extensible = false;
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

}
