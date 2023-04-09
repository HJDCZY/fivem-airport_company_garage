## FIVEM aircraft_company_garage

由HJDCZY编写，目前在洛城飞行大队的模拟飞行服务器使用，代码在github开源。

本插件需要一些前置插件，有：

1. es_extended
2. mysql-async
3. menuv
4. polyzone

这个插件根据玩家所在的公司分配公司的机库，公司的载具是有限制的，不是无限刷的。跟市面上的很多玩家车库差不多。

目前的话加载具需要手动去数据库加，在“aircraft_company_garage”这个表里面。

另外一个表“aircraft_company"是储存机库信息，4个坐标是机库的四个角，机库是一个四边形区域。

后面如果更新的话大概就是更新：
* 目前不能储存载具的损坏值，数据库有这一列，但是没写相应代码
* 改用omxysql而不是mysql-async


这是我写的第一个插件，我也是小白，调试了很久。我在代码中写了很详细的注释，我觉得我写的这个插件非常适合作为新手学习的插件。

默认按F6打开菜单，F7/F3储存载具，一般进机库区域会有提示。

大家有什么更新想法可以提出来，我去做。

-------

## FIVEM aircraft_ company_ garage



Written by HJDCZY and currently used in the simulation flight server of the CNAT , the code is open source on Github.



This plugin requires some front-end plugins, including:



1. es_ extended

2. mysql-async

3. menuv

4. polyzone

This plugin allocates company hangars based on the player's company, and the company's vehicles are limited and not unlimited. Similar to many player garages existed.

At present, the loader needs to manually add to the database, in the "aircraft_company_garage" table.

The other table, 'aircraft_company', stores hangar information. The four coordinates represent the four corners of the hangar, and the hangar is a quadrilateral area.

If updated later, it will probably update:

* At present, the damage value of the vehicle cannot be stored. The database has this column, but no corresponding code has been written

* Use omxySQL instead of mysql async

This is the first plugin I wrote, and I am not professional in programming with fivem lua. I have been debugging for a long time. I have written detailed comments in the code, and I think the plugin I have written is very suitable for beginners to learn.

By default, press F6 to open the menu, and F7/F3 to store the vehicle. Generally, there will be a prompt when entering the hangar area.


If you have any update ideas, I will do it.
