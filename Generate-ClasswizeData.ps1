#import csv and convert to collection object
$csv = { Import-Csv -Path "All students.csv" -Header StudentCode, Surname, Firstname, Year, FloatsLetter, FloatsNumber, CourseCode, ClassId, ClassYear, TeacherCode, TeacherName, Subject }.Invoke()
#remove header row
if ($csv[0].StudentCode -notmatch '[A-Za-z]{3}[0-9]{4}') { $csv.RemoveAt(0) }

$count = $csv.Count

# Students
$list = @()
$i = 0
$time = Measure-Command {
  $csv | ForEach-Object {
    $i++
    Write-Progress -Activity "Students" -Status "$i/$count" -PercentComplete ($i * 100 / $count)
    $list += [PSCUSTOMOBJECT]@{
      user      = $_.StudentCode.ToLower()
      class     = ($_.CourseCode + "_" + $_.ClassId).ToLower()
      isTeacher = "false"
    }
  }
}
Write-Host ("{0,-30} {1}s" -f "Students Done", $time.TotalSeconds)


# Teachers
$i = 0
$time = Measure-Command {
  $staff = @{}
  $csv | ForEach-Object {
    $i++
    Write-Progress -Activity "Staff" -Status "$i/$count" -PercentComplete ($i * 100 / $count)
    if ($_.TeacherCode -ne "" -and $_.CourseCode -ne "") {
      $staff[$_.TeacherCode + "_" + $_.CourseCode + "_" + $_.ClassId] = [PSCUSTOMOBJECT]@{
        user      = $_.TeacherCode.ToLower()
        class     = ($_.CourseCode + "_" + $_.ClassId).ToLower()
        isTeacher = "true"
      }
    }
  }
}
Write-Host ("{0,-30} {1}s" -f "Staff Done", $time.TotalSeconds)


#Varify Teachers Exist
$time = Measure-Command {
  $uniqueStaff = $staff.Clone()
  $count = $uniqueStaff.Count
  $i = 0
  foreach ($s in $uniqueStaff.GetEnumerator()) {
    $i++
    Write-Progress -Activity "Varifying Staff" -Status "$i/$count" -PercentComplete ($i * 100 / $count)
    try {
      Get-ADUser -Identity $s.Value.user -ErrorAction Stop | Out-Null
    }
    catch {
      $staff.Remove($s.Key)
    }
  }
  $list += $staff.Values
}
Write-Host ("{0,-30} {1}s" -f "Varifying Staff Done", $time.TotalSeconds)


# Create Classes
$classes = @{}

$list | ForEach-Object {
  $classes[$_.class] += @($_)
}

if (Test-Path "./Classes") {
  Get-ChildItem "./Classes/*" | Remove-Item
} else {
  New-Item "./Classes" -ItemType "directory" | Out-Null
}

# Write to files
foreach ($c in $classes.GetEnumerator() ) {
  $hasTeacher = $false
  $outStr = ""
  # Write-Host $c.Name $c.Value.Count
  # $c.Value | Format-Table
  foreach ($i in $c.Value) {
    if ($i.isTeacher -eq "true") {
      $hasTeacher = $true
    }
    $outStr += "{0},{1},{2}`n" -f $i.user, $i.class, $i.isTeacher
  }
  if ($hasTeacher) {
    $outStr | Set-Content "./Classes/$($c.Key).csv"
  }
}
Write-Host "Class Files Exported"