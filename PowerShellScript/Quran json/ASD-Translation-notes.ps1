$MySQLAdminUserName = 'root'
$MySQLAdminPassword = 'usbw'
$MySQLDatabase = 'alim_dev'
$MySQLHost = 'localhost'
$ConnectionString = "server=" + $MySQLHost + ";port=3307;uid=" + $MySQLAdminUserName + ";pwd=" + $MySQLAdminPassword + ";database="+$MySQLDatabase
Try {
  [void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
  $Connection = New-Object MySql.Data.MySqlClient.MySqlConnection
  $Connection.ConnectionString = $ConnectionString
  $Connection.Open()

  #while loop starts here 
  $flag=1
  while($flag -le 114)
  {

  $Command = New-Object MySql.Data.MySqlClient.MySqlCommand("SELECT BookCode, concat(SurahNumber) As SurahNumber, concat(AyahNumber) As AyahNumber,  concat(NoteID) As NoteID, Body FROM  translation_notes WHERE BookCode =  'ASD' ", $Connection)
  $DataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($Command)
  $DataSet = New-Object System.Data.DataSet
  $RecordCount = $dataAdapter.Fill($dataSet, "data") 
  $f = New-Item "C:\HugoDataExport\Quran\Book\ASD\$flag" -ItemType Directory -Force
  $g = New-Item "C:\HugoDataExport\Quran\Book\ASD\$flag\notes" -ItemType Directory -Force
  ($DataSet.Tables[0] | select $DataSet.Tables[0].Columns.ColumnName ) | ConvertTo-Json -Depth 2|% { [System.Text.RegularExpressions.Regex]::Unescape($_) } | Out-File "C:\HugoDataExport\Quran\Book\ASD\$flag\notes\notes.json " -Encoding default
  $flag ++
  }

  }
Catch {
  Write-Host "ERROR : Unable to run query : $query `n$Error[0]"
 }
Finally {
  $Connection.Close()
  }