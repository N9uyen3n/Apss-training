// Ví dụ GET/POST Item; tạo mặt hàng không phải ghi nhận tồn kho.
page 80204 "Training Item API"
{
    PageType = API;
    Extensible = false;
    Caption = 'Training Item API';
    APIPublisher = 'neo';
    APIGroup = 'training';
    APIVersion = 'v1.0';
    EntityName = 'itemExample';
    EntitySetName = 'itemExamples';
    SourceTable = Item;
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
                field(description; Rec.Description) { Caption = 'Description'; }
                // Chờ nhận toàn bộ JSON để UOM không gây insert sớm khi number chưa có.
                field(baseUnitOfMeasure; BaseUnitOfMeasure) { Caption = 'Base Unit of Measure'; }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        BaseUnitOfMeasure := Rec."Base Unit of Measure";
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(BaseUnitOfMeasure);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.TestField("No.");
        Rec.TestField(Description);
        Rec.Insert(true);
        if BaseUnitOfMeasure <> '' then begin
            Rec.Validate("Base Unit of Measure", BaseUnitOfMeasure);
            Rec.Modify(true);
        end;
        // Đã insert ở trên; lỗi validate sẽ rollback cả request, không COMMIT giữa chừng.
        exit(false);
    end;

    var
        BaseUnitOfMeasure: Code[10];
}
