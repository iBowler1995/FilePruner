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
    This parameter is an integer - specifies the target age to delete. Required ALWAYS
    .PARAMETER Path
    This parameter is a string - specifies the directory to prune. Required ONLY if NOT using -File switch. If using -File switch do not use this parameter.
    .PARAMETER File
    This parameter is optional and for use if you want to put multiple directories in a file to have read
    .PARAMETER FilePath
    This parameter is required ONLY if you use the File parameter. If you don't use the File parameter, don't use this parameter
    .EXAMPLES
    FilePruner.ps1 -Threshold 15 -Path "C:\Windows\Temp" <- This will delete all files and folders older than 15 days at "C:\Windows\Temp"
    FilePruner.pS1 -Threshold 15 -File -Path "C:\Temp\Directories.txt" <- This will delete all files and folders older than 15 days in each of the directors in C:\Temp\Directories.txt
    #>


#These are the parameters required to run the script
[cmdletbinding()]
param (
    [Parameter(Mandatory=$True)]
    [Int]$Threshold,
    [Parameter(Mandatory=$true)]
    [String]$Path,
    [Parameter(Mandatory = $false)]
    [Switch]$File
)


$Age=(Get-Date).AddDays(- $Threshold)

If ($File){
    Try{
        $Files = Get-Content -Path $Path
    }
    catch{
        $Error[0].Exception.InnerException | out-file .\ErrorLog.log -Force -Append
        exit
    }
    Try{
        $Files = Get-Content -Path $Path
        foreach ($Line in $Files){
            #Gets all items (and items in subdirectories, thanks to -recurse) where last write time is less than or equal to our $Age and writes any errors to a log file
            Get-ChildItem -Path $Line -Recurse | Where-Object {($_.LastWriteTime -le $Age)} | #The pipline | lets you combine multiple actions into one command
                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            #Deleting all empty folders afterwards
            Get-ChildItem -Path $Line -Recurse -Force |
                Where-Object {$_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | #PsIsContainer is a boolean for whether an item is a directory or not. True = yes, False = no
                Where-Object {!$_.PSIsContainer}) -eq $null } | #This line and the above get all items that are directories and have no files in them
                Remove-Item -Force -Recurse
                }
        }
    Catch{
        $Error[0].Exception.InnerException | out-file .\ErrorLog.log -Force -Append
    } 
}

else{
    Try{
    Get-ChildItem -Path $path -Recurse | Where-Object {($_.LastWriteTime -le $Age)} |
        Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    }
    Catch{
        $Error[0].Exception.InnerException | out-file .\ErrorLog.log -Append
    } 

    Get-ChildItem -Path $Path -Recurse -Force |
        Where-Object {$_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force |
        Where-Object {!$_.PSIsContainer}) -eq $null } |
        Remove-Item -Force -Recurse   
}
