// Ví dụ GET/POST Vendor; không đưa thông tin liên hệ lên API mẫu.
page 80203 "Training Vendor API"
{
    PageType = API;
    Extensible = false;
    Caption = 'Training Vendor API';
    APIPublisher = 'neo';
    APIGroup = 'training';
    APIVersion = 'v1.0';
    EntityName = 'vendorExample';
    EntitySetName = 'vendorExamples';
    SourceTable = Vendor;
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
                field(name; Rec.Name) { Caption = 'Name'; }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.TestField("No.");
        Rec.TestField(Name);
        exit(true);
    end;
}
