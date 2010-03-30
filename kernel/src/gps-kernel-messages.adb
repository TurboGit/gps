-----------------------------------------------------------------------
--                               G P S                               --
--                                                                   --
--                 Copyright (C) 2009-2010, AdaCore                  --
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

with Ada.Strings.Fixed.Hash;
with Ada.Unchecked_Conversion;

with Glib.Convert;

with GPS.Kernel.Hooks;
with GPS.Kernel.Messages.Classic_Models;
with GPS.Kernel.Messages.Hyperlink;
with GPS.Kernel.Messages.Markup;
with GPS.Kernel.Messages.Simple;
with GPS.Kernel.Messages.View;
with GPS.Kernel.Project;
with Traces;
with XML_Parsers;
with XML_Utils;

package body GPS.Kernel.Messages is

   use Ada;
   use Ada.Containers;
   use Ada.Strings;
   use Ada.Strings.Fixed;
   use Ada.Strings.Unbounded;
   use Ada.Tags;
   use Basic_Types;
   use Category_Maps;
   use File_Maps;
   use GPS.Editors;
   use GPS.Kernel.Hooks;
   use GPS.Kernel.Project;
   use GPS.Kernel.Styles;
   use Listener_Vectors;
   use Model_Vectors;
   use Node_Vectors;
   use Projects;
   use Sort_Order_Hint_Maps;
   use Traces;
   use XML_Parsers;
   use XML_Utils;

   Messages_File_Name : constant Filesystem_String := "messages.xml";

   type Project_Changed_Hook_Record is new Function_No_Args with null record;

   type Project_Changed_Hook_Access is
     access all Project_Changed_Hook_Record'Class;

   overriding procedure Execute
     (Self   : Project_Changed_Hook_Record;
      Kernel : access Kernel_Handle_Record'Class);
   --  Clears messages container and load data for opened project.

   package Notifiers is

      procedure Notify_Listeners_About_Category_Added
        (Self     : not null access constant Messages_Container'Class;
         Category : Ada.Strings.Unbounded.Unbounded_String);
      --  Calls listeners to notify about add of the category

      procedure Notify_Listeners_About_File_Added
        (Self     : not null access constant Messages_Container'Class;
         Category : Ada.Strings.Unbounded.Unbounded_String;
         File     : GNATCOLL.VFS.Virtual_File);
      --  Calls listeners to notify about add of the file

      procedure Notify_Listeners_About_File_Removed
        (Self     : not null access constant Messages_Container'Class;
         Category : Ada.Strings.Unbounded.Unbounded_String;
         File     : GNATCOLL.VFS.Virtual_File);
      --  Calls listeners to notify about remove of the file

      procedure Notify_Listeners_About_Message_Added
        (Self    : not null access constant Messages_Container'Class;
         Message : not null access Abstract_Message'Class);
      --  Calls listeners to notify about add of message

      procedure Notify_Listeners_About_Message_Property_Changed
        (Self     : not null access constant Messages_Container'Class;
         Message  : not null access Abstract_Message'Class;
         Property : String);
      --  Calls listeners to notify about change of message's property

      procedure Notify_Listeners_About_Message_Removed
        (Self    : not null access constant Messages_Container'Class;
         Message : not null access Abstract_Message'Class);
      --  Calls listeners to notify about remove of message

      procedure Notify_Models_About_Category_Added
        (Self : not null access constant Messages_Container'Class;
         Node : not null access Node_Record'Class);
      --  Calls models to notify about add of the category

      procedure Notify_Models_About_File_Added
        (Self : not null access constant Messages_Container'Class;
         Node : not null access Node_Record'Class);
      --  Calls models to notify about add of the file

      procedure Notify_Models_About_File_Removed
        (Self   : not null access constant Messages_Container'Class;
         Parent : not null access Node_Record'Class;
         Index  : Positive);
      --  Calls models to notify about remove of the file

      procedure Notify_Models_About_Message_Added
        (Self    : not null access constant Messages_Container'Class;
         Message : not null access Abstract_Message'Class);
      --  Calls models to notify about add of the message

      procedure Notify_Models_About_Message_Property_Changed
        (Self    : not null access constant Messages_Container'Class;
         Message : not null access Abstract_Message'Class);
      --  Calls models to notify about change of message's property

      procedure Notify_Models_About_Message_Removed
        (Self   : not null access constant Messages_Container'Class;
         Parent : not null access Node_Record'Class;
         Index  : Positive);
      --  Calls models to notify about remove of the message

   end Notifiers;

   procedure Remove_Category
     (Self              : not null access Messages_Container'Class;
      Category_Position : in out Category_Maps.Cursor;
      Category_Index    : Positive;
      Category_Node     : in out Node_Access);
   --  Removes specified category and all underling entities

   procedure Remove_File
     (Self          : not null access Messages_Container'Class;
      File_Position : in out File_Maps.Cursor;
      File_Index    : Positive;
      File_Node     : in out Node_Access;
      Recursive     : Boolean);
   --  Removes specified file and all underling entities. Removes category
   --  when it doesn't have items and resursive destruction is allowed.

   procedure Remove_Message
     (Self      : not null access Messages_Container'Class;
      Message   : in out Message_Access;
      Recursive : Boolean);
   --  Removes specified message, all secondary messages. Removes enclosing
   --  file and category when they don't have other items and recursive
   --  destruction is allowed.

   procedure Increment_Message_Counters
     (Self : not null access Abstract_Message'Class);
   --  Increments messages counters on parent nodes

   procedure Decrement_Message_Counters
     (Self : not null access Abstract_Message'Class);
   --  Decrements messages counters on parent nodes

   function Get_Container
     (Self : not null access constant Abstract_Message'Class)
      return not null Messages_Container_Access;

   procedure Load (Self : not null access Messages_Container'Class);
   --  Loads all messages for the current project

   function To_Address is
     new Unchecked_Conversion (Messages_Container_Access, System.Address);
   function To_Messages_Container_Access is
     new Unchecked_Conversion (System.Address, Messages_Container_Access);

   procedure Free is
     new Ada.Unchecked_Deallocation
       (GPS.Editors.Line_Information_Record, Action_Item);

   procedure Free is
     new Ada.Unchecked_Deallocation (Node_Record'Class, Node_Access);

   -------------------------------
   -- Create_Messages_Container --
   -------------------------------

   function Create_Messages_Container
     (Kernel : not null access Kernel_Handle_Record'Class)
      return System.Address
   is
      use GPS.Kernel.Messages.Classic_Models;

      Result : constant Messages_Container_Access :=
                 new Messages_Container (Kernel);
      Model  : Classic_Tree_Model;
      Hook   : Project_Changed_Hook_Access;

   begin
      --  Creates Gtk+ model

      Gtk_New (Model, Result);
      Result.Models.Append (Messages_Model_Access (Model));

      --  Register simple message load/save procedures

      GPS.Kernel.Messages.Simple.Register (Result);
      GPS.Kernel.Messages.Hyperlink.Register (Result);
      GPS.Kernel.Messages.Markup.Register (Result);

      --  Setup "project_changed" hook

      Hook := new Project_Changed_Hook_Record;
      Add_Hook
        (Kernel,
         Project_Changed_Hook,
         Hook,
         "messages_container.project_changed");

      return To_Address (Result);
   end Create_Messages_Container;

   --------------------------------
   -- Decrement_Message_Counters --
   --------------------------------

   procedure Decrement_Message_Counters
     (Self : not null access Abstract_Message'Class)
   is
      Node : Node_Access := Self.Parent;

   begin
      while Node /= null loop
         Node.Message_Count := Node.Message_Count - 1;
         Node := Node.Parent;
      end loop;
   end Decrement_Message_Counters;

   -------------
   -- Execute --
   -------------

   overriding procedure Execute
     (Self   : Project_Changed_Hook_Record;
      Kernel : access Kernel_Handle_Record'Class)
   is
      pragma Unreferenced (Self);

      Container : constant Messages_Container_Access :=
                    Get_Messages_Container (Kernel);

   begin
      --  Save messages for previous project

      Container.Save;
      Container.Remove_All_Messages;

      --  Load messages for opened project

      GPS.Kernel.Messages.View.Do_Not_Goto_First_Location (Kernel);
      Container.Project_File := Get_Project (Kernel).Project_Path;
      Container.Load;
   end Execute;

   --------------
   -- Finalize --
   --------------

   procedure Finalize (Self : not null access Abstract_Message) is

      procedure Free is
        new Ada.Unchecked_Deallocation (Editor_Mark'Class, Editor_Mark_Access);

   begin
      Self.Mark.Delete;
      Free (Self.Mark);
      Free (Self.Action);
   end Finalize;

   -----------------------------
   -- Free_Messages_Container --
   -----------------------------

   procedure Free_Messages_Container
     (Kernel : not null access Kernel_Handle_Record'Class)
   is

      procedure Free is
        new Ada.Unchecked_Deallocation
          (Messages_Container'Class, Messages_Container_Access);

      Container : Messages_Container_Access := Get_Messages_Container (Kernel);

   begin
      Container.Remove_All_Messages;

      while not Container.Models.Is_Empty loop
         Container.Models.Last_Element.Unref;
         Container.Models.Delete_Last;
      end loop;

      Free (Container);
   end Free_Messages_Container;

   ----------------
   -- Get_Action --
   ----------------

   function Get_Action
     (Self : not null access constant Abstract_Message'Class)
      return Action_Item is
   begin
      return Self.Action;
   end Get_Action;

   --------------------
   -- Get_Categories --
   --------------------

   function Get_Categories
     (Self : not null access constant Messages_Container'Class)
      return Unbounded_String_Array
   is
      Result : Unbounded_String_Array (1 .. Natural (Self.Categories.Length));

   begin
      for J in Result'Range loop
         Result (J) := Self.Categories.Element (J).Name;
      end loop;

      return Result;
   end Get_Categories;

   ------------------
   -- Get_Category --
   ------------------

   function Get_Category
     (Self : not null access constant Abstract_Message'Class) return String is
   begin
      return To_String (Self.Get_Category);
   end Get_Category;

   ------------------
   -- Get_Category --
   ------------------

   function Get_Category
     (Self : not null access constant Abstract_Message'Class)
      return Ada.Strings.Unbounded.Unbounded_String is
   begin
      case Self.Level is
         when Primary =>
            return Self.Parent.Parent.Name;

         when Secondary =>
            return Abstract_Message'Class (Self.Parent.all).Get_Category;
      end case;
   end Get_Category;

   ----------------------------
   -- Get_Classic_Tree_Model --
   ----------------------------

   function Get_Classic_Tree_Model
     (Self : not null access constant Messages_Container'Class)
      return Gtk.Tree_Model.Gtk_Tree_Model is
   begin
      return Gtk.Tree_Model.Gtk_Tree_Model (Self.Models.First_Element);
   end Get_Classic_Tree_Model;

   ----------------
   -- Get_Column --
   ----------------

   function Get_Column
     (Self : not null access constant Abstract_Message'Class)
      return Basic_Types.Visible_Column_Type is
   begin
      return Self.Column;
   end Get_Column;

   -------------------
   -- Get_Container --
   -------------------

   function Get_Container
     (Self : not null access constant Abstract_Message'Class)
      return not null Messages_Container_Access is
   begin
      case Self.Level is
         when Primary =>
            return Self.Parent.Parent.Container;

         when Secondary =>
            return Abstract_Message'Class (Self.Parent.all).Get_Container;
      end case;
   end Get_Container;

   ---------------------
   -- Get_Editor_Mark --
   ---------------------

   function Get_Editor_Mark
     (Self : not null access constant Abstract_Message'Class)
      return GPS.Editors.Editor_Mark'Class is
   begin
      return Self.Mark.all;
   end Get_Editor_Mark;

   --------------
   -- Get_File --
   --------------

   function Get_File
     (Self : not null access constant Abstract_Message'Class)
      return GNATCOLL.VFS.Virtual_File is
   begin
      case Self.Level is
         when Primary =>
            return Self.Parent.File;

         when Secondary =>
            return Self.Corresponding_File;
      end case;
   end Get_File;

   ---------------
   -- Get_Files --
   ---------------

   function Get_Files
     (Self     : not null access constant Messages_Container'Class;
      Category : Ada.Strings.Unbounded.Unbounded_String)
      return Virtual_File_Array
   is
      Category_Position : constant Category_Maps.Cursor :=
                            Self.Category_Map.Find (Category);
      Category_Node     : Node_Access;

   begin
      if Has_Element (Category_Position) then
         Category_Node := Element (Category_Position);

         declare
            Result : Virtual_File_Array
              (1 .. Natural (Category_Node.Children.Length));

         begin
            for J in Result'Range loop
               Result (J) := Category_Node.Children.Element (J).File;
            end loop;

            return Result;
         end;

      else
         return Virtual_File_Array'(1 .. 0 => No_File);
      end if;
   end Get_Files;

   -----------------------------
   -- Get_Highlighting_Length --
   -----------------------------

   function Get_Highlighting_Length
     (Self : not null access constant Abstract_Message'Class) return Natural is
   begin
      return Self.Length;
   end Get_Highlighting_Length;

   ----------------------------
   -- Get_Highlighting_Style --
   ----------------------------

   function Get_Highlighting_Style
     (Self : not null access constant Abstract_Message'Class)
      return GPS.Kernel.Styles.Style_Access is
   begin
      return Self.Style;
   end Get_Highlighting_Style;

   --------------
   -- Get_Line --
   --------------

   function Get_Line
     (Self : not null access constant Abstract_Message'Class)
      return Positive is
   begin
      return Self.Line;
   end Get_Line;

   ----------------
   -- Get_Markup --
   ----------------

   function Get_Markup
     (Self : not null access constant Abstract_Message)
      return Ada.Strings.Unbounded.Unbounded_String is
   begin
      return
        To_Unbounded_String
          (Glib.Convert.Escape_Text
               (To_String (Abstract_Message'Class (Self.all).Get_Text)));
   end Get_Markup;

   ------------------
   -- Get_Messages --
   ------------------

   function Get_Messages
     (Self     : not null access constant Messages_Container'Class;
      Category : Ada.Strings.Unbounded.Unbounded_String;
      File     : GNATCOLL.VFS.Virtual_File) return Message_Array
   is
      Category_Position : constant Category_Maps.Cursor :=
                            Self.Category_Map.Find (Category);
      Category_Node     : Node_Access;
      File_Position     : File_Maps.Cursor;
      File_Node         : Node_Access;

   begin
      if Has_Element (Category_Position) then
         Category_Node := Element (Category_Position);
         File_Position := Category_Node.File_Map.Find (File);

         if Has_Element (File_Position) then
            File_Node := Element (File_Position);

            declare
               Result : Message_Array
                 (1 .. Natural (File_Node.Children.Length));

            begin
               for J in Result'Range loop
                  Result (J) :=
                    Message_Access (File_Node.Children.Element (J));
               end loop;

               return Result;
            end;
         end if;
      end if;

      return Message_Array'(1 .. 0 => null);
   end Get_Messages;

   ----------------------------
   -- Get_Messages_Container --
   ----------------------------

   function Get_Messages_Container
     (Kernel : not null access Kernel_Handle_Record'Class)
      return not null Messages_Container_Access is
   begin
      return To_Messages_Container_Access (Kernel.Messages_Container);
   end Get_Messages_Container;

   ----------------
   -- Get_Parent --
   ----------------

   function Get_Parent
     (Self : not null access constant Abstract_Message'Class)
      return Message_Access is
   begin
      case Self.Level is
         when Primary =>
            return null;

         when Secondary =>
            return Message_Access (Self.Parent);
      end case;
   end Get_Parent;

   ----------
   -- Hash --
   ----------

   function Hash (Item : Ada.Tags.Tag) return Ada.Containers.Hash_Type is
   begin
      return Ada.Strings.Fixed.Hash (External_Tag (Item));
   end Hash;

   --------------------------------
   -- Increment_Message_Counters --
   --------------------------------

   procedure Increment_Message_Counters
     (Self : not null access Abstract_Message'Class)
   is
      Node : Node_Access := Self.Parent;

   begin
      while Node /= null loop
         Node.Message_Count := Node.Message_Count + 1;
         Node := Node.Parent;
      end loop;
   end Increment_Message_Counters;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (Self          : not null access Abstract_Message'Class;
      Container     : not null Messages_Container_Access;
      Category      : String;
      File          : GNATCOLL.VFS.Virtual_File;
      Line          : Natural;
      Column        : Basic_Types.Visible_Column_Type;
      Weight        : Natural;
      Actual_Line   : Integer;
      Actual_Column : Integer)
   is
      pragma Assert (Category /= "");
      pragma Assert (File /= No_File);

      Category_Name     : constant Unbounded_String :=
                            To_Unbounded_String (Category);
      Category_Position : constant Category_Maps.Cursor :=
                            Container.Category_Map.Find (Category_Name);
      Category_Node     : Node_Access;
      File_Position     : File_Maps.Cursor;
      File_Node         : Node_Access;
      Sort_Position     : Sort_Order_Hint_Maps.Cursor;
      Sort_Hint         : Sort_Order_Hint;

   begin
      Self.Message_Count := 0;
      Self.Line := Line;
      Self.Column := Column;
      Self.Weight := Weight;
      Self.Mark :=
        new Editor_Mark'Class'
          (Container.Kernel.Get_Buffer_Factory.New_Mark
               (File, Actual_Line, Actual_Column));

      --  Resolve category node, create new one when there is no existent node

      if Has_Element (Category_Position) then
         Category_Node := Element (Category_Position);

      else
         Sort_Position := Container.Sort_Order_Hints.Find (Category_Name);

         if Has_Element (Sort_Position) then
            Sort_Hint := Element (Sort_Position);

         else
            Sort_Hint := Chronological;
         end if;

         Category_Node :=
           new Node_Record'
             (Kind          => Node_Category,
              Parent        => null,
              Children      => Node_Vectors.Empty_Vector,
              Message_Count => 0,
              Container     => Container,
              Name          => Category_Name,
              File_Map      => File_Maps.Empty_Map,
              Sort_Hint     => Sort_Hint);
         Container.Categories.Append (Category_Node);
         Container.Category_Map.Insert (Category_Name, Category_Node);

         --  Notify models and listeners

         Notifiers.Notify_Models_About_Category_Added
           (Container, Category_Node);
         Notifiers.Notify_Listeners_About_Category_Added
           (Container, Category_Name);
      end if;

      --  Resolve file node, create new one when there is no existent node

      File_Position := Category_Node.File_Map.Find (File);

      if Has_Element (File_Position) then
         File_Node := Element (File_Position);

      else
         File_Node :=
           new Node_Record'
             (Kind          => Node_File,
              Parent        => Category_Node,
              Children      => Node_Vectors.Empty_Vector,
              Message_Count => 0,
              File          => File);
         Category_Node.Children.Append (File_Node);
         Category_Node.File_Map.Insert (File, File_Node);

         --  Notify models and listeners

         Notifiers.Notify_Models_About_File_Added (Container, File_Node);
         Notifiers.Notify_Listeners_About_File_Added
           (Container, Category_Name, File);
      end if;

      --  Connect message with file node

      Self.Parent := File_Node;
      File_Node.Children.Append (Node_Access (Self));

      --  Update message counters

      Self.Increment_Message_Counters;

      --  Notify models and listeners

      Notifiers.Notify_Models_About_Message_Added (Container, Self);
      Notifiers.Notify_Listeners_About_Message_Added (Container, Self);
   end Initialize;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
     (Self          : not null access Abstract_Message'Class;
      Parent        : not null Message_Access;
      File          : GNATCOLL.VFS.Virtual_File;
      Line          : Natural;
      Column        : Basic_Types.Visible_Column_Type;
      Actual_Line   : Integer;
      Actual_Column : Integer) is
   begin
      Self.Corresponding_File := File;
      Self.Line := Line;
      Self.Column := Column;
      Self.Message_Count := 0;
      Self.Mark :=
        new Editor_Mark'Class'
          (Parent.Get_Container.Kernel.Get_Buffer_Factory.New_Mark
               (File, Actual_Line, Actual_Column));

      Self.Parent := Node_Access (Parent);
      Parent.Children.Append (Node_Access (Self));

      --  Update messages counters

      Self.Increment_Message_Counters;

      --  Notify models and listeners

      Notifiers.Notify_Models_About_Message_Added (Parent.Get_Container, Self);
      Notifiers.Notify_Listeners_About_Message_Added
        (Parent.Get_Container, Self);
   end Initialize;

   ----------
   -- Load --
   ----------

   procedure Load (Self : not null access Messages_Container'Class) is

      procedure Load_Message
        (XML_Node : Node_Ptr;
         Category : String;
         File     : Virtual_File);
      --  Loads primary message and its secondary messages

      procedure Load_Message
        (XML_Node : Node_Ptr;
         Parent   : not null Message_Access);
      --  Loads secondary message

      ------------------
      -- Load_Message --
      ------------------

      procedure Load_Message
        (XML_Node : Node_Ptr;
         Category : String;
         File     : Virtual_File)
      is
         Class         : constant Tag :=
                           Internal_Tag
                             (Get_Attribute (XML_Node, "class", ""));
         Line          : constant Natural :=
                           Natural'Value
                             (Get_Attribute (XML_Node, "line", ""));
         Column        : constant Visible_Column_Type :=
                           Visible_Column_Type'Value
                             (Get_Attribute (XML_Node, "column", ""));
         Weight        : constant Natural :=
                           Natural'Value
                             (Get_Attribute (XML_Node, "weight", "0"));
         Actual_Line   : constant Integer :=
                           Integer'Value
                             (Get_Attribute
                                (XML_Node,
                                 "actual_line",
                                 Natural'Image (Line)));
         Actual_Column : constant Integer :=
                           Integer'Value
                             (Get_Attribute
                                (XML_Node,
                                 "actual_column",
                                 Visible_Column_Type'Image (Column)));
         Style_Name    : constant String :=
                           Get_Attribute (XML_Node, "highlighting_style", "");
         Length        : constant Natural :=
                           Natural'Value
                             (Get_Attribute
                                (XML_Node, "highlighting_length", "0"));
         Message       : Message_Access;
         XML_Child     : Node_Ptr := XML_Node.Child;
         Style         : Style_Access;

      begin
         Message :=
           Self.Primary_Loaders.Element (Class)
           (XML_Node,
            Messages_Container_Access (Self),
            Category,
            File,
            Line,
            Column,
            Weight,
            Actual_Line,
            Actual_Column);

         if Style_Name /= "" then
            Style := Get_Or_Create_Style (Self.Kernel, Style_Name, True);

            if Length = 0 then
               Set_Highlighting (Message, Style);

            else
               Set_Highlighting (Message, Style, Length);
            end if;
         end if;

         while XML_Child /= null loop
            if XML_Child.Tag.all = "message" then
               Load_Message (XML_Child, Message);
            end if;

            XML_Child := XML_Child.Next;
         end loop;
      end Load_Message;

      ------------------
      -- Load_Message --
      ------------------

      procedure Load_Message
        (XML_Node : Node_Ptr;
         Parent   : not null Message_Access)
      is
         Class         : constant Tag :=
                           Internal_Tag
                             (Get_Attribute (XML_Node, "class", ""));
         File          : constant Virtual_File :=
                           Get_File_Child (XML_Node, "file");
         Line          : constant Natural :=
                           Natural'Value
                             (Get_Attribute (XML_Node, "line", ""));
         Column        : constant Visible_Column_Type :=
                           Visible_Column_Type'Value
                             (Get_Attribute (XML_Node, "column", ""));
         Actual_Line   : constant Integer :=
                           Integer'Value
                             (Get_Attribute
                                (XML_Node,
                                 "actual_line",
                                 Natural'Image (Line)));
         Actual_Column : constant Integer :=
                           Integer'Value
                             (Get_Attribute
                                (XML_Node,
                                 "actual_column",
                                 Visible_Column_Type'Image (Column)));

      begin
         Self.Secondary_Loaders.Element (Class)
           (XML_Node, Parent, File, Line, Column, Actual_Line, Actual_Column);
      end Load_Message;

      Messages_File     : constant Virtual_File :=
                            Create_From_Dir
                              (Self.Kernel.Home_Dir, Messages_File_Name);
      Project_File      : constant Virtual_File :=
                            Get_Project (Self.Kernel).Project_Path;
      Root_XML_Node     : Node_Ptr;
      Project_XML_Node  : Node_Ptr;
      Category_XML_Node : Node_Ptr;
      File_XML_Node     : Node_Ptr;
      Message_XML_Node  : Node_Ptr;
      Error             : GNAT.Strings.String_Access;
      Category          : Unbounded_String;
      File              : Virtual_File;

   begin
      if Messages_File.Is_Regular_File then
         Parse (Messages_File, Root_XML_Node, Error);
      end if;

      if Root_XML_Node /= null then
         Project_XML_Node := Root_XML_Node.Child;

         while Project_XML_Node /= null loop
            exit when Get_File_Child (Project_XML_Node, "file") = Project_File;

            Project_XML_Node := Project_XML_Node.Next;
         end loop;
      end if;

      if Project_XML_Node /= null then
         Category_XML_Node := Project_XML_Node.Child;

         while Category_XML_Node /= null loop
            if Category_XML_Node.Tag.all = "sort_order_hint" then
               Self.Sort_Order_Hints.Insert
                 (To_Unbounded_String
                    (Get_Attribute (Category_XML_Node, "category", "")),
                  Sort_Order_Hint'Value
                    (Get_Attribute
                       (Category_XML_Node,
                        "hint",
                        Sort_Order_Hint'Image (Chronological))));

            elsif Category_XML_Node.Tag.all = "category" then
               Category :=
                 To_Unbounded_String
                   (Get_Attribute (Category_XML_Node, "name", "ERROR"));

               File_XML_Node := Category_XML_Node.Child;

               while File_XML_Node /= null loop
                  File := Get_File_Child (File_XML_Node, "name");

                  Message_XML_Node := File_XML_Node.Child;

                  while Message_XML_Node /= null loop
                     if Message_XML_Node.Tag.all = "message" then
                        Load_Message
                          (Message_XML_Node, To_String (Category), File);
                     end if;

                     Message_XML_Node := Message_XML_Node.Next;
                  end loop;

                  File_XML_Node := File_XML_Node.Next;
               end loop;
            end if;

            Category_XML_Node := Category_XML_Node.Next;
         end loop;
      end if;

      Free (Root_XML_Node);
   end Load;

   package body Notifiers is

      -------------------------------------------
      -- Notify_Listeners_About_Category_Added --
      -------------------------------------------

      procedure Notify_Listeners_About_Category_Added
        (Self     : not null access constant Messages_Container'Class;
         Category : Ada.Strings.Unbounded.Unbounded_String)
      is
         Listener_Position : Listener_Vectors.Cursor := Self.Listeners.First;

      begin
         while Has_Element (Listener_Position) loop
            begin
               Element (Listener_Position).Category_Added (Category);

            exception
               when E : others =>
                  Trace (Exception_Handle, E);
            end;

            Next (Listener_Position);
         end loop;
      end Notify_Listeners_About_Category_Added;

      ---------------------------------------
      -- Notify_Listeners_About_File_Added --
      ---------------------------------------

      procedure Notify_Listeners_About_File_Added
        (Self     : not null access constant Messages_Container'Class;
         Category : Ada.Strings.Unbounded.Unbounded_String;
         File     : GNATCOLL.VFS.Virtual_File)
      is
         Listener_Position : Listener_Vectors.Cursor := Self.Listeners.First;

      begin
         while Has_Element (Listener_Position) loop
            begin
               Element (Listener_Position).File_Added (Category, File);

            exception
               when E : others =>
                  Trace (Exception_Handle, E);
            end;

            Next (Listener_Position);
         end loop;
      end Notify_Listeners_About_File_Added;

      ---------------------------------------
      -- Notify_Listeners_About_File_Removed --
      ---------------------------------------

      procedure Notify_Listeners_About_File_Removed
        (Self     : not null access constant Messages_Container'Class;
         Category : Ada.Strings.Unbounded.Unbounded_String;
         File     : GNATCOLL.VFS.Virtual_File)
      is
         Listener_Position : Listener_Vectors.Cursor := Self.Listeners.First;

      begin
         while Has_Element (Listener_Position) loop
            begin
               Element (Listener_Position).File_Removed (Category, File);

            exception
               when E : others =>
                  Trace (Exception_Handle, E);
            end;

            Next (Listener_Position);
         end loop;
      end Notify_Listeners_About_File_Removed;

      ------------------------------------------
      -- Notify_Listeners_About_Message_Added --
      ------------------------------------------

      procedure Notify_Listeners_About_Message_Added
        (Self    : not null access constant Messages_Container'Class;
         Message : not null access Abstract_Message'Class)
      is
         Listener_Position : Listener_Vectors.Cursor := Self.Listeners.First;

      begin
         while Has_Element (Listener_Position) loop
            begin
               Element (Listener_Position).Message_Added (Message);

            exception
               when E : others =>
                  Trace (Exception_Handle, E);
            end;

            Next (Listener_Position);
         end loop;
      end Notify_Listeners_About_Message_Added;

      -----------------------------------------------------
      -- Notify_Listeners_About_Message_Property_Changed --
      -----------------------------------------------------

      procedure Notify_Listeners_About_Message_Property_Changed
        (Self     : not null access constant Messages_Container'Class;
         Message  : not null access Abstract_Message'Class;
         Property : String)
      is
         Listener_Position : Listener_Vectors.Cursor := Self.Listeners.First;

      begin
         while Has_Element (Listener_Position) loop
            begin
               Element (Listener_Position).Message_Property_Changed
                 (Message, Property);

            exception
               when E : others =>
                  Trace (Exception_Handle, E);
            end;

            Next (Listener_Position);
         end loop;
      end Notify_Listeners_About_Message_Property_Changed;

      --------------------------------------------
      -- Notify_Listeners_About_Message_Removed --
      --------------------------------------------

      procedure Notify_Listeners_About_Message_Removed
        (Self    : not null access constant Messages_Container'Class;
         Message : not null access Abstract_Message'Class)
      is
         Listener_Position : Listener_Vectors.Cursor := Self.Listeners.First;

      begin
         while Has_Element (Listener_Position) loop
            begin
               Element (Listener_Position).Message_Removed (Message);

            exception
               when E : others =>
                  Trace (Exception_Handle, E);
            end;

            Next (Listener_Position);
         end loop;
      end Notify_Listeners_About_Message_Removed;

      ----------------------------------------
      -- Notify_Models_About_Category_Added --
      ----------------------------------------

      procedure Notify_Models_About_Category_Added
        (Self : not null access constant Messages_Container'Class;
         Node : not null access Node_Record'Class)
      is
         Model_Position : Model_Vectors.Cursor := Self.Models.First;

      begin
         while Has_Element (Model_Position) loop
            Element (Model_Position).Category_Added (Node_Access (Node));
            Next (Model_Position);
         end loop;
      end Notify_Models_About_Category_Added;

      ------------------------------------
      -- Notify_Models_About_File_Added --
      ------------------------------------

      procedure Notify_Models_About_File_Added
        (Self : not null access constant Messages_Container'Class;
         Node : not null access Node_Record'Class)
      is
         Model_Position : Model_Vectors.Cursor := Self.Models.First;

      begin
         while Has_Element (Model_Position) loop
            Element (Model_Position).File_Added (Node_Access (Node));
            Next (Model_Position);
         end loop;
      end Notify_Models_About_File_Added;

      --------------------------------------
      -- Notify_Models_About_File_Removed --
      --------------------------------------

      procedure Notify_Models_About_File_Removed
        (Self   : not null access constant Messages_Container'Class;
         Parent : not null access Node_Record'Class;
         Index  : Positive)
      is
         Model_Position : Model_Vectors.Cursor := Self.Models.First;

      begin
         while Has_Element (Model_Position) loop
            Element (Model_Position).File_Removed
              (Node_Access (Parent), Index);
            Next (Model_Position);
         end loop;
      end Notify_Models_About_File_Removed;

      ---------------------------------------
      -- Notify_Models_About_Message_Added --
      ---------------------------------------

      procedure Notify_Models_About_Message_Added
        (Self    : not null access constant Messages_Container'Class;
         Message : not null access Abstract_Message'Class)
      is
         Model_Position : Model_Vectors.Cursor := Self.Models.First;

      begin
         while Has_Element (Model_Position) loop
            Element (Model_Position).Message_Added (Message_Access (Message));
            Next (Model_Position);
         end loop;
      end Notify_Models_About_Message_Added;

      --------------------------------------------------
      -- Notify_Models_About_Message_Property_Changed --
      --------------------------------------------------

      procedure Notify_Models_About_Message_Property_Changed
        (Self    : not null access constant Messages_Container'Class;
         Message : not null access Abstract_Message'Class)
      is
         Model_Position : Model_Vectors.Cursor := Self.Models.First;

      begin
         while Has_Element (Model_Position) loop
            Element (Model_Position).Message_Property_Changed
              (Message_Access (Message));
            Next (Model_Position);
         end loop;
      end Notify_Models_About_Message_Property_Changed;

      -----------------------------------------
      -- Notify_Models_About_Message_Removed --
      -----------------------------------------

      procedure Notify_Models_About_Message_Removed
        (Self   : not null access constant Messages_Container'Class;
         Parent : not null access Node_Record'Class;
         Index  : Positive)
      is
         Model_Position : Model_Vectors.Cursor := Self.Models.First;

      begin
         while Has_Element (Model_Position) loop
            Element (Model_Position).Message_Removed
              (Node_Access (Parent), Index);
            Next (Model_Position);
         end loop;
      end Notify_Models_About_Message_Removed;

   end Notifiers;

   -----------------------
   -- Register_Listener --
   -----------------------

   procedure Register_Listener
     (Self     : not null access Messages_Container;
      Listener : not null Listener_Access)
   is
      Listener_Position : constant Listener_Vectors.Cursor :=
                            Self.Listeners.Find (Listener);

   begin
      if not Has_Element (Listener_Position) then
         Self.Listeners.Append (Listener);
      end if;
   end Register_Listener;

   ----------------------------
   -- Register_Message_Class --
   ----------------------------

   procedure Register_Message_Class
     (Self           : not null access Messages_Container'Class;
      Tag            : Ada.Tags.Tag;
      Save           : not null Message_Save_Procedure;
      Primary_Load   : Primary_Message_Load_Procedure;
      Secondary_Load : Secondary_Message_Load_Procedure) is
   begin
      Self.Savers.Insert (Tag, Save);

      if Primary_Load /= null then
         Self.Primary_Loaders.Insert (Tag, Primary_Load);
      end if;

      if Secondary_Load /= null then
         Self.Secondary_Loaders.Insert (Tag, Secondary_Load);
      end if;
   end Register_Message_Class;

   ------------
   -- Remove --
   ------------

   procedure Remove (Self : not null access Abstract_Message'Class) is
      Message : Message_Access := Message_Access (Self);

   begin
      Self.Get_Container.Remove_Message (Message, True);
   end Remove;

   -------------------------
   -- Remove_All_Messages --
   -------------------------

   procedure Remove_All_Messages
     (Self : not null access Messages_Container'Class)
   is
      Category_Position : Category_Maps.Cursor;
      Category_Node     : Node_Access;

   begin
      while not Self.Categories.Is_Empty loop
         Category_Node := Self.Categories.Last_Element;
         Category_Position := Self.Category_Map.Find (Category_Node.Name);

         Self.Remove_Category
           (Category_Position,
            Self.Categories.Last_Index,
            Category_Node);
      end loop;
   end Remove_All_Messages;

   ---------------------
   -- Remove_Category --
   ---------------------

   procedure Remove_Category
     (Self              : not null access Messages_Container'Class;
      Category_Position : in out Category_Maps.Cursor;
      Category_Index    : Positive;
      Category_Node     : in out Node_Access)
   is
      pragma Assert (Has_Element (Category_Position));
      pragma Assert (Category_Node /= null);

   begin
      --  Remove files

      while not Category_Node.Children.Is_Empty loop
         declare
            File_Node     : Node_Access := Category_Node.Children.Last_Element;
            File_Position : File_Maps.Cursor :=
                              Category_Node.File_Map.Find (File_Node.File);

         begin
            Self.Remove_File
              (File_Position,
               Category_Node.Children.Last_Index,
               File_Node,
               False);
         end;
      end loop;

      Self.Category_Map.Delete (Category_Position);
      Self.Categories.Delete (Category_Index);

      declare
         Model_Position : Model_Vectors.Cursor := Self.Models.First;

      begin
         while Has_Element (Model_Position) loop
            Element (Model_Position).Category_Removed (Category_Index);
            Next (Model_Position);
         end loop;
      end;

      Free (Category_Node);
   end Remove_Category;

   ---------------------
   -- Remove_Category --
   ---------------------

   procedure Remove_Category
     (Self     : not null access Messages_Container'Class;
      Category : String)
   is
      Category_Position : Category_Maps.Cursor :=
                            Self.Category_Map.Find
                              (To_Unbounded_String (Category));
      Category_Index    : Positive;
      Category_Node     : Node_Access;

   begin
      if Has_Element (Category_Position) then
         Category_Node := Element (Category_Position);
         Category_Index := Self.Categories.Find_Index (Category_Node);

         Self.Remove_Category
           (Category_Position, Category_Index, Category_Node);
      end if;
   end Remove_Category;

   -----------------
   -- Remove_File --
   -----------------

   procedure Remove_File
     (Self          : not null access Messages_Container'Class;
      File_Position : in out File_Maps.Cursor;
      File_Index    : Positive;
      File_Node     : in out Node_Access;
      Recursive     : Boolean)
   is
      Category_Node : Node_Access := File_Node.Parent;

   begin
      --  Remove messages

      while not File_Node.Children.Is_Empty loop
         declare
            Message : Message_Access :=
              Message_Access (File_Node.Children.Last_Element);

         begin
            Self.Remove_Message (Message, False);
         end;
      end loop;

      --  Notify listeners

      Notifiers.Notify_Listeners_About_File_Removed
        (Self, Category_Node.Name, File_Node.File);

      --  Delete file's node

      Category_Node.File_Map.Delete (File_Position);
      Category_Node.Children.Delete (File_Index);
      Free (File_Node);

      --  Nofity models

      Notifiers.Notify_Models_About_File_Removed
        (Self, Category_Node, File_Index);

      --  Remove category when there are no files for it

      if Recursive
        and then Category_Node.Children.Is_Empty
      then
         declare
            Category_Position : Category_Maps.Cursor :=
              Self.Category_Map.Find (Category_Node.Name);
            Category_Index    : constant Positive :=
              Self.Categories.Find_Index (Category_Node);

         begin
            Self.Remove_Category
              (Category_Position, Category_Index, Category_Node);
         end;
      end if;
   end Remove_File;

   -----------------
   -- Remove_File --
   -----------------

   procedure Remove_File
     (Self     : not null access Messages_Container'Class;
      Category : String;
      File     : GNATCOLL.VFS.Virtual_File)
   is
      Category_Position : constant Category_Maps.Cursor :=
                            Self.Category_Map.Find
                              (To_Unbounded_String (Category));
      Category_Node     : Node_Access;
      File_Position     : File_Maps.Cursor;
      File_Index        : Positive;
      File_Node         : Node_Access;

   begin
      if Has_Element (Category_Position) then
         Category_Node := Element (Category_Position);

         File_Position := Category_Node.File_Map.Find (File);

         if Has_Element (File_Position) then
            File_Node := Element (File_Position);
            File_Index := Category_Node.Children.Find_Index (File_Node);
            Self.Remove_File (File_Position, File_Index, File_Node, True);
         end if;
      end if;
   end Remove_File;

   --------------------
   -- Remove_Message --
   --------------------

   procedure Remove_Message
     (Self      : not null access Messages_Container'Class;
      Message   : in out Message_Access;
      Recursive : Boolean)
   is

      procedure Free is
        new Unchecked_Deallocation (Abstract_Message'Class, Message_Access);

      Parent    : Node_Access := Message.Parent;
      Index     : constant Positive :=
                    Parent.Children.Find_Index (Node_Access (Message));

   begin
      while not Message.Children.Is_Empty loop
         declare
            Secondary : Message_Access :=
              Message_Access (Message.Children.Last_Element);

         begin
            Self.Remove_Message (Secondary, False);
         end;
      end loop;

      Notifiers.Notify_Listeners_About_Message_Removed (Self, Message);
      Message.Decrement_Message_Counters;
      Parent.Children.Delete (Index);
      Notifiers.Notify_Models_About_Message_Removed (Self, Parent, Index);

      Message.Finalize;
      Free (Message);

      --  Remove file node when there are no messages for the file and
      --  recursive destruction is enabled.

      if Recursive
        and then Parent.Kind = Node_File
        and then Parent.Children.Is_Empty
      then
         declare
            Category_Node : constant Node_Access := Parent.Parent;
            File_Position : File_Maps.Cursor :=
              Category_Node.File_Map.Find (Parent.File);
            File_Index    : constant Positive :=
              Category_Node.Children.Find_Index (Parent);

         begin
            Self.Remove_File (File_Position, File_Index, Parent, True);
         end;
      end if;
   end Remove_Message;

   ----------
   -- Save --
   ----------

   procedure Save (Self : not null access Messages_Container'Class) is
   begin
      Self.Save
        (Create_From_Dir (Self.Kernel.Home_Dir, Messages_File_Name), False);
   end Save;

   ----------
   -- Save --
   ----------

   procedure Save
     (Self  : not null access Messages_Container'Class;
      File  : GNATCOLL.VFS.Virtual_File;
      Debug : Boolean)
   is

      procedure Save_Node
        (Current_Node    : not null Node_Access;
         Parent_XML_Node : not null Node_Ptr);
      --  Saves specified node as child of specified XML node

      ---------------
      -- Save_Node --
      ---------------

      procedure Save_Node
        (Current_Node    : not null Node_Access;
         Parent_XML_Node : not null Node_Ptr)
      is
         XML_Node : Node_Ptr;

      begin
         --  Create XML node for the current node with corresponding tag and
         --  add corresponding attributes to it.

         case Current_Node.Kind is
            when Node_Category =>
               XML_Node :=
                 new Node'(Tag => new String'("category"), others => <>);

            when Node_File =>
               XML_Node :=
                 new Node'(Tag => new String'("file"), others => <>);

            when Node_Message =>
               XML_Node :=
                 new Node'(Tag => new String'("message"), others => <>);
         end case;

         Add_Child (Parent_XML_Node, XML_Node, True);

         case Current_Node.Kind is
            when Node_Category =>
               Set_Attribute (XML_Node, "name", To_String (Current_Node.Name));

            when Node_File =>
               Add_File_Child (XML_Node, "name", Current_Node.File);

            when Node_Message =>
               Set_Attribute
                 (XML_Node, "class", External_Tag (Current_Node'Tag));
               Set_Attribute
                 (XML_Node,
                  "line",
                  Trim (Positive'Image (Current_Node.Line), Both));
               Set_Attribute
                 (XML_Node,
                  "column",
                  Trim
                    (Visible_Column_Type'Image (Current_Node.Column), Both));

               if Current_Node.Mark.Line /= Current_Node.Line then
                  Set_Attribute
                    (XML_Node,
                     "actual_line",
                     Trim (Integer'Image (Current_Node.Mark.Line), Both));
               end if;

               if Current_Node.Mark.Column
                 /= Integer (Current_Node.Column)
               then
                  Set_Attribute
                    (XML_Node,
                     "actual_column",
                     Trim (Integer'Image (Current_Node.Mark.Column), Both));
               end if;

               if Current_Node.Style /= null then
                  Set_Attribute
                    (XML_Node,
                     "highlighting_style",
                     Get_Name (Current_Node.Style));

                  if Current_Node.Length /= 0 then
                     Set_Attribute
                       (XML_Node,
                        "highlighting_length",
                        Trim (Integer'Image (Current_Node.Length), Both));
                  end if;
               end if;

               case Message_Access (Current_Node).Level is
                  when Primary =>
                     if Message_Access (Current_Node).Weight /= 0 then
                        Set_Attribute
                          (XML_Node,
                           "weight",
                           Trim
                             (Natural'Image
                                (Message_Access (Current_Node).Weight),
                              Both));
                     end if;

                  when Secondary =>
                     Add_File_Child
                       (XML_Node,
                        "file",
                        Message_Access (Current_Node).Corresponding_File);
               end case;

               Self.Savers.Element
                 (Current_Node'Tag) (Message_Access (Current_Node), XML_Node);

               if Debug then
                  --  In debug mode save flag to mark messages with associated
                  --  action

                  if Current_Node.Action /= null then
                     Set_Attribute (XML_Node, "has_action", "true");
                  end if;
               end if;
         end case;

         --  Save child nodes also

         for J in 1 .. Natural (Current_Node.Children.Length) loop
            Save_Node (Current_Node.Children.Element (J), XML_Node);
         end loop;
      end Save_Node;

      Project_File     : constant Virtual_File := Self.Project_File;
      Sort_Position    : Sort_Order_Hint_Maps.Cursor :=
                           Self.Sort_Order_Hints.First;
      Root_XML_Node    : Node_Ptr;
      Project_XML_Node : Node_Ptr;
      Sort_XML_Node    : Node_Ptr;
      Error            : GNAT.Strings.String_Access;

   begin
      if Project_File /= No_File then
         if File.Is_Regular_File then
            Parse (File, Root_XML_Node, Error);
         end if;

         --  Create root node when it is absent

         if Root_XML_Node = null then
            Root_XML_Node :=
              new Node'(Tag => new String'("messages"), others => <>);
         end if;

         --  Remove project specific node if necessary

         declare
            Current : Node_Ptr := Root_XML_Node.Child;

         begin
            while Current /= null loop
               exit when Get_File_Child (Current, "file") = Project_File;

               Current := Current.Next;
            end loop;

            Free (Current);
         end;

         --  Create project node

         Project_XML_Node :=
           new Node'(Tag => new String'("project"), others => <>);
         Add_Child (Root_XML_Node, Project_XML_Node);
         Add_File_Child (Project_XML_Node, "file", Project_File);

         --  Save sort order hints

         while Has_Element (Sort_Position) loop
            if Element (Sort_Position) /= Chronological then
               Sort_XML_Node :=
                 new Node'
                   (Tag => new String'("sort_order_hint"), others => <>);
               Set_Attribute
                 (Sort_XML_Node,
                  "category",
                  To_String (Key (Sort_Position)));
               Set_Attribute
                 (Sort_XML_Node,
                  "hint",
                  Sort_Order_Hint'Image (Element (Sort_Position)));
               Add_Child (Project_XML_Node, Sort_XML_Node, True);
            end if;

            Next (Sort_Position);
         end loop;

         --  Save categories

         for J in 1 .. Natural (Self.Categories.Length) loop
            Save_Node (Self.Categories.Element (J), Project_XML_Node);
         end loop;

         Print (Root_XML_Node, File);
         Free (Root_XML_Node);
      end if;
   end Save;

   ----------------
   -- Set_Action --
   ----------------

   procedure Set_Action
     (Self   : not null access Abstract_Message'Class;
      Action : Action_Item)
   is
      Container : constant Messages_Container_Access := Self.Get_Container;

   begin
      Free (Self.Action);
      Self.Action := Action;

      Notifiers.Notify_Listeners_About_Message_Property_Changed
        (Container, Self, "action");
      Notifiers.Notify_Models_About_Message_Property_Changed (Container, Self);
   end Set_Action;

   ----------------------
   -- Set_Highlighting --
   ----------------------

   procedure Set_Highlighting
     (Self   : not null access Abstract_Message'Class;
      Style  : GPS.Kernel.Styles.Style_Access;
      Length : Positive) is
   begin
      Self.Style := Style;
      Self.Length := Length;

      Notifiers.Notify_Listeners_About_Message_Property_Changed
        (Self.Get_Container, Self, "highlighting");
   end Set_Highlighting;

   ----------------------
   -- Set_Highlighting --
   ----------------------

   procedure Set_Highlighting
     (Self  : not null access Abstract_Message'Class;
      Style : GPS.Kernel.Styles.Style_Access) is
   begin
      Self.Style := Style;
      Self.Length := 0;

      Notifiers.Notify_Listeners_About_Message_Property_Changed
        (Self.Get_Container, Self, "highlighting");
   end Set_Highlighting;

   -------------------------
   -- Set_Sort_Order_Hint --
   -------------------------

   procedure Set_Sort_Order_Hint
     (Self     : not null access Messages_Container'Class;
      Category : String;
      Hint     : Sort_Order_Hint)
   is
      Category_Name : constant Unbounded_String :=
                        To_Unbounded_String (Category);
      Position      : constant Sort_Order_Hint_Maps.Cursor :=
                        Self.Sort_Order_Hints.Find (Category_Name);

   begin
      if Has_Element (Position) then
         Self.Sort_Order_Hints.Replace_Element (Position, Hint);

      else
         Self.Sort_Order_Hints.Insert (Category_Name, Hint);
      end if;
   end Set_Sort_Order_Hint;

   -------------------------
   -- Unregister_Listener --
   -------------------------

   procedure Unregister_Listener
     (Self     : not null access Messages_Container;
      Listener : not null Listener_Access)
   is
      Listener_Position : Listener_Vectors.Cursor :=
                            Self.Listeners.Find (Listener);

   begin
      if Has_Element (Listener_Position) then
         Self.Listeners.Delete (Listener_Position);
      end if;
   end Unregister_Listener;

end GPS.Kernel.Messages;
