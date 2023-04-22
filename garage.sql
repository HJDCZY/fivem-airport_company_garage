use es_extended;
-- 创建一个新表aircraft_company_garage,用于储存机库飞机信息
create table aircraft_company_garage(
    id int(11) not null auto_increment,
    -- 创建一列名为company,char
    company char(50) not null,
    -- 创建一列名为model,char
    model char(50) not null,
    -- 创建一列名为state,bool
    state bool not null,
    -- 创建一列名为damage,int
    damage int(11) not null,
    -- 创建一列名为plate,char
    plate char(50) not null,
    -- 创建一列名为gameplate,text,默认为NULL
    gameplate text default NULL,
    -- 创建一列名为label,char
    label char(50) not null,

    -- 结束
    primary key(id)
)engine=innodb default charset=utf8;
-- 创建一个新表aircraft_company,用于储存公司机库坐标等信息
create table aircraft_company(
    id int(11) not null auto_increment,
    -- 创建一列名为company,char
    company char(50) not null,
    -- 创建一列名为label,char
    label char(50) not null,
    -- 需要储存4个点（边角）的坐标
    -- 创建一列名为x1,float
    x1 float not null,
    -- 创建一列名为y1,float
    y1 float not null,
    -- 创建一列名为x2,float
    x2 float not null,
    -- 创建一列名为y2,float
    y2 float not null,
    -- 创建一列名为x3,float
    x3 float not null,
    -- 创建一列名为y3,float
    y3 float not null,
    -- 创建一列名为x4,float
    x4 float not null,
    -- 创建一列名为y4,float
    y4 float not null,
    -- 结束
    primary key(id)
)engine=innodb default charset=utf8;
