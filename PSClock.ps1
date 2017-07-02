#################################################################################################
# Name			: 	PSClock.ps1
# Description	: 	Main
# Author		: 	Axel Anderson
# License		:	
# History		: 	04.01.2017 	AAn		Created
# 					15.4.2017	AAn		Clock Main ready with Resizable Content (Fonts), Settings in XML, Notify Icon
#					30.4.2017	AAn		0.2.0.0		Alarm Dialog
#					07.05.2017	AAn		0.2.1.0		Calculate-FontFromText ==> Font.Dispose()
#					11.05.2017	AAn		0.2.2.0		Opacity-Settings in Config
#					17.05.2017	AAn		0.2.3.0		Add StopWatch in ContectMenu
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#Requires –Version 3
[CmdletBinding()]
Param   (
			
		)
Set-StrictMode -Version Latest	
#
#################################################################################################
#
#
#region ScriptVariables
#
$script:ScriptName		= "PSClock"
$script:ScriptDesc		= "Powershell Clock"
$script:ScriptDate		= "17. Mai 2017"
$script:ScriptAuthor	= "Axel Anderson"					
$script:ScriptVersion	= "0.2.3.0"
$script:ConfigVersion	= "1"
#
#Script Information
$script:WorkingFileName = $MyInvocation.MyCommand.Definition
$script:WorkingDirectory = Split-Path $script:WorkingFileName -Parent

[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
	
Add-Type –assemblyName WindowsBase -IgnoreWarnings	

#region WINFORMS CONTROLS	

[System.Windows.Forms.Application]::EnableVisualStyles()

$script:formMainWindow			= New-Object System.Windows.Forms.Form	
	$script:tablePanelMain 		= New-Object System.Windows.Forms.TableLayoutPanel	
		$script:lbTimeDisplay 	= New-Object System.Windows.Forms.Label
		$script:lbDateDisplay 	= New-Object System.Windows.Forms.Label
		$script:tablePanelTimer	= New-Object System.Windows.Forms.TableLayoutPanel	

$Script:FontBase = New-Object System.Drawing.Font("Segoe UI",9, [System.Drawing.FontStyle]::Regular)
$script:FontMainTime = New-Object System.Drawing.Font("Segoe UI",52, [System.Drawing.FontStyle]::Bold)
$script:FontMainDate = New-Object System.Drawing.Font("Segoe UI",16, [System.Drawing.FontStyle]::Bold)

$script:contextMenu = New-Object System.Windows.Forms.ContextMenu
	$script:menuItem_Timer_1Minutes 	= New-Object System.Windows.Forms.MenuItem "1 Minute"
	$script:menuItem_Timer_2Minutes 	= New-Object System.Windows.Forms.MenuItem "2 Minuten"
	$script:menuItem_Timer_3Minutes 	= New-Object System.Windows.Forms.MenuItem "3 Minuten"
	$script:menuItem_Timer_4Minutes 	= New-Object System.Windows.Forms.MenuItem "4 Minuten"
	$script:menuItem_Timer_5Minutes 	= New-Object System.Windows.Forms.MenuItem "5 Minuten"
	$script:menuItem_Timer_6Minutes 	= New-Object System.Windows.Forms.MenuItem "6 Minuten"
	$script:menuItem_Timer_7Minutes 	= New-Object System.Windows.Forms.MenuItem "7 Minuten"
	$script:menuItem_Timer_8Minutes 	= New-Object System.Windows.Forms.MenuItem "8 Minuten"
	$script:menuItem_Timer_9Minutes 	= New-Object System.Windows.Forms.MenuItem "9 Minuten"
	$script:menuItem_Timer_10Minutes 	= New-Object System.Windows.Forms.MenuItem "10 Minuten"
	$script:menuItem_Timer_15Minutes 	= New-Object System.Windows.Forms.MenuItem "15 Minuten"
	$script:menuItem_Timer_20Minutes 	= New-Object System.Windows.Forms.MenuItem "20 Minuten"
	$script:menuItem_Timer_25Minutes 	= New-Object System.Windows.Forms.MenuItem "25 Minuten"
	$script:menuItem_Timer_30Minutes 	= New-Object System.Windows.Forms.MenuItem "30 Minuten"
	$script:menuItem_Timer_35Minutes 	= New-Object System.Windows.Forms.MenuItem "35 Minuten"
	$script:menuItem_Timer_40Minutes 	= New-Object System.Windows.Forms.MenuItem "40 Minuten"
	$script:menuItem_Timer_45Minutes 	= New-Object System.Windows.Forms.MenuItem "45 Minuten"
	$script:menuItem_Timer_50Minutes 	= New-Object System.Windows.Forms.MenuItem "50 Minuten"
	$script:menuItem_Timer_55Minutes 	= New-Object System.Windows.Forms.MenuItem "55 Minuten"
	$script:menuItem_Timer_60Minutes 	= New-Object System.Windows.Forms.MenuItem "1 Stunde"
	$script:menuItem_Timer_75Minutes 	= New-Object System.Windows.Forms.MenuItem "1 Stunde, 15 Minuten"
	$script:menuItem_Timer_90Minutes 	= New-Object System.Windows.Forms.MenuItem "1 Stunde, 30 Minuten"
	$script:menuItem_Timer_105Minutes 	= New-Object System.Windows.Forms.MenuItem "1 Stunde, 45 Minuten"
	$script:menuItem_Timer_120Minutes 	= New-Object System.Windows.Forms.MenuItem "2 Stunden"
	$script:menuItem_Timer_135Minutes 	= New-Object System.Windows.Forms.MenuItem "2 Stunden 15 Minuten"
	$script:menuItem_Timer_150Minutes 	= New-Object System.Windows.Forms.MenuItem "2 Stunden 30 Minuten"
	$script:menuItem_Timer_165Minutes 	= New-Object System.Windows.Forms.MenuItem "2 Stunden 45 Minuten"
	$script:menuItem_Timer_180Minutes 	= New-Object System.Windows.Forms.MenuItem "3 Stunden"
	$script:menuItem_Timer_Custom	 	= New-Object System.Windows.Forms.MenuItem "Custom"
	
	$script:menuItem_CountDown 				= New-Object System.Windows.Forms.MenuItem "Timer (Down)"
	$script:menuItem_CountDown.MenuItems.AddRange(
												@($script:menuItem_Timer_1Minutes,
												  $script:menuItem_Timer_2Minutes,		
												  $script:menuItem_Timer_3Minutes,		
												  $script:menuItem_Timer_4Minutes,		
												  $script:menuItem_Timer_5Minutes,		
												  $script:menuItem_Timer_6Minutes,		
												  $script:menuItem_Timer_7Minutes,		
												  $script:menuItem_Timer_8Minutes,		
												  $script:menuItem_Timer_9Minutes,		
												  $script:menuItem_Timer_10Minutes,
												  $script:menuItem_Timer_15Minutes,
												  $script:menuItem_Timer_20Minutes,
												  $script:menuItem_Timer_25Minutes,
												  $script:menuItem_Timer_30Minutes,
												  $script:menuItem_Timer_35Minutes,
												  $script:menuItem_Timer_40Minutes,
												  $script:menuItem_Timer_45Minutes,
												  $script:menuItem_Timer_50Minutes,
												  $script:menuItem_Timer_55Minutes,
												  $script:menuItem_Timer_60Minutes,
												  $script:menuItem_Timer_75Minutes,
												  $script:menuItem_Timer_90Minutes,
												  $script:menuItem_Timer_105Minutes,
												  $script:menuItem_Timer_120Minutes ,
												  $script:menuItem_Timer_135Minutes,
												  $script:menuItem_Timer_150Minutes,
												  $script:menuItem_Timer_165Minutes ,
												  $script:menuItem_Timer_180Minutes,
												  $script:menuItem_Timer_Custom
											  )) | out-null
	
	$contextMenu.MenuItems.Add($script:menuItem_CountDown) | out-null
	$script:menuItem_Alarm 				= New-Object System.Windows.Forms.MenuItem "Alarm"
	$contextMenu.MenuItems.Add($script:menuItem_Alarm) | out-null

	$script:menuItem_StopWatch 				= New-Object System.Windows.Forms.MenuItem "StopWatch"
	$contextMenu.MenuItems.Add($script:menuItem_StopWatch) | out-null

	$contextMenu.MenuItems.Add("-") | out-null
	$script:menuItem_Exit = $contextMenu.MenuItems.Add("Exit")

$Script:NotifyIcon				= New-Object System.Windows.Forms.NotifyIcon
	$Script:NIContextMenu		= New-Object System.Windows.Forms.ContextMenu
		$Script:NIMenuItemExit	= New-Object System.Windows.Forms.MenuItem

		
	
$script:MainFormWidth	= 350
$script:MainFormHeight	= 130
#endregion WINFORMS CONTROLS
	
#region  CLOCK Tick (Main)

$script:tmrTickMain = New-Object System.Windows.Threading.DispatcherTimer 
$script:tmrTickMain.Stop()
$script:tmrTickMain.IsEnabled = $false
$script:tmrTickMain.Interval = [System.TimeSpan]::FromMilliSeconds(500)

$script:MainTimer = @{
						Now 			= [System.Datetime]::Now;
						Time			= $Null
						Date			= $Null
						CurrentNow      = $Null
						CurrentTime		= $Null
						CurrentDate		= $Null
						MinutesChanged  = $False
						HourChanged		= $False
						DateChanged		= $False
	
					}
$Script:MainTimer.CurrentNow  = $Script:MainTimer.Now
$Script:MainTimer.CurrentDate = $Script:MainTimer.CurrentNow.Date
$Script:MainTimer.CurrentTime = $Script:MainTimer.CurrentNow.TimeOfDay

$Script:MainTimer.Now = ((((($Script:MainTimer.Now).AddDays(-1)).AddHours(-1)).AddMinutes(-1)).AddSeconds(-1))
$Script:MainTimer.Date 		  = $Script:MainTimer.Now.Date
$Script:MainTimer.Time 		  = $Script:MainTimer.Now.TimeOfDay
	
$SB_MainClockTimerTick = {

	$Script:MainTimer.CurrentNow = [System.Datetime]::Now
	Update-CLOCK
}
# 
#endregion  CLOCK Tick (Main)	

#region ScriptIconData

[string]$script:ScriptIconString = @"
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
"@
$iconStream=[System.IO.MemoryStream][System.Convert]::FromBase64String($script:ScriptIconString)
$iconBmp=[System.Drawing.Bitmap][System.Drawing.Image]::FromStream($iconStream)
$iconHandle=$iconBmp.GetHicon()
$script:ScriptIcon=[System.Drawing.Icon]::FromHandle($iconHandle)
#>
#endregion ScriptIconData

# Move / Dragging
$script:isDrag			= $false
$script:StartDragPoint 	= $null

# Settings
$script:MainClock_ShowSeconds 		= $True
$script:Opacity_Activated_Main 		= 1
$script:Opacity_Deactivate_Main 	= 0.6
	
#endregion ScriptVariables

#region CONFIGURATION

#region CONFIGURATION_VARIABLES
#Configuration Variables
$script:xmlConfigFilename = Join-Path $script:WorkingDirectory "PSClock.config.xml"
$script:ConfigurationDataSetName = "PSClock"
$script:xmlConfig = New-Object System.Data.DataSet($script:ConfigurationDataSetName)

$script:DummyID = "00000000-0000-0000-0000-000000000000"

# Window ID for Bounds-Settings
$script:BoundsMainWindowID = "02BCBDFF-26AB-4182-9FBA-BFF4DAFBC8B7-00001"

#endregion CONFIGURATION_VARIABLES

#region CONFIGURATION_FUNCTIONS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Function Add-DataSetTable {
    Param(	[System.Data.Dataset]$DataSet,
			[string]$TableName,
			[array]$Columns)
			
    $dtTable = New-Object System.Data.DataTable($TableName)
    $dtTable.Columns.AddRange(@($Columns))
    $DataSet.Tables.Add($dtTable)
}
#
# --------------------------------------------------------------------------------------------------------------------------
#
Function Add-DataTableRow {
    Param(	[System.Data.DataSet]$DataSet,
			[string]$TableName,
			[hashtable]$RowData)
			
    $NewRow = $DataSet.Tables[$TableName].NewRow()
    $RowData.keys | % {$NewRow.$_ = $RowData.$_}
    $DataSet.Tables[$TableName].Rows.Add($NewRow)
	
}
#
# ---------------------------------------------------------------------------------------------------------------------------
#
Function Load-AllScriptSettingValues {
[CmdletBinding()]
Param	()

	$UInt32Value = Get-ScriptSettingsValue "MainClock_ShowSeconds" -DefaultValue 1
	$script:MainClock_ShowSeconds	= if ($UInt32Value -eq 1) {$True} else {$False}
	# ------------------------------------------------------------------------------------------------------------------------
	$script:Opacity_Activated_Main 	= (Get-ScriptSettingsValue "Opacity_Activated_Main" -DefaultValue ($script:Opacity_Activated_Main*100))/100
	$script:Opacity_Deactivate_Main = (Get-ScriptSettingsValue "Opacity_Deactivate_Main" -DefaultValue ($script:Opacity_Deactivate_Main*100))/100	

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Load-Settings {
[CmdletBinding()]
Param	()

	$retVal = ReLoad-Config -XmlConfigFile $script:xmlConfigFilename -CreateNewIfNeeded:$true

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Save-Settings {
[CmdletBinding()]
Param( )
	
	$script:xmlConfig.Tables["Script"].Rows[0].ScriptName		= $script:ScriptName
	$script:xmlConfig.Tables["Script"].Rows[0].ScriptDate		= $script:ScriptDate
	$script:xmlConfig.Tables["Script"].Rows[0].ScriptVersion	= $script:ScriptVersion
	$script:xmlConfig.Tables["Script"].Rows[0].ScriptAuthor		= $script:ScriptAuthor
	$script:xmlConfig.Tables["Script"].Rows[0].ConfigVersion	= $script:ConfigVersion
	
	#
	# ADD HERE ALL other required settings
	#
	#----------------------------------------------------------------------------------------------------------
	Set-ScriptSettingsValue "Opacity_Activated_Main" 				($script:Opacity_Activated_Main*100)
	#----------------------------------------------------------------------------------------------------------
	Set-ScriptSettingsValue "Opacity_Deactivate_Main" 				($script:Opacity_Deactivate_Main*100)
	#----------------------------------------------------------------------------------------------------------
	$UIntValue = if ($script:MainClock_ShowSeconds) {1} else {0}	
	Set-ScriptSettingsValue "MainClock_ShowSeconds" $UIntValue
	#----------------------------------------------------------------------------------------------------------
	
	try {
		$script:xmlConfig.AcceptChanges()
		[void]$script:xmlConfig.WriteXml($script:xmlConfigFilename)
	} catch {
	}

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function ReLoad-Config {
	Param	( [string]$xmlConfigFilename,
			  [switch]$CreateNewIfNeeded=$false
			)
	
	$bRetVal = $false

    if (Test-Path $xmlConfigFilename) { #The config exists, read it.
	
		try {
			$script:xmlConfig.clear()
			$script:xmlConfig = New-Object System.Data.DataSet($script:ConfigurationDataSetName)
			$script:xmlConfig.ReadXml($xmlConfigFilename) | Out-Null
			$script:xmlConfig.AcceptChanges()
			$bRetVal = $true
		} catch {
			Write-Host -fore red "ERROR LOADING FILE $($xmlConfigFilename)" 
			$_ | out-host
		}
	    
		if ($bRetVal -and (Validate-Config $script:xmlConfig)) {
			$script:xmlConfigFilename = $xmlConfigFilename
		} else {
			$bRetVal = $false
		}
	} 	
    if (!$bRetVal) {
		
		if ($CreateNewIfNeeded) {
	
			$script:xmlConfig = Create-NewConfigurationDataSet
			
			try {
				$script:xmlConfig.AcceptChanges()
				[void]$script:xmlConfig.WriteXml($script:xmlConfigFilename)
			} catch {
				$_ | out-host
			}
		}	
	}
	
	$bRetVal 	
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Validate-Config{
    param([System.Data.DataSet]$DataSet)
	
    try {
		#Read settings table from the XML dataset.
		$SettingsInfo = $DataSet.Tables["Script"].Rows[0]
	
        if (($SettingsInfo.ScriptName -eq $script:ScriptName) -and
			($SettingsInfo.ScriptAuthor -eq $script:ScriptAuthor) -and
			($SettingsInfo.ConfigVersion -eq $script:ConfigVersion)) {
			
			return $True
		} else {
			return $False
		}
	} catch{ 
		$_ | out-host
		return $False
	}
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Create-NewConfigurationDataSet {
[CmdletBinding()]
Param	(
		)
    #Create a brand new dataset.
    $ConfigurationDataSet = New-Object System.Data.DataSet($script:ConfigurationDataSetName)

    #Define table structures for the config tables.
    $htTableStructure_Script = @{
        DataSet=$ConfigurationDataSet
        TableName="Script"
        Columns=@("ScriptName", "ScriptDate", "ScriptVersion", "ScriptAuthor", "ConfigVersion")
    }
    $htTableStructure_Settings = @{
        DataSet=$ConfigurationDataSet
        TableName="Settings"
        Columns=@("MainClock_ShowSeconds","Opacity_Activated_Main","Opacity_Deactivate_Main")
    }	
	$htTableStructure_Bounds = @{
        DataSet=$ConfigurationDataSet
        TableName="Bounds"
        Columns=@("ID","Name","XPos","YPos","Width","Height","IsSet")
    }
	
    #Add base configuration tables to the dataset.
    Add-DataSetTable @htTableStructure_Script
	Add-DataSetTable @htTableStructure_Settings
    Add-DataSetTable @htTableStructure_Bounds
    
	# -------------------------------------------------------------------------------------------------------------------------
	
	$htDataScript = @{
        DataSet=$ConfigurationDataSet
        TableName="Script"
        RowData = @{
            ScriptName		= $script:ScriptName
			ScriptDate		= $script:ScriptDate
            ScriptVersion	= $script:ScriptVersion
            ScriptAuthor	= $script:ScriptAuthor
			ConfigVersion 	= $script:ConfigVersion
        }
    }
	Add-DataTableRow @htDataScript
	$htDataSettings = @{
        DataSet=$ConfigurationDataSet
        TableName="Settings"
        RowData = @{
            MainClock_ShowSeconds	= 1
			Opacity_Activated_Main  = 100
			Opacity_Deactivate_Main = 60
        }
    }
	Add-DataTableRow @htDataSettings
    $htDataBounds = @{
        DataSet=$ConfigurationDataSet
        TableName="Bounds"
        RowData = @{
            ID			= $script:BoundsMainWindowID
			Name		= "MainWindow"
			XPos		= "0"
			YPos		= "0"
			Width		= $script:MainFormWidth
			Height		= $script:MainFormHeight
			IsSet		= "0"
        }
    }

    Add-DataTableRow @htDataBounds	
    
	Write-Output $ConfigurationDataSet
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function New-SettingsWindowBoundsObject {
[CmdletBinding()]
Param	(
			[string]$ID
		)
		
	$Bounds = New-Object PSObject -Property @{
            ID			= $ID
			Name		= ""
			XPos		= 0
			YPos		= 0
			Width		= -1
			Height		= -1
			IsSet		= "0"	
	}
	Write-Output $Bounds
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Get-SettingsWindowBounds {
[CmdletBinding()]
Param	(
			[string]$ID
		)
		
	$Bounds = New-SettingsWindowBoundsObject -ID $ID
	
	$SettingsObject = $script:xmlconfig.Tables["Bounds"].Select(("ID = '"+$ID+"'"))
		
	if ($SettingsObject) {
		
		$Bounds.ID			= $SettingsObject[0].ID
		$Bounds.Name		= $SettingsObject[0].Name
		$Bounds.XPos		= [int]$SettingsObject[0].XPos
		$Bounds.YPos		= [int]$SettingsObject[0].YPos
		$Bounds.Width		= [int]$SettingsObject[0].Width
		$Bounds.Height		= [int]$SettingsObject[0].Height
		$Bounds.IsSet		= $SettingsObject[0].IsSet
		
		$WorkingArea = [System.Windows.Forms.Screen]::AllScreens | Where-Object {$_.Primary -eq 'True'} | Select-Object -Expand WorkingArea
		$ScreenWidth = $WorkingArea.Width
		$ScreenHeight = $WorkingArea.Height
		
		if (($Bounds.XPos -gt $ScreenWidth) -or ($Bounds.XPos -lt 0)) {$Bounds.XPos = 0}
		if (($Bounds.YPos -gt $ScreenHeight) -or ($Bounds.YPos -lt 0)) {$Bounds.YPos = 0}
	
	}
	
	Write-Output $Bounds
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Set-SettingsWindowBounds {
[CmdletBinding()]
Param	(
			[string]$ID,
			[System.Drawing.Rectangle]$FormsBound
		)
		
	$SettingsObject = $script:xmlconfig.Tables["Bounds"].Select(("ID = '"+$ID+"'"))
		
	if ($SettingsObject) {
	
		$SettingsObject[0].XPos   = [String]$FormsBound.X
		$SettingsObject[0].YPos   = [String]$FormsBound.Y
		$SettingsObject[0].Width  = [String]$FormsBound.Width
		$SettingsObject[0].Height = [String]$FormsBound.Height
		$SettingsObject[0].IsSet  = [string]"1"
		$SettingsObject.AcceptChanges()	
		
	} else {
	
		$htDataBounds = @{
			DataSet=$script:xmlConfig
			TableName="Bounds"
			RowData = @{
				ID			= $ID
				Name		= ""
				XPos		= [String]$FormsBound.X
				YPos		= [String]$FormsBound.Y
				Width		= [String]$FormsBound.Width
				Height		= [String]$FormsBound.Height
				IsSet		= "1"
			}
		}

		Add-Row @htDataBounds	
	}

}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Set-ScriptSettingsValue {
[CmdletBinding()]
Param	(
			[string]$SettingsName,
			$SettingsValue
		)
	if ($script:xmlconfig.Tables["Settings"]) {
		if ( !($script:xmlconfig.Tables["Settings"].Columns.Contains($SettingsName))) {
			$script:xmlconfig.Tables["Settings"].Columns.Add($SettingsName)
			$script:xmlConfig.AcceptChanges()
		} 
		$SettingsObject = $script:xmlconfig.Tables["Settings"].Select()
		if ($SettingsObject) {
			$SettingsObject[0].($SettingsName) = $SettingsValue
			$SettingsObject.AcceptChanges()
		}
	}
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Get-ScriptSettingsValue {
[CmdletBinding()]
Param	(
			[string]$SettingsName,
			$DefaultValue
		)
	$SettingsValue = $DefaultValue
	
	if ($script:xmlconfig.Tables["Settings"]) {
		if ( $script:xmlconfig.Tables["Settings"].Columns.Contains($SettingsName)) {
			$SettingsObject = $script:xmlconfig.Tables["Settings"].Select()
			if ($SettingsObject) {
				$SettingsValue = $SettingsObject[0].($SettingsName)
			}
		}
	}

	Write-Output $SettingsValue
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
#endregion CONFIGURATION_FUNCTIONS

#endregion CONFIGURATION

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
<#
public static void SetDoubleBuffering(System.Windows.Forms.Control control, bool value)
{
    System.Reflection.PropertyInfo controlProperty = typeof(System.Windows.Forms.Control)
        .GetProperty("DoubleBuffered", System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Instance);
    controlProperty.SetValue(control, value, null);
}

$L.GetType().getProperty("DoubleBuffered",[System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Instance)
$prop.SetValue($L,$True,$Null)
#>
Function Set-WincontrolDoubleBuffering {
[CmdletBinding()]
Param	(
			$Control,
			[switch]$value = $True
		)
		
	$prop = $Control.GetType().getProperty("DoubleBuffered",[System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Instance)
	$prop.SetValue($Control,$True,$Null)
	
}

Function Update-Clock {
[CmdletBinding()]
Param	(
		)
	$Script:MainTimer.CurrentDate = $Script:MainTimer.CurrentNow.Date
	$Script:MainTimer.CurrentTime = $Script:MainTimer.CurrentNow.TimeOfDay
	
	#
	# General : Time and date changed
	#

	#
	# Check if Date has changed
	#
	if ($Script:MainTimer.Date -ne $Script:MainTimer.CurrentNow.Date) {
		#
		$script:lbdateDisplay.Text = $Script:MainTimer.CurrentNow.ToLongDateString()
		Resize-Controls
		#
	}
	#
	# Check every Second 
	#
	if ($Script:MainTimer.Time.Seconds -ne $Script:MainTimer.CurrentTime.Seconds) {
		if ($script:MainClock_ShowSeconds) {
			$script:lbTimeDisplay.Text = $Script:MainTimer.CurrentNow.ToLongTimeString()
		} else {
			$script:lbTimeDisplay.Text = $Script:MainTimer.CurrentNow.ToShortTimeString()
		}
	}
	#
	# Check every Minute 
	#
	if ($Script:MainTimer.Time.Minutes -ne $Script:MainTimer.CurrentTime.Minutes) {
	}	
	#
	# Check every Hour 
	#
	if ($Script:MainTimer.Time.Hours -ne $Script:MainTimer.CurrentTime.Hours) {
	}	
	$Script:MainTimer.Date = $Script:MainTimer.CurrentNow.Date
	$Script:MainTimer.Time = $Script:MainTimer.CurrentNow.TimeOfDay
}
#					
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
Function Start-MainClockTick {
[CmdletBinding()]
Param	(
		)

	# ---------------------------------------------------------------------------------------------------------------
	$Script:MainTimer.Now 		  = [System.Datetime]::Now;
	$Script:MainTimer.CurrentNow  = $Script:MainTimer.Now
	$Script:MainTimer.CurrentDate = $Script:MainTimer.CurrentNow.Date
	$Script:MainTimer.CurrentTime = $Script:MainTimer.CurrentNow.TimeOfDay

	$Script:MainTimer.Now = ((((($Script:MainTimer.Now).AddDays(-1)).AddHours(-1)).AddMinutes(-1)).AddSeconds(-1))
	$Script:MainTimer.Date 		  = $Script:MainTimer.Now.Date
	$Script:MainTimer.Time 		  = $Script:MainTimer.Now.TimeOfDay
	# ---------------------------------------------------------------------------------------------------------------
		
	$script:tmrTickMain.Add_Tick($SB_MainClockTimerTick)
	$script:tmrTickMain.Start()

}
#					
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
Function Stop-MainClockTick {
[CmdletBinding()]
Param	(
		)
		
	$script:tmrTickMain.Stop()
	$script:tmrTickMain.IsEnabled = $false
	$script:tmrTickMain.Remove_Tick($SB_MainClockTimerTick)

}
function Calculate-FontFromText {
[CmdletBinding()]
	Param(  [Parameter(Mandatory=$true)][System.Drawing.Font]$StartFont,
			[Parameter(Mandatory=$true)][string]$Text,
			[Parameter(Mandatory=$true)][System.Drawing.Size]$Size,
			$Offset = 0
		 )
	#"Calculate-FontFromText"|out-host
	$FontFamily = $StartFont.FontFamily
	$FontStyle  = $StartFont.Style
	$FontSize   = $StartFont.Size		
	$Font = New-Object System.Drawing.Font ($FontFamily, $FontSize, $FontStyle)
	
	$TextWidth = [System.Windows.Forms.TextRenderer]::MeasureText($Text, $Font).Width + $offset
	
	if ($size.Width -lt $TextWidth) {
		while($size.Width -lt $TextWidth) {
			$FontSize   = $Font.Size
			$Font.Dispose()
			
			$Font = New-Object System.Drawing.Font ($FontFamily, ($FontSize - 0.5), $FontStyle)
			$TextWidth = [System.Windows.Forms.TextRenderer]::MeasureText($Text, $Font).Width + $offset
		}
	} elseif ($size.Width -gt $TextWidth) {
		while($size.Width -gt $TextWidth) {
			$FontSize   = $Font.Size
			$Font.Dispose()
			
			$Font = New-Object System.Drawing.Font ($FontFamily, ($FontSize + 0.5), $FontStyle)
			$TextWidth = [System.Windows.Forms.TextRenderer]::MeasureText($Text, $Font).Width + $offset
		}
	} 
	$TextHeight = [System.Windows.Forms.TextRenderer]::MeasureText($Text, $Font).Height
	if ($TextHeight -gt $size.Height ) {

		while($TextHeight -gt $size.Height) {
			$FontSize   = $Font.Size
			$Font.Dispose()
			
			$Font = New-Object System.Drawing.Font ($FontFamily, ($FontSize - 0.5), $FontStyle)
			$TextHeight = [System.Windows.Forms.TextRenderer]::MeasureText($Text, $Font).Height
			
		}
	} 
	return $font
}
#					
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
Function Adjust-ControlFont {
[CmdletBinding()]
Param	(
			$Control,
			$ControlFont,
			$Offset
		)
		
		
	$size 			= New-Object System.Drawing.Size
	$size.Width 	= $Control.Width
	$size.Height 	= $Control.Height
	
	$text 			= $Control.Text
	
	$Font = Calculate-FontFromText -StartFont $ControlFont -Text $text -Size $size -Offset $Offset
 
	return $Font
}
#					
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
Function Resize-Controls {
[CmdletBinding()]
Param	(
		)
	$script:FontMainTime = Adjust-ControlFont -Control $script:lbTimeDisplay -ControlFont $script:FontMainTime
	$script:lbTimeDisplay.Font = $script:FontMainTime
	# ----------------------------------------------------------------------------------------------------
	$script:FontMainDate = Adjust-ControlFont -Control $script:lbdateDisplay -ControlFont $script:FontMainDate -Offset 20
	$script:lbdateDisplay.Font = $script:FontMainDate
	# ----------------------------------------------------------------------------------------------------

}
#					
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
Function New-MainWindow {
[CmdletBinding()]
Param	(
		)

	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region CONTROLS
	$script:lbTimeDisplay | % {
		$_.Font = $script:FontMainTime
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)		
		$_.Name = "lbTimeDisplay"
		$_.TabStop = $false
		$_.Text = ""
	}
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:lbdateDisplay | % {
		$_.Font = $script:FontMainDate
		$_.Location = New-Object System.Drawing.Point(0,0)
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)		
		$_.Name = "lbdateDisplay"
		$_.TabStop = $false
		$_.Text = ""
	}
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	$script:tablePanelMain  | % {
		$_.Autosize = $True
		$_.AutosizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.Location = New-Object System.Drawing.Point(0, 0)
		$_.Margin = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "tablePanelMain"

		$_.ColumnCount = 1
		$_.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100))) | Out-Null
		$_.RowCount = 2;
		$_.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 80))) | Out-Null
		$_.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 20))) | Out-Null
		$_.Controls.Add($script:lbTimeDisplay, 0,0)
		$_.Controls.Add($script:lbDateDisplay, 1,0)
		$_.TabStop = $false
	}
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:formMainWindow | % {
		$_.AutoSize = $true
		
		$_.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::Sizable
		$_.BackColor = [System.Drawing.Color]::Black
		$_.ForeColor = [System.Drawing.Color]::WhiteSmoke
		
		$_.Controls.Add($script:tablePanelMain)

		$_.Name = "formMainWindow"
		$_.ControlBox = $False
		$_.ShowInTaskBar = $False
		$_.Margin = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		
		$Bounce = Get-SettingsWindowBounds -ID $script:BoundsMainWindowID
		
		if ($Bounce.IsSet -eq "1") {
			$xpos = [int]$Bounce.XPos
			$ypos = [int]$Bounce.YPos
			$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
			$_.StartPosition = "Manual"
			
			$width = [int]$Bounce.Width
			$height = [int]$Bounce.Height
			$_.Size = New-Object System.Drawing.Size($Width, $Height)
		} else {
			$_.StartPosition = "CenterScreen"
			$_.ClientSize = New-Object System.Drawing.Size($script:MainFormWidth, $script:MainFormHeight)
		}
		$_.Text = ""
		$_.Font = $Script:FontBase
		$_.Opacity = $script:Opacity_Activated_Main
	}
#endregion CONTROLS
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region EVENTS	
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:formMainWindow.add_Resize({
		Resize-Controls
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:formMainWindow.add_ResizeBegin({
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:formMainWindow.add_ResizeEnd({
		[System.GC]::Collect()
		[System.GC]::WaitForPendingFinalizers()
		Start-Sleep -Milliseconds 100
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:formMainWindow.Add_Shown({
		Resize-Controls
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:formMainWindow.Add_FormClosing({

		Set-SettingsWindowBounds -ID $script:BoundsMainWindowID -FormsBound $script:formMainWindow.Bounds
		Save-Settings
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:formMainWindow.Add_Activated({
		$script:formMainWindow.Opacity = $script:Opacity_Activated_Main
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:formMainWindow.Add_DeActivate({
		$script:formMainWindow.Opacity = $script:Opacity_Deactivate_Main
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:lbTimeDisplay.Add_MouseMove({
		Param ( $c,
				[System.Windows.Forms.MouseEventArgs]$e)

		if ($script:isDrag) {
		
			$EndDragPoint = ([System.Windows.Forms.Label]$c).PointToScreen((New-Object System.Drawing.Point $e.X, $e.Y))

			$NewX = $script:StartDragPoint.X - $EndDragPoint.X
			$NewY = $script:StartDragPoint.Y - $EndDragPoint.Y
		
			$X = $script:formMainWindow.Location.X - $NewX
			$Y = $script:formMainWindow.Location.Y - $NewY
			
			$script:formMainWindow.Location = New-Object System.Drawing.Point($X,$Y)
	
		
			$script:StartDragPoint = $EndDragPoint
		}		
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:lbTimeDisplay.Add_MouseDown({
		Param ( $c,
				[System.Windows.Forms.MouseEventArgs]$e)
		if ($_.Button -eq 'Left') {
			$script:StartDragPoint = ([System.Windows.Forms.Label]$c).PointToScreen((New-Object System.Drawing.Point $e.X, $e.Y))
			$script:isDrag	= $True
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:lbTimeDisplay.Add_MouseUp({
		Param ( $c,
				[System.EventArgs]$e)
		$script:isDrag	= $False
		
		if ($_.Button -eq 'Right') {
			$P = New-Object System.Drawing.Point ($_.X,$_.Y)
			$contextMenu.Show($script:lbTimeDisplay,$P)

		}

	})

#endregion EVENTS
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region CONTEXT MENU EVENTS
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$menuItem_Exit.add_click({
		$script:formMainWindow.Close()
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:menuItem_Timer_1Minutes.add_click({Start-Alarm "CountDown" "00:01:00";})
	$script:menuItem_Timer_2Minutes.add_click({Start-Alarm "CountDown" "00:02:00";})		
	$script:menuItem_Timer_3Minutes.add_click({Start-Alarm "CountDown" "00:03:00";})		
	$script:menuItem_Timer_4Minutes.add_click({Start-Alarm "CountDown" "00:04:00";})		
	$script:menuItem_Timer_5Minutes.add_click({Start-Alarm "CountDown" "00:05:00";})
	$script:menuItem_Timer_6Minutes.add_click({Start-Alarm "CountDown" "00:06:00";})
	$script:menuItem_Timer_7Minutes.add_click({Start-Alarm "CountDown" "00:07:00";})
	$script:menuItem_Timer_8Minutes.add_click({Start-Alarm "CountDown" "00:08:00";})
	$script:menuItem_Timer_9Minutes.add_click({Start-Alarm "CountDown" "00:09:00";})
	$script:menuItem_Timer_10Minutes.add_click({Start-Alarm "CountDown" "00:10:00";})
	$script:menuItem_Timer_15Minutes.add_click({Start-Alarm "CountDown" "00:15:00";})
	$script:menuItem_Timer_20Minutes.add_click({Start-Alarm "CountDown" "00:20:00";})
	$script:menuItem_Timer_25Minutes.add_click({Start-Alarm "CountDown" "00:25:00";})
	$script:menuItem_Timer_30Minutes.add_click({Start-Alarm "CountDown" "00:30:00";})
	$script:menuItem_Timer_35Minutes.add_click({Start-Alarm "CountDown" "00:35:00";})
	$script:menuItem_Timer_40Minutes.add_click({Start-Alarm "CountDown" "00:40:00";})
	$script:menuItem_Timer_45Minutes.add_click({Start-Alarm "CountDown" "00:45:00";})
	$script:menuItem_Timer_50Minutes.add_click({Start-Alarm "CountDown" "00:50:00";})
	$script:menuItem_Timer_55Minutes.add_click({Start-Alarm "CountDown" "00:55:00";})
	$script:menuItem_Timer_60Minutes.add_click({Start-Alarm "CountDown" "01:00:00";})
	$script:menuItem_Timer_75Minutes.add_click({Start-Alarm "CountDown" "01:15:00";})
	$script:menuItem_Timer_90Minutes.add_click({Start-Alarm "CountDown" "01:30:00";})
	$script:menuItem_Timer_105Minutes.add_click({Start-Alarm "CountDown" "01:45:00";})
	$script:menuItem_Timer_120Minutes.add_click({Start-Alarm "CountDown" "02:00:00";})
	$script:menuItem_Timer_135Minutes.add_click({Start-Alarm "CountDown" "02:15:00";})
	$script:menuItem_Timer_150Minutes.add_click({Start-Alarm "CountDown" "02:30:00";})
	$script:menuItem_Timer_165Minutes.add_click({Start-Alarm "CountDown" "02:45:00";})
	$script:menuItem_Timer_180Minutes.add_click({Start-Alarm "CountDown" "03:00:00";})
	$script:menuItem_Timer_Custom.add_click({
		$Alarm = Get-TimeDialog "Timer"
		
		if ($Alarm -ne $Null) {
			Start-Alarm "CountDown" $Alarm
		}		
	})
	$script:menuItem_Alarm.add_click({
	
		$Alarm = Get-TimeDialog "Alarm"
		
		if ($Alarm -ne $Null) {
			Start-Alarm "Alarm" $Alarm
		}
	})
	$script:menuItem_StopWatch.add_click({
	
		Start-Alarm "StopWatch" 

	})
#endregion CONTEXT MENU EVENTS
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region NOTIFY ICON
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$Script:NotifyIcon.ContextMenu = $Script:NIContextMenu
	
	$Script:NotifyIcon.Text = "$script:ScriptName $script:ScriptVersion"

	$Script:NIMenuItemExit.Text = "&Exit"
	
	$Script:NIMenuItemExit.Index = 1
	
	$Script:NotifyIcon.ContextMenu.MenuItems.AddRange(@($Script:NIMenuItemExit)) | out-null
	
	$Script:NotifyIcon.Icon = $script:ScriptIcon
	$Script:NotifyIcon.Visible = $True
	
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$Script:NIMenuItemExit.add_Click({
		$script:formMainWindow.Close()
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	$Script:NotifyIcon.Add_MouseClick({
		#
		# One Click 
		#
		
		$script:formMainWindow.Show()
		$script:formMainWindow.Activate()		
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$Script:NotifyIcon.Add_MouseDoubleClick({
		#
		# Double Click
		#

		$script:formMainWindow.Show()
		$script:formMainWindow.Activate()	
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion NOTIFY ICON	

	if ($script:MainClock_ShowSeconds) {
		$script:lbTimeDisplay.Text = [System.Datetime]::Now.ToLongTimeString()
	} else {
		$script:lbTimeDisplay.Text = [System.Datetime]::Now.ToShortTimeString()
	}
	$script:lbdateDisplay.Text = [System.Datetime]::Now.ToLongDateString()
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	Set-WincontrolDoubleBuffering -Control $script:lbTimeDisplay
	Set-WincontrolDoubleBuffering -Control $script:lbdateDisplay
	
	Start-MainClockTick 


	
	$script:formMainWindow.ShowDialog() | out-null	
	
	$Script:NotifyIcon.Visible = $False
	$Script:NotifyIcon.Dispose()
}
#					
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
Function New-ApplicationLauncherObject {
	[cmdletbinding()]
	Param()
	#
	# Function taken from PSScriptLauncher.ps1 by AAN
	#
	$HData = @{
		Ident						= $(([string][guid]::NewGuid()).ToUpper())
		Name						= "unknown"
		Description					= "Description for unknown"
		# -------------------------------------------------------------------------------------------------------------------------
		Category1					= ""
		Category2					= ""
		Category3					= ""
		# -------------------------------------------------------------------------------------------------------------------------
		ExecutionType				= "psscript"		# psscript, programs
		# -------------------------------------------------------------------------------------------------------------------------
		PsProcessFilename			= 	""
		# -------------------------------------------------------------------------------------------------------------------------
		ArgumentList				=	""
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		UseElevated					= "0"
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		UseCredentials				= "0"
		CredentialUsername			= ""
		
		WorkingDirectory			=	""
		# -------------------------------------------------------------------------------------------------------------------------
		PSLaunchType				= 	"script"		# script, command, encodedcommand
		
		PSScriptFilename			=	""
		PSScriptArguments			=	""
		
		PSCommand					=	""
		PSEncodedCommand			=	""
		
	}
	
	$ApplicationLauncherObject = New-Object PSObject -Property $HData 

	Write-Output $ApplicationLauncherObject
}
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
Function Invoke-ApplicationLauncher {
	[cmdletbinding()]
	Param(
			[PSObject]$ExData
		 )

	#
	# Function taken from PSScriptLauncher.ps1 by AAN
	#
	
	$startArgs = @{
		ErrorAction = 'Stop';
	}		
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$ArgumentList = ""
	# #####################################################################################
	if (($exData.ExecutionType -ieq "psscript") -or ($exData.ExecutionType -ieq "programs")){
		$startArgs.Add('FilePath',$exData.PsProcessFilename)
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		if ($exData.WorkingDirectory -ne "") {
			$startArgs.Add('WorkingDirectory',(''+$exData.WorkingDirectory+''))
		}
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		if ($exData.ArgumentList -ne "") {
			$ArgumentList = $exData.ArgumentList
		}
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		if ($exData.UseElevated -eq "1") {
			$startArgs.Add('Verb',"RunAs")
		}
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		
		if 		 ($exData.PSLaunchType -ieq "script") {
			if (($ExData.PSScriptFilename -ne "") -and (Test-Path $ExData.PSScriptFilename)) {
				$argumentList = $ArgumentList + " -File " + ('"'+$ExData.PSScriptFilename+'"') +  $ExData.PSScriptArguments
			}
		} elseif ($exData.PSLaunchType -ieq "command") {
			if ($ExData.PSCommand -ne "") {
				$argumentList = $ArgumentList + ' -Command "& {' + $ExData.PSCommand + "}" + '"' 
			}
		} elseif ($exData.PSLaunchType -ieq "encodedcommand") {
			# ToDo
		}
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		if ($ArgumentList -ne "") {
			$startArgs.Add('ArgumentList',(''+$ArgumentList+''))
		}
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		
		try {
			if ($exData.UseCredentials  -eq "1") {
				$Cred = Get-Credential $exData.CredentialUsername
				Start-Job {Param($startArgs);Start-Process @startArgs} -ArgumentList $startArgs	-Credential $Cred	
			} else {
				Start-Process @startArgs
	
			}
		} catch {
			$_ | out-host
			$SB = new-Object text.stringbuilder
			$SB = $SB.AppendLine($script:ScriptName)
			$SB = $SB.AppendLine("`nCannot process this Item.`n")
			$SB = $SB.AppendLine("Please check the Parameter, validate path, arguments...")
			$SB = $SB.AppendLine("Check Powershell-Script and Command.")
			$SB = $SB.AppendLine("`n... and try again!`n")
			
			$d = [Windows.Forms.MessageBox]::Show($SB.toString(), "Invoke-ApplicationLauncher", 
			[Windows.Forms.MessageBoxButtons]::Ok, [Windows.Forms.MessageBoxIcon]::Information,
			[System.Windows.Forms.MessageBoxDefaultButton]::Button1)			
		}
	} 
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Start-Alarm {
	[cmdletbinding()]
	Param(
			[string]$Mode,
			[string]$TimeString
		 )
	$ALO = New-ApplicationLauncherObject
	
	$Executable = (Get-Command 'PowerShell.exe' | Select-Object -ExpandProperty Definition)
	$ScriptName = ".\PSTimer.ps1"
	$ALO = New-ApplicationLauncherObject
	
	$ALO.ExecutionType		= "psscript"
	$ALO.PsProcessFilename	= $Executable
	$ALo.WorkingDirectory	= $script:WorkingDirectory
	$ALO.ArgumentList		= '-WindowStyle Hidden'
	#$ALO.ArgumentList		= '-NoExit'
	$ALO.PSLaunchType 		= "command"
	$ALO.PSCommand			= ('Set-Location '+$script:WorkingDirectory+";"+$ScriptName+" -TimerMode '"+$Mode+"' -AlarmTime "+"'"+$TimeString)+"'"
	$ALO.UseCredentials		= "0"
	$ALO.UseElevated		= "0"
	Invoke-ApplicationLauncher $ALO	
}
#
# ---------------------------------------------------------------------------------------------------------------------------------
#
Function Get-TimeDialog {
[CmdletBinding()]
Param	(
			[string]$Mode
		)
#region CONTROLS
	$DialogWidth	= 300
	$DialogHeight	= 200
	$xPos = 3
	$yPos = 3
	$dist = 3
	$labelWidth = $DialogWidth - (2*$dist)
	$labelHeight = 100

	$comboBoxWidth	= 60
	$comboBoxHeight = 24
	
	$formDialog			= New-Object System.Windows.Forms.Form	
		$lblText  			= New-Object System.Windows.Forms.Label
		$comboHour	 		= New-Object System.Windows.Forms.ComboBox
		$comboMinute 		= New-Object System.Windows.Forms.ComboBox
		$comboSecond 		= New-Object System.Windows.Forms.ComboBox
		$checkTomorrow		= New-Object System.Windows.Forms.Checkbox
		$buttonOK 			= New-Object System.Windows.Forms.Button
		
	$LabelText = "Alarm`r`nBitte einen gültigen Zeitwert einstellen, der definitiv in der Zukunft liegt. Sollte er in den morgigen Tag laufen, bitte die CheckBox anklicken.`r`nTimer`r`nDer Zeitwert darf den heutigen Tag überschreiten."		
	
	$lblText | % {
		$_.AutoSize = $False
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($labelWidth, $labelHeight)
		$_.TextAlign = [System.Drawing.ContentAlignment]::TopLeft
		$_.BackColor = [System.Drawing.Color]::Yellow
		$_.TabStop = $false
		$_.Text = $LabelText
	}	
	$yPos += $labelHeight + $dist
	$comboHour  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($comboBoxWidth, $comboBoxHeight)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.DropDownHeight = 400
		$_.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
		$_.FormattingEnabled = $True		
		$_.TabStop = $false	
	}
	$xPos += $ComboboxWidth + $Dist
	$comboMinute  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($comboBoxWidth, $comboBoxHeight)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.DropDownHeight = 400
		$_.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
		$_.FormattingEnabled = $True		
		$_.TabStop = $false	
	}
	$xPos += $ComboboxWidth + $Dist
	$comboSecond  | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size($comboBoxWidth, $comboBoxHeight)
		#$_.BackColor = [System.Drawing.Color]::Transparent
		$_.DropDownHeight = 400
		$_.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
		$_.FormattingEnabled = $True		
		$_.TabStop = $false	
	}	
	$xPos = $Dist
	$yPos += ($Dist + $comboBoxHeight)
	$checkTomorrow | % {
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Size = New-Object System.Drawing.Size(150, 22)
		$_.TabStop = $true
		$_.Text = "Tomorrow"
	}
	$xPos = $DialogWidth - $Dist - 40
	$yPos += ($Dist + 22)
	$buttonOk | % {
		$_.BackColor = [System.Drawing.SystemColors]::Control
		$_.Location = New-Object System.Drawing.Point($xPos, $yPos)
		$_.Name = "OkButton"
		$_.Size = New-Object System.Drawing.Size(40, 24)
		$_.Text = "Ok"
		$_.UseVisualStyleBackColor = $True		
		$_.TabStop = $true
	}
	$DialogHeight = $YPos + $Dist + 24
	$formDialog | % {
		#$_.AutoSize = $true
		
		$_.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
		
		$_.Controls.Add($lblText)
		$_.Controls.Add($comboHour)
		$_.Controls.Add($comboMinute)
		$_.Controls.Add($comboSecond)
		$_.Controls.Add($checkTomorrow)
		$_.Controls.Add($buttonOK)
		
		$_.Name = "formDialog"
		$_.ControlBox = $True
		$_.MinimizeBox = $False
		$_.MaximizeBox = $False
		$_.ShowInTaskBar = $True
		$_.Margin = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		
		$_.StartPosition = "CenterParent"
		$_.ClientSize = New-Object System.Drawing.Size($DialogWidth, $DialogHeight)

		$_.Text = "$($script:ScriptName) - Get Time"
		$_.Font = $Script:FontBase

	}	
#endregion CONTROLS	
#region EVENTS
	$buttonOk.Add_Click({
		$formDialog.DialogResult = [System.Windows.Forms.DialogResult]::Ok
		$formDialog.Close()
	})
#endregion EVENTS
#region FILLDATA
	$comboHour.Items.Clear()
	$comboHour.Items.AddRange(@("0".."23"))
	$comboHour.Text = "12"
	
	$ComboMinute.Items.Clear()
	$ComboMinute.Items.AddRange(@("0".."60"))
	$ComboMinute.Text = "30"
	
	$comboSecond.Items.Clear()
	$comboSecond.Items.AddRange(@("0".."60"))
	$comboSecond.Text = "0"	
#endregion FILLDATA	
	$response = $formDialog.ShowDialog()
	
	if ($Response -eq [System.Windows.Forms.DialogResult]::Ok) {
		$Days = 0
		
		if ($checkTomorrow.Checked) {$Days = 1}
		$Hours 		= [int]$comboHour.Text
		$Minutes 	= [int]$comboMinute.Text
		$Seconds 	= [int]$comboSecond.Text
		
		$TS = New-Object system.Timespan -ArgumentList $Hours,$Minutes,$Seconds
		$TSStr = $ts.tostring("hh\:mm\:ss")
		
		$D = (Get-Date $TSStr).AddDays($Days)
		
		if ($Mode -eq "Alarm") {
			$OutStr = $d.ToString("dd.MM.yyyy HH:mm:ss")
		} elseif ($Mode -eq "Timer") {
			$OutStr = $d.ToString("HH:mm:ss")
		} else {
			return $Null
		}
		return $OutStr
	} else {
		return $Null
	}
	
}
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region MAIN
# #############################################################################
# ##### MAIN
# #############################################################################
Load-Settings
Load-AllScriptSettingValues

New-MainWindow

Stop-MainClockTick
$script:tmrTickMain = $null

# #############################################################################
# ##### END MAIN
# #############################################################################
#endregion MAIN