function  attribute = attrib()
  
    attrib1 =[];
    attrib1(1) = -90 +  (-75 + 90) * rand(1);
    attrib1(2) = 700 + (2000 - 700) * rand(1);
    attrib1(3) = 10 + (50 - 10) * rand(1);
    attrib1(4) = 5 +  (15 - 5) * rand(1);
    attrib1(5) = 2 +  (10 - 2) * rand(1);
    attrib1(6) = 5 +  (35 - 5) * rand(1);
    
    attrib2 =[];
    attrib2(1) = -90  +  (-60 + 90) * rand(1);
    attrib2(2) = 800 + (4000-800) * rand(1);
    attrib2(3) = 40 + (80-40) * rand(1);
    attrib2(4) = 15  + (40-15) * rand(1);
    attrib2(5) = 6  +  (20 - 6) * rand(1);
    attrib2(6) = 10  +  (45 - 10) * rand(1);
    
    attrib3 =[];
    attrib3(1) = -95 + (-40 + 95) * rand(1);     
    attrib3(2) = 1000 + (8000-1000) * rand(1);
    attrib3(3) = 70  + (100-70) * rand(1);
    attrib3(4) = 30  +  (65 - 30) * rand(1);
    attrib3(5) = 4 +  (15 - 4) * rand(1);
    attrib3(6) = 0 +  (20 - 0) * rand(1);

    attrib4 =[];
    attrib4(1) =  -90  +  (-75 + 90) * rand(1);
    attrib4(2) = 900  + (6000-900) * rand(1);
    attrib4(3) = 50  + (90-50) * rand(1);
    attrib4(4) = 20 +  (50 - 20) * rand(1);
    attrib4(5) = 8 +  (20 - 8) * rand(1);
    attrib4(6) = 15  +  (50 - 15) * rand(1);
    double attribute;
    attribute = [attrib1;attrib2;attrib3;attrib4];        
    
end
