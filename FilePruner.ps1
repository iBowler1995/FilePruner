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
    [Parameter(Mandatory = $false)]
    [Switch]$File,
    [Parameter(Mandatory = $false)]
    [String]$FilePath
)


$Age=(Get-Date).AddDays(- $Threshold)

If ($File){
    If ($FilePath -eq $null)
    {
        "File switch used but no file path provided. Please provide file path or remove file switch and run again." | out-file .\ErrorLog -Append
    }
    else{
        $Files = Get-Content $FilePath
        Try{
        foreach ($Line in $Files){
            #Gets all items (and items in subdirectories, thanks to -recurse) where last write time is less than or equal to our $Age and writes any errors to a log file
            Get-ChildItem -Path $path -Recurse | Where-Object {($_.LastWriteTime -le $Age)} | #The pipline | lets you combine multiple actions into one command
                    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                }
        Catch{
             $Error | out-file .\ErrorLog.log -Append
            } 
            #Deleting all empty folders afterwards
        Get-ChildItem -Path $Path -Recurse -Force |
            Where-Object {$_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | #PsIsContainer is a boolean for whether an item is a directory or not. True = yes, False = no
            Where-Object {!$_.PSIsContainer}) -eq $null } | #This line and the above get all items that are directories and have no files in them
            Remove-Item -Force -Recurse
        }       
    }

    }
else{
    Try{
    Get-ChildItem -Path $path -Recurse | Where-Object {($_.LastWriteTime -le $Age)} |
        Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    }
    Catch{
        $Error | out-file .\ErrorLog.log -Append
    } 

    Get-ChildItem -Path $Path -Recurse -Force |
        Where-Object {$_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force |
        Where-Object {!$_.PSIsContainer}) -eq $null } |
        Remove-Item -Force -Recurse   
}
