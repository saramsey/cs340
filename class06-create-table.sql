CREATE TABLE student (
       id MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT,
       sname VARCHAR(256) NOT NULL,
       onid_id VARCHAR(32),
       college_code SET('COE','COS','COF','COB','CLA','CVM',
                        'CAS','COP','CEOAS','CPHHS','CED') NOT NULL,
       year_enrolled YEAR NOT NULL,
       gpa DECIMAL(3,2) UNSIGNED,
       PRIMARY KEY (id)
);



        
       
