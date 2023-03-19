cls
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

Add-Type @"
using System.Windows.Forms;
public class objForm : Form {
    public string ServerPath { get; set; }
}
"@

$iconPath = ".\server.ico"
$folderPath = "Logo"
$objForm.serverPath = ""
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

$ApplyButtonPath = New-Object System.Windows.Forms.Button
# Die nächsten beiden Zeilen legen die Position und die Größe des Buttons fest
$ApplyButtonPath.Location = New-Object System.Drawing.Size(280,39)
$ApplyButtonPath.Size = New-Object System.Drawing.Size(75,23)
$ApplyButtonPath.Text = "Apply"
$ApplyButtonPath.Name = "ApplyButtonPath"
#Die folgende Zeile ordnet dem Click-Event die Schließen-Funktion für das Formular zu
$ApplyButtonPath.Add_Click({
    Write-Host "Server Path:"
    $objForm.serverPath = $textBoxSelect.Text
    Write-Host $objForm.serverPath
})
$objForm.Controls.Add($ApplyButtonPath)


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

$ApplyButtonBat = New-Object System.Windows.Forms.Button
# Die nächsten beiden Zeilen legen die Position und die Größe des Buttons fest
$ApplyButtonBat.Location = New-Object System.Drawing.Size(280,99)
$ApplyButtonBat.Size = New-Object System.Drawing.Size(75,23)
$ApplyButtonBat.Text = "Apply"
$ApplyButtonBat.Name = "Apply"
#Die folgende Zeile ordnet dem Click-Event die Schließen-Funktion für das Formular zu
$ApplyButtonBat.Add_Click({
    Write-Host "Bat Name:"
    global:batName = $textBoxBat.Text
    Write-Host $batName
})
$objForm.Controls.Add($ApplyButtonBat)

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
    Write-Host "Path:"
    Write-Host $objForm.serverPath
    startServer
    startNgrok
})
$objForm.Controls.Add($StartButton)

[void] $objForm.ShowDialog()

function startServer{
    $objForm.serverPath
    $batName

    #Start Bat 
    Set-Location $objForm.serverPath
    Start-Process $batName
}

function startNgrok{
$ngrokJob = Start-Job -ScriptBlock {"start $Using:serverPath\ngrok.exe tcp 25565 --region eu" |  cmd}

sleep 2

$url = (Invoke-WebRequest -UseBasicParsing -uri "http://localhost:4040/api/tunnels").Content
echo $url
$Json= ConvertFrom-Json -InputObject $url
$url = $Json.tunnels.public_url
$url = $url.trimStart("tcp://")
$url

Stop-Job -id $ngrokJob.Id
Remove-Job -id $ngrokJob.Id
}