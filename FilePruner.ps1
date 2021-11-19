    <#
    NOTES
	===========================================================================
	 Script Name: File Pruner
	 Created on:   	11/19/2021
	 Created by:   	iBowler1995
	 Filename: FilePruner.ps1
	===========================================================================
	.DESCRIPTION
		This script is used to clean files and folders older than x days in a specified directory
	===========================================================================
	IMPORTANT:
	===========================================================================
	This script is provided 'as is' without any warranty. Any issues stemming 
	from use is on the user.
    ===========================================================================
    .PARAMETER Threshold
    This parameter is an integer - specifies the target age to delete
    .PARAMETER Path
    This parameter is a string - specifies the directory to prune
    .EXAMPLE
    FilePruner.ps1 -Threshold -15 -Path "C:\Windows\Temp"    
    #>


#These are the parameters required to run the script
[cmdletbinding()]
param (
    [Parameter(Mandatory=$True)]
    [Int]$Threshold,
    [Parameter(Mandatory=$true)]
    [String]$Path
)

$Age=(Get-Date).AddDays(- $Threshold)
#Recording our actions
Start-Transcript -Path .\FilePrune.log -Force
#Gets all items (and items in subdirectories, thanks to -recurse) where last write time is less than or equal to our $Age
Get-ChildItem -Path $path -Recurse | Where-Object {($_.LastWriteTime -le $Age)} | #The pipline | lets you combine multiple actions into one command
    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue #We ignore errors because some files will throw an error if they're in use or locked
#Deleting all empty folders afterwards
Get-ChildItem -Path $Path -Recurse -Force |
    Where-Object {$_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | #PsIsContainer is a boolean for whether an item is a directory or not. True = yes, False = no
    Where-Object {!$_.PSIsContainer}) -eq $null } | #This line and the above get all items that are directories and have no files in them
    Remove-Item -Force -Recurse
Stop-Transcript
