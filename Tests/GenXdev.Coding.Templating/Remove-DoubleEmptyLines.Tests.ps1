###############################################################################
Pester\Describe 'Remove-DoubleEmptyLines' {

    Pester\It 'should work as expected' {

        $inputStr = @"

        protected static DataTable CreatePermissionGroupMembershipsAdminSyncOutDataTable() {


            DataTable dt = new();


            dt.Columns.Add("PermissionGroupId", typeof(System.Guid));

            dt.Columns.Add("CreatedOn", typeof(System.DateTime));

            dt.Columns.Add("Enabled", typeof(System.Boolean));

            dt.Columns.Add("Sequence", typeof(System.Int64));
            dt.Columns.Add("LastModified", typeof(System.DateTime));
            dt.Columns.Add("IsDeleted", typeof(System.Boolean));
            return dt;
        }


        function test() {
            return true;

        }
"@

        $expected = @"

        protected static DataTable CreatePermissionGroupMembershipsAdminSyncOutDataTable() {

            DataTable dt = new();

            dt.Columns.Add("PermissionGroupId", typeof(System.Guid));
            dt.Columns.Add("CreatedOn", typeof(System.DateTime));
            dt.Columns.Add("Enabled", typeof(System.Boolean));
            dt.Columns.Add("Sequence", typeof(System.Int64));
            dt.Columns.Add("LastModified", typeof(System.DateTime));
            dt.Columns.Add("IsDeleted", typeof(System.Boolean));

            return dt;
        }

        function test() {

            return true;
        }
"@

        $result = GenXdev\Remove-DoubleEmptyLines -code $inputStr -Reformat

        ($result -replace "`r`n", "`n") | PESTER\Should -BeExactly ($expected -replace "`r`n", "`n")

    }
}