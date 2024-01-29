$raw_ext = ".NEF" # extension of raw files to keep

# Function that removes all .jpg files that are duplicates of .NEF files from the given directory 
function Remove-Jpg-Dups {
    param([string]$directory)
    Write-Verbose "Removing JPG duplicates from $directory"
    # Find all .jpg files in the given directory
    $jpgs = Get-ChildItem -Path "$directory" -Include *.jpg -Name
    # count the jpgs found
    Write-Verbose "Found $jpgs.Length .jpg files"
    # Iterate over jpgs and remove any that are duplicates of NEF files
    foreach ($jpg in $jpgs) {
        $nef = $jpg.replace(".jpg", "$raw_ext") # replace .jpg if exists
        $nef = $nef.replace(".JPG", "$raw_ext") # replace .JPG if exists
        Write-Verbose "Checking $jpg against $nef"
        if (Test-Path -Path "$directory/$nef" -PathType Leaf) {
            Write-Verbose "$raw_ext exists for $jpg, removing"
            Remove-Item -Path "$directory/$jpg" -Force
            Write-Verbose "Removed $jpg"
        }
    }
}
