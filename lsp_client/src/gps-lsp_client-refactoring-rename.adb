------------------------------------------------------------------------------
--                               GNAT Studio                                --
--                                                                          --
--                       Copyright (C) 2019-2020, AdaCore                   --
--                                                                          --
-- This is free software;  you can redistribute it  and/or modify it  under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  This software is distributed in the hope  that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License for  more details.  You should have  received  a copy of the GNU --
-- General  Public  License  distributed  with  this  software;   see  file --
-- COPYING3.  If not, go to http://www.gnu.org/licenses for a complete copy --
-- of the license.                                                          --
------------------------------------------------------------------------------

with Ada.Strings.Unbounded;         use Ada.Strings.Unbounded;

with GNATCOLL.Traces;               use GNATCOLL.Traces;
with GNATCOLL.VFS;                  use GNATCOLL.VFS;

with Glib;                          use Glib;
with Gtk.Box;                       use Gtk.Box;
with Gtk.Check_Button;              use Gtk.Check_Button;
with Gtk.Dialog;                    use Gtk.Dialog;
with Gtk.GEntry;                    use Gtk.GEntry;
with Gtk.Stock;                     use Gtk.Stock;
with Gtk.Widget;                    use Gtk.Widget;

with Dialog_Utils;                  use Dialog_Utils;
with GPS.Dialogs;                   use GPS.Dialogs;
with GPS.Editors;                   use GPS.Editors;
with GPS.Kernel.Actions;            use GPS.Kernel.Actions;
with GPS.Kernel.Contexts;           use GPS.Kernel.Contexts;
with GPS.Kernel.MDI;                use GPS.Kernel.MDI;
with GPS.Kernel.Modules.UI;         use GPS.Kernel.Modules.UI;
with GPS.Main_Window;               use GPS.Main_Window;

with Basic_Types;
with Commands;                      use Commands;
with Commands.Interactive;          use Commands.Interactive;
with Histories;                     use Histories;
with Language;

with Refactoring.Rename;
with Src_Editor_Module.Shell;

with GPS.LSP_Module;
with GPS.LSP_Client.Edit_Workspace;
with GPS.LSP_Client.Requests.Rename;
with GPS.LSP_Client.Configurations;
with LSP.Messages;
with LSP.Types;

package body GPS.LSP_Client.Refactoring.Rename is

   Me : constant Trace_Handle := Create ("GPS.REFACTORING.LSP_RENAME");

   Refactoring_Module : GPS.Kernel.Modules.Module_ID;

   type Rename_Entity_Command is new Interactive_Command with null record;
   overriding function Execute
     (Command : access Rename_Entity_Command;
      Context : Interactive_Command_Context) return Command_Return_Type;
   --  Called for "Rename Entity" menu

   -- Rename_Request --

   type Rename_Request is
     new GPS.LSP_Client.Requests.Rename.Abstract_Rename_Request with
      record
         Kernel        : Kernel_Handle;
         Old_Name      : Unbounded_String;
         Make_Writable : Boolean;
         Auto_Save     : Boolean;
      end record;
   type Rename_Request_Access is access all Rename_Request;
   --  Used for communicate with LSP

   overriding procedure On_Result_Message
     (Self   : in out Rename_Request;
      Result : LSP.Messages.WorkspaceEdit);

   -- Entity_Renaming_Dialog_Record --

   type Entity_Renaming_Dialog_Record is new GPS_Dialog_Record with record
      New_Name          : Gtk_GEntry;
      Auto_Save         : Gtk_Check_Button;
      Make_Writable     : Gtk_Check_Button;
      In_Comments       : Gtk_Check_Button;
   end record;
   type Entity_Renaming_Dialog is access all
     Entity_Renaming_Dialog_Record'Class;

   procedure Gtk_New
     (Dialog        : out Entity_Renaming_Dialog;
      Kernel        : access Kernel_Handle_Record'Class;
      Entity        : String;
      With_Comments : Boolean);
   --  Create a new dialog for renaming entities

   procedure Refactoring_Rename_Procedure
     (Kernel             : Kernel_Handle;
      File               : GNATCOLL.VFS.Virtual_File;
      Line               : Integer;
      Column             : Basic_Types.Visible_Column_Type;
      Name               : String;
      New_Name           : String;
      Make_Writable      : Boolean;
      Auto_Save          : Boolean;
      Rename_In_Comments : Boolean);

   Auto_Save_Hist         : constant History_Key := "refactor_auto_save";
   Make_Writable_Hist     : constant History_Key := "refactor_make_writable";
   In_Comments_Hist       : constant History_Key := "refactor_rename_comments";

   procedure Set_Rename_In_Comments_Option
     (Lang  : Language.Language_Access;
      Value : Boolean);
   --  Set server configuration option

   function LSP_Renaming_Enabled
     (Lang : Language.Language_Access)
      return Boolean;
   --  Check whether LSP renaming is enabled

   -------------
   -- Gtk_New --
   -------------

   procedure Gtk_New
     (Dialog        : out Entity_Renaming_Dialog;
      Kernel        : access Kernel_Handle_Record'Class;
      Entity        : String;
      With_Comments : Boolean)
   is
      Box       : Gtk_Box;
      Button    : Gtk_Widget;
      Main_View : Dialog_View;
      Group     : Dialog_Group_Widget;
      pragma Unreferenced (Button);
   begin
      Dialog := new Entity_Renaming_Dialog_Record;
      GPS.Dialogs.Initialize
        (Dialog,
         Title  => "Renaming entity",
         Kernel => Kernel);
      Set_Default_Size_From_History
        (Win    => Dialog,
         Name   => "Renaming entity",
         Kernel => Kernel,
         Width  => 400,
         Height => 300);

      Main_View := new Dialog_View_Record;
      Dialog_Utils.Initialize (Main_View);
      Dialog.Get_Content_Area.Pack_Start (Main_View);

      Group := new Dialog_Group_Widget_Record;
      Dialog_Utils.Initialize
        (Self        => Group,
         Parent_View => Main_View,
         Group_Name  => "Renaming " & Entity);

      Gtk_New_Hbox (Box);
      Pack_Start (Get_Content_Area (Dialog), Box, Expand => False);

      Gtk_New (Dialog.New_Name);
      Dialog.New_Name.Set_Name ("new_name");
      Set_Text (Dialog.New_Name, Entity);
      Select_Region (Dialog.New_Name, 0, -1);
      Set_Activates_Default (Dialog.New_Name, True);

      Group.Create_Child
        (Widget => Dialog.New_Name,
         Label  => "New name:");

      Group := new Dialog_Group_Widget_Record;
      Dialog_Utils.Initialize
        (Self        => Group,
         Parent_View => Main_View,
         Group_Name  => "Options");

      Gtk_New (Dialog.Auto_Save, "Automatically save modified files");
      Associate (Get_History (Kernel).all, Auto_Save_Hist, Dialog.Auto_Save);
      Group.Create_Child (Dialog.Auto_Save);

      Gtk_New (Dialog.Make_Writable, "Make files writable");
      Set_Tooltip_Text
        (Dialog.Make_Writable,
         "If a read-only file contains references to the entity, this"
         & " switch will make the file writable so that changes can be made."
         & " If the switch is off, then the file will not be edited, but the"
         & " renaming will only be partial.");
      Create_New_Boolean_Key_If_Necessary
        (Hist          => Get_History (Kernel).all,
         Key           => Make_Writable_Hist,
         Default_Value => True);
      Associate (Get_History (Kernel).all,
                 Make_Writable_Hist,
                 Dialog.Make_Writable);
      Group.Create_Child (Widget => Dialog.Make_Writable);

      if With_Comments then
         Gtk_New (Dialog.In_Comments, "Rename in comments");
         Set_Tooltip_Text
           (Dialog.In_Comments,
            "Also rename entities in all comments.");
         Create_New_Boolean_Key_If_Necessary
           (Hist          => Get_History (Kernel).all,
            Key           => In_Comments_Hist,
            Default_Value => False);
         Associate (Get_History (Kernel).all,
                    In_Comments_Hist,
                    Dialog.In_Comments);
         Group.Create_Child (Widget => Dialog.In_Comments);
      end if;

      Grab_Default (Add_Button (Dialog, Stock_Ok, Gtk_Response_OK));
      Button := Add_Button (Dialog, Stock_Cancel, Gtk_Response_Cancel);
   end Gtk_New;

   -------------
   -- Execute --
   -------------

   overriding function Execute
     (Command : access Rename_Entity_Command;
      Context : Interactive_Command_Context) return Command_Return_Type
   is
      pragma Unreferenced (Command);

      Kernel      : constant Kernel_Handle := Get_Kernel (Context.Context);
      Entity      : constant String := Entity_Name_Information
        (Context.Context);
      Dialog      : Entity_Renaming_Dialog;
      Lang        : constant Language.Language_Access :=
        Kernel.Get_Language_Handler.Get_Language_From_File
          (File_Information (Context.Context));
      LSP_Enabled : constant Boolean := LSP_Renaming_Enabled (Lang);

   begin
      if Entity /= "" then
         Gtk_New
           (Dialog        => Dialog,
            Kernel        => Get_Kernel (Context.Context),
            Entity        => Entity,
            With_Comments => LSP_Enabled
            and then GPS.LSP_Module.Get_Language_Server
              (Lang).Is_Configuration_Supported
                (GPS.LSP_Client.Configurations.Rename_In_Comments));

         if Dialog = null then
            return Failure;
         end if;

         Show_All (Dialog);

         if Run (Dialog) = Gtk_Response_OK then
            if LSP_Enabled then
               declare
                  Request : Rename_Request_Access := new Rename_Request;
               begin
                  Request.Kernel        := Kernel;
                  Request.Text_Document := File_Information (Context.Context);
                  Request.Line          := Line_Information
                    (Context.Context);
                  Request.Column        := Column_Information
                    (Context.Context);
                  Request.New_Name      := LSP.Types.To_LSP_String
                    (Get_Text (Dialog.New_Name));
                  Request.Old_Name      := To_Unbounded_String (Entity);
                  Request.Make_Writable := Get_Active (Dialog.Make_Writable);
                  Request.Auto_Save     := Get_Active (Dialog.Auto_Save);

                  if Dialog.In_Comments /= null then
                     Set_Rename_In_Comments_Option
                       (Lang, Get_Active (Dialog.In_Comments));
                  end if;

                  GPS.LSP_Client.Requests.Execute
                    (Lang, GPS.LSP_Client.Requests.Request_Access (Request));
               end;

            else
               --  Call old implementation
               Standard.Refactoring.Rename.Rename
                 (Kernel, Context,
                  Old_Name      => To_Unbounded_String (Entity),
                  New_Name      => To_Unbounded_String
                    (Get_Text (Dialog.New_Name)),
                  Auto_Save     => Get_Active (Dialog.Auto_Save),
                  Overridden    => True,
                  Make_Writable => Get_Active (Dialog.Make_Writable));
            end if;
         end if;

         Destroy (Dialog);
      end if;

      return Success;

   exception
      when E : others =>
         Trace (Me, E);
         Destroy (Dialog);
         return Failure;
   end Execute;

   --------------------------
   -- LSP_Renaming_Enabled --
   --------------------------

   function LSP_Renaming_Enabled
     (Lang : Language.Language_Access)
      return Boolean
   is
      use type Language.Language_Access;
   begin
      if Lang /= null
        and then GPS.LSP_Module.LSP_Is_Enabled (Lang)
      then
         return GPS.LSP_Module.Get_Language_Server
           (Lang).Get_Client.Capabilities.renameProvider.Is_Set;

      else
         return False;
      end if;
   end LSP_Renaming_Enabled;

   -----------------------
   -- On_Result_Message --
   -----------------------

   overriding procedure On_Result_Message
     (Self   : in out Rename_Request;
      Result : LSP.Messages.WorkspaceEdit)
   is
      On_Error : Boolean with Unreferenced;
   begin
      GPS.LSP_Client.Edit_Workspace.Edit
        (Self.Kernel, Result,
         "Refactoring - rename " & To_String (Self.Old_Name) & " to ",
         Self.Make_Writable, Self.Auto_Save, True, On_Error);

   exception
      when E : others =>
         Trace (Me, E);
   end On_Result_Message;

   ----------------------------------
   -- Refactoring_Rename_Procedure --
   ----------------------------------

   procedure Refactoring_Rename_Procedure
     (Kernel             : Kernel_Handle;
      File               : GNATCOLL.VFS.Virtual_File;
      Line               : Integer;
      Column             : Basic_Types.Visible_Column_Type;
      Name               : String;
      New_Name           : String;
      Make_Writable      : Boolean;
      Auto_Save          : Boolean;
      Rename_In_Comments : Boolean)
   is
      Lang : constant Language.Language_Access :=
        Kernel.Get_Language_Handler.Get_Language_From_File (File);
   begin
      if LSP_Renaming_Enabled (Lang) then
         declare
            Request : Rename_Request_Access := new Rename_Request;
         begin
            Request.Kernel        := Kernel;
            Request.Text_Document := File;
            Request.Line          := Line;
            Request.Column        := Column;
            Request.New_Name      := LSP.Types.To_LSP_String (New_Name);
            Request.Old_Name      := To_Unbounded_String (Name);
            Request.Make_Writable := Make_Writable;
            Request.Auto_Save     := Auto_Save;

            Set_Rename_In_Comments_Option (Lang, Rename_In_Comments);

            GPS.LSP_Client.Requests.Execute
              (Lang, GPS.LSP_Client.Requests.Request_Access (Request));
         end;

      else
         --  Call old implementation
         declare
            Context     : Selection_Context := New_Context
              (Kernel, Refactoring_Module);
            Interactive : Interactive_Command_Context :=
              Create_Null_Context (Context);

         begin
            Set_File_Information
              (Context,
               Files           => (1 => File),
               Project         => Kernel.Get_Project_Tree.Root_Project,
               Publish_Project => False,
               Line            => Line,
               Column          => Column);

            Set_Entity_Information
              (Context,
               Name,
               Basic_Types.Editable_Line_Type (Line),
               Column);

            Standard.Refactoring.Rename.Rename
              (Kernel,
               Interactive,
               Old_Name      => To_Unbounded_String (Name),
               New_Name      => To_Unbounded_String (New_Name),
               Auto_Save     => Auto_Save,
               Overridden    => True,
               Make_Writable => Make_Writable);

            Free (Interactive);
         end;
      end if;

   exception
      when E : others =>
         Trace (Me, E);
   end Refactoring_Rename_Procedure;

   -----------------------------------
   -- Set_Rename_In_Comments_Option --
   -----------------------------------

   procedure Set_Rename_In_Comments_Option
     (Lang  : Language.Language_Access;
      Value : Boolean)
   is
      use GPS.LSP_Client.Configurations;
   begin
      GPS.LSP_Module.Get_Language_Server (Lang).Set_Configuration
        (Rename_In_Comments,
         Configuration_Value'(Kind => Boolean_Type, vBoolean => Value));
   end Set_Rename_In_Comments_Option;

   --------------
   -- Register --
   --------------

   procedure Register
     (Kernel : Kernel_Handle;
      Id     : GPS.Kernel.Modules.Module_ID) is
   begin
      Refactoring_Module := Id;

      Src_Editor_Module.Shell.Refactoring_Rename_Handler :=
        Refactoring_Rename_Procedure'Access;

      Register_Contextual_Submenu
        (Kernel,
         Name  => "Refactoring",
         Group => Editing_Contextual_Group);

      Register_Action
        (Kernel, "rename entity",
         Command      => new Rename_Entity_Command,
         Description  => "Rename an entity, including its references",
         Category     => "Refactoring",
         Filter       => Lookup_Filter (Kernel, "Entity"),
         For_Learning => True);

      Register_Contextual_Menu
        (Kernel,
         Label  => "Refactoring/Rename %s",
         Action => "rename entity",
         Group  => Editing_Contextual_Group);
   end Register;

end GPS.LSP_Client.Refactoring.Rename;
