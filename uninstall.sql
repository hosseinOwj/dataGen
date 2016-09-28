/**********************************
        UNINSTALL FILE 
**********************************/
-- This file includes 1 tasks:
-- Delete Everything. This COMMAND will remove all TABLE, VIEW, FUNCTION, SEQUENCE and PROCEDURE. 

set define on;
set define on;

-- Installation Directory
-- Change this variable with the exact path of the project(where you copy paste the folder). Use a '\' at the end.

define path = 'C:\DB\finalProject\';
define s_KILL_DB = '\scripts\KILL_DB';

@&path&s_KILL_DB;