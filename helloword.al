pageextension 80200 CustomerListExt extends "Customer List"
{
    trigger OnOpenPage()
    begin
        Message('App published: Hello world');
    end;
}
