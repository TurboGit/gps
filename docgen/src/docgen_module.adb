-----------------------------------------------------------------------
--                               G P S                               --
--                                                                   --
--                     Copyright (C) 2003                            --
--                            ACT-Europe                             --
--                                                                   --
-- GPS is free  software; you can  redistribute it and/or modify  it --
-- under the terms of the GNU General Public License as published by --
-- the Free Software Foundation; either version 2 of the License, or --
-- (at your option) any later version.                               --
--                                                                   --
-- This program is  distributed in the hope that it will be  useful, --
-- but  WITHOUT ANY WARRANTY;  without even the  implied warranty of --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU --
-- General Public License for more details. You should have received --
-- a copy of the GNU General Public License along with this library; --
-- if not,  write to the  Free Software Foundation, Inc.,  59 Temple --
-- Place - Suite 330, Boston, MA 02111-1307, USA.                    --
-----------------------------------------------------------------------

with Glide_Kernel;             use Glide_Kernel;
with Glide_Kernel.Preferences; use Glide_Kernel.Preferences;
with Glide_Kernel.Project;     use Glide_Kernel.Project;
with Glide_Kernel.Modules;     use Glide_Kernel.Modules;
with Glide_Intl;               use Glide_Intl;
with Glib.Object;              use Glib.Object;
with VFS;                      use VFS;
with Docgen.Work_On_File;      use Docgen.Work_On_File;
with Docgen;                   use Docgen;
with Docgen.Html_Output;       use Docgen.Html_Output;
with Src_Info;                 use Src_Info;
with Traces;                   use Traces;
with Ada.Exceptions;           use Ada.Exceptions;
with Gtkada.File_Selector;     use Gtkada.File_Selector;
with Projects;                 use Projects;
with Glib;                     use Glib;
with Glib.Generic_Properties;
with Glib.Properties.Creation; use Glib.Properties.Creation;
with Gtk.Menu_Item;            use Gtk.Menu_Item;
with Gtk.Menu;                 use Gtk.Menu;
with File_Utils;               use File_Utils;
with Projects.Registry;        use Projects.Registry;
with Src_Info.Queries;         use Src_Info.Queries;
with String_Utils;             use String_Utils;

package body Docgen_Module is

   Me : constant Debug_Handle := Create ("Docgen");

   package TSFL renames Type_Source_File_List;

   package Type_Api_Doc_Properties is new
     Glib.Generic_Properties.Generic_Enumeration_Property
     ("Type_Api_Doc", Type_Api_Doc);

   --  Docgen preferences
   Type_Generated_File   : Param_Spec_Enum;
   --  Type of the generated file (html, texi...)

   Generate_Body_Files   : Param_Spec_Boolean;
   --  Create also the body documentation?

   Ignore_Some_Comments  : Param_Spec_Boolean;
   --  Ignore all comments with "--!"

   Comments_Before       : Param_Spec_Boolean;
   --  Find doc comments for entities before the entity itself

   Show_Private_Entities : Param_Spec_Boolean;
   --  Show also private entities

   Show_References       : Param_Spec_Boolean;
   --  True if the program should search for the references
   --  Adding information like "subprogram called by..."

   One_Document_File     : Param_Spec_Boolean;
   --  Used for TexInfo: True, if the project.texi file should be
   --  build and the package files should be included there later.

   Link_All_References   : Param_Spec_Boolean;
   --  Should links be created to entities whose declaration files
   --  aren't being processed

   Options : All_Options;
   --  Group all the preferences

   procedure Set_Options
     (Type_Of_File_P       : Type_Api_Doc := HTML;
      Process_Body_Files_P : Boolean := False;
      Ignorable_Comments_P : Boolean := False;
      Comments_Above_P     : Boolean := False;
      Show_Private_P       : Boolean := False;
      References_P         : Boolean := False;
      One_Doc_File_P       : Boolean := False;
      Link_All_P           : Boolean := False);
   --  Set new options or reset options
   --  ??? Need to document each parameter.

   procedure Array2List
     (Kernel : Kernel_Handle;
      Tab : in VFS.File_Array_Access;
      List : in out Type_Source_File_List.List);
   --  Create a list of files with those contained in the array

   procedure On_Preferences_Changed
     (Kernel : access GObject_Record'Class; K : Kernel_Handle);
   --  Called when the preferences have changed

   -----------------------------
   -- For the contextual menu --
   -----------------------------

   procedure Docgen_Contextual
     (Object    : access GObject_Record'Class;
      Context   : access Selection_Context'Class;
      Menu      : access Gtk.Menu.Gtk_Menu_Record'Class);
   --  Add entries to the contextual menu

   procedure Add_Doc_Menu_Project
     (Menu         : in out Gtk_Menu;
      Project      : Project_Type;
      Kernel       : access Kernel_Handle_Record'Class);
   --  Submenu for a project

   procedure On_Generate_Project
     (Kernel : access GObject_Record'Class; Data : File_Project_Record);
   --  Contextual menu : Generate Doc -> Only this project

   procedure On_Generate_Project_Recursive
     (Kernel : access GObject_Record'Class; Data : File_Project_Record);
   --  Contextual menu : Generate Doc -> this project & imported projects

   procedure On_Generate_File
     (Kernel : access GObject_Record'Class; Data : File_Project_Record);
   --  Contextual menu : Generate Doc (for a file)

   --------------------
   --  For the menu  --
   --------------------

   procedure Choose_Menu_Current_File
     (Widget : access GObject_Record'Class; Kernel : Kernel_Handle);
   --  Generate the doc for the selected file

   procedure Choose_Menu_Project
      (Widget : access GObject_Record'Class; Kernel : Kernel_Handle);
   --  In order to generate the doc of the loaded project
   --  It generates only the direct sources of the project
   --  It calls Generate_Project

   procedure Choose_Menu_Project_Recursive
     (Widget : access GObject_Record'Class; Kernel : Kernel_Handle);
   --  In order to generate the doc of the project loaded
   --  It generates the direct sources of the project and the sources
   --     from imported projects
   --  It calls Generate_Project

   procedure Generate_Project
     (Kernel    : Kernel_Handle;
      Recursive : Boolean);
   --  Generate the doc for the project
   --  If Recursive is true, it generates the direct sources of
   --  the project and also the sources from imported projects

   procedure Choose_Menu_File
      (Widget : access GObject_Record'Class; Kernel : Kernel_Handle);
   --  In order to choose a file and generate its documentation
   --  It calls Generate_File

   procedure Generate_File
     (Kernel : Kernel_Handle;
      File : Virtual_File);
   --  In order to generate the documentation of one file

   --------------------------------------------
   --  main procedure for the documentation  --
   --------------------------------------------

   procedure Generate
     (Kernel : Kernel_Handle;
      List : in out Type_Source_File_List.List);
   --  With the list of source files, it generates the documentation

   -------------------
   --  Set_Options  --
   -------------------

   procedure Set_Options
     (Type_Of_File_P       : Type_Api_Doc := HTML;
      Process_Body_Files_P : Boolean := False;
      Ignorable_Comments_P : Boolean := False;
      Comments_Above_P     : Boolean := False;
      Show_Private_P       : Boolean := False;
      References_P         : Boolean := False;
      One_Doc_File_P       : Boolean := False;
      Link_All_P           : Boolean := False)
   is
   begin
      Options.Type_Of_File := Type_Of_File_P;
      Options.Process_Body_Files := Process_Body_Files_P;
      Options.Ignorable_Comments := Ignorable_Comments_P;
      Options.Comments_Above := Comments_Above_P;
      Options.Show_Private := Show_Private_P;
      Options.References := References_P;
      Options.One_Doc_File := One_Doc_File_P;
      Options.Link_All := Link_All_P;
   end Set_Options;

   -----------------
   --  Array2List --
   -----------------

   procedure Array2List
     (Kernel : Kernel_Handle;
      Tab    : in VFS.File_Array_Access;
      List   : in out Type_Source_File_List.List)
   is
      use Type_Source_File_List;
      File : Virtual_File;
      LI   : LI_File_Ptr;
   begin
      for J in 1 .. Tab'Length loop
         File := Tab (J);

         if Is_Spec_File (Kernel, File)
           or else Options.Process_Body_Files
         then
            LI := Locate_From_Source_And_Complete (Kernel, File);
            Append
              (List,
               (File_Name        => File,
                Package_Name     => new String'(Get_Unit_Name (LI, File)),
                Other_File_Found => True));
         end if;
      end loop;
   end Array2List;

   ----------------------------
   -- On_Preferences_Changed --
   ----------------------------

   procedure On_Preferences_Changed
     (Kernel : access GObject_Record'Class; K : Kernel_Handle)
   is
      pragma Unreferenced (Kernel);
   begin
      Set_Options
        (Type_Api_Doc'Val (Get_Pref (K, Type_Generated_File)),
         Get_Pref (K, Generate_Body_Files),
         Get_Pref (K, Ignore_Some_Comments),
         Get_Pref (K, Comments_Before),
         Get_Pref (K, Show_Private_Entities),
         Get_Pref (K, Show_References),
         Get_Pref (K, One_Document_File),
         Get_Pref (K, Link_All_References));
   end On_Preferences_Changed;

   -----------------------
   -- Docgen_Contextual --
   -----------------------

   procedure Docgen_Contextual
     (Object    : access GObject_Record'Class;
      Context   : access Selection_Context'Class;
      Menu      : access Gtk.Menu.Gtk_Menu_Record'Class)
   is
      pragma Unreferenced (Object);
      Item         : Gtk_Menu_Item;
      File_Context : File_Selection_Context_Access;
      Submenu      : Gtk_Menu;
      File         : Virtual_File;

   begin
      if Context.all in File_Selection_Context'Class then
         File_Context := File_Selection_Context_Access (Context);

         if Has_Project_Information (File_Context)
           and then not Has_Directory_Information (File_Context)
           and then not Has_File_Information (File_Context)
         then
            Add_Doc_Menu_Project
              (Menu         => Submenu,
               Project      => Project_Information (File_Context),
               Kernel       => Get_Kernel (Context));

            if Submenu /= null then
               Gtk_New (Item, -"Documentation");
               Set_Submenu (Item, Submenu);
               Append (Menu, Item);
            end if;

         elsif Has_Directory_Information (File_Context)
           and then not Has_File_Information (File_Context)
         then
            null;

         elsif Has_File_Information (File_Context) then
            File := File_Information (File_Context);
            Gtk_New (Item, -"Generate doc for " & Krunch (Base_Name (File)));
            File_Project_Cb.Object_Connect
               (Item, "activate",
                File_Project_Cb.To_Marshaller (On_Generate_File'Access),
                Slot_Object => Get_Kernel (Context),
                User_Data => File_Project_Record'
                  (Project => No_Project,
                   File    => File));
            Append (Menu, Item);
         end if;
      end if;
   end Docgen_Contextual;

   --------------------------
   -- Add_Doc_Menu_Project --
   --------------------------

   procedure Add_Doc_Menu_Project
     (Menu         : in out Gtk_Menu;
      Project      : Project_Type;
      Kernel       : access Kernel_Handle_Record'Class)
   is
      pragma Unreferenced (Project);
      Mitem     : Gtk_Menu_Item;
      Mitem_Bis : Gtk_Menu_Item;

   begin
      if Menu = null then
         Gtk_New (Menu);
      end if;

      Gtk_New (Mitem, -"Generate project");
      Append (Menu, Mitem);
      Gtk_New (Mitem_Bis, -"Generate project & subprojects");
      Append (Menu, Mitem_Bis);

      File_Project_Cb.Object_Connect
        (Mitem, "activate",
         File_Project_Cb.To_Marshaller (On_Generate_Project'Access),
         Slot_Object => Kernel,
         User_Data => File_Project_Record'
           (Project => Get_Project (Kernel),
            File    => VFS.No_File));
      File_Project_Cb.Object_Connect
        (Mitem_Bis, "activate",
         File_Project_Cb.To_Marshaller (On_Generate_Project_Recursive'Access),
         Slot_Object => Kernel,
         User_Data => File_Project_Record'
           (Project => Get_Project (Kernel),
            File    => VFS.No_File));
   end Add_Doc_Menu_Project;

   -------------------------
   -- On_Generate_Project --
   -------------------------

   procedure On_Generate_Project
     (Kernel : access GObject_Record'Class; Data : File_Project_Record)
   is
      pragma Unreferenced (Data);
   begin
      Generate_Project (Kernel_Handle (Kernel), False);
   end On_Generate_Project;

   -------------------------------------
   --  On_Generate_Project_Recursive  --
   -------------------------------------

   procedure On_Generate_Project_Recursive
     (Kernel : access GObject_Record'Class; Data : File_Project_Record)
   is
   pragma Unreferenced (Data);
   begin
      Generate_Project (Kernel_Handle (Kernel), True);
   end On_Generate_Project_Recursive;


   ------------------------
   --  On_Generate_File  --
   ------------------------

   procedure On_Generate_File
     (Kernel : access GObject_Record'Class; Data : File_Project_Record)
   is
      File : Virtual_File;
   begin
      File := Data.File;
      Generate_File (Kernel_Handle (Kernel), File);
   end On_Generate_File;

   ------------------------------
   -- Choose_Menu_Current_File --
   ------------------------------

   procedure Choose_Menu_Current_File
     (Widget : access GObject_Record'Class; Kernel : Kernel_Handle)
   is
      pragma Unreferenced (Widget);
      Context : constant Selection_Context_Access :=
        Get_Current_Context (Kernel);
      File    : Virtual_File;

   begin
      if Context.all in File_Selection_Context'Class
        and then Has_File_Information (File_Selection_Context_Access (Context))
      then
         File := File_Information (File_Selection_Context_Access (Context));
         if File = VFS.No_File then
            return;
         else
            Generate_File (Kernel, File);
         end if;
      end if;
   end Choose_Menu_Current_File;

   -------------------------
   -- Choose_Menu_Project --
   -------------------------

   procedure Choose_Menu_Project
     (Widget : access GObject_Record'Class; Kernel : Kernel_Handle)
   is
      pragma Unreferenced (Widget);
   begin
      Generate_Project (Kernel, False);
   end Choose_Menu_Project;

   -----------------------------------
   -- Choose_Menu_Project_Recursive --
   -----------------------------------

   procedure Choose_Menu_Project_Recursive
     (Widget : access GObject_Record'Class; Kernel : Kernel_Handle)
   is
      pragma Unreferenced (Widget);
   begin
      Generate_Project (Kernel, True);
   end Choose_Menu_Project_Recursive;

   ----------------------
   -- Generate_Project --
   ----------------------

   procedure Generate_Project
     (Kernel    : Kernel_Handle;
      Recursive : Boolean)
   is
      Sources : VFS.File_Array_Access;
      Project : Project_Type;
      Context : constant Selection_Context_Access :=
        Get_Current_Context (Kernel);
      Source_File_List : Type_Source_File_List.List;

   begin
      --  ??? Should use the root project if current context has not
      --  project info

      if Context.all in File_Selection_Context'Class
        and then Has_Project_Information
          (File_Selection_Context_Access (Context))
      then
         Project := Project_Information
           (File_Selection_Context_Access (Context));
         Sources := Get_Source_Files (Project, Recursive);
         Array2List (Kernel, Sources, Source_File_List);
         Generate (Kernel, Source_File_List);
      end if;
   end Generate_Project;

   ----------------------
   -- Choose_Menu_File --
   ---------------------

   procedure Choose_Menu_File
    (Widget : access GObject_Record'Class; Kernel : Kernel_Handle)
   is
      pragma Unreferenced (Widget);
      File  : constant Virtual_File :=
        Select_File
          (Title             => -"Generate Documentation For",
           Parent            => Get_Main_Window (Kernel),
           Use_Native_Dialog => Get_Pref (Kernel, Use_Native_Dialogs),
           Kind              => Unspecified,
           History           => Get_History (Kernel));

   begin
      if File = VFS.No_File then
         return;
      else
         Generate_File (Kernel, File);
      end if;
   end Choose_Menu_File;

   --------------------
   --  Generate_File --
   --------------------

   procedure Generate_File
     (Kernel : Kernel_Handle;
      File   : Virtual_File)
   is
      use Type_Source_File_List;
      Source_File_List : Type_Source_File_List.List;
      LI               : LI_File_Ptr;
      Body_File        : Virtual_File;

   begin
      if not Is_Spec_File (Kernel, File)
        and then not Options.Process_Body_Files
      then
         return;
      end if;

      LI := Locate_From_Source_And_Complete (Kernel, File);
      Append
        (Source_File_List,
         (File_Name        => File,
          Package_Name     => new String'(Get_Unit_Name (LI, File)),
          Other_File_Found => True));

      if Is_Spec_File (Kernel, File)
        and then Options.Process_Body_Files
      then
         Body_File := Get_Other_File_Of (LI, File);

         if Body_File /= No_File then
            Append
              (Source_File_List,
               (File_Name        => Body_File,
                Package_Name     => new String'(Get_Unit_Name (LI, Body_File)),
                Other_File_Found => True));
         end if;
      end if;

      Generate (Kernel, Source_File_List);
   end Generate_File;

   --------------
   -- Generate --
   --------------

   procedure Generate
     (Kernel : Kernel_Handle;
      List   : in out Type_Source_File_List.List)
   is
      use Type_Source_File_List;
   begin
      Push_State (Kernel, Busy);

      --  ??? Should give a choice of the format
      Process_Files
        (List,
         Kernel,
         Options,
         Doc_Suffix => ".htm",
         Converter  => Doc_HTML_Create'Access);
      Free (List);

      --  ??? Should open the appropriate file, this one is only valid for html
      --  ??? <frameset> not supported by internal html viewer.

      declare
         Doc_Directory_Root : constant String := File_Utils.Name_As_Directory
           (Object_Path (Get_Root_Project (Get_Registry (Kernel)),
                         False)) & "index.htm";
      begin
         Open_Html (Kernel, Filename =>
                      Create (Full_Filename => Doc_Directory_Root));
      end;

      Pop_State (Kernel);

   exception
      when E : others =>
         Trace (Me, "Unexpected exception: " & Exception_Information (E));
         Pop_State (Kernel);
   end Generate;

   ---------------------
   -- Register_Module --
   ---------------------

   procedure Register_Module
     (Kernel : access Glide_Kernel.Kernel_Handle_Record'Class)
   is
      Docgen_Module_ID : Module_ID;

      Tools    : constant String := '/' & (-"Tools");
      Generate : constant String := '/' & (-"_Documentation");

   begin
      Register_Module
        (Module                  => Docgen_Module_ID,
         Kernel                  => Kernel,
         Module_Name             => "Docgen",
         Contextual_Menu_Handler => Docgen_Contextual'Access,
         Priority                => Default_Priority);

      Type_Generated_File := Param_Spec_Enum
        (Type_Api_Doc_Properties.Gnew_Enum
           (Name    => "Doc-Output",
            Default => HTML,
            Blurb   => -"Choose the kind of documentation generated",
            Nick    => -"Output"));
      Register_Property
        (Kernel, Param_Spec (Type_Generated_File), -"Documentation");

      Generate_Body_Files := Param_Spec_Boolean
        (Gnew_Boolean
          (Name    => "Doc-Process-Body",
           Default => False,
           Blurb   => -"Whether body files should be processed",
           Nick    => -"Process body files"));
      Register_Property
        (Kernel, Param_Spec (Generate_Body_Files), -"Documentation");

      Ignore_Some_Comments := Param_Spec_Boolean
        (Gnew_Boolean
          (Name    => "Doc-Ignore-Special-Comments",
           Default => False,
           Blurb   =>
             -("Whether Docgen should ignore all comments with --!"),
           Nick    => -"Ignore comments with --!"));
      Register_Property
        (Kernel,
         Param_Spec (Ignore_Some_Comments),
         -"Documentation");

      Comments_Before := Param_Spec_Boolean
        (Gnew_Boolean
          (Name    => "Doc-Comments-Before",
           Default => False,
           Blurb   =>
             -("Whether comments are found before corresponding entities"),
           Nick    => -"Comments before entities"));
      Register_Property
        (Kernel, Param_Spec (Comments_Before), -"Documentation");

      Show_Private_Entities := Param_Spec_Boolean
        (Gnew_Boolean
          (Name    => "Doc-Show-Private",
           Default => False,
           Blurb   => -"Whether Docgen should show private entities",
           Nick    => -"Show private entities"));
      Register_Property
        (Kernel,
         Param_Spec (Show_Private_Entities),
         -"Documentation");

      Show_References := Param_Spec_Boolean
        (Gnew_Boolean
          (Name    => "Doc-References",
           Default => False,
           Blurb   =>
             -("Whether Docgen should compute references (e.g. call graph)"),
           Nick    => -"Compute references"));
      Register_Property
        (Kernel, Param_Spec (Show_References), -"Documentation");

      One_Document_File := Param_Spec_Boolean
        (Gnew_Boolean
          (Name    => "Doc-Texi-Single",
           Default => False,
           Blurb   =>
             -("Whether Docgen should generate doc in one file (TexInfo"),
           Nick    => -"Single file (for TexInfo)"));
      Register_Property (Kernel, Param_Spec (One_Document_File),
                           -"Documentation");

      Link_All_References := Param_Spec_Boolean
        (Gnew_Boolean
          (Name    => "Doc-Xref-All",
           Default => False,
           Blurb   =>
             -("Links for entities declared in files which are not processed"),
           Nick    => -"Create all links"));
      Register_Property
        (Kernel,
         Param_Spec (Link_All_References),
         -"Documentation");

      Kernel_Callback.Connect
        (Kernel, Preferences_Changed_Signal,
         Kernel_Callback.To_Marshaller (On_Preferences_Changed'Access),
         Kernel_Handle (Kernel));

      On_Preferences_Changed (Kernel, Kernel_Handle (Kernel));

      Register_Menu
        (Kernel,
         Tools & Generate,
         -"Generate _project",
         Callback => Choose_Menu_Project'Access);

      Register_Menu
        (Kernel,
         Tools & Generate,
         -"Generate project & _subprojects",
         Callback => Choose_Menu_Project_Recursive'Access);

      Register_Menu
        (Kernel,
         Tools & Generate,
         -"Generate _current file",
         Callback => Choose_Menu_Current_File'Access);

      Register_Menu
        (Kernel,
         Tools & Generate,
         -"Generate _for ...",
         Callback => Choose_Menu_File'Access);
   end Register_Module;

end Docgen_Module;
