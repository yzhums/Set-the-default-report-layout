tableextension 50111 SalesHeaderExt extends "Sales Header"
{
    fields
    {
        field(50100; "Report Name"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Report Name';
            trigger OnLookup()
            var
                ReportLayoutList: Record "Report Layout List";
            begin
                ReportLayoutList.Reset();
                ReportLayoutList.SetRange("Report ID", 1305);
                if Page.RunModal(Page::"Report Layouts", ReportLayoutList) = Action::LookupOK then begin
                    SetDefaultReportLayoutSelection(ReportLayoutList);
                    Rec."Report Name" := ReportLayoutList.Caption;
                    Rec.Modify(true);
                end;
            end;
        }
    }

    var
        TenantReportLayoutSelection: Record "Tenant Report Layout Selection";
        EmptyGuid: Guid;
        DefaultLayoutSetTxt: Label '"%1" has been set as the default layout for Report "%2"', Comment = '%1 = Layout Name, %2 = Report Name';

    procedure SetDefaultReportLayoutSelection(SelectedReportLayoutList: Record "Report Layout List")
    var
        ReportLayoutSelection: Record "Report Layout Selection";
    begin
        // Add to TenantReportLayoutSelection table with an Empty Guid.
        AddLayoutSelection(SelectedReportLayoutList, EmptyGuid);
        // Add to the report layout selection table
        if ReportLayoutSelection.get(SelectedReportLayoutList."Report ID", CompanyName) then begin
            ReportLayoutSelection.Type := GetReportLayoutSelectionCorrespondingEnum(SelectedReportLayoutList);
            ReportLayoutSelection.Modify(true);
        end else begin
            ReportLayoutSelection."Report ID" := SelectedReportLayoutList."Report ID";
            ReportLayoutSelection."Company Name" := CompanyName;
            ReportLayoutSelection."Custom Report Layout Code" := '';
            ReportLayoutSelection.Type := GetReportLayoutSelectionCorrespondingEnum(SelectedReportLayoutList);
            ReportLayoutSelection.Insert(true);
        end;
        Message(DefaultLayoutSetTxt, SelectedReportLayoutList."Caption", SelectedReportLayoutList."Report Name");
    end;

    local procedure AddLayoutSelection(SelectedReportLayoutList: Record "Report Layout List"; UserId: Guid): Boolean
    begin
        TenantReportLayoutSelection.Init();
        TenantReportLayoutSelection."App ID" := SelectedReportLayoutList."Application ID";
        TenantReportLayoutSelection."Company Name" := CompanyName;
        TenantReportLayoutSelection."Layout Name" := SelectedReportLayoutList."Name";
        TenantReportLayoutSelection."Report ID" := SelectedReportLayoutList."Report ID";
        TenantReportLayoutSelection."User ID" := UserId;
        if not TenantReportLayoutSelection.Insert(true) then
            TenantReportLayoutSelection.Modify(true);
    end;

    local procedure GetReportLayoutSelectionCorrespondingEnum(SelectedReportLayoutList: Record "Report Layout List"): Integer
    begin
        case SelectedReportLayoutList."Layout Format" of
            SelectedReportLayoutList."Layout Format"::RDLC:
                exit(0);
            SelectedReportLayoutList."Layout Format"::Word:
                exit(1);
            SelectedReportLayoutList."Layout Format"::Excel:
                exit(3);
            SelectedReportLayoutList."Layout Format"::Custom:
                exit(4);
        end
    end;
}
pageextension 50112 SalesOrderExt extends "Sales Order"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("Report Name"; Rec."Report Name")
            {
                ApplicationArea = All;
                Caption = 'Report Name';
                ToolTip = 'Report Name';
            }
        }
    }
}
