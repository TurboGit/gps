-----------------------------------------------------------------------
--                 Odd - The Other Display Debugger                  --
--                                                                   --
--                         Copyright (C) 2000                        --
--                 Emmanuel Briot and Arnaud Charlet                 --
--                                                                   --
-- Odd is free  software;  you can redistribute it and/or modify  it --
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

with Gtk.Window; use Gtk.Window;
with Gtk.Box; use Gtk.Box;
with Gtk.Menu_Bar; use Gtk.Menu_Bar;
with Gtk.Menu_Item; use Gtk.Menu_Item;
with Gtk.Menu; use Gtk.Menu;
with Gtk.Widget; use Gtk.Widget;
with Gtk.Frame; use Gtk.Frame;
with Gtk.Notebook; use Gtk.Notebook;
with Odd.Status_Bar; use Odd.Status_Bar;
with Odd_Preferences_Pkg; use Odd_Preferences_Pkg;
with Open_Program_Pkg; use Open_Program_Pkg;
with Open_Session_Pkg; use Open_Session_Pkg;
with Odd.Dialogs; use Odd.Dialogs;
with Gtkada.Toolbar; use Gtkada.Toolbar;
with GNAT.OS_Lib; use GNAT.OS_Lib;
with Odd.Types;
with Odd.Histories;
with Debugger;

package Main_Debug_Window_Pkg is

   type History_Data is record
      Mode         : Debugger.Command_Type;
      Debugger_Num : Natural;
      Command      : String_Access;
   end record;

   type Debugger_List_Node;
   type Debugger_List_Link is access Debugger_List_Node;

   type Debugger_List_Node is record
      Debugger : Gtk_Widget;
      Next     : Debugger_List_Link;
   end record;

   package String_History is new Odd.Histories (History_Data);
   use String_History;

   type Cache_List_Record is private;
   type Cache_List is access Cache_List_Record;
   --  Implement caches for the files that can be loaded in the application.

   type Main_Debug_Window_Record is new Gtk_Window_Record with record
      -----------------------
      -- Additional fields --
      -----------------------

      Odd_Preferences     : Odd_Preferences_Access;
      Open_Program        : Open_Program_Access;
      Open_Session        : Open_Session_Access;
      Task_Dialog         : Task_Dialog_Access;
      Backtrace_Dialog    : Backtrace_Dialog_Access;
      Breakpoints_Editor  : Gtk.Window.Gtk_Window;
      Log_File            : File_Descriptor := Standerr;
      TTY_Mode            : Boolean := False;
      Debug_Mode          : Boolean := False;

      File_Caches         : Cache_List;
      --  List of data cached for each of the file of the application

      Command_History : String_History.History_List;
      --  The history of commands for the current session.

      Sessions_Dir        : String_Access;
      --  The directory containing session files.

      First_Debugger      : Debugger_List_Link;
      --  The pointer to the list of debuggers.

      -------------------------

      Vbox1 : Gtk_Vbox;
      Menubar1 : Gtk_Menu_Bar;
      File1 : Gtk_Menu_Item;
      File1_Menu : Gtk_Menu;
      Open_Program1 : Gtk_Menu_Item;
      Open_Debugger1 : Gtk_Menu_Item;
      Open_Recent1 : Gtk_Menu_Item;
      Open_Core_Dump1 : Gtk_Menu_Item;
      Separator0 : Gtk_Menu_Item;
      Edit_Source1 : Gtk_Menu_Item;
      Reload_Source1 : Gtk_Menu_Item;
      Separator1 : Gtk_Menu_Item;
      Open_Session1 : Gtk_Menu_Item;
      Save_Session_As1 : Gtk_Menu_Item;
      Separator2 : Gtk_Menu_Item;
      Attach_To_Process1 : Gtk_Menu_Item;
      Detach_Process1 : Gtk_Menu_Item;
      Separator3 : Gtk_Menu_Item;
      Change_Directory1 : Gtk_Menu_Item;
      Separator4 : Gtk_Menu_Item;
      Restart1 : Gtk_Menu_Item;
      Exit1 : Gtk_Menu_Item;
      Edit2 : Gtk_Menu_Item;
      Edit2_Menu : Gtk_Menu;
      Undo3 : Gtk_Menu_Item;
      Redo1 : Gtk_Menu_Item;
      Separator5 : Gtk_Menu_Item;
      Cut1 : Gtk_Menu_Item;
      Copy1 : Gtk_Menu_Item;
      Paste1 : Gtk_Menu_Item;
      Select_All1 : Gtk_Menu_Item;
      Separator6 : Gtk_Menu_Item;
      Search1 : Gtk_Menu_Item;
      Separator7 : Gtk_Menu_Item;
      Preferences1 : Gtk_Menu_Item;
      Gdb_Settings1 : Gtk_Menu_Item;
      Program1 : Gtk_Menu_Item;
      Program1_Menu : Gtk_Menu;
      Run1 : Gtk_Menu_Item;
      Separator10 : Gtk_Menu_Item;
      Step1 : Gtk_Menu_Item;
      Step_Instruction1 : Gtk_Menu_Item;
      Next1 : Gtk_Menu_Item;
      Next_Instruction1 : Gtk_Menu_Item;
      Finish1 : Gtk_Menu_Item;
      Separator12 : Gtk_Menu_Item;
      Continue1 : Gtk_Menu_Item;
      Continue_Without_Signal1 : Gtk_Menu_Item;
      Separator13 : Gtk_Menu_Item;
      Kill1 : Gtk_Menu_Item;
      Interrupt1 : Gtk_Menu_Item;
      Abort1 : Gtk_Menu_Item;
      Command1 : Gtk_Menu_Item;
      Command1_Menu : Gtk_Menu;
      Command_History1 : Gtk_Menu_Item;
      Clear_Window1 : Gtk_Menu_Item;
      Separator14 : Gtk_Menu_Item;
      Define_Command1 : Gtk_Menu_Item;
      Edit_Buttons1 : Gtk_Menu_Item;
      Data1 : Gtk_Menu_Item;
      Data1_Menu : Gtk_Menu;
      Backtrace1 : Gtk_Menu_Item;
      Threads1 : Gtk_Menu_Item;
      Processes1 : Gtk_Menu_Item;
      Signals1 : Gtk_Menu_Item;
      Separator17 : Gtk_Menu_Item;
      Edit_Breakpoints1 : Gtk_Menu_Item;
      Edit_Displays1 : Gtk_Menu_Item;
      Examine_Memory1 : Gtk_Menu_Item;
      Separator24 : Gtk_Menu_Item;
      Display_Local_Variables1 : Gtk_Menu_Item;
      Display_Arguments1 : Gtk_Menu_Item;
      Display_Registers1 : Gtk_Menu_Item;
      Display_Expression1 : Gtk_Menu_Item;
      More_Status_Display1 : Gtk_Menu_Item;
      Separator27 : Gtk_Menu_Item;
      Refresh1 : Gtk_Menu_Item;
      Help1 : Gtk_Menu_Item;
      Help1_Menu : Gtk_Menu;
      Overview1 : Gtk_Menu_Item;
      On_Item1 : Gtk_Menu_Item;
      Separator29 : Gtk_Menu_Item;
      What_Now_1 : Gtk_Menu_Item;
      Tip_Of_The_Day1 : Gtk_Menu_Item;
      Separator30 : Gtk_Menu_Item;
      About_Odd1 : Gtk_Menu_Item;
      Toolbar2 : Gtkada_Toolbar;
      Button49 : Gtk_Widget;
      Button50 : Gtk_Widget;
      Button52 : Gtk_Widget;
      Button53 : Gtk_Widget;
      Button54 : Gtk_Widget;
      Button55 : Gtk_Widget;
      Button58 : Gtk_Widget;
      Button60 : Gtk_Widget;
      Button57 : Gtk_Widget;
      Button51 : Gtk_Widget;
      Button61 : Gtk_Widget;
      Frame7 : Gtk_Frame;
      Process_Notebook : Gtk_Notebook;
      Statusbar1 : Odd_Status_Bar;
   end record;
   type Main_Debug_Window_Access is access all Main_Debug_Window_Record'Class;

   procedure Gtk_New (Main_Debug_Window : out Main_Debug_Window_Access);
   procedure Initialize
     (Main_Debug_Window : access Main_Debug_Window_Record'Class);

   function Find_In_Cache
     (Window    : access Main_Debug_Window_Record'Class;
      File_Name : String) return Odd.Types.File_Cache_Access;
   --  Return the cached data for a given file.
   --  If no data was previously cached for that file, then a new File_Cache
   --  is returned.

   procedure Update_External_Dialogs
     (Window : access Main_Debug_Window_Record'Class;
      Debugger : Gtk.Widget.Gtk_Widget := null);
   --  Update the contents of all the dialogs associated with the window
   --  (backtrace, threads, ...) if they are visible.
   --  Their contents is updated based on the current debugger, unless
   --  Debugger is not null.

private

   type Cache_List_Record is record
      File_Name : Odd.Types.String_Access;
      Cache     : Odd.Types.File_Cache_Access;
      Next      : Cache_List;
   end record;
end Main_Debug_Window_Pkg;
