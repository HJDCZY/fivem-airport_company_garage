-- 使用aircraft_company_garage,添加一些载具信息

-- 给 company 为 flightschool 添加5个model 为luxor的载具，plate从b-1019到b-1023,id从19到23，state均为1，damage均为1000，label均为“乐梭”
insert into aircraft_company_garage(company,model,state,damage,plate,label) values('flightschool','luxor',1,1000,'b-1019','乐梭');
insert into aircraft_company_garage(company,model,state,damage,plate,label) values('flightschool','luxor',1,1000,'b-1020','乐梭');
insert into aircraft_company_garage(company,model,state,damage,plate,label) values('flightschool','luxor',1,1000,'b-1021','乐梭');
insert into aircraft_company_garage(company,model,state,damage,plate,label) values('flightschool','luxor',1,1000,'b-1022','乐梭');
insert into aircraft_company_garage(company,model,state,damage,plate,label) values('flightschool','luxor',1,1000,'b-1023','乐梭');
-- 给 company 为 flightschool 添加3个model 为f50的载具，plate从b-1024到b-1026,id从24到26，state均为1，damage均为1000，label均为“F50”
insert into aircraft_company_garage(company,model,state,damage,plate,label) values('flightschool','f50',1,1000,'b-1024','F50');
insert into aircraft_company_garage(company,model,state,damage,plate,label) values('flightschool','f50',1,1000,'b-1025','F50');
insert into aircraft_company_garage(company,model,state,damage,plate,label) values('flightschool','f50',1,1000,'b-1026','F50');
-- 给 company 为 flightschool 添加3个model 为dh6300的载具，plate从b-1027到b-1029,id从27到29，state均为1，damage均为1000，label均为“dh6300”
insert into aircraft_company_garage(company,model,state,damage,plate,label) values('flightschool','dh6300',1,1000,'b-1027','dh6300');
insert into aircraft_company_garage(company,model,state,damage,plate,label) values('flightschool','dh6300',1,1000,'b-1028','dh6300');
insert into aircraft_company_garage(company,model,state,damage,plate,label) values('flightschool','dh6300',1,1000,'b-1029','dh6300');

