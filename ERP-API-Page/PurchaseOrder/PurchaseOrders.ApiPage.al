// Purchase Header chứa nhiều loại chứng từ; ví dụ này chỉ chọn Order.
page 80206 "Training Purchase Order API"
{
    PageType = API;
    Extensible = false;
    Caption = 'Training Purchase Order API';
    APIPublisher = 'neo';
    APIGroup = 'training';
    APIVersion = 'v1.0';
    EntityName = 'purchaseOrderExample';
    EntitySetName = 'purchaseOrderExamples';
    SourceTable = "Purchase Header";
    SourceTableView = where("Document Type" = const(Order));
    ODataKeyFields = SystemId;
    DelayedInsert = true;
    InsertAllowed = true;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(id; Rec.SystemId) { Caption = 'Id'; Editable = false; }
                field(number; Rec."No.") { Caption = 'No.'; }
                field(vendorNumber; VendorNumber) { Caption = 'Buy-from Vendor No.'; }
                field(orderDate; OrderDate) { Caption = 'Order Date'; }
                field(vendorName; Rec."Buy-from Vendor Name") { Caption = 'Vendor Name'; Editable = false; }
                field(status; Rec.Status) { Caption = 'Status'; Editable = false; }
            }
        }
    }

    // Gán loại chứng từ trước khi các trường của đơn được xử lý.
    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(VendorNumber);
        Clear(OrderDate);
        Rec.Validate("Document Type", Rec."Document Type"::Order);
    end;

    trigger OnAfterGetRecord()
    begin
        VendorNumber := Rec."Buy-from Vendor No.";
        OrderDate := Rec."Order Date";
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if VendorNumber = '' then
            Error(VendorRequiredErr);
        Rec.TestField("Document Type", Rec."Document Type"::Order);
        // OnInsert chuẩn khởi tạo No. Series và ngày mặc định trước khi validate vendor.
        // Bỏ number trong POST để BC tự cấp số; nếu gửi thì No. Series phải cho nhập tay.
        Rec.Insert(true);
        Rec.Validate("Buy-from Vendor No.", VendorNumber);
        if OrderDate <> 0D then
            Rec.Validate("Order Date", OrderDate);
        Rec.Modify(true);
        VendorNumber := Rec."Buy-from Vendor No.";
        OrderDate := Rec."Order Date";
        exit(false);
    end;

    var
        VendorNumber: Code[20];
        OrderDate: Date;
        VendorRequiredErr: Label 'vendorNumber is required.';
}
