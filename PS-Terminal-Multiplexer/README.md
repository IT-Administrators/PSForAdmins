# PowerShell Terminal Multiplexer

If you are working with Linux, than you are propably familiar with the Linux commandline, and programms like tmux or terminator, to split your sessions and enhance you productivity.

While Linux provides such programms to split your commandline sessions and arrange these session on your screen, depending on the keyboard shortcurt you pressed, Windows 10 doesn't provide this solution. If you need more than one commandline session on Windows 10, you need to open and arrange them by hand, to prevent them from blocking themselves.
Another way to work with more than one commandline session on Windows, is using Windows Terminal. There you can split your session by using keyboard shortcuts, similar to tmux. While Windows Terminal is preinstalled on Windows 11, it needs to be installed on Windows 10. It is not supported on Windows server of any kind, at the moment. 

Because i like the functionality of terminator and i'm using it everytime i'm working with the Linux commandline, i wanted a similar functionality on Windows 10 and Windows Servers, without the need of installing Windows Terminal. After searching the internet for quite some time and not finding any similar programm for Windows, like terminator on Linux, i decided to create this feature myself. While i had some failures with c# and because i didn't want to use 3rd party software and keep it as simple as possible, i came up with the idea to create this functionality with a PowerShell profile. This way it is compatible with PowerShell, my goto tool for configuring Windows and Linux via commandline. 

## System Prerequisites

-	Windows 10 (not tested on Windows 11)
-	PowerShell 5.1 or Higher

## What The Script Does

The script implements two functions to every PowerShell session and adjusts the prompt that is shown in each session.

Functions:
-	Split-Vertical
-	Split-Horizontal

Before downloading the script or copying the code into your current profile, i recommend reading the following article and all sub articles related to PowerShell profiles.

https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.3

## How To Use It

If you downloaded the script or copied the code into your current profile you can use the implemented functions like shown below.

![image](https://user-images.githubusercontent.com/91905626/209553825-b40644df-dbdd-4397-82c6-ab57932733c4.png)

![image](https://user-images.githubusercontent.com/91905626/209553852-dcce34f8-06de-4605-81fe-3567885ec08c.png)

This way the current session is eather split, vertical or horizontal.

If you want to run scripts, scriptblocks or make time intensive configurations, you can use these functions to keep up your producitivity by using another session. An example is shown below.

Let's say you want to test if every machine inside your network is reachable via ping.

![image](https://user-images.githubusercontent.com/91905626/209559312-1fbfd83f-8de3-4c56-90b5-14c9aa85dc2a.png)

While running the connection test in the old session, another session opens and you can work in there, with the same command history of the old session.

You could say, why not using PS jobs, if you need to make huge configurations? That's because you need to wait for the job to complete and receive the complete results, but with this splitted sessions, you can interact with the old session while using a new one. You can exit them or even interact with them, if you get prompted for credentials or anything else, inside your script.

![image](https://user-images.githubusercontent.com/91905626/209560156-5c34aafc-2a4d-4812-ac62-543bca39f14f.png)

![image](https://user-images.githubusercontent.com/91905626/209564228-3a1bdcbc-9890-41ff-ab42-d2c8281c7c8c.png)

Every new session is a Windows PowerShell session. This profile is specifically made for Windows PowerShell. If you need another commandline like PowerShell-Core (PowerShell 7+) or the standard Windows commandline cmd, you can switch to them by using the commands "pwsh" or "cmd" in your current session.

## Known Issues

-	Gab between sessions, they are not docking right next to each other (vertical and horizontal)
-	Doesn't work with Exchange Management Shell
	- If you want to have the same functionality like the exchange management shell, you need to import the exchange module into a normal PowerShell session
- If you change the $NewConsole variable to pwsh, "Start-Process pwsh -PassThru" (line 130,242) and adjust the last line of each function (line 160,272) to "pwsh -command $ScriptBlock", every second session will be Windows Powershell and the code is also run in Windows PowerShell. This might happen if you use both PowerShell Versions on the same system, although it should run Side-by-Side.
