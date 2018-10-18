DROP TABLE IF EXISTS dept_locations;
DROP TABLE IF EXISTS works_on;
DROP TABLE IF EXISTS department;
DROP TABLE IF EXISTS project;
DROP TABLE IF EXISTS employee;

CREATE TABLE department (
       Dnumber INT UNSIGNED NOT NULL AUTO_INCREMENT,
       Dname VARCHAR(15) NOT NULL,
       PRIMARY KEY (Dnumber),
       UNIQUE (Dname)
);       
       
CREATE TABLE project (
       Pnumber INT UNSIGNED NOT NULL AUTO_INCREMENT,
       Pname VARCHAR(15) NOT NULL,
       PRIMARY KEY (Pnumber),
       UNIQUE (Pname)
);

CREATE TABLE employee (
       Eid INT UNSIGNED NOT NULL AUTO_INCREMENT,  /* employee ID */
       Fname VARCHAR(15) NOT NULL,                /* first name */
       Minit CHAR,                                /* middle initial */
       Lname VARCHAR(15) NOT NULL,                /* last name */
       Super_eid INT UNSIGNED,                    /* supervisor's employee ID */
       Bdate DATE,                                /* birthdate */
       Dno INT NOT NULL DEFAULT 1,                /* num. of dept. that they work in */
       PRIMARY KEY (Eid)                          /* designate Eid as primary key */
);     

CREATE TABLE dept_locations (
       Dnumber INT UNSIGNED NOT NULL,             /* refers to department number */
       Dlocation VARCHAR(15) NOT NULL,
       PRIMARY KEY (Dnumber, Dlocation),
       FOREIGN KEY (Dnumber) REFERENCES department(Dnumber)
);
       
CREATE TABLE works_on (
       Eid INT UNSIGNED NOT NULL,   /* refers to employee ID */
       Pno INT UNSIGNED NOT NULL,   /* refers to project number */
       PRIMARY KEY (Eid, Pno),
       FOREIGN KEY (Eid) REFERENCES employee(Eid),
       FOREIGN KEY (Pno) REFERENCES project (Pnumber)
);

ALTER TABLE employee
    ADD CONSTRAINT FOREIGN KEY (Super_eid) references employee(Eid);
    
    

