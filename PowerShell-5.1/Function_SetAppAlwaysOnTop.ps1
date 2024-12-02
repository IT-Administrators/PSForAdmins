<#
.Synopsis
    Sets window top most.

.DESCRIPTION
    Sets the window of the specified process top most and keeps it there.

    If this is done to more than one process, the first one will be the primary.

    For example, if this is run on notepad and than on teams, the notepad window can be 
    moved above the teams window. 

.EXAMPLE
    Set process to always be top most.

    Set-AppAlwaysOnTopRoH -AppName "teams"

.EXAMPLE
    Disable topmost position of specified process.

    Set-AppAlwaysOnTopRoH -AppName "teams" -Disable

.NOTES
    Written and testet in PowerShell 5.1.

    Original script from:

    https://github.com/bkfarnsworth/Always-On-Top-PS-Script/blob/master/Always_On_Top.ps1

.LINK
    https://github.com/IT-Administrators/PSForAdmins/tree/main/PowerShell-5.1
#>

function Set-AppAlwaysOnTopRoH {

    [CmdletBinding(DefaultParameterSetName='AppAlwaysonTop', 
                   SupportsShouldProcess=$true)]
    
    param(
        [Parameter(
        ParameterSetName='AppAlwaysonTop',
        Position=0,
        HelpMessage='App Name.')]
        [String]$AppName,

        [Parameter(
        ParameterSetName='AppAlwaysonTop',
        Position=0,
        HelpMessage='App Name.')]
        [Switch]$Disable
    )

    # Adding Pinvoke interface. 
    Add-Type @"

    using System;
    using System.Runtime.InteropServices;

    public class Process {
	
        // Retrieves handle to top-level window, where classname and window name match specified string.
	    [DllImport("user32.dll")]  
	    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);  

	    public static IntPtr FindWindow(string windowName){
		    return FindWindow(null,windowName);
	    }
        
        // Sets the window position to the specified parameters.
	    [DllImport("user32.dll")]
	    public static extern bool SetWindowPos(IntPtr hWnd, 
	    IntPtr hWndInsertAfter, int X,int Y, int cx, int cy, uint uFlags);
        
        // Show state of the window. Possible parameters can be found here: https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-showwindow
	    [DllImport("user32.dll")]  
	    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow); 
        
        // https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowpos
        // Place window above all non-topmost windows. Keep it there even it is deactivated (minimized).
	    static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);
        // Place window behind all non-topmost windows.
	    static readonly IntPtr HWND_NOTOPMOST = new IntPtr(-2);
        
        // https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowpos
        // Retain current size.
	    const UInt32 SWP_NOSIZE = 0x0001;
        // Retain current position.
	    const UInt32 SWP_NOMOVE = 0x0002;

	    const UInt32 TOPMOST_FLAGS = SWP_NOMOVE | SWP_NOSIZE;
        
        // Custom methods wrapping the SetWindowPos function.
	    public static void MakeTopMost (IntPtr fHandle)
	    {
		    SetWindowPos(fHandle, HWND_TOPMOST, 0, 0, 0, 0, TOPMOST_FLAGS);
	    }

	    public static void MakeNormal (IntPtr fHandle)
	    {
		    SetWindowPos(fHandle, HWND_NOTOPMOST, 0, 0, 0, 0, TOPMOST_FLAGS);
	    }
    }
"@ -ErrorAction SilentlyContinue # Deactivate error message when used mroe than once.

    # Get mainwindow handle.
    $Hwnd = (Get-Process -Name "*$AppName*").MainWindowHandle
    # Check if process was found.
    # Here can not be checked for 0. An empty process is returned as null.
    if($Hwnd -ne $null)
	{
        # A lot of processes run more than one instance (Teams).
        # All instances will be set TOPMOST because there is no way to determine the primary instance.
        foreach($hwnd in $Hwnd) {
            if($Disable)
		    {
                # Return window to normal preferences.
			    [void][Process]::MakeNormal($Hwnd)
                return
		    }
		    # Set window top most.
		    [void][Process]::MakeTopMost($Hwnd)
        }
	}
	else
	{
        # Create error message if no process was found.
		Write-Error -Category InvalidArgument -Message "The specified process was not found." -Verbose
	}
}