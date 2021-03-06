﻿function Out-FileUtf8NoBom {

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
Try{
  [void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
  $Connection = New-Object MySql.Data.MySqlClient.MySqlConnection
  $Connection.ConnectionString = $ConnectionString
  $Connection.Open()
  #while loop starts here 
  $flag=1
  while($flag -le 9)
  {
  $Command1 = New-Object MySql.Data.MySqlClient.MySqlCommand("SELECT HadithNumber FROM  sahih_bukhari WHERE VolumeNumber =$flag AND HadithNumber !=  'NULL' group by HadithNumber", $Connection)
  $DataAdapter1 = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($Command1)
  $DataSet1 = New-Object System.Data.DataSet
  $RecordCount = $dataAdapter1.Fill($dataSet1, "data")
  $result =$DataSet1.Tables[0]
    foreach($oDataSet in $result)
    {
        #hadith properties fetching
		$HadithNumber1 =  $oDataSet.HadithNumber 
		$Command = New-Object MySql.Data.MySqlClient.MySqlCommand("SELECT concat('#','Sahih Al-Bukhari Hadith ',sahih_bukhari.VolumeNumber,'. ',sahih_bukhari.HadithNumber,'#') As title ,NOW() As date,'false' As draft,concat('#','hadith','#') As type, concat('#','hadith','#') As layout, concat('#',sahih_bukhari.BookCode,'#') As BookCode,concat('#',sahih_bukhari.VolumeNumber,'#') As VolumeNumber,concat('#',sahih_bukhari.HadithNumber,'#') As HadithNumber, concat('[#',sahih_bukhari.NarratorName,'#]') As tags
		FROM sahih_bukhari 
		WHERE sahih_bukhari.HadithNumber = $HadithNumber1 AND sahih_bukhari.VolumeNumber = $flag  ", $Connection)  
		$DataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($Command)
		$DataSet = New-Object System.Data.DataSet
		$RecordCount = $dataAdapter.Fill($dataSet, "data")
        $result1 =$DataSet.Tables[0]
		
		$f = New-Item "C:\HugoDataExport\Content\Hadith\SHB\$flag\" -ItemType Directory -Force
		$f = New-Item "C:\HugoDataExport\Content\Hadith\SHB\$flag\$HadithNumber1\" -ItemType Directory -Force
	    ( $DataSet.Tables[0] | select $DataSet.Tables[0].Columns.ColumnName ) | Format-List |   Out-FileUtf8NoBom "C:\HugoDataExport\Content\Hadith\SHB\$flag\$HadithNumber1\index.md"
		
        #subjects related to the hadith and updating the markdown file.
        $Command2 = New-Object MySql.Data.MySqlClient.MySqlCommand("SELECT SubTopic,Topic FROM hadith_subject WHERE VolumeNumber = $flag and HadithNumber = $HadithNumber1 and BookCode= 'SHB'", $Connection)  
		$DataAdapter2 = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($Command2)
		$DataSet2 = New-Object System.Data.DataSet
		$RecordCount2 = $DataAdapter2.Fill($dataSet2, "data")
        $result2 =$DataSet2.Tables[0]
        $tgs =""
        foreach($oDataSet2 in $result2)
        {
		$content = ''
            if($tgs  -and ($oDataSet2.Topic)){
                $tgs = $tgs+","+'"'+$oDataSet2.SubTopic + " - " +$oDataSet2.Topic+'"'
            }
            elseif($tgs -and (!$oDataSet2.Topic)){
                $tgs = $tgs+","+'"'+$oDataSet2.SubTopic +'"'
            }
            else{
                $tgs = '"'+$oDataSet2.SubTopic + " - " +$oDataSet2.Topic+'"'
            }
        }
        $tgs = $tgs.Trim()
		$content = [System.IO.File]::ReadAllText("C:\HugoDataExport\Content\Hadith\SHB\$flag\$HadithNumber1\index.md")
        $content = $content.replace('#','"')
        $content = $content+"category"+"  :  ["+$tgs+"]"
		$content = "---`n"+$content.Trim() +"`n---"
		[System.IO.File]::WriteAllText("C:\HugoDataExport\Content\Hadith\SHB\$flag\$HadithNumber1\index.md", $content) 
	}

  $flag ++
  }

}
Catch {
  Write-Host "ERROR : Unable to run query : $query `n$Error[0]"
 }
Finally {
  $Connection.Close()
  }