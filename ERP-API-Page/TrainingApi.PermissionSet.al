permissionset 80200 "NEO TRAINING API"
{
    Assignable = true;
    Caption = 'Neo Training API';
    // Quyền bảng chuẩn và các bảng liên quan do permission set nghiệp vụ của user cấp.
    Permissions =
        tabledata "Training Entry" = RI,
        table "Training Entry" = X,
        page "Training Entries API" = X,
        page "Training Customer API" = X,
        page "Training Vendor API" = X,
        page "Training Item API" = X,
        page "Training Purchase Order API" = X;
}
