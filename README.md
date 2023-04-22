## FIVEM aircraft_company_garage

<!-- 通过链接切换中英文 -->
[English](README.md) | [中文](README_CN.md)
# FIVEM aircraft_ company_ garage

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
