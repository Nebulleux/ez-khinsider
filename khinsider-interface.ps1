Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Fonction pour mettre à jour l'interface avec les sorties du script
function Update-Output {
    param (
        [string]$outputLine
    )
    $textboxOutput.Invoke([System.Action]{
        $textboxOutput.AppendText("$outputLinern")
        $textboxOutput.ScrollToCaret()
    })
}

# Créer la fenêtre
$form = New-Object System.Windows.Forms.Form
$form.Text = "OST Downloader"
$form.Size = New-Object System.Drawing.Size(600,400)
$form.StartPosition = "CenterScreen"

# Créer une étiquette pour l'URL
$labelUrl = New-Object System.Windows.Forms.Label
$labelUrl.Text = "Entrez l'URL de l'OST :"
$labelUrl.Location = New-Object System.Drawing.Point(10,20)
$labelUrl.Size = New-Object System.Drawing.Size(120,20)
$form.Controls.Add($labelUrl)

# Créer la boîte de texte pour l'URL
$textboxUrl = New-Object System.Windows.Forms.TextBox
$textboxUrl.Location = New-Object System.Drawing.Point(150,20)
$textboxUrl.Size = New-Object System.Drawing.Size(400,20)
$form.Controls.Add($textboxUrl)

# Créer une étiquette pour le format
$labelFormat = New-Object System.Windows.Forms.Label
$labelFormat.Text = "Sélectionnez le format :"
$labelFormat.Location = New-Object System.Drawing.Point(10,60)
$labelFormat.Size = New-Object System.Drawing.Size(120,20)
$form.Controls.Add($labelFormat)

# Créer la liste déroulante pour le format
$comboboxFormat = New-Object System.Windows.Forms.ComboBox
$comboboxFormat.Location = New-Object System.Drawing.Point(150,60)
$comboboxFormat.Size = New-Object System.Drawing.Size(400,20)
$comboboxFormat.Items.AddRange(@("mp3", "m4a", "flac"))
$comboboxFormat.DropDownStyle = "DropDownList"
$form.Controls.Add($comboboxFormat)

# Créer la barre de progression
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10,100)
$progressBar.Size = New-Object System.Drawing.Size(560,20)
$progressBar.Minimum = 0
$progressBar.Maximum = 100
$form.Controls.Add($progressBar)

# Créer la boîte de texte pour la sortie
$textboxOutput = New-Object System.Windows.Forms.TextBox
$textboxOutput.Location = New-Object System.Drawing.Point(10,130)
$textboxOutput.Size = New-Object System.Drawing.Size(560,200)
$textboxOutput.Multiline = $true
$textboxOutput.ScrollBars = 'Vertical'
$form.Controls.Add($textboxOutput)

# Créer le bouton OK
$buttonOk = New-Object System.Windows.Forms.Button
$buttonOk.Text = "OK"
$buttonOk.Location = New-Object System.Drawing.Point(250,340)
$form.Controls.Add($buttonOk)

# Créer le bouton Quitter
$buttonQuit = New-Object System.Windows.Forms.Button
$buttonQuit.Text = "Quitter"
$buttonQuit.Location = New-Object System.Drawing.Point(340,340)
$buttonQuit.Add_Click({
    $form.Close()
})
$form.Controls.Add($buttonQuit)

# Fonction qui sera exécutée dans un runspace
$runspaceJob = {
    param ($textboxOutput, $progressBar, $url, $format, $scriptDirectory)

    try {
        # Définir le répertoire de travail
        Set-Location -Path $scriptDirectory

        # Commande Python avec chemin absolu pour le script
        $pythonScript = "$scriptDirectory\khinsider.py"
        $arguments = "--format $format $url"

        # Créer un processus pour exécuter le script Python
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = "python"
        $psi.Arguments = "$pythonScript $arguments"
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true

        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $psi
        $process.Start() | Out-Null

        # Lire la sortie du script Python
        $outputReader = $process.StandardOutput
        $errorReader = $process.StandardError

        while (-not $process.HasExited) {
            $line = $outputReader.ReadLine()
            if ($line) {
                $textboxOutput.Invoke([action] { $textboxOutput.AppendText("$linern") })
            }
        }

        # Traiter les lignes restantes
        while ($line = $outputReader.ReadLine()) {
            $textboxOutput.Invoke([action] { $textboxOutput.AppendText("$linern") })
        }

        # Lire et afficher les erreurs s'il y en a
        while ($errorLine = $errorReader.ReadLine()) {
            $textboxOutput.Invoke([action] { $textboxOutput.AppendText("ERROR: $errorLinern") })
        }

        # Mettre à jour la barre de progression à 100% une fois terminé
        $progressBar.Invoke([action] { $progressBar.Value = 100 })
    }
    catch {
        $textboxOutput.Invoke([action] { $textboxOutput.AppendText("ERROR: $($_.Exception.Message)rn") })
    }
}

# Action pour le bouton OK
$buttonOk.Add_Click({
    $textboxOutput.Invoke([action] { $textboxOutput.AppendText("OK Button clicked, get a coffee.rn") })

    $url = $textboxUrl.Text
    $format = $comboboxFormat.SelectedItem

    # Définir le répertoire de travail pour s'assurer que khinsider.py est trouvé
    $scriptDirectory = "C:\Users\jbrop\Bureau\ez-khinsider-main"  # Remplacez par le chemin correct

    # Vérifier si l'URL et le format ont été saisis
    if ($url -and $format) {
        $progressBar.Invoke([action] { $progressBar.Value = 0 })

        # Créer un nouveau runspace pour exécuter le script en arrière-plan
        $runspace = [powershell]::Create().AddScript($runspaceJob).AddArgument($textboxOutput).AddArgument($progressBar).AddArgument($url).AddArgument($format).AddArgument($scriptDirectory)
        $runspace.RunspacePool = [runspacefactory]::CreateRunspacePool(1, [int]::MaxValue)
        $runspace.RunspacePool.Open()
        $runspace.BeginInvoke()
    } else {
        $textboxOutput.Invoke([action] { $textboxOutput.AppendText("URL ou format non spécifié. Le script ne sera pas exécuté.rn") })
    }
})

# Afficher le formulaire
$form.Topmost = $true
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()