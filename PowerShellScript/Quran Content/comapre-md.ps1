function Out-FileUtf8NoBom {

  [CmdletBinding()]
  param(
    [Parameter(Mandatory, Position=0)] [string] $LiteralPath,
    [switch] $Append,
    [switch] $NoClobber,
    [AllowNull()] [int] $Width,
    [Parameter(ValueFromPipeline)] $InputObject
  )

  #requires -version 3

  # Make sure that the .NET framework sees the same working dir. as PS
  # and resolve the input path to a full path.
  [System.IO.Directory]::SetCurrentDirectory($PWD) # Caveat: .NET Core doesn't support [Environment]::CurrentDirectory
  $LiteralPath = [IO.Path]::GetFullPath($LiteralPath)

  # If -NoClobber was specified, throw an exception if the target file already
  # exists.
  if ($NoClobber -and (Test-Path $LiteralPath)) {
    Throw [IO.IOException] "The file '$LiteralPath' already exists."
  }

  # Create a StreamWriter object.
  # Note that we take advantage of the fact that the StreamWriter class by default:
  # - uses UTF-8 encoding
  # - without a BOM.
  $sw = New-Object IO.StreamWriter $LiteralPath, $Append

  $htOutStringArgs = @{}
  if ($Width) {
    $htOutStringArgs += @{ Width = $Width }
  }

  # Note: By not using begin / process / end blocks, we're effectively running
  #       in the end block, which means that all pipeline input has already
  #       been collected in automatic variable $Input.
  #       We must use this approach, because using | Out-String individually
  #       in each iteration of a process block would format each input object
  #       with an indvidual header.
  try {
    $Input | Out-String -Stream @htOutStringArgs | % { $sw.WriteLine($_) }
  } finally {
    $sw.Dispose()
  }

}
$MySQLAdminUserName = ''
$MySQLAdminPassword = ''
$MySQLDatabase = ''
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
  $Command1 = New-Object MySql.Data.MySqlClient.MySqlCommand("select quran.SurahNumber,quran.AyahNumber, surah_overview.AyahCount As TotalAyah from quran left join surah_overview on quran.SurahNumber = surah_overview.SurahNumber  where quran.SurahNumber = $flag and BookCode='ARBU'", $Connection)
  $DataAdapter1 = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($Command1)
  $DataSet1 = New-Object System.Data.DataSet
  $RecordCount = $dataAdapter1.Fill($dataSet1, "data")
  $result =$DataSet1.Tables[0]
   foreach($oDataSet in $result)
    {
        $SurahNo1 =  $oDataSet.SurahNumber 
        $AyahNo1 =  $oDataSet.AyahNumber
        $Command = New-Object MySql.Data.MySqlClient.MySqlCommand(" select concat('#','Surah ',quran.SurahNumber,'. ',surah_overview.SurahName,', Ayah ', quran.AyahNumber ,'#') As title ,NOW() As date,'false' As draft,concat('#','quran','#') As type, concat('#','compare','#') As layout, concat('#','CMP','#') As BookCode, concat('#',quran.SurahNumber,'#') As SurahNumber,concat('#',quran.AyahNumber,'#') As AyahNumber, concat('#',surah_overview.AyahCount,'#') As TotalAyah from quran left join surah_overview on quran.SurahNumber = surah_overview.SurahNumber  where quran.SurahNumber = $SurahNo1 And quran.AyahNumber = $AyahNo1 and BookCode='ARBU'", $Connection)
        $DataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($Command)
        $DataSet2 = New-Object System.Data.DataSet
        $RecordCount1 = $DataAdapter.Fill($dataSet2, "data")
        $surahNo = $oDataSet.SurahNumber
        $AyahNo = $oDataSet.AyahNumber
        $f = New-Item "C:\HugoDataExport\Content\quran\Compare\$surahNo" -ItemType Directory -Force
        $g = New-Item "C:\HugoDataExport\Content\quran\Compare\$surahNo\$AyahNo" -ItemType Directory -Force
        ( $DataSet2.Tables[0] | select $DataSet2.Tables[0].Columns.ColumnName ) | Format-List  |  Out-FileUtf8NoBom "C:\HugoDataExport\Content\quran\Compare\$surahNo\$AyahNo\index.md"
        $content = [System.IO.File]::ReadAllText("C:\HugoDataExport\Content\quran\Compare\$surahNo\$AyahNo\index.md")
		$content = $content.replace('#','"')
        $content = "---`n"+$content.Trim() +"`n---"
        [System.IO.File]::WriteAllText("C:\HugoDataExport\Content\quran\Compare\$surahNo\$AyahNo\index.md", $content)
         
    }

  $flag ++
  }
   $Connection.Close()
  }
Catch {
  Write-Host "ERROR : Unable to run query : $query `n$Error[0]"
 }