<#
.SYNOPSIS
Updates the graphical user interface (GUI) for managing the HDToolbox tool.

.DESCRIPTION
This script Updates a user-friendly GUI for interacting with the HDToolbox tool. The interface allows helpdesk teams to select configurations, browse log files, and execute associated PowerShell scripts without needing to use the command line.  

Users can also view outputs and save processed results directly from the GUI.  

.PARAMETER Form
The HDTForm Window object to update


.EXAMPLE
Update-HdtUi -SelectedConfig $SelectedConfig

.NOTES
Version: 1.0  
Author:JPS
Created: 12/22/2024 

This script uses Windows Presentation Foundation (WPF) or Windows Forms for building the GUI.

.LINK
TBD
#>
Function Update-HdtUi {
[CmdletBinding()]
param (
	[HdtForm]
	$HdtForm,

	[Switch] $Update
)

	#Update Dimentions
	Update-HdtUiBranding -HdtForm $HdtForm

	#Update config
	if (-not ($update.IsPresent)){
		Write-Debug -Message "HDToolbox UI is updating configs"
		Update-HdtUiConfigDrop -HdtForm $HdtForm
	}

	#update Variables 
	Update-HdtUiVariables -HdtForm $HdtForm

	# Update Script Nodes
	Write-verbose -Message "HDToolbox Removing old script Nodes"
	Remove-HdtUiScriptsNode -HdtForm $HdtForm

	Write-verbose -Message "HDToolbox Adding Script Nodes"
	Update-HdtUiScriptsNode -HdtForm $HdtForm

	#logs
	Write-verbose -Message "HDToolbox adding Logs"
	$LogsExpanderGrid = $HdtForm.form.FindName("LogsExpander")
	$GridRows = $HdtForm.form.FindName("GridRows")
	$index = $GridRows.RowDefinitions.IndexOf($HdtForm.form.FindName("LogGridRow")) 
	[System.Windows.Controls.Grid]::SetRow($LogsExpanderGrid,$index)
	Update-HdtLogs -HdtForm $HdtForm

	#Update on timer
	if (-not ($Update.IsPresent)){
		Write-verbose -Message "HDToolbox Setting Refresh timer for logs"
		$Timer = New-Object System.Windows.Forms.Timer
		$Timer.Interval = 1000  # Timer interval in milliseconds (1000 ms = 1 second)
		$timer.tag = @{'HdtForm' = $HdtForm}
		$Null = $Timer.Add_Tick({
			param($sender, $e)
			# Update the label text with the current time
			Update-HdtLogs -HdtForm $sender.Tag['HdtForm'] -Update
		})
		$timer.Add_Tick({
			param($sender, $e)
			Start-HdtTickScriptMonitor -HdtForm $sender.Tag['HdtForm']
		})
		$Timer.Start()
	}

	#Buttons
	$GatherLogsButton = $HdtForm.form.FindName("GatherLogs")
	$index = $GridRows.RowDefinitions.IndexOf($HdtForm.form.FindName("ButtonGridRow")) 
	[System.Windows.Controls.Grid]::SetRow($GatherLogsButton,$index)
	$GatherLogsButton.tag = @{'HdtForm' = $HdtForm}
	$GatherLogsButton.Add_Click({
		param($sender, $e)
		Start-HdtGather -HdtForm $sender.Tag['HdtForm']
	})
	pop-location
}
