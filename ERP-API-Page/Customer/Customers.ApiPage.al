// Ví dụ GET/POST Customer; cần kiểm thử theo cấu hình sandbox.
page 80202 "Training Customer API"
{
    PageType = API;
    Extensible = false;
    Caption = 'Training Customer API';
    APIPublisher = 'neo';
    APIGroup = 'training';
    APIVersion = 'v1.0';
    EntityName = 'customerExample';
    EntitySetName = 'customerExamples';
    SourceTable = Customer;
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
