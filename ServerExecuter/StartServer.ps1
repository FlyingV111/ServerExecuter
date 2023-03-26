Clear-Host
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$Global:url = $null
$Global:batName = $null
$Global:serverPath = $null
$Global:ngrokJob = $null
function StartNgrok {
    $Global:serverPath = $Global:textBoxSelect.Text
    $ngrok = "$Global:serverPath\ngrok.exe tcp 25565 --region eu"
    $Global:ngrokJob = Start-Job -ScriptBlock {"start $Using:ngrok" | cmd}
}
function SaveIpAdress{
    if(!$Global:ngrokJob.Error){
    Start-Sleep 2

    $Global:url = (Invoke-WebRequest -UseBasicParsing -uri "http://localhost:4040/api/tunnels").Content
    $Json= ConvertFrom-Json -InputObject $Global:url
    $Global:url = $Json.tunnels.public_url
    $Global:url = $Global:url.trimStart("tcp://")
    $Global:ipLabel.Text = "Ip-Adress:   " + $Global:url
    $Global:objForm.Controls.Add($Global:ipLabel)
    $Global:objForm.Controls.Add($copyButton)
    $Global:objForm.Activate()
    }   
}
function SaveIpToClipboard {
    $Global:url = $Global:ipLabel.Text.trimStart("Ip-Adress:   ")
    Set-Clipboard -Value $Global:url
    $Global:objForm.Controls.Add($copyiedLabel)
    Start-Sleep 2
    $Global:objForm.Controls.Remove($copyiedLabel)
}
function StartServer{
    $Global:batName = $textBoxBat.Text
    $Global:serverPath = $Global:textBoxSelect.Text
    MakeBatFileReadyToStart
    Set-Location $Global:serverPath
    $Global:minecraftServer = Start-Process $Global:batName -PassThru
    if($checkbox.Checked){
        StartNgrok
        SaveIpAdress
    }
}
function StopServer{
    $wsh = New-Object -ComObject WScript.Shell
    $wsh.AppActivate("StartBat")
    $wsh.SendKeys("stop")
    $wsh.SendKeys("{ENTER}")
    if($checkbox.Checked){
        StopNgrok
    }
}
function CancelServer{
    CloseBatWindow
    $Global:objForm.Close()
    if($checkbox.Checked){
        StopNgrok
    }
}       
function SelectPath {
    $Global:folderBrowser =  New-Object System.Windows.Forms.FolderBrowserDialog
    if ($Global:folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::Ok) {
        $Global:textBoxSelect.Text = $Global:folderBrowser.SelectedPath
    }
}
function SelectBat {
    $Global:batBrowser =  New-Object System.Windows.Forms.OpenFileDialog
    $Global:batBrowser.Filter = "Batch Files (*.bat, *.cmd)|*.bat; *.cmd"
    if ($Global:batBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::Ok) {
        $textBoxBat.Text = [System.IO.Path]::GetFileName($Global:batBrowser.FileName)  
    }
}
function StopNgrok {
    taskkill /F /IM ngrok.exe
    Stop-Job -id $global:ngrokJob.Id
    Remove-Job -id $global:ngrokJob.Id
}
function CloseBatWindow {
    taskkill /F /FI "WINDOWTITLE eq StartBat" /T
}
function MakeBatFileReadyToStart{
    if(-not (Select-String -Path $Global:batBrowser.FileName -Pattern "title StartBat"))
    {
        $batContent = "title StartBat`n"
        $batContent = $batContent + (Get-Content $Global:batBrowser.FileName -Raw)
        Set-Content $Global:batBrowser.FileName $batContent
    }
}

$Global:objForm = New-Object System.Windows.Forms.Form
$Global:objForm.Text = "Server-Management"
$Global:objForm.StartPosition = "CenterScreen"
$Global:objForm.Size = New-Object System.Drawing.Size(800,500)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(20,20)
$objLabel.Size = New-Object System.Drawing.Size(200,20)
$objLabel.Text = "Server-Ordner Path :"
$Global:objForm.Controls.Add($objLabel)

$Global:textBoxSelect = New-Object System.Windows.Forms.TextBox
$Global:textBoxSelect.Location = New-Object System.Drawing.Size(20,40)
$Global:textBoxSelect.Size = New-Object System.Drawing.Size(200,20)
$Global:objForm.Controls.Add($Global:textBoxSelect)

$selectPath = New-Object System.Windows.Forms.Button
$selectPath.Location = New-Object System.Drawing.Size(225,39)
$selectPath.Size = New-Object System.Drawing.Size(30,22)
$selectPath.Text = "..."
$selectPath.Add_Click({
    SelectPath
})
$Global:objForm.Controls.Add($selectPath)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(20,79)
$objLabel.Size = New-Object System.Drawing.Size(200,20)
$objLabel.Text = "Server-Run Bat:"
$Global:objForm.Controls.Add($objLabel)

$textBoxBat = New-Object System.Windows.Forms.TextBox
$textBoxBat.Location = New-Object System.Drawing.Size(20,99)
$textBoxBat.Size = New-Object System.Drawing.Size(200,20)
$Global:objForm.Controls.Add($textBoxBat)

$selectPathBat = New-Object System.Windows.Forms.Button
$selectPathBat.Location = New-Object System.Drawing.Size(225,99)
$selectPathBat.Size = New-Object System.Drawing.Size(30,22)
$selectPathBat.Text = "..."
$selectPathBat.Add_Click({
    SelectBat
})
$Global:objForm.Controls.Add($selectPathBat)


$Global:checkbox = New-Object System.Windows.Forms.CheckBox
$Global:checkbox.Location = New-Object System.Drawing.Point(20, 140)
$Global:checkbox.Text = "Online-Modus"
$Global:checkbox.Name = "OnlineMode"
$Global:objForm.Controls.Add($Global:checkbox)


$CancelButton = New-Object System.Windows.Forms.Button
# Die nächsten beiden Zeilen legen die Position und die Größe des Buttons fest
$CancelButton.Location = New-Object System.Drawing.Size(20,420)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Abbrechen"
$CancelButton.Name = "Abbrechen"
$CancelButton.DialogResult = "Cancel"
#Die folgende Zeile ordnet dem Click-Event die Schließen-Funktion für das Formular zu
$CancelButton.Add_Click({
    CancelServer
})
$Global:objForm.Controls.Add($CancelButton)

$StartButton = New-Object System.Windows.Forms.Button
# Die nächsten beiden Zeilen legen die Position und die Größe des Buttons fest
$StartButton.Location = New-Object System.Drawing.Size(695,420)
$StartButton.Size = New-Object System.Drawing.Size(75,23)
$StartButton.Text = "Start"
$StartButton.Name = "Start"
#Die folgende Zeile ordnet dem Click-Event die Schließen-Funktion für das Formular zu
$StartButton.Add_Click({
    StartServer
})
$Global:objForm.Controls.Add($StartButton)


$StopButton = New-Object System.Windows.Forms.Button
# Setting Position
$StopButton.Location = New-Object System.Drawing.Size(595, 420)
# Setting Size
$StopButton.Size = New-Object System.Drawing.Size(75, 23)
$StopButton.Text = "Stop"
$StopButton.Name = "Stop"
# Adding Click Event-Listener
$StopButton.Add_Click({
    StopServer
})
$Global:objForm.Controls.Add($StopButton)

# Simply shut down ngrok => Stop-Process -Name "ngrok" (all processes of ngrok will be stopped)
# Getting PID's (Process ID) of started tasks (tasks because ngrok starts usually more than one task)

$Global:ipLabel = New-Object System.Windows.Forms.Label
$Global:ipLabel.Location = New-Object System.Drawing.Size(280,425)
$Global:ipLabel.Size = New-Object System.Drawing.Size(200,20)

$copyButton = New-Object System.Windows.Forms.Button
$copyButton.Location = New-Object System.Drawing.Size(480,420)
$copyButton.Size = New-Object System.Drawing.Size(75,23)
$copyButton.Text = "Copy"
$copyButton.Name = "Copy"
$copyButton.Add_Click({
    SaveIpToClipboard
})

$copyiedLabel = New-Object System.Windows.Forms.Label
$copyiedLabel.Location = New-Object System.Drawing.Size(350,400)
$copyiedLabel.Size = New-Object System.Drawing.Size(200,20)
$copyiedLabel.Text = "Copied to the clipboard."
$copyiedLabel.ForeColor = "Green"

[void] $Global:objForm.ShowDialog()