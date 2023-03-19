[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$iconPath = ".\server.ico"
$folderPath = "Logo"

$objForm = New-Object System.Windows.Forms.Form
$objForm.Text = "Server-Management"
$objForm.StartPosition = "CenterScreen"
$objForm.Size = New-Object System.Drawing.Size(800,500)

$drives = (Get-PSDrive -PSProvider FileSystem).Name

$objListbox = New-Object System.Windows.Forms.Listbox 
$objListbox.Location = New-Object System.Drawing.Size(10,40) 
$objListbox.Size = New-Object System.Drawing.Size(20,20) 
$objListbox.SelectionMode = "MultiExtended"
$objListbox.Height = 70
$psDrivers = Get-PrinterDriver | Where-Object {$_.Type -eq "PS"}
foreach ($psDriver in $psDrivers) {
    $objListBox.Items.Add($psDriver.Name)
}
$objForm.Controls.Add($objListbox) 

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(20,20)
$objLabel.Size = New-Object System.Drawing.Size(200,20)
$objLabel.Text = "Server-Ordner Path :"
$objForm.Controls.Add($objLabel)

$objTextBox = New-Object System.Windows.Forms.TextBox
$objTextBox.Location = New-Object System.Drawing.Size(20,40)
$objTextBox.Size = New-Object System.Drawing.Size(200,20)
$objForm.Controls.Add($objTextBox)

$ApplyButton = New-Object System.Windows.Forms.Button
# Die nächsten beiden Zeilen legen die Position und die Größe des Buttons fest
$ApplyButton.Location = New-Object System.Drawing.Size(240,39)
$ApplyButton.Size = New-Object System.Drawing.Size(75,23)
$ApplyButton.Text = "Apply"
$ApplyButton.Name = "Apply"
#Die folgende Zeile ordnet dem Click-Event die Schließen-Funktion für das Formular zu
$ApplyButton.Add_Click({
    Get-PSDrive
})
$objForm.Controls.Add($ApplyButton)

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

})
$objForm.Controls.Add($StartButton)

#[void] $objForm.ShowDialog()

function startServer{
    #Start Bat 
    ServerSet-Location $serverPath
    Start-Process run.bat
}
$serverPath = "E:\Order\AllServer\Minecraft-Server\TestServer"
$batPath = "E:\Order\AllServer\Minecraft-Server\TestServer\run.bat"



$ngrokJob = Start-Job -ScriptBlock {"start / $Using:serverPath\ngrok.exe tcp 25565 --region eu" |  cmd}
sleep 2

$url = (Invoke-WebRequest -UseBasicParsing -uri "http://localhost:4040/api/tunnels").Content
$Json= ConvertFrom-Json -InputObject $url
$url = $contentJson.tunnels.public_url
$url = $url.trimStart("tcp://")
$url

Stop-Job -id $ngrokJob.Id
Remove-Job -id $ngrokJob.Id