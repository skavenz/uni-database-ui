# uni-database-ui
Maintaining a simulated university database online using ReactJS, HTML + CSS frontend and SQL database backend. Hobbies of students are stored so that appropriate clubs/societies can be reccomended.

## Database Schema:
Course(Crs_Code, Crs_Title, Crs_Enrollment, Lecturer_ID)
PRIMARY KEY: Crs_Code
FOREIGN KEY: Lecturer_ID REFERENCES Lecturer(Lecturer_ID)

Student(URN, Stu_FName, Stu_LName, Stu_DOB, Stu_Phone, Stu_Course, Stu_Type)
PRIMARY KEY: URN
FOREIGN KEY: Stu_Course REFERENCES Course(Crs_Code)

Undergraduate(UG_URN, UG_Credits)
PRIMARY KEY: UG_URN
FOREIGN KEY: UG_URN REFERENCES Student(URN)

Postgraduate(PG_URN, Thesis)
PRIMARY KEY: PG_URN
FOREIGN KEY: PG_URN REFERENCES Student(URN)

Hobby(Hob_ID, Hobby_Name)
PRIMARY KEY: Hob_ID

Society(Soc_ID, Soc_Name, Soc_Desc)
PRIMARY KEY: Soc_ID

StudentSociety(URN, Soc_ID)
PRIMARY KEY: URN, Soc_ID
FOREIGN KEY: URN REFERENCES Student(URN)
FOREIGN KEY: Soc_ID REFERENCES Society(Soc_ID)

SocietyLeader(SocL_ID, Soc_ID, Start_Date)
PRIMARY KEY: SocL_ID
FOREIGN KEY: Soc_ID REFERENCES Society(Soc_ID)

StudentHobby(URN, Hob_ID)
PRIMARY KEY: URN, Hob_ID
FOREIGN KEY: URN REFERENCES Student(URN)
FOREIGN KEY: Hob_ID REFERENCES Hobby(Hob_ID)

Lecturer(Lec_ID, Dep_ID, Lec_FName, Lec_LName, Lec_Course)
PRIMARY KEY: Lec_ID
FOREIGN KEY: Dep_ID REFERENCES Department(Dep_ID)

Department(Dep_ID, Dep_Name, Dep_Phone)
PRIMARY KEY: Dep_ID
DepartmentPhone(Dep_ID, Phone_Number, PhoneType)
PRIMARY KEY: Dep_ID, Phone Number
FOREIGN KEY: Dep_ID REFERENCES Department(Dep_ID)


## Application Structure
├── website
│ ├── index.js 
│ ├── package.json
| ├── views
| | ├── index.ejs
| | ├── search.ejs
| | ├── viewall.ejs
| | ├── update.ejs
| | ├── updatebranch.ejs
| | ├── societyadviser.ejs
| | ├── societyadviserbranch.ejs
| | ├── common
| | | ├── header.ejs
| | | ├── footer.ejs
| ├── public
| | ├── main.css
