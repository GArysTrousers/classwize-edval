#import csv and convert to collection object
$csv = {Import-Csv -Path "All students.csv" -Header StudentCode, Surname, Firstname, Year, FloatsLetter, FloatsNumber, CourseCode, ClassId, ClassYear, TeacherCode, TeacherName, Subject}.Invoke()
#remove header row
if ($csv[0].StudentCode -notmatch '[A-Za-z]{3}[0-9]{4}') { $csv.RemoveAt(0) }

#Students
Write-Host "Adding Students..." -NoNewline
$list = @()
$csv | ForEach-Object {
  $list += [PSCUSTOMOBJECT]@{
    username  = $_.StudentCode
    class     = $_.CourseCode + "_" + $_.ClassId
    isTeacher = "false"
  }
}
Write-Host "Done."

#Teachers
Write-Host "Adding Teachers..." -NoNewline
$sigs = @()
$csv | ForEach-Object {
  #ignore teacherless classes
  $teacherCode = $_.TeacherCode
  if ($_.TeacherCode -ne "" -and $_.CourseCode -ne "") {
    try {
      #tests if user exists
      Get-ADUser -Identity $_.TeacherCode -ErrorAction Stop | Out-Null
      #if item is not in List already
      $sig = $_.TeacherCode + ',' + $_.CourseCode + "_" + $_.ClassId + ",true"
      if (!$sigs.Contains($sig)) {
        $sigs += $sig
        $list += [PSCUSTOMOBJECT]@{
          username  = $_.TeacherCode
          class     = $_.CourseCode + "_" + $_.ClassId
          isTeacher = "true"
        }
      }
    }
    catch {
      Write-Host "$teacherCode doesn't exist in AD"
    }
  }
}
Write-Host "Done."

$list | Export-Csv -Path "./Classwize.csv" -NoTypeInformation -Delimiter ","
Write-Host "File Exported: Classwize.csv"