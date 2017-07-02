#################################################################################################
# Name			: 	PSTimer.ps1
# Description	: 	Main
# Author		: 	Axel Anderson
# License		:	
# History		: 	17.04.2017 	AAn		Created		Display Functions from PSClock
#					23.04.2017	AAn		0.1.9.0		Alarm added
# 					30.04.2017	AAn		0.2.0.0		Show Date, when Alarm in the future
#					01.05.2017	AAn		0.2.1.0		RestartFromSuspend : Recalc-Timer
#					07.05.2017	AAn		0.2.2.0		Calculate-FontFromText ==> Font.Dispose()
#					11.05.2017	AAn		0.2.3.0		TimerUp,TimerDown shows EndDate, if Timer ends on future days
#					17.05.2017	AAn		0.2.4.0		RestartFromSuspend : Recalc-Timer only when not AlarmReached
#					17.05.2017	AAn		0.2.5.0		Added Mode 'StopWatch"
#													Change behavior of AutoStart :
#														- On CountUp, CountDown and Alarm	: Default TRUE
#														- On StopWatch						: Default FALSE
#														otherwise Value of Parameter 'AutoStart'
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#Requires –Version 3
[CmdletBinding(DefaultParameterSetName='ALL')]
Param   (
			[Parameter(Mandatory=$True,Position=0)][ValidateSet("CountUp","CountDown","Alarm","StopWatch")]
			[string]$TimerMode,
			[Parameter(Position=1)]
			[string]$AlarmTime = "0.00:00:01",
			[string]$Message = "",
			[switch]$AutoStart
		)
Set-StrictMode -Version Latest	
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#
#region ScriptVariables
#
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[System.Windows.Forms.Application]::EnableVisualStyles()
Add-Type –assemblyName WindowsBase -IgnoreWarnings	
Add-Type -AssemblyName System.Speech -IgnoreWarnings

$script:ScriptName		= "PSTimer"
$script:ScriptDesc		= "Powershell Timer with Timer/CountDown/Alarm"
$script:ScriptDate		= "17. Mai 2017"
$script:ScriptAuthor	= "Axel Anderson"					
$script:ScriptVersion	= "0.2.5.0"
$script:ConfigVersion	= "1"
#
#Script Information
$script:WorkingFileName = $MyInvocation.MyCommand.Definition
$script:WorkingDirectory = Split-Path $script:WorkingFileName -Parent

$script:SoundPlayer = New-Object System.Media.SoundPlayer
$script:SoundPlayer.SoundLocation = Join-Path (Join-Path $script:WorkingDirectory "Sounds") "Alarm.wav"

$script:CurrentTimeMode 	= $TimerMode
$script:CurrentAlarmTime 	= $AlarmTime
$script:CurrentAlarmMessage = $Message
$script:CurrentAutostart 	= $AutoStart

[int64]$script:AlarmSeconds = 0
[int64]$script:CurrentAlarmSeconds = 0
$script:AlarmReached = $False

$script:BrokenTimer = $False

$script:futureDays = 0
#
# NOTE : we can only use Global-Variables in PowerEvent Action-Callback
#
$Global:SuspendTime = [datetime]::Now
$Global:ResumeTime = [datetime]::Now
$Global:RestartFromSuspend = $False
	
#region WINFORMS CONTROLS	
$script:formMainWindow			= New-Object System.Windows.Forms.Form	
	$script:tablePanelMain 		= New-Object System.Windows.Forms.TableLayoutPanel	
		$script:lbTimeDisplay 	= New-Object System.Windows.Forms.Label
		$script:lbNoticeDisplay 	= New-Object System.Windows.Forms.Label
		$script:tablePanelButton	= New-Object System.Windows.Forms.TableLayoutPanel	
			$buttonStart 		= New-Object System.Windows.Forms.Button
			$buttonStop 		= New-Object System.Windows.Forms.Button
			$buttonSet	 		= New-Object System.Windows.Forms.Button

			$Script:FontBase = New-Object System.Drawing.Font("Segoe UI",9, [System.Drawing.FontStyle]::Regular)
$script:FontMainTime = New-Object System.Drawing.Font("Segoe UI",52, [System.Drawing.FontStyle]::Bold)
$script:FontMainDate = New-Object System.Drawing.Font("Segoe UI",16, [System.Drawing.FontStyle]::Bold)

$script:MainFormWidth	= 390
$script:MainFormHeight	= 170
#endregion WINFORMS CONTROLS
	
#region  CLOCK Tick (Main)

$script:MainClock_ShowSeconds = $True

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

#endregion ScriptVariables
#					
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#					
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
Function Set-WincontrolDoubleBuffering {
[CmdletBinding()]
Param	(
			$Control,
			[switch]$value = $True
		)
		
	$prop = $Control.GetType().getProperty("DoubleBuffered",[System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Instance)
	$prop.SetValue($Control,$True,$Null)
	
}
#					
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
Function Show-MessageBox {
	param ($title,$text,$buttons="OK",$icon="None")
	 
	$FormsAssembly = [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
	 
	$dialogButtons = @{
	 "OK"=[Windows.Forms.MessageBoxButtons]::OK;
	 "OKCancel"=[Windows.Forms.MessageBoxButtons]::OKCancel;
	 "AbortRetryIgnore"=[Windows.Forms.MessageBoxButtons]::AbortRetryIgnore;
	 "YesNoCancel"=[Windows.Forms.MessageBoxButtons]::YesNoCancel;
	 "YesNo"=[Windows.Forms.MessageBoxButtons]::YesNo;
	 "RetryCancel"=[Windows.Forms.MessageBoxButtons]::RetryCancel }
	 
	$dialogIcons = @{
	 "None"=[Windows.Forms.MessageBoxIcon]::None
	 "Hand"=[Windows.Forms.MessageBoxIcon]::Hand
	 "Question"=[Windows.Forms.MessageBoxIcon]::Question
	 "Exclamation"=[Windows.Forms.MessageBoxIcon]::Exclamation
	 "Asterisk"=[Windows.Forms.MessageBoxIcon]::Asterisk
	 "Stop"=[Windows.Forms.MessageBoxIcon]::Stop
	 "Error"=[Windows.Forms.MessageBoxIcon]::Error
	 "Warning"=[Windows.Forms.MessageBoxIcon]::Warning
	 "Information"=[Windows.Forms.MessageBoxIcon]::Information
	}
	 
	$dialogResponses = @{
	 [System.Windows.Forms.DialogResult]::None="None";
	 [System.Windows.Forms.DialogResult]::OK="Ok";
	 [System.Windows.Forms.DialogResult]::Cancel="Cancel";
	 [System.Windows.Forms.DialogResult]::Abort="Abort";
	 [System.Windows.Forms.DialogResult]::Retry="Retry";
	 [System.Windows.Forms.DialogResult]::Ignore="Ignore";
	 [System.Windows.Forms.DialogResult]::Yes="Yes";
	 [System.Windows.Forms.DialogResult]::No="No"
	}
	 
	return $dialogResponses[[Windows.Forms.MessageBox]::Show($text,$title,$dialogButtons[$buttons],$dialogIcons[$icon])]
}
#					
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
Function Recalc-Timer {
[CmdletBinding()]
Param	(
		)

	if ($script:CurrentTimeMode -eq "Alarm") {
		try {
			$span = (Get-date -Date $script:AlarmTime) - ((Get-date).AddSeconds(-1))
		} catch {
			$span = New-Object System.Timespan -ArgumentList 0,0,1
		}
		$script:AlarmSeconds = $span.TotalSeconds
		
		if ($script:AlarmSeconds -le 0) {
			$script:AlarmSeconds = 1
			$script:BrokenTimer = $True
		}
		$script:CurrentAlarmSeconds = $script:AlarmSeconds
				
	} elseif ($script:CurrentTimeMode -eq "CountDown") {
		$TimeSuspended = $Global:ResumeTime - $Global:SuspendTime
		$SecondsSuspended = $TimeSuspended.TotalSeconds
		
		$script:CurrentAlarmSeconds -= $SecondsSuspended
		
		if ($script:CurrentAlarmSeconds -le 0) {
			$script:CurrentAlarmSeconds = 1
			$script:BrokenTimer = $True
		}
		
	} elseif ($script:CurrentTimeMode -eq "CountUp") {
		$TimeSuspended = $Global:ResumeTime - $Global:SuspendTime
		$SecondsSuspended = $TimeSuspended.TotalSeconds
		
		$script:CurrentAlarmSeconds += $SecondsSuspended
		
		if ($script:CurrentAlarmSeconds -gt $script:AlarmSeconds) {
			$script:CurrentAlarmSeconds = 1
			$script:BrokenTimer = $True
		}
	}
}
#					
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
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
	# NOTHING to do here
	#
	
	#
	# Check every Second 
	#
	if ($Script:MainTimer.Time.Seconds -ne $Script:MainTimer.CurrentTime.Seconds) {
		#
		if ($script:BrokenTimer) {
			[console]::beep(2000,500)

			if ($script:lbTimeDisplay.ForeColor.Name -eq "WhiteSmoke") {
				$script:lbTimeDisplay.ForeColor = [System.Drawing.Color]::OrangeRed
			} else {
				$script:lbTimeDisplay.ForeColor = [System.Drawing.Color]::WhiteSmoke
			}	
			$buttonSet.Enabled = $False
			$buttonStart.Enabled = $False
			$buttonStop.Enabled = $False	

			$script:lbNoticeDisplay.Text =	"Sorry, Timer broken... !!!"
			
			Set-WindowTopMost
			
		} elseif ($Global:RestartFromSuspend) {
			if (!$script:AlarmReached) {
				Recalc-Timer
			}
			$Global:RestartFromSuspend = $False
			
		} elseif ($script:AlarmReached) {
			if ($script:lbTimeDisplay.ForeColor.Name -eq "WhiteSmoke") {
				$script:lbTimeDisplay.ForeColor = [System.Drawing.Color]::Red
			} else {
				$script:lbTimeDisplay.ForeColor = [System.Drawing.Color]::WhiteSmoke
			}
			
		} elseif ($script:CurrentTimeMode -eq "CountUp") {

			[TimeSpan]$spanOld = [Timespan]::FromSeconds($script:CurrentAlarmSeconds)
			[TimeSpan]$span = [Timespan]::FromSeconds(++$script:CurrentAlarmSeconds)
			$script:lbTimeDisplay.Text = Get-TimeDisplayText -Seconds $script:CurrentAlarmSeconds

			if ($script:CurrentAlarmSeconds -ge $script:AlarmSeconds) {
				$script:AlarmReached = $True
				Start-Sound -Looping
				$buttonSet.Enabled = $False
				$buttonStart.Enabled = $False
				$buttonStop.Enabled = $True		
				Set-WindowTopMost
			}
			if ($spanOld.Days -ne $span.days) {
				Resize-Controls
			}

		} elseif ($script:CurrentTimeMode -eq "CountDown") {

			[TimeSpan]$spanOld = [Timespan]::FromSeconds($script:CurrentAlarmSeconds)
			[TimeSpan]$span = [Timespan]::FromSeconds(--$script:CurrentAlarmSeconds)
			
			$script:lbTimeDisplay.Text = Get-TimeDisplayText -Seconds $script:CurrentAlarmSeconds

			if ($script:CurrentAlarmSeconds -le 0) {
				$script:AlarmReached = $True
				Start-Sound -Looping
				$buttonSet.Enabled = $False
				$buttonStart.Enabled = $False
				$buttonStop.Enabled = $True		
				Set-WindowTopMost
			}
			if ($spanOld.Days -ne $span.days) {
				Resize-Controls
			}	
			
		} elseif ($script:CurrentTimeMode -eq "Alarm") {
			
			[TimeSpan]$spanOld = [Timespan]::FromSeconds($script:CurrentAlarmSeconds)
			[TimeSpan]$span = [Timespan]::FromSeconds(--$script:CurrentAlarmSeconds)
			$script:lbTimeDisplay.Text = Get-TimeDisplayText -Seconds $script:CurrentAlarmSeconds

			if ($script:CurrentAlarmSeconds -le 0) {
				$script:AlarmReached = $True
				Start-Sound -Looping
				$buttonSet.Enabled = $False
				$buttonStart.Enabled = $False
				$buttonStop.Enabled = $True	
				Set-WindowTopMost
			}
			if ($spanOld.Days -ne $span.days) {
				Resize-Controls
			}
		} elseif ($script:CurrentTimeMode -eq "StopWatch") {

			[TimeSpan]$spanOld = [Timespan]::FromSeconds($script:CurrentAlarmSeconds)
			[TimeSpan]$span = [Timespan]::FromSeconds(++$script:CurrentAlarmSeconds)
			$script:lbTimeDisplay.Text = Get-TimeDisplayText -Seconds $script:CurrentAlarmSeconds

			if ($script:CurrentAlarmSeconds -ge $script:AlarmSeconds) {
				$script:AlarmReached = $True
				Start-Sound -Looping
				$buttonSet.Enabled = $False
				$buttonStart.Enabled = $False
				$buttonStop.Enabled = $True		
				Set-WindowTopMost
			}
			if ($spanOld.Days -ne $span.days) {
				Resize-Controls
			}		
		}
	}
	#
	# Check if Date has changed
	#
	if ($Script:MainTimer.Date -ne $Script:MainTimer.CurrentNow.Date) {
		 
	}
	#
	# Check every Minute 
	#
	if ($Script:MainTimer.Time.Minutes -ne $Script:MainTimer.CurrentTime.Minutes) {
		#
	}	
	#
	# Check every Hour 
	#
	if ($Script:MainTimer.Time.Hours -ne $Script:MainTimer.CurrentTime.Hours) {
		#
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
#					
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
Function Start-Sound {
[CmdletBinding()]
Param	(
			[switch]$Looping
		)
	if ($Looping) {
		$script:SoundPlayer.PlayLooping()
	} else {
		$script:SoundPlayer.Play()
	}
	#

}
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
Function Stop-Sound {
[CmdletBinding()]
Param	(
		)
	$script:SoundPlayer.Stop()
}
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
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
	$script:FontMainDate = Adjust-ControlFont -Control $script:lbNoticeDisplay -ControlFont $script:FontMainDate -Offset 20
	$script:lbNoticeDisplay.Font = $script:FontMainDate
	# ----------------------------------------------------------------------------------------------------

}
#					
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
Function Build-TimerText {
[CmdletBinding()]
Param	(
		)
	[TimeSpan]$span = [Timespan]::FromSeconds($script:AlarmSeconds)
	[string]$Text = ""
	
	if ($span.Days -eq 1) {
		$Text += "1 Day"
	} elseif ($span.days -gt 1) {
		$Text += "$($span.Days) Days"
	}
	if ($span.Hours -eq 1) {
		if ($Text.length -gt 0) {$Text += ", "}
		$Text += "1 Hour"
	} elseif ($span.Hours -gt 1) {
		if ($Text.length -gt 0) {$Text += ", "}
		$Text += "$($span.Hours) Hours"
	}	
	if ($span.Minutes -eq 1) {
		if ($Text.length -gt 0) {$Text += ", "}
		$Text += "1 Minute"
	} elseif ($span.Minutes -gt 1) {
		if ($Text.length -gt 0) {$Text += ", "}
		$Text += "$($span.Minutes) Minutes"
	}
	if ($span.Seconds -eq 1) {
		if ($Text.length -gt 0) {$Text += ", "}
		$Text += "1 Second"
	} elseif ($span.Seconds -gt 1) {
		if ($Text.length -gt 0) {$Text += ", "}
		$Text += "$($span.Seconds) Seconds"
	}

	$Text = "Alarm set to " + $Text
	Write-Output $Text
}
#					
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
Function Get-FinishedTimeText {
[CmdletBinding()]
Param	(
		)
	[TimeSpan]$span = [Timespan]::FromSeconds($script:AlarmSeconds)

	if ($script:futureDays -gt 0) {
		$TimeStr = ((get-date)+$span).ToString("HH.mm.ss") + " ("+$script:Enddate.ToShortDateString()+")"
	} else {
		if ($script:CurrentTimeMode -eq "StopWatch") {
			$TimeStr = ""
		} else {
			$TimeStr = ((get-date)+$span).ToString("HH.mm.ss")
		}
	}
	Write-Output $Timestr	
}
#					
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
Function Get-TimeDisplayText {
[CmdletBinding()]
Param	(
			[int64]$Seconds
		)
	[TimeSpan]$span = [Timespan]::FromSeconds($Seconds)
	if ($span.Days -gt 0) {
		$Text = "{0:N0}.{1}:{2}:{3}" -f $span.Days,(([string]$span.Hours).PadLeft(2,'0')),(([string]$span.Minutes).PadLeft(2,'0')),(([string]$span.Seconds).PadLeft(2,'0'))
	} else {
		$Text = "{0}:{1}:{2}" -f (([string]$span.Hours).PadLeft(2,'0')),(([string]$span.Minutes).PadLeft(2,'0')),(([string]$span.Seconds).PadLeft(2,'0'))
	}
	Write-Output $Text
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
	$buttonWidth = 80
	$buttonHeight = 22
	
	$buttonStart| % {
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.BackColor = [System.Drawing.Color]::LightGray
		$_.ForeColor = [System.Drawing.Color]::Blue
		$_.Name = "buttonClose"
		$_.Text = "Start"
		$_.UseVisualStyleBackColor = $True		
		$_.TabStop = $false		
	}
	# -----------------------------------------------------------------------------------------------------------------------------
	$buttonStop| % {
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.BackColor = [System.Drawing.Color]::LightGray
		$_.ForeColor = [System.Drawing.Color]::Blue
		$_.Name = "buttonStop"
		$_.Text = "Stop"
		$_.UseVisualStyleBackColor = $True		
		$_.TabStop = $false		
	}
	# -----------------------------------------------------------------------------------------------------------------------------
	$buttonSet| % {
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.BackColor = [System.Drawing.Color]::LightGray
		$_.ForeColor = [System.Drawing.Color]::Blue
		$_.Name = "buttonSet"
		$_.Text = "Reset"
		$_.UseVisualStyleBackColor = $True		
		$_.TabStop = $false		
	}
	# -----------------------------------------------------------------------------------------------------------------------------
	$script:tablePanelButton  | % {
		$_.Autosize = $True
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.Margin = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Name = "tablePanelButton"

		$_.ColumnCount = 3
		$_.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100))) | Out-Null
		$_.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100))) | Out-Null
		$_.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100))) | Out-Null
		$_.RowCount = 1;
		$_.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize, 0))) | Out-Null
		$_.Controls.Add($buttonStart, 0,0)
		$_.Controls.Add($buttonStop, 1,0)
		$_.Controls.Add($buttonSet, 2,0)
		$_.TabStop = $false
	}
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	$script:lbTimeDisplay | % {
		$_.Font = $script:FontMainTime
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)		
		$_.Name = "lbTimeDisplay"
		$_.TabStop = $false
		$_.Text = "00:00:00"
	}
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:lbNoticeDisplay | % {
		$_.Font = $script:FontMainDate
		$_.Location = New-Object System.Drawing.Point(0,0)
		$_.Dock = [System.Windows.Forms.DockStyle]::Fill
		$_.TextAlign = [System.Drawing.ContentAlignment]::TopCenter
		$_.BackColor = [System.Drawing.Color]::Transparent
		$_.Margin = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)		
		$_.Name = "lbNoticeDisplay"
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
		$_.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::AutoSize, 0))) | Out-Null
		$_.RowCount = 3;
		$_.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 80))) | Out-Null
		$_.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 20))) | Out-Null
		$_.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize, 0))) | Out-Null
		$_.Controls.Add($script:lbTimeDisplay, 0,0)
		$_.Controls.Add($script:lbNoticeDisplay, 1,0)
		$_.Controls.Add($script:tablePanelButton, 2, 0)
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
		$_.ControlBox = $True
		$_.MinimizeBox = $False
		$_.ShowInTaskBar = $False
		$_.Margin = New-Object System.Windows.Forms.Padding (0,0,0,0)
		$_.Padding = New-Object System.Windows.Forms.Padding (0,0,0,0)
		
		$_.StartPosition = "CenterScreen"
		$_.ClientSize = New-Object System.Drawing.Size($script:MainFormWidth, $script:MainFormHeight)

		$_.Text = "$($script:ScriptName) - "+$script:CurrentTimeMode
		
		$_.Font = $Script:FontBase
		$_.Opacity = 1.0
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
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:formMainWindow.Add_Activated({
		$script:formMainWindow.Opacity = 1.0
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$script:formMainWindow.Add_DeActivate({
		$script:formMainWindow.Opacity = 0.6
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonStart.Add_Click({
		Start-MainClockTick	
		$buttonSet.Enabled = $False
		$buttonStart.Enabled = $False
		$buttonStop.Enabled = $True
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonStop.Add_Click({
		Stop-Sound
		
		if (!$script:AlarmReached) {
			Stop-MainClockTick
			$buttonStop.Enabled = $false
			if ($script:CurrentTimeMode -ne "Alarm" ) {
				$buttonSet.Enabled = $true
				$buttonStart.Enabled = $true			
			}
		} else {
			if ($script:CurrentTimeMode -eq "Alarm" ) {
				$buttonStop.Enabled = $false
			}
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	$buttonSet.Add_Click({
		if ($script:CurrentTimeMode -eq "CountUp") {
			$script:CurrentAlarmSeconds = 0
			$script:lbTimeDisplay.Text = "00:00:00"
			$buttonStart.Enabled = $True
			
		} elseif ($script:CurrentTimeMode -eq "CountDown") {
			$script:CurrentAlarmSeconds = $script:AlarmSeconds	
			$script:lbTimeDisplay.Text = Get-TimeDisplayText -Seconds $script:CurrentAlarmSeconds
			$buttonStart.Enabled = $True
			
		} elseif ($script:CurrentTimeMode -eq "StopWatch") {
			$script:CurrentAlarmSeconds = 0
			$script:lbTimeDisplay.Text = "00:00:00"
			$buttonStart.Enabled = $True		
		}
	})
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#endregion EVENTS
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region NOTIFY ICON
#endregion NOTIFY ICON	

	$script:lbNoticeDisplay.Text = Build-TimerText
	# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	if ($script:CurrentTimeMode -eq "CountUp") {
		$script:lbTimeDisplay.Text = "00:00:00"
		
		$script:formMainWindow.Text += " - $(Get-FinishedTimeText)"
		
	} elseif ($script:CurrentTimeMode -eq "CountDown") {
		$script:lbTimeDisplay.Text = Get-TimeDisplayText -Seconds $script:CurrentAlarmSeconds
		
		$script:formMainWindow.Text += " - $(Get-FinishedTimeText)"
		
	} elseif ($script:CurrentTimeMode -eq "Alarm") {
		$script:lbTimeDisplay.Text = Get-TimeDisplayText -Seconds $script:CurrentAlarmSeconds
		$script:lbNoticeDisplay.Text = " At $(Get-FinishedTimeText)"	
		
		$script:formMainWindow.Text += " - $(Get-FinishedTimeText)"
		
	} elseif ($script:CurrentTimeMode -eq "StopWatch") {
		$script:lbTimeDisplay.Text = Get-TimeDisplayText -Seconds $script:CurrentAlarmSeconds
		$script:lbNoticeDisplay.Text = " . . . "	
		
	}
	
		
	if ($script:CurrentAutostart) {
		Start-MainClockTick
		$buttonStart.Enabled = $False
		$buttonSet.Enabled = $False
		if ($script:CurrentTimeMode -eq "Alarm") {
			$buttonStop.Enabled = $False
		} else {
			$buttonStop.Enabled = $True
		}
		
	} else {
		$buttonStop.Enabled = $False	
	}
	Set-WincontrolDoubleBuffering -Control $script:lbTimeDisplay
	
	
	$script:formMainWindow.ShowDialog() | out-null	
	
}
#					
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
Function Set-WindowTopMost {
[CmdletBinding()]
Param	(
		)
	$script:formMainWindow.TopMost = $True
	$script:formMainWindow.Show()
	$script:formMainWindow.Activate()

}
#					
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
Function Get-Laptop {
[CmdletBinding()]
Param	(
		)
	$isLaptop = $false
	try {
		if(Get-WmiObject -Class win32_systemenclosure | Where-Object { $_.chassistypes -eq 9 -or $_.chassistypes -eq 10 -or $_.chassistypes -eq 14}) { 
			$isLaptop = $true
		}
	} catch {}
	try {
		if(Get-WmiObject -Class win32_battery) { 
			$isLaptop = $true
		}
	} catch {}
	Write-Output $isLaptop
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region MAIN
# #############################################################################
# ##### MAIN
# #############################################################################

if ($script:CurrentTimeMode -eq "CountUp") {
	try {
		$span = [Timespan]::Parse($AlarmTime)
		$script:AlarmSeconds = $span.TotalSeconds
		
		$script:Startdate = (Get-date).date
		$script:Enddate   = ($script:StartDate).AddSeconds($span.TotalSeconds)
		$script:futureDays = ($script:EndDate - $script:StartDate).days
		
	} catch {
		Show-MessageBox $script:ScriptName "ALARM TIME MISMATCH $($_)" "OK" "Error"
		return 1
	}
	$script:CurrentAlarmSeconds = 0
	
	if ($PSBoundParameters.ContainsKey("AutoStart")) {
		$script:CurrentAutostart 	= $AutoStart
	} else {
		$script:CurrentAutostart 	= $True
	}
	
} elseif ($script:CurrentTimeMode -eq "CountDown") {
	try {
		$span = [Timespan]::Parse($AlarmTime)
		$script:AlarmSeconds = $span.TotalSeconds

		$script:Startdate = (Get-date).date
		$script:Enddate   = ($script:StartDate).AddSeconds($span.TotalSeconds)
		$script:futureDays = ($script:EndDate - $script:StartDate).days
		
	} catch {
		Show-MessageBox $script:ScriptName "ALARM TIME MISMATCH $($_)" "OK" "Error"
		return 1
	}
	$script:CurrentAlarmSeconds = $script:AlarmSeconds

	if ($PSBoundParameters.ContainsKey("AutoStart")) {
		$script:CurrentAutostart 	= $AutoStart
	} else {
		$script:CurrentAutostart 	= $True
	}
	
} elseif ($script:CurrentTimeMode -eq "Alarm") {
	try {
		if ((Get-date -Date $AlarmTime) -le ((Get-date).AddSeconds(0))) {
			Show-MessageBox $script:ScriptName "ALARM : $($AlarmTime) must be in the future !!!!" "OK" "Error"
			return 1
		}
		$span = (Get-date -Date $AlarmTime) - ((Get-date).AddSeconds(0))
		
		$script:Startdate = (Get-date).date
		$script:Enddate   = (Get-date -Date $AlarmTime).date
		
		$script:futureDays = ($script:EndDate - $script:StartDate).days

	} catch {
		Show-MessageBox $script:ScriptName "ALARM TIME MISMATCH $($_)" "OK" "Error"
		return 1	
	}
	$script:AlarmSeconds = $span.TotalSeconds
	$script:CurrentAlarmSeconds = $script:AlarmSeconds

	if ($PSBoundParameters.ContainsKey("AutoStart")) {

		$script:CurrentAutostart 	= $AutoStart
	} else {
		$script:CurrentAutostart 	= $True
	}
	
} elseif ($script:CurrentTimeMode -eq "StopWatch") {

	$totalSeconds = [int64](([timespan]::MaxValue).TotalSeconds)

	$script:AlarmSeconds = $TotalSeconds - 1
	$script:CurrentAlarmSeconds = 0
	
	$script:Startdate = (Get-date).date
	$script:Enddate   = $script:StartDate
	$script:futureDays = 0
	
	if ($PSBoundParameters.ContainsKey("AutoStart")) {
		$script:CurrentAutostart 	= $AutoStart
	} else {
		$script:CurrentAutostart 	= $False
	}
	
} else {
	return 100
}

#region POWER MANAGEMENT

if (Get-Laptop) {
	$WMIEventQuery = "Select * From Win32_PowerManagementEvent where EventType=4"
	$JobSuspend = Register-WmiEvent `
			-Query $WMIEventQuery  `
			-SourceIdentifier "PowerSuspend" `
			-Action {
						$Global:SuspendTime = [datetime]::Now
						"########## Entering Suspend ($([datetime]::Now)) ##########" | out-host;
					}
	$WMIEventQuery = "Select * From Win32_PowerManagementEvent where EventType=7"
	$JobResume = Register-WmiEvent `
			-Query $WMIEventQuery  `
			-SourceIdentifier "PowerResume" `
			-Action {
						$Global:ResumeTime = [datetime]::Now
						"########## Resume from Suspend ($([datetime]::Now)) ##########" | out-host;
						$Global:RestartFromSuspend = $True
					}
}					
#endregion POWER MANAGEMENT

New-MainWindow

Stop-Sound
Stop-MainClockTick
$script:tmrTickMain = $null

if (Get-Laptop) {
	Unregister-Event -SourceIdentifier "PowerSuspend"
	Unregister-Event -SourceIdentifier "PowerResume"
}

# #############################################################################
# ##### END MAIN
# #############################################################################
#endregion MAIN