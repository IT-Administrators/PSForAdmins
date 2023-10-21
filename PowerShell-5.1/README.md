PowerShell scripts and modules for admins

I'm using powershell and i'm interested in improving my powershell skills. 
I'm working as an IT-Admin, so working with powershell is daily business.  

Here you can find powershell scripts that work with PowerShell 5.1 (Windows Powershell).

Scripts with a "-" in it's name, are scripts you can use like any other cmdlet in powershell. But they always end with a ".ps1".

Use <Get-Help ScriptName.ps1 -Full>, to get a comment based help on every script.

Scripts with an underscore are snippets, you can copy and paste to use them in your scripts.

Scripts starting with the word "Function" are scripts implementing a function. They are following the syntax:

<Function_FunctionName.ps1>

To use the function you have to import it via dotsourcing, for example:

<. .\Function_FunctionName>

The comment based help of every function, can be called just like any other.  

<Get-Help FunctionName -Full>

After importing the function, you can use it just like any other function/cmdlet. 

Feel free to contribute with tips, scripts or even modules. 
