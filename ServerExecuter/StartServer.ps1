cls
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$iconPath = ".\server.ico"
$folderPath = "Logo"
$serverPath = ""
$batName = ""

$objForm = New-Object System.Windows.Forms.Form
$objForm.Text = "Server-Management"
$objForm.StartPosition = "CenterScreen"
$objForm.Size = New-Object System.Drawing.Size(800,500)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(20,20)
$objLabel.Size = New-Object System.Drawing.Size(200,20)
$objLabel.Text = "Server-Ordner Path :"
$objForm.Controls.Add($objLabel)

$textBoxSelect = New-Object System.Windows.Forms.TextBox
$textBoxSelect.Location = New-Object System.Drawing.Size(20,40)
$textBoxSelect.Size = New-Object System.Drawing.Size(200,20)
$objForm.Controls.Add($textBoxSelect)

$selectPath = New-Object System.Windows.Forms.Button
$selectPath.Location = New-Object System.Drawing.Size(225,39)
$selectPath.Size = New-Object System.Drawing.Size(30,22)
$selectPath.Text = "..."
$selectPath.Add_Click({
    $folderBrowser =  New-Object System.Windows.Forms.FolderBrowserDialog
    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::Ok) {
        $textBoxSelect.Text = $folderBrowser.SelectedPath
    }

})
$objForm.Controls.Add($selectPath)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(20,79)
$objLabel.Size = New-Object System.Drawing.Size(200,20)
$objLabel.Text = "Server-Run Bat:"
$objForm.Controls.Add($objLabel)

$textBoxBat = New-Object System.Windows.Forms.TextBox
$textBoxBat.Location = New-Object System.Drawing.Size(20,99)
$textBoxBat.Size = New-Object System.Drawing.Size(200,20)
$objForm.Controls.Add($textBoxBat)

$selectPathBat = New-Object System.Windows.Forms.Button
$selectPathBat.Location = New-Object System.Drawing.Size(225,99)
$selectPathBat.Size = New-Object System.Drawing.Size(30,22)
$selectPathBat.Text = "..."
$selectPathBat.Add_Click({
    $batBrowser =  New-Object System.Windows.Forms.OpenFileDialog
    $batBrowser.Filter = "Batch Files (*.bat, *.cmd)|*.bat; *.cmd"
    if ($batBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::Ok) {
        $textBoxBat.Text = [System.IO.Path]::GetFileName($batBrowser.FileName)
    }

})
$objForm.Controls.Add($selectPathBat)


$checkbox = New-Object System.Windows.Forms.CheckBox
$checkbox.Location = New-Object System.Drawing.Point(20, 140)
$checkbox.Text = "Online-Modus"
$checkbox.Name = "OnlineMode"
$objForm.Controls.Add($checkbox)


$CancelButton = New-Object System.Windows.Forms.Button
# Die nächsten beiden Zeilen legen die Position und die Größe des Buttons fest
$CancelButton.Location = New-Object System.Drawing.Size(20,420)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Abbrechen"
$CancelButton.Name = "Abbrechen"
$CancelButton.DialogResult = "Cancel"
#Die folgende Zeile ordnet dem Click-Event die Schließen-Funktion für das Formular zu
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)

$StartButton = New-Object System.Windows.Forms.Button
# Die nächsten beiden Zeilen legen die Position und die Größe des Buttons fest
$StartButton.Location = New-Object System.Drawing.Size(695,420)
$StartButton.Size = New-Object System.Drawing.Size(75,23)
$StartButton.Text = "Start"
$StartButton.Name = "Start"
#Die folgende Zeile ordnet dem Click-Event die Schließen-Funktion für das Formular zu
$StartButton.Add_Click({
    $batName = $textBoxBat.Text
    $serverPath = $textBoxSelect.Text
    Write-Host $serverPath
    Write-Host $batName
    startServer
    if($checkbox.Checked){
         startNgrok 
    }
})
$objForm.Controls.Add($StartButton)
$ipLabel = New-Object System.Windows.Forms.Label
$ipLabel.Location = New-Object System.Drawing.Size(280,425)
$ipLabel.Size = New-Object System.Drawing.Size(200,20)

$copyButton = New-Object System.Windows.Forms.Button
$copyButton.Location = New-Object System.Drawing.Size(480,420)
$copyButton.Size = New-Object System.Drawing.Size(75,23)
$copyButton.Text = "Copy"
$copyButton.Name = "Copy"


[void] $objForm.ShowDialog()

function startServer{
    $serverPath
    $batName

    #Start Bat 
    Set-Location $serverPath
    Start-Process $batName
}

function startNgrok{
    $copyButton.Site
    $ipLabel
    $url
    $serverPath

    $ngrokJob = Start-Job -ScriptBlock {"start $Using:serverPath\ngrok.exe tcp 25565 --region eu" |  cmd}

    sleep 2

    $url = (Invoke-WebRequest -UseBasicParsing -uri "http://localhost:4040/api/tunnels").Content
    $Json= ConvertFrom-Json -InputObject $url
    $url = $Json.tunnels.public_url
    $url = $url.trimStart("tcp://")
    $ipLabel.Text = "Ip-Adress:   " + $url
    $objForm.Controls.Add($ipLabel)
    $objForm.Controls.Add($copyButton)
    $objForm.Activate()
    Stop-Job -id $ngrokJob.Id
    Remove-Job -id $ngrokJob.Id
}