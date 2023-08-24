# What is this?
This is a powershell script to generate CSVs of classes for importing into Classwize.

It will assign both teachers and students to their classrooms.

You will need the support team at Linewize to drop all your current classes before importing the new ones.

# How to use
## Exporting EdVal Data
1. Open EdVal Staff
2. Classes -> Export class list
    - Rot 1+2 = Semester 1
    - Rot 3+4 = Semester 2
3. Save the export into the script folder and name it "All students.csv"
4. Run Generate-ClasswizeData.ps1
5. This will write the output to files containing each class in "./Classes/"

## Importing Classes
1.	Go to Linewize Console
2.	Configuration -> Classroom -> Classrooms
3.	Import CSV
4.	Select Upload Classrooms
5.	Select select up to a year level at a time and upload

## Notes
- Your "All students.csv" should have the following columns in this order:

  Student code,Surname,First name,Year,FloatsLetter,FloatsNumber,Course code,Class id,Class year,Teacher code,Teacher name,Subject