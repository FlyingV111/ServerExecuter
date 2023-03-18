[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$objForm = New-Object System.Windows.Forms.Form
$objForm.Text = "Server-Management"
$objForm.StartPosition = "CenterScreen"
$objForm.Size = New-Object System.Drawing.Size(800,500)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(20,20)
$objLabel.Size = New-Object System.Drawing.Size(200,20)
$objLabel.Text = "Server-Ordner Path :"
$objForm.Controls.Add($objLabel)

$objTextBox = New-Object System.Windows.Forms.TextBox
$objTextBox.Location = New-Object System.Drawing.Size(20,40)
$objTextBox.Size = New-Object System.Drawing.Size(200,20)
$objForm.Controls.Add($objTextBox)


[void] $objForm.ShowDialog()

E:
cd "E:\Order\AllServer\Minecraft Server\TestServer"
start run.bat

E:
cd "E:\Order\AllServer\Minecraft Server"  
#.\ngrok.exe tcp 25565 --region eu --log=stdout > .\Log.txt 2>&1;

echo Moin
$extract = Select-String -Path "Log.txt" -Pattern "url=tcp:";
echo $extract
pause

