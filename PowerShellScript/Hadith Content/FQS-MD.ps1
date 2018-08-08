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
Try{
  [void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
  $Connection = New-Object MySql.Data.MySqlClient.MySqlConnection
  $Connection.ConnectionString = $ConnectionString
  $Connection.Open()
  #while loop starts here 
  $flag=1
  while($flag -le 5)
  {
  $Command1 = New-Object MySql.Data.MySqlClient.MySqlCommand("SELECT FiqhNumber FROM  fiqh_sunnah WHERE VolumeNumber =$flag AND FiqhNumber !=  'NULL' group by FiqhNumber", $Connection)
  $DataAdapter1 = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($Command1)
  $DataSet1 = New-Object System.Data.DataSet
  $RecordCount = $dataAdapter1.Fill($dataSet1, "data")
  $result =$DataSet1.Tables[0]
    foreach($oDataSet in $result)
    {
        #hadith properties fetching
		$FiqhNumber1 =  $oDataSet.FiqhNumber 
		$Command = New-Object MySql.Data.MySqlClient.MySqlCommand("SELECT concat('#','Fiqh-us-Sunnah ',fiqh_sunnah.VolumeNumber,'. ',fiqh_sunnah.FiqhNumber,'#') As title ,NOW() As date,'false' As draft,concat('#','hadith','#') As type, concat('#','hadith','#') As layout, concat('#',fiqh_sunnah.BookCode,'#') As BookCode,concat('#',fiqh_sunnah.VolumeNumber,'#') As VolumeNumber,concat('#',fiqh_sunnah.FiqhNumber,'#') As FiqhNumber
		FROM fiqh_sunnah 
		WHERE fiqh_sunnah.FiqhNumber = $FiqhNumber1 AND fiqh_sunnah.VolumeNumber = $flag group by FiqhNumber ", $Connection)  
		$DataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($Command)
		$DataSet = New-Object System.Data.DataSet
		$RecordCount = $dataAdapter.Fill($dataSet, "data")
        $result1 =$DataSet.Tables[0]
		
		$f = New-Item "C:\HugoDataExport\Content\Hadith\FQS\$flag\" -ItemType Directory -Force
		$f = New-Item "C:\HugoDataExport\Content\Hadith\FQS\$flag\$FiqhNumber1\" -ItemType Directory -Force
	    ( $DataSet.Tables[0] | select $DataSet.Tables[0].Columns.ColumnName ) | Format-List |   Out-FileUtf8NoBom "C:\HugoDataExport\Content\Hadith\FQS\$flag\$FiqhNumber1\index.md"
		
        #subjects related to the hadith and updating the markdown file.
        $Command2 = New-Object MySql.Data.MySqlClient.MySqlCommand("SELECT SubTopic,Topic FROM hadith_subject WHERE VolumeNumber = $flag and HadithNumber = $FiqhNumber1 and BookCode= 'FQS'", $Connection)  
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
		$content = [System.IO.File]::ReadAllText("C:\HugoDataExport\Content\Hadith\FQS\$flag\$FiqhNumber1\index.md")
        $content = $content.replace('#','"')
        $content = $content+"category"+"  :  ["+$tgs+"]"
		$content = "---`n"+$content.Trim() +"`n---"
		[System.IO.File]::WriteAllText("C:\HugoDataExport\Content\Hadith\FQS\$flag\$FiqhNumber1\index.md", $content) 
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