//imports
const express = require("express");
const app = express();
const ejs = require("ejs");
var mysql = require("mysql2");
const util = require("util");
const port = 3000;
const bodyParser = require('body-parser');

var connection = mysql.createConnection({
    host: 'localhost',
    database: 'coursework',
    user: 'root',
    password: ''
});

connection.query = util.promisify(connection.query).bind(connection);

connection.connect((err) => {
    if (err) throw err;
    console.log('SQL database connected!');
});

//function to search student using their first name
async function searchStudentByName(studentName) {
    try {
        const sql = "SELECT * FROM Student WHERE Stu_FName = ?";
        const result = await connection.query(sql, [studentName]);
        return result.length > 0 ? result[0] : null;
    } catch (error) {
        console.error("Error searching for student:", error);
        throw error;
    }
}

//gets random index from array
function getRandomFromArray(arr) {
    const randomIndex = Math.floor(Math.random() * arr.length);
    return arr[randomIndex];
}

//made for society recommendations based on hobbies
const recommendations = {
    "Reading": "LiteratureSoc",
    "Hiking": ["RowingSoc", "ClimbingSoc", "WalkingSoc"],
    "Chess": "ChessSoc",
    "Taichi": "TaichiSoc",
    "Ballroom Dancing": "DanceSoc",
    "Football": ["FootballSoc", "TenniSoc", "BasketballSoc"],
    "Tennis": ["TennisSoc", "FootballSoc", "BasketballSoc"],
    "Rugby": ["TennisSoc", "FootballSoc", "BasketballSoc"],
    "Climbing": ["RowingSoc", "ClimbingSoc", "WalkingSoc"],
    "Rowing": ["RowingSoc", "ClimbingSoc", "WalkingSoc"],
    "Cooking": "BakingSoc",
  };

  //to randomise if student is already in all societies
  const Allsocieties = [
    'LiteratureSoc',
    'WalkingSoc',
    'ChessSoc',
    'TaichiSoc',
    'DanceSoc',
    'FootballSoc',
    'TenniSoc',
    'RugbySoc',
    'ClimbingSoc',
    'RowingSoc',
    'BakingSoc',
    'BasketballSoc',
    'MusicSoc',
    'ArtSoc',
    'PhotographySoc',
    'Science Fiction Society',
    'CompSoc'
];


app.set("view engine", "ejs");
app.use(express.static("public"));
app.use(bodyParser.urlencoded({ extended: false }));

//these queries allow us to retrieve the total numbers.
app.get("/", async (req, res) => {
    const studentCount = await connection.query(
        "SELECT COUNT(*) as count FROM student"
    );
    const undergraduateCount = await connection.query(
        "SELECT COUNT(*) as count FROM undergraduate"
    );
    const postgraduateCount = await connection.query(
        "SELECT COUNT(*) as count FROM postgraduate"
    );
    const courseCount = await connection.query(
        "SELECT COUNT(*) as count FROM course"
    );
    res.render("index", {
        currentPage: "home",
        studentCount: studentCount[0].count,
        undergraduateCount: undergraduateCount[0].count,
        postgraduateCount: postgraduateCount[0].count,
        courseCount: courseCount[0].count,
    });
});

//search one.
app.get("/search", (req, res) => {
    res.render("search", { searched: false, currentPage: "search" });
});

//post request which allows for data submission and allows us to retrieve all data using the req.body passed through.
app.post("/search", async (req, res) => {
    const studentName = req.body.studentName;   
    if (!studentName) {
        res.redirect("/search");
        return;
    }
    try {
        const studentData = await searchStudentByName(studentName);

        res.render("search", {
            studentData: studentData,
            searched: true,
            currentPage: "search"
        });
    } catch (error) {
        res.status(500).send("Internal Server Error");
    }
});


//displays all values. Join queries are used to join all tables together.
app.get("/viewall", async (req, res) => {
    try {
        const results = await connection.query(`
            SELECT Student.*, Course.Crs_Title AS Course_Name, GROUP_CONCAT(DISTINCT Hobby.Hob_Name) AS Hobbies, GROUP_CONCAT(DISTINCT Society.Soc_Name) AS Societies
            FROM Student
            LEFT JOIN Course ON Student.Stu_Course = Course.Crs_Code
            LEFT JOIN StudentHobby ON Student.URN = StudentHobby.URN
            LEFT JOIN Hobby ON StudentHobby.Hob_ID = Hobby.Hob_ID
            LEFT JOIN StudentSociety ON Student.URN = StudentSociety.URN
            LEFT JOIN Society ON StudentSociety.Soc_ID = Society.Soc_ID
            GROUP BY Student.URN;
            `);
        res.render("viewall", { data: results, currentPage: "viewall" });
    } catch (error) {
        console.error(error);
        res.status(500).send("A server error occurred.");
    }
});


//shows all students. we can click their name to access their unique route.
app.get("/update", async (req, res) => {
        const students = await connection.query("SELECT * FROM Student");
        res.render("update", { students, selectedStudent: null, currentPage: "update"});
});

//this is a branch from update. We repopulate the website to display the course and student details beforehand
app.get("/update/:URN", async (req, res) => {
    const course = await connection.query("SELECT * FROM Course");
    const student = await connection.query("SELECT * from Student INNER JOIN Course on student.Stu_Course = course.Crs_Code WHERE URN =  ?", [req.params.URN])
    res.render("updatebranch", { student: student[0], courses: course, message: '', currentPage: "" });
});

//the updated student details are in req.body, so we extract the values from that and finally update them in the database.
app.post("/update/:URN", async (req, res) => {
    urn = req.params.URN
    const updated = req.body    

    if (isNaN(updated.Stu_Phone) || updated.Stu_Phone.length !== 11) {
        const course = await connection.query("SELECT * FROM Course");
        const student = await connection.query("SELECT * from Student INNER JOIN Course on student.Stu_Course = course.Crs_Code WHERE URN =  ?", [urn])
        res.render('updatebranch', { student: student[0], courses: course, message: 'Error: Invalid phone number format.', currentPage: "update" });
        return;
    }
    
    try {
        await connection.query("UPDATE Student SET Stu_Course = ?, Stu_Phone = ? WHERE URN = ?", [updated.Stu_Course, updated.Stu_Phone, urn]);
        const course = await connection.query("SELECT * FROM Course");
        const student = await connection.query("SELECT * from Student INNER JOIN Course on student.Stu_Course = course.Crs_Code WHERE URN =  ?", [urn])
        res.render('updatebranch', { student: student[0], courses: course, message: 'Sucessfully updated student.', currentPage: "update" });
        
    } catch (error) {
        console.error("Error updating student:", error);
        res.status(500).send("Internal Server Error");
    }
});

// shows all students. we can click their name to access their unique route.
app.get('/societyadviser', async (req, res) => {
        const students = await connection.query("SELECT * FROM Student");
        res.render('societyadviser', { students, selectedStudent: null, currentPage: 'societyadviser' });
});

// We fetch all hobbies, and society values based on the urn of the student we are checking. we will get their values, map them as strings in an array
// and then will use .find to get a society that it is related to in the predefined table above. If the student has no hobbies, they receive a random
//society recommendation as their is no value to serve as a basis
app.get('/societyadviser/:URN', async (req, res) => {
    const urn = req.params.URN
    const students = await connection.query("SELECT Stu_FName, Stu_LName FROM Student WHERE URN = ?", [urn]);
    const fetchHobbies = await connection.query("SELECT Hob_Name FROM StudentHobby INNER JOIN Hobby ON StudentHobby.Hob_ID = Hobby.Hob_ID WHERE URN = ?", [urn]);
    const fetchSocieties = await connection.query("SELECT Soc_Name FROM StudentSociety INNER JOIN Society ON StudentSociety.Soc_ID = Society.Soc_ID WHERE URN = ?", [urn]);
    const studentHobbies = fetchHobbies.map((row) => row.Hob_Name);
    const studentSocieties = fetchSocieties.map((row) => row.Soc_Name);
    let chosenSociety = ""
    let recommendedSociety = [];

    if (!studentHobbies || studentHobbies.length === 0) {
        chosenSociety = getRandomFromArray(Allsocieties);
    } else {
        const randomHobby = getRandomFromArray(studentHobbies);
        const recommendationsForHobby = recommendations[randomHobby];
        if (Array.isArray(recommendationsForHobby)) {
            chosenSociety = recommendationsForHobby.find(society => !studentSocieties.includes(society));
        } else if (typeof recommendationsForHobby === 'string') {
            chosenSociety = recommendationsForHobby;
        }
        
        if (chosenSociety === "") {
            while (studentSocieties.includes(chosenSociety)) {
                chosenSociety = getRandomFromArray(Allsocieties);
            }
        }
    }
    //society description retrieved from table and displayed.
    const societyDescription = await connection.query("SELECT Soc_Desc FROM Society WHERE Soc_Name = ?", [chosenSociety]);

    recommendedSociety = {name: chosenSociety, description: societyDescription.length > 0 ? societyDescription[0].Soc_Desc : "No description available."}
        
    res.render('societyadviserbranch', {
        currentPage: 'societyadviser', message: "", student: students[0], recommendedSociety: recommendedSociety, studentHobbies, studentSocieties});
});

//retrieves data again to repopulate. Based on which button is clicked, the value of decision will be different. if accepted, we insert the data, otherwise we don't
app.post('/societyadviser/:URN', async (req, res) => {
    const urn = req.params.URN;
    const students = await connection.query("SELECT Stu_FName, Stu_LName FROM Student WHERE URN = ?", [urn]);
    const fetchHobbies = await connection.query("SELECT Hob_Name FROM StudentHobby INNER JOIN Hobby ON StudentHobby.Hob_ID = Hobby.Hob_ID WHERE URN = ?", [urn]);
    const fetchSocieties = await connection.query("SELECT Soc_Name FROM StudentSociety INNER JOIN Society ON StudentSociety.Soc_ID = Society.Soc_ID WHERE URN = ?", [urn]);
    const studentHobbies = fetchHobbies.map((row) => row.Hob_Name);
    const studentSocieties = fetchSocieties.map((row) => row.Soc_Name);
    const decision = req.body.decision;
    const recommendedSociety = req.body.recommendedSociety
    // the recommended society and urn are passed into here which will then insert the data into the table.
    if (decision === 'accept') {
        await connection.query("INSERT INTO StudentSociety (URN, Soc_ID) VALUES (?, (SELECT Soc_ID FROM Society WHERE Soc_Name = ?))", [urn, recommendedSociety]);
        res.render('societyadviserbranch', { message: 'Society recommendation accepted successfully', student: students[0], studentHobbies, studentSocieties, recommendedSociety, currentPage: ""});
    } else if (decision === 'deny') {
        res.render('societyadviserbranch', { message: 'Society recommendation denied', student: students[0], studentHobbies, studentSocieties, recommendedSociety, currentPage: ""});
    }
});


app.listen(port, () => {
    console.log(`Listening on http://localhost:${port}`);
});
