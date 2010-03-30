-----------------------------------------------------------------------
--                               G P S                               --
--                                                                   --
--                     Copyright (C) 2003-2010, AdaCore              --
--                                                                   --
-- GPS is free  software;  you can redistribute it and/or modify  it --
-- under the terms of the GNU General Public License as published by --
-- the Free Software Foundation; either version 2 of the License, or --
-- (at your option) any later version.                               --
--                                                                   --
-- This program is  distributed in the hope that it will be  useful, --
-- but  WITHOUT ANY WARRANTY;  without even the  implied warranty of --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU --
-- General Public License for more details. You should have received --
-- a copy of the GNU General Public License along with this program; --
-- if not,  write to the  Free Software Foundation, Inc.,  59 Temple --
-- Place - Suite 330, Boston, MA 02111-1307, USA.                    --
-----------------------------------------------------------------------

with Entities;
with GNATCOLL.Projects;
with GNATCOLL.VFS;
with Projects;
with Language.Tree.Database;

package ALI_Parser is

   function Create_ALI_Handler
     (Db       : Entities.Entities_Database;
      Registry : Projects.Project_Registry)
      return Entities.LI_Handler;
   --  Create a new ALI handler

   type ALI_Handler_Record is new Entities.LI_Handler_Record with record
      Db       : Entities.Entities_Database;
      Registry : Projects.Project_Registry;
   end record;
   type ALI_Handler is access all ALI_Handler_Record'Class;
   --  Generic ALI handler. Can be overriden for e.g. GCC .gli files.

   overriding function Get_Name (LI : access ALI_Handler_Record) return String;
   overriding function Get_Source_Info
     (Handler               : access ALI_Handler_Record;
      Source_Filename       : GNATCOLL.VFS.Virtual_File;
      File_Has_No_LI_Report : Entities.File_Error_Reporter := null)
      return Entities.Source_File;
   overriding function Case_Insensitive_Identifiers
     (Handler : access ALI_Handler_Record) return Boolean;
   overriding function Parse_All_LI_Information
     (Handler   : access ALI_Handler_Record;
      Project   : GNATCOLL.Projects.Project_Type)
      return Entities.LI_Information_Iterator'Class;
   overriding function Generate_LI_For_Project
     (Handler      : access ALI_Handler_Record;
      Lang_Handler : access
        Language.Tree.Database.Abstract_Language_Handler_Record'Class;
      Project      : GNATCOLL.Projects.Project_Type;
      Errors       : GNATCOLL.Projects.Error_Report;
      Recursive    : Boolean := False)
      return Entities.LI_Handler_Iterator'Class;
   --  See doc for inherited subprograms

   type ALI_Information_Iterator
     is new Entities.LI_Information_Iterator with private;
   overriding procedure Free (Iter : in out ALI_Information_Iterator);
   overriding procedure Next
     (Iter  : in out ALI_Information_Iterator;
      Steps : Natural := Natural'Last;
      Count : out Natural;
      Total : out Natural);
   --  See doc for inherited subprograms

   function Get_ALI_Ext
     (LI : access ALI_Handler_Record)
      return GNATCOLL.VFS.Filesystem_String;
   --  Return the ali file extension (e.g. ".ali") for the given handler

   function Get_ALI_Filename
     (Handler   : access ALI_Handler_Record;
      Base_Name : GNATCOLL.VFS.Filesystem_String)
      return GNATCOLL.VFS.Filesystem_String;
   --  Return the most likely candidate for an ALI file, given a source name

private
   type ALI_Information_Iterator
     is new Entities.LI_Information_Iterator with
      record
         Handler : ALI_Handler;
         Files   : GNATCOLL.VFS.File_Array_Access;  --  in current dir
         Current : Natural;            --  current file
         Project : GNATCOLL.Projects.Project_Type;
      end record;
end ALI_Parser;
