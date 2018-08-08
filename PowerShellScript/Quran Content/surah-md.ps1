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
    $Command = New-Object MySql.Data.MySqlClient.MySqlCommand("SELECT CONCAT(  '#',  'Surah ', surah_overview.SurahNumber,  '. ', surah_overview.SurahName,  '#' ) AS title, NOW( ) AS DATE,  'false' AS draft, CONCAT(  '#',  'quran',  '#' ) AS TYPE , CONCAT(  '#',  'surah',  '#' ) AS layout, CONCAT(  '#',  'ARB',  '#' ) AS BookCode, CONCAT(  '#', surah_overview.SurahNumber,  '#' ) AS SurahNumber, CONCAT(  '#', surah_overview.AyahCount,  '#' ) AS TotalAyah FROM surah_overview WHERE surah_overview.SurahNumber= $flag", $Connection)  
    $DataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($Command)
    $DataSet = New-Object System.Data.DataSet
    $RecordCount = $dataAdapter.Fill($dataSet, "data")
    $f = New-Item "C:\HugoDataExport\Content\quran\Surah\$flag" -ItemType Directory -Force
    ( $DataSet.Tables[0] | select $DataSet.Tables[0].Columns.ColumnName ) | Format-List |   Out-FileUtf8NoBom "C:\HugoDataExport\Content\quran\Surah\$flag\index.md"  
    #$content = ''
    $content = [System.IO.File]::ReadAllText("C:\HugoDataExport\Content\quran\Surah\$flag\index.md")
    $content = $content.replace('#','"')
    $content = "---`n"+$content.Trim() +"`n---"
    [System.IO.File]::WriteAllText("C:\HugoDataExport\Content\quran\Surah\$flag\index.md", $content)
  $flag ++
  }

  }
Catch {
  Write-Host "ERROR : Unable to run query : $query `n$Error[0]"
 }
Finally {
  $Connection.Close()
  }