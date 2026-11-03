// Giả lập GET/POST bằng action trong BC; không gửi HTTP request đến API endpoint.
page 80207 "Training API Demo"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Caption = 'Training API Demo';

    layout
    {
        area(Content)
        {
            group(Request)
            {
                Caption = 'Training Entry';
                field(Number; EntryNumber)
                {
                    ApplicationArea = All;
                    Caption = 'Number';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the entry number to create or read. Clear it to GET up to 50 training entries.';
                }
                field(Description; EntryDescription)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ShowMandatory = true;
                    ToolTip = 'Specifies the description to save when choosing POST.';
                }
                field(Quantity; EntryQuantity)
                {
                    ApplicationArea = All;
                    Caption = 'Quantity';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the quantity to save. POST requires a quantity greater than zero.';
                }
                field(UnitPrice; EntryUnitPrice)
                {
                    ApplicationArea = All;
                    Caption = 'Unit Price';
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Specifies the unit price to save. POST requires a nonnegative price.';
                }
            }
            group(Result)
            {
                Caption = 'Simulation Result';
                field(Status; ResultStatus)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    Editable = false;
                    ToolTip = 'Shows the result of the GET or POST simulation inside Business Central.';
                }
                field(Response; ResponseJson)
                {
                    ApplicationArea = All;
                    Caption = 'Response JSON';
                    Editable = false;
                    MultiLine = true;
                    ToolTip = 'Shows JSON built from the saved Training Entry data.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GetEntries)
            {
                ApplicationArea = All;
                Caption = 'GET';
                Image = GetLines;
                ToolTip = 'Reads the specified training entry. Clear Number to read up to 50 entries. This action does not change data.';

                trigger OnAction()
                begin
                    ClearResult();
                    GetTrainingEntries();
                    CurrPage.Update(false);
                end;
            }
            action(PostEntry)
            {
                ApplicationArea = All;
                Caption = 'POST';
                Image = New;
                ToolTip = 'Creates one Training Entry using the values above. This simulation saves real training data and rejects duplicate numbers.';

                trigger OnAction()
                begin
                    ClearResult();
                    PostTrainingEntry();
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(GetEntries_Promoted; GetEntries) { }
                actionref(PostEntry_Promoted; PostEntry) { }
            }
        }
    }

    trigger OnOpenPage()
    begin
        // Mã riêng cho mỗi lần mở trang, không dùng No. Series của bảng nghiệp vụ.
        EntryNumber := 'TRAIN-' + CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, 14);
        EntryDescription := 'Training keyboard';
        EntryQuantity := 2;
        EntryUnitPrice := 125.50;
    end;

    local procedure GetTrainingEntries()
    var
        TrainingEntry: Record "Training Entry";
        Entries: JsonArray;
        ResponseObject: JsonObject;
        EntryCount: Integer;
    begin
        if EntryNumber <> '' then
            TrainingEntry.SetRange("No.", EntryNumber);
        if TrainingEntry.FindSet() then
            repeat
                Entries.Add(EntryToJson(TrainingEntry));
                EntryCount += 1;
            until (TrainingEntry.Next() = 0) or (EntryCount = 50);

        ResponseObject.Add('value', Entries);
        ResponseObject.WriteTo(ResponseJson);
        ResultStatus := StrSubstNo(GetResultMsg, EntryCount);
    end;

    local procedure PostTrainingEntry()
    var
        TrainingEntry: Record "Training Entry";
        ResponseObject: JsonObject;
    begin
        TrainingEntry.Init();
        TrainingEntry.Validate("No.", EntryNumber);
        TrainingEntry.Validate(Description, EntryDescription);
        TrainingEntry.Validate(Quantity, EntryQuantity);
        TrainingEntry.Validate("Unit Price", EntryUnitPrice);
        // Chạy cùng table trigger kiểm tra/tính tiền mà API Page sử dụng.
        TrainingEntry.Insert(true);

        ResponseObject := EntryToJson(TrainingEntry);
        ResponseObject.WriteTo(ResponseJson);
        ResultStatus := StrSubstNo(PostResultMsg, TrainingEntry."No.");
    end;

    local procedure EntryToJson(TrainingEntry: Record "Training Entry") Entry: JsonObject
    begin
        Entry.Add('id', LowerCase(DelChr(Format(TrainingEntry.SystemId), '=', '{}')));
        Entry.Add('number', TrainingEntry."No.");
        Entry.Add('description', TrainingEntry.Description);
        Entry.Add('quantity', TrainingEntry.Quantity);
        Entry.Add('unitPrice', TrainingEntry."Unit Price");
        Entry.Add('amount', TrainingEntry.Amount);
    end;

    local procedure ClearResult()
    begin
        Clear(ResultStatus);
        Clear(ResponseJson);
    end;

    var
        EntryNumber: Code[20];
        EntryDescription: Text[100];
        EntryQuantity: Decimal;
        EntryUnitPrice: Decimal;
        ResultStatus: Text;
        ResponseJson: Text;
        GetResultMsg: Label 'GET simulation completed: %1 record(s) returned (maximum 50).', Comment = '%1 = number of returned records';
        PostResultMsg: Label 'POST simulation completed: training entry %1 created.', Comment = '%1 = entry number';
}
