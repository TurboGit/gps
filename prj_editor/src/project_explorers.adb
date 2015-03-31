------------------------------------------------------------------------------
--                                  G P S                                   --
--                                                                          --
--                     Copyright (C) 2001-2015, AdaCore                     --
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

with Ada.Characters.Handling;   use Ada.Characters.Handling;
with Ada.Containers.Doubly_Linked_Lists;
with Ada.Containers.Hashed_Maps;
with Ada.Containers.Indefinite_Hashed_Maps;
with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Strings.Hash;

with GNATCOLL.Projects;         use GNATCOLL.Projects;
with GNATCOLL.Traces;           use GNATCOLL.Traces;
with GNATCOLL.Utils;            use GNATCOLL.Utils;
with GNATCOLL.VFS;              use GNATCOLL.VFS;
with GNATCOLL.VFS.GtkAda;       use GNATCOLL.VFS.GtkAda;

with Glib;                      use Glib;
with Glib.Main;                 use Glib.Main;
with Glib.Object;               use Glib.Object;
with Glib.Values;               use Glib.Values;

with Gdk;                       use Gdk;
with Gdk.Dnd;                   use Gdk.Dnd;
with Gdk.Event;                 use Gdk.Event;
with Gdk.Rectangle;             use Gdk.Rectangle;
with Gdk.Window;                use Gdk.Window;

with Gtk.Dnd;                   use Gtk.Dnd;
with Gtk.Enums;                 use Gtk.Enums;
with Gtk.Box;                   use Gtk.Box;
with Gtk.Check_Menu_Item;       use Gtk.Check_Menu_Item;
with Gtk.Label;                 use Gtk.Label;
with Gtk.Toolbar;               use Gtk.Toolbar;
with Gtk.Tree_Model;            use Gtk.Tree_Model;
with Gtk.Tree_Model_Filter;     use Gtk.Tree_Model_Filter;
with Gtk.Tree_View;             use Gtk.Tree_View;
with Gtk.Tree_Store;            use Gtk.Tree_Store;
with Gtk.Tree_Selection;        use Gtk.Tree_Selection;
with Gtk.Menu;                  use Gtk.Menu;
with Gtk.Widget;                use Gtk.Widget;
with Gtk.Cell_Renderer_Text;    use Gtk.Cell_Renderer_Text;
with Gtk.Cell_Renderer_Pixbuf;  use Gtk.Cell_Renderer_Pixbuf;
with Gtk.Scrolled_Window;       use Gtk.Scrolled_Window;
with Gtk.Tree_Sortable;         use Gtk.Tree_Sortable;
with Gtk.Tree_View_Column;      use Gtk.Tree_View_Column;
with Gtkada.MDI;                use Gtkada.MDI;
with Gtkada.Tree_View;          use Gtkada.Tree_View;
with Gtkada.Handlers;           use Gtkada.Handlers;

with Commands.Interactive;      use Commands, Commands.Interactive;
with Default_Preferences;       use Default_Preferences;
with Generic_Views;             use Generic_Views;
with Histories;                 use Histories;
with GPS.Kernel;                use GPS.Kernel;
with GPS.Kernel.Actions;        use GPS.Kernel.Actions;
with GPS.Kernel.Contexts;       use GPS.Kernel.Contexts;
with GPS.Kernel.Hooks;          use GPS.Kernel.Hooks;
with GPS.Kernel.Project;        use GPS.Kernel.Project;
with GPS.Kernel.MDI;            use GPS.Kernel.MDI;
with GPS.Kernel.Modules;        use GPS.Kernel.Modules;
with GPS.Kernel.Modules.UI;     use GPS.Kernel.Modules.UI;
with GPS.Kernel.Preferences;    use GPS.Kernel.Preferences;
with GPS.Kernel.Standard_Hooks; use GPS.Kernel.Standard_Hooks;
with GPS.Search;                use GPS.Search;
with GPS.Intl;                  use GPS.Intl;
with GUI_Utils;                 use GUI_Utils;
with Projects;                  use Projects;
with Project_Explorers_Common;  use Project_Explorers_Common;
with String_Utils;              use String_Utils;
with Tooltips;

package body Project_Explorers is

   Me : constant Trace_Handle := Create ("Project_Explorers");

   Show_Absolute_Paths : Boolean_Preference;
   Show_Flat_View      : Boolean_Preference;
   Show_Hidden_Dirs    : Boolean_Preference;
   Show_Empty_Dirs     : Boolean_Preference;
   Projects_Before_Directories : Boolean_Preference;
   Show_Object_Dirs    : Boolean_Preference;
   Show_Runtime        : Boolean_Preference;
   Show_Directories    : Boolean_Preference;

   Toggle_Absolute_Path_Name : constant String :=
     "Explorer toggle absolute paths";
   Toggle_Absolute_Path_Tip : constant String :=
     "Toggle the display of absolute paths or just base names in the"
     & " project explorer";

   package Boolean_User_Data is new Glib.Object.User_Data (Boolean);
   User_Data_Projects_Before_Directories : constant String :=
     "gps-prj-before-dirs";
   --  local cache of the history key, for use in Sort_Func

   -------------
   --  Filter --
   -------------

   type Filter_Type is (Show_Direct, Show_Indirect, Hide);
   --  The status of the filter for each node:
   --  - show_direct is used when the node itself matches the filter.
   --  - show_indirect is used when a child of the node must be displayed, but
   --    the node itself does not match the filter.
   --  - hide is used when the node should be hidden

   package Filter_Maps is new Ada.Containers.Hashed_Maps
     (Key_Type        => Virtual_File,
      Hash            => GNATCOLL.VFS.Full_Name_Hash,
      Element_Type    => Filter_Type,
      Equivalent_Keys => "=");
   use Filter_Maps;

   type Explorer_Filter is record
      Pattern  : GPS.Search.Search_Pattern_Access;
      --  The pattern on which we filter.

      Cache    : Filter_Maps.Map;
      --  A cache of the filter. We do not manipulate the gtk model directlyy,
      --  because it does not contain everything in general (the contents of
      --  nodes is added dynamically).
   end record;

   procedure Set_Pattern
     (Self    : in out Explorer_Filter;
      Kernel  : not null access Kernel_Handle_Record'Class;
      Pattern : Search_Pattern_Access);
   --  Change the pattern and update the cache

   function Is_Visible
     (Self : Explorer_Filter; File : Virtual_File) return Filter_Type;
   --  Whether the given file should be visible

   ---------------------------------
   -- The project explorer widget --
   ---------------------------------

   type Project_Explorer_Record is new Generic_Views.View_Record with record
      Tree      : Gtkada.Tree_View.Tree_View;
      Filter    : Explorer_Filter;
      Expanding : Boolean := False;
   end record;
   overriding procedure Create_Menu
     (View    : not null access Project_Explorer_Record;
      Menu    : not null access Gtk.Menu.Gtk_Menu_Record'Class);
   overriding procedure Create_Toolbar
     (View    : not null access Project_Explorer_Record;
      Toolbar : not null access Gtk.Toolbar.Gtk_Toolbar_Record'Class);
   overriding procedure Filter_Changed
     (Self    : not null access Project_Explorer_Record;
      Pattern : in out GPS.Search.Search_Pattern_Access);

   function Initialize
     (Explorer : access Project_Explorer_Record'Class)
      return Gtk.Widget.Gtk_Widget;
   --  Create a new explorer, and return the focus widget.

   type Explorer_Child_Record is
      new MDI_Explorer_Child_Record with null record;
   overriding function Build_Context
     (Self  : not null access Explorer_Child_Record;
      Event : Gdk.Event.Gdk_Event := null)
      return Selection_Context;

   package Explorer_Views is new Generic_Views.Simple_Views
     (Module_Name        => Explorer_Module_Name,
      View_Name          => "Project",
      Formal_View_Record => Project_Explorer_Record,
      Formal_MDI_Child   => Explorer_Child_Record,
      Reuse_If_Exist     => True,
      Local_Toolbar      => True,
      Local_Config       => True,
      Areas              => Gtkada.MDI.Sides_Only,
      Position           => Position_Left,
      Initialize         => Initialize);
   use Explorer_Views;
   subtype Project_Explorer is Explorer_Views.View_Access;

   package Set_Visible_Funcs is new Set_Visible_Func_User_Data
     (User_Data_Type => Project_Explorer);

   function Is_Visible
     (Child_Model : Gtk.Tree_Model.Gtk_Tree_Model;
      Iter        : Gtk.Tree_Model.Gtk_Tree_Iter;
      Self        : Project_Explorer) return Boolean;
   --  Filter out some lines in the project view, based on the filter in the
   --  toolbar.

   -----------------------
   -- Local subprograms --
   -----------------------

   type Toggle_Absolute_Path_Command is
      new Interactive_Command with null record;
   overriding function Execute
     (Self    : access Toggle_Absolute_Path_Command;
      Context : Commands.Interactive.Interactive_Command_Context)
      return Commands.Command_Return_Type;

   function Hash (Key : Filesystem_String) return Ada.Containers.Hash_Type;
   pragma Inline (Hash);

   package Filename_Node_Hash is new Ada.Containers.Indefinite_Hashed_Maps
     (Key_Type        => Filesystem_String,
      Element_Type    => Gtk_Tree_Iter,
      Hash            => Hash,
      Equivalent_Keys => "=");
   use Filename_Node_Hash;

   package File_Node_Hash is new Ada.Containers.Indefinite_Hashed_Maps
     (Key_Type        => Virtual_File,
      Element_Type    => Gtk_Tree_Iter,
      Hash            => GNATCOLL.VFS.Full_Name_Hash,
      Equivalent_Keys => "=");
   use File_Node_Hash;

   type Directory_Info is record
      Directory : Virtual_File;
      Kind      : Node_Types;
   end record;
   function "<" (D1, D2 : Directory_Info) return Boolean;
   package Files_List is new Ada.Containers.Doubly_Linked_Lists (Virtual_File);
   package Dirs_Files_Hash is new Ada.Containers.Indefinite_Ordered_Maps
     (Key_Type        => Directory_Info,
      Element_Type    => Files_List.List,
      "="             => Files_List."=");
   use Files_List, Dirs_Files_Hash;

   procedure For_Each_File_Node
     (Model    : Gtk_Tree_Store;
      Parent   : Gtk_Tree_Iter;
      Callback : not null access procedure (It : in out Gtk_Tree_Iter));
   --  For each file node representing a direct source of Parent (does not
   --  look into nested project nodes). Callback can freely modify It, or
   --  the model.

   function Find_Project_Node
     (Self    : not null access Project_Explorer_Record'Class;
      Project : Project_Type) return Gtk_Tree_Iter;
   --  Find the first node matching the project

   procedure Preferences_Changed
     (Kernel : access Kernel_Handle_Record'Class;
      Data   : access Hooks_Data'Class);
   --  Called when the preferences have changed

   function Sort_Func
     (Model : Gtk_Tree_Model;
      A     : Gtk.Tree_Model.Gtk_Tree_Iter;
      B     : Gtk.Tree_Model.Gtk_Tree_Iter) return Gint;
   --  Used to sort nodes in the explorer

   function Compute_Project_Node_Type
      (Explorer : not null access Project_Explorer_Record'Class;
       Project  : Project_Type) return Node_Types;
   --  The node type to use for a project

   --------------
   -- Tooltips --
   --------------

   type Explorer_Tooltips is new Tooltips.Tooltips with record
      Explorer : Project_Explorer;
   end record;
   type Explorer_Tooltips_Access is access all Explorer_Tooltips'Class;
   overriding function Create_Contents
     (Tooltip  : not null access Explorer_Tooltips;
      Widget   : not null access Gtk.Widget.Gtk_Widget_Record'Class;
      X, Y     : Glib.Gint) return Gtk.Widget.Gtk_Widget;
   --  See inherited documentatoin

   -----------------------
   -- Local subprograms --
   -----------------------

   procedure Set_Column_Types (Tree : Gtk_Tree_View);
   --  Sets the types of columns to be displayed in the tree_view

   ---------------------
   -- Expanding nodes --
   ---------------------

   function Directory_Node_Text
     (Show_Abs_Paths : Boolean;
      Project        : Project_Type;
      Dir            : Virtual_File) return String;
   --  Return the text to use for a directory node

   procedure Expand_Row_Cb
     (Explorer    : access Gtk.Widget.Gtk_Widget_Record'Class;
      Filter_Iter : Gtk_Tree_Iter;
      Filter_Path : Gtk_Tree_Path);
   --  Called every time a node is expanded. It is responsible for
   --  automatically adding the children of the current node if they are not
   --  there already.

   procedure Collapse_Row_Cb
     (Explorer    : access Gtk.Widget.Gtk_Widget_Record'Class;
      Filter_Iter : Gtk_Tree_Iter;
      Filter_Path : Gtk_Tree_Path);
   --  Called every time a node is collapsed

   procedure Refresh_Project_Node
     (Self      : not null access Project_Explorer_Record'Class;
      Node      : Gtk_Tree_Iter;
      Flat_View : Boolean);
   --  Insert the children nodes for the project (directories, imported
   --  projects,...)
   --  Node is associated with Project. Both can be null when in flat view
   --  mode.

   function Button_Press
     (Explorer : access GObject_Record'Class;
      Event    : Gdk_Event_Button) return Boolean;
   --  Called every time a row is clicked
   --  ??? It is actually called twice in that case: a first time when the
   --  mouse button is pressed and a second time when it is released.

   function Key_Press
     (Explorer : access Gtk_Widget_Record'Class;
      Event    : Gdk_Event) return Boolean;
   --  Calledback on a key press

   procedure Tree_Select_Row_Cb
     (Explorer : access Gtk.Widget.Gtk_Widget_Record'Class; Args : GValues);
   --  Called every time a new row is selected

   --------------------
   -- Updating nodes --
   --------------------

   procedure Update_Absolute_Paths
     (Explorer : access Gtk_Widget_Record'Class);
   --  Update the text for all directory nodes in the tree, mostly after the
   --  "show absolute path" setting has changed.

   procedure Update_View (Explorer : access Gtk_Widget_Record'Class);
   --  Clear the view and recreate from scratch.

   ----------------------------
   -- Retrieving information --
   ----------------------------

   procedure Refresh
     (Explorer : access Gtk.Widget.Gtk_Widget_Record'Class);
   --  Refresh the contents of the tree after the project view has changed.
   --  This procedure tries to keep as many things as possible in the current
   --  state (expanded nodes,...)

   type Refresh_Hook_Record is new Function_No_Args with record
      Explorer : Project_Explorer;
   end record;
   type Refresh_Hook is access all Refresh_Hook_Record'Class;
   overriding procedure Execute
     (Hook   : Refresh_Hook_Record;
      Kernel : access Kernel_Handle_Record'Class);
   --  Called when the project view has changed

   type Project_Changed_Hook_Record is new Function_No_Args with record
      Explorer : Project_Explorer;
   end record;
   type Project_Hook is access all Project_Changed_Hook_Record'Class;
   overriding procedure Execute
     (Hook   : Project_Changed_Hook_Record;
      Kernel : access Kernel_Handle_Record'Class);
   --  Called when the project as changed, as opposed to the project view.
   --  This means we need to start up with a completely new tree, no need to
   --  try to keep the current one.

   procedure Jump_To_Node
     (Explorer    : Project_Explorer;
      Target_Node : Gtk_Tree_Iter);
   --  Select Target_Node, and make sure it is visible on the screen

   --------------
   -- Commands --
   --------------

   type Locate_File_In_Explorer_Command
     is new Interactive_Command with null record;
   overriding function Execute
     (Command : access Locate_File_In_Explorer_Command;
      Context : Interactive_Command_Context) return Command_Return_Type;

   type Locate_Project_In_Explorer_Command
     is new Interactive_Command with null record;
   overriding function Execute
     (Command : access Locate_Project_In_Explorer_Command;
      Context : Interactive_Command_Context) return Command_Return_Type;

   -------------
   -- Filters --
   -------------

   type Project_View_Filter_Record is new Action_Filter_Record
      with null record;
   type Project_Node_Filter_Record is new Action_Filter_Record
      with null record;
   type Directory_Node_Filter_Record is new Action_Filter_Record
      with null record;
   type File_Node_Filter_Record is new Action_Filter_Record
      with null record;
   type Entity_Node_Filter_Record is new Action_Filter_Record
      with null record;
   overriding function Filter_Matches_Primitive
     (Context : access Project_View_Filter_Record;
      Ctxt    : GPS.Kernel.Selection_Context) return Boolean;
   overriding function Filter_Matches_Primitive
     (Context : access Project_Node_Filter_Record;
      Ctxt    : GPS.Kernel.Selection_Context) return Boolean;
   overriding function Filter_Matches_Primitive
     (Context : access Directory_Node_Filter_Record;
      Ctxt    : GPS.Kernel.Selection_Context) return Boolean;
   overriding function Filter_Matches_Primitive
     (Context : access File_Node_Filter_Record;
      Ctxt    : GPS.Kernel.Selection_Context) return Boolean;
   overriding function Filter_Matches_Primitive
     (Context : access Entity_Node_Filter_Record;
      Ctxt    : GPS.Kernel.Selection_Context) return Boolean;

   -------------------------------
   -- Compute_Project_Node_Type --
   -------------------------------

   function Compute_Project_Node_Type
      (Explorer : not null access Project_Explorer_Record'Class;
       Project  : Project_Type) return Node_Types
   is
   begin
      if Project.Modified then
         return Modified_Project_Node;
      elsif Project = Explorer.Kernel.Registry.Tree.Root_Project then
         return Root_Project_Node;
      elsif Extending_Project (Project) /= No_Project then
         return Extends_Project_Node;
      else
         return Project_Node;
      end if;
   end Compute_Project_Node_Type;

   ---------
   -- "<" --
   ---------

   function "<" (D1, D2 : Directory_Info) return Boolean is
   begin
      if D1.Kind < D2.Kind then
         return True;
      elsif D1.Kind = D2.Kind then
         return D1.Directory < D2.Directory;
      else
         return False;
      end if;
   end "<";

   ------------------------------
   -- Filter_Matches_Primitive --
   ------------------------------

   overriding function Filter_Matches_Primitive
     (Context : access Project_View_Filter_Record;
      Ctxt    : GPS.Kernel.Selection_Context) return Boolean
   is
      pragma Unreferenced (Context);
   begin
      return Module_ID (Get_Creator (Ctxt)) = Explorer_Views.Get_Module;
   end Filter_Matches_Primitive;

   ------------------------------
   -- Filter_Matches_Primitive --
   ------------------------------

   overriding function Filter_Matches_Primitive
     (Context : access Project_Node_Filter_Record;
      Ctxt    : GPS.Kernel.Selection_Context) return Boolean
   is
      pragma Unreferenced (Context);
   begin
      return Module_ID (Get_Creator (Ctxt)) = Explorer_Views.Get_Module
        and then Has_Project_Information (Ctxt)
        and then not Has_Directory_Information (Ctxt);
   end Filter_Matches_Primitive;

   ------------------------------
   -- Filter_Matches_Primitive --
   ------------------------------

   overriding function Filter_Matches_Primitive
     (Context : access Directory_Node_Filter_Record;
      Ctxt    : GPS.Kernel.Selection_Context) return Boolean
   is
      pragma Unreferenced (Context);
   begin
      return Module_ID (Get_Creator (Ctxt)) = Explorer_Views.Get_Module
        and then Has_Directory_Information (Ctxt)
        and then not Has_File_Information (Ctxt);
   end Filter_Matches_Primitive;

   ------------------------------
   -- Filter_Matches_Primitive --
   ------------------------------

   overriding function Filter_Matches_Primitive
     (Context : access File_Node_Filter_Record;
      Ctxt    : GPS.Kernel.Selection_Context) return Boolean
   is
      pragma Unreferenced (Context);
   begin
      return Module_ID (Get_Creator (Ctxt)) = Explorer_Views.Get_Module
        and then Has_File_Information (Ctxt)
        and then not Has_Entity_Name_Information (Ctxt);
   end Filter_Matches_Primitive;

   ------------------------------
   -- Filter_Matches_Primitive --
   ------------------------------

   overriding function Filter_Matches_Primitive
     (Context : access Entity_Node_Filter_Record;
      Ctxt    : GPS.Kernel.Selection_Context) return Boolean
   is
      pragma Unreferenced (Context);
   begin
      return Module_ID (Get_Creator (Ctxt)) = Explorer_Views.Get_Module
        and then Has_Entity_Name_Information (Ctxt);
   end Filter_Matches_Primitive;

   ----------------------
   -- Set_Column_Types --
   ----------------------

   procedure Set_Column_Types (Tree : Gtk_Tree_View) is
      Col         : Gtk_Tree_View_Column;
      Text_Rend   : Gtk_Cell_Renderer_Text;
      Pixbuf_Rend : Gtk_Cell_Renderer_Pixbuf;
      Dummy       : Gint;
      pragma Unreferenced (Dummy);

   begin
      Gtk_New (Text_Rend);
      Gtk_New (Pixbuf_Rend);

      Set_Rules_Hint (Tree, False);

      Gtk_New (Col);
      Pack_Start (Col, Pixbuf_Rend, False);
      Pack_Start (Col, Text_Rend, True);
      Add_Attribute (Col, Pixbuf_Rend, "icon-name", Icon_Column);
      Add_Attribute (Col, Text_Rend, "markup", Display_Name_Column);
      Dummy := Append_Column (Tree, Col);
   end Set_Column_Types;

   ------------------
   -- Button_Press --
   ------------------

   function Button_Press
     (Explorer : access GObject_Record'Class;
      Event    : Gdk_Event_Button) return Boolean
   is
      T : constant Project_Explorer := Project_Explorer (Explorer);
   begin
      --  If expanding/collapsing, don't handle  button clicks
      if T.Expanding then
         T.Expanding := False;
         return False;
      else
         return On_Button_Press
           (T.Kernel,
            MDI_Explorer_Child
              (Explorer_Views.Child_From_View (T)),
            T.Tree, T.Tree.Model, Event, Add_Dummy => False);
      end if;
   exception
      when E : others =>
         Trace (Me, E);
         return False;
   end Button_Press;

   ---------------
   -- Key_Press --
   ---------------

   function Key_Press
     (Explorer : access Gtk_Widget_Record'Class;
      Event    : Gdk_Event) return Boolean
   is
      T : constant Project_Explorer := Project_Explorer (Explorer);
   begin
      return On_Key_Press (T.Kernel, T.Tree, Event);
   exception
      when E : others =>
         Trace (Me, E);
         return False;
   end Key_Press;

   ------------------------
   -- Tree_Select_Row_Cb --
   ------------------------

   procedure Tree_Select_Row_Cb
     (Explorer : access Gtk.Widget.Gtk_Widget_Record'Class; Args : GValues)
   is
      pragma Unreferenced (Args);
      T : constant Project_Explorer := Project_Explorer (Explorer);
      Child : constant GPS_MDI_Child := Explorer_Views.Child_From_View (T);
   begin
      T.Kernel.Context_Changed (Child.Build_Context);
   end Tree_Select_Row_Cb;

   ----------------
   -- Initialize --
   ----------------

   function Initialize
     (Explorer : access Project_Explorer_Record'Class)
      return Gtk.Widget.Gtk_Widget
   is
      H1       : Refresh_Hook;
      H2       : Project_Hook;
      Tooltip  : Explorer_Tooltips_Access;
      Scrolled : Gtk_Scrolled_Window;
   begin
      Initialize_Vbox (Explorer, Homogeneous => False);

      Gtk_New (Scrolled);
      Scrolled.Set_Policy (Policy_Automatic, Policy_Automatic);
      Explorer.Pack_Start (Scrolled, Expand => True, Fill => True);

      Gtk_New (Explorer.Tree, Columns_Types, Filtered => True);
      Set_Headers_Visible (Explorer.Tree, False);
      Explorer.Tree.Set_Enable_Search (False);
      Set_Column_Types (Gtk_Tree_View (Explorer.Tree));

      Set_Visible_Funcs.Set_Visible_Func
         (Explorer.Tree.Filter, Is_Visible'Access, Data => Explorer);

      Set_Name (Explorer.Tree, "Project Explorer Tree");  --  For testsuite

      Scrolled.Add (Explorer.Tree);

      Setup_Contextual_Menu
        (Kernel          => Explorer.Kernel,
         Event_On_Widget => Explorer.Tree);

      --  The contents of the nodes is computed on demand. We need to be aware
      --  when the user has changed the visibility status of a node.

      Widget_Callback.Object_Connect
        (Explorer.Tree,
         Signal_Row_Expanded,
         Widget_Callback.To_Marshaller (Expand_Row_Cb'Access),
         Explorer);
      Widget_Callback.Object_Connect
        (Explorer.Tree,
         Signal_Row_Collapsed,
         Widget_Callback.To_Marshaller (Collapse_Row_Cb'Access),
         Explorer);

      Explorer.Tree.On_Button_Release_Event (Button_Press'Access, Explorer);
      Explorer.Tree.On_Button_Press_Event (Button_Press'Access, Explorer);

      Gtkada.Handlers.Return_Callback.Object_Connect
        (Explorer.Tree,
         Signal_Key_Press_Event,
         Gtkada.Handlers.Return_Callback.To_Marshaller (Key_Press'Access),
         Slot_Object => Explorer,
         After       => False);

      Widget_Callback.Object_Connect
        (Get_Selection (Explorer.Tree), Signal_Changed,
         Tree_Select_Row_Cb'Access, Explorer, After => True);

      --  Automatic update of the tree when the project changes
      H1 := new Refresh_Hook_Record'
        (Function_No_Args with Explorer => Project_Explorer (Explorer));
      Add_Hook
        (Explorer.Kernel, Project_View_Changed_Hook, H1,
         Name => "explorer.project_view_changed", Watch => GObject (Explorer));

      H2 := new Project_Changed_Hook_Record'
        (Function_No_Args with Explorer => Project_Explorer (Explorer));
      Add_Hook
        (Explorer.Kernel, Project_Changed_Hook, H2,
         Name => "explorer.project_changed", Watch => GObject (Explorer));

      --  The explorer (project view) is automatically refreshed when the
      --  project view is changed.

      Gtk.Dnd.Dest_Set
        (Explorer.Tree, Dest_Default_All, Target_Table_Url, Action_Any);
      Kernel_Callback.Connect
        (Explorer.Tree, Signal_Drag_Data_Received,
         Drag_Data_Received'Access, Explorer.Kernel);

      --  Sorting is now alphabetic: directories come first, then files. Use
      --  a custom sort function

      Set_Sort_Func
        (+Explorer.Tree.Model,
         Display_Name_Column,
         Sort_Func      => Sort_Func'Access);
      Set_Sort_Column_Id
        (+Explorer.Tree.Model, Display_Name_Column, Sort_Ascending);

      --  Initialize tooltips

      Tooltip := new Explorer_Tooltips;
      Tooltip.Explorer := Project_Explorer (Explorer);
      Tooltip.Set_Tooltip (Explorer.Tree);

      Refresh (Explorer);

      Add_Hook (Explorer.Kernel, Preference_Changed_Hook,
                Wrapper (Preferences_Changed'Access),
                Name => "project_Explorer.preferences_changed",
                Watch => GObject (Explorer));
      Preferences_Changed (Explorer.Kernel, null);

      return Gtk.Widget.Gtk_Widget (Explorer.Tree);
   end Initialize;

   ---------------
   -- Sort_Func --
   ---------------

   function Sort_Func
     (Model : Gtk_Tree_Model;
      A     : Gtk.Tree_Model.Gtk_Tree_Iter;
      B     : Gtk.Tree_Model.Gtk_Tree_Iter) return Gint
   is
      A_Before_B : Gint := -1;
      B_Before_A : Gint := 1;
      M          : constant Gtk_Tree_Store := -Model;
      A_Type     : constant Node_Types :=
                     Get_Node_Type (M, A);
      B_Type     : constant Node_Types :=
                     Get_Node_Type (M, B);
      Order      : Gtk_Sort_Type;
      Column     : Gint;

      function Alphabetical return Gint;
      --  Compare the two nodes alphabetically
      --  ??? Should take into account the sorting order

      ------------------
      -- Alphabetical --
      ------------------

      function Alphabetical return Gint is
         A_Name : constant String := To_Lower (Get_String (Model, A, Column));
         B_Name : constant String := To_Lower (Get_String (Model, B, Column));
      begin
         if A_Name < B_Name then
            return A_Before_B;
         elsif A_Name = B_Name then
            case A_Type is   --  same as B_Type
               when Project_Node_Types | Directory_Node_Types | File_Node =>

                  if Get_File (Model, A, File_Column) <
                    Get_File (Model, B, File_Column)
                  then
                     return A_Before_B;
                  else
                     return B_Before_A;
                  end if;

               when others =>
                  return A_Before_B;
            end case;
         else
            return B_Before_A;
         end if;
      end Alphabetical;

      Projects_Before_Directories : constant Boolean :=
        Boolean_User_Data.Get (M, User_Data_Projects_Before_Directories);

   begin
      Get_Sort_Column_Id (M, Column, Order);
      if Order = Sort_Descending then
         A_Before_B := 1;
         B_Before_A := -1;
      end if;

      --  Subprojects first

      case A_Type is
         when Project_Node_Types =>
            case B_Type is
               when Project_Node_Types =>
                  return Alphabetical;

               when Runtime_Node =>
                  return A_Before_B;

               when others =>
                  if Projects_Before_Directories then
                     return A_Before_B;
                  else
                     return B_Before_A;
                  end if;
            end case;

         when Directory_Node =>
            case B_Type is
               when Project_Node_Types =>
                  if Projects_Before_Directories then
                     return B_Before_A;
                  else
                     return A_Before_B;
                  end if;

               when Directory_Node =>
                  return Alphabetical;

               when others =>
                  return A_Before_B;
            end case;

         when Obj_Directory_Node | Lib_Directory_Node =>
            case B_Type is
               when Project_Node_Types =>
                  if Projects_Before_Directories then
                     return B_Before_A;
                  else
                     return A_Before_B;
                  end if;

               when Directory_Node =>
                  return B_Before_A;

               when Obj_Directory_Node | Lib_Directory_Node =>
                  return Alphabetical;

               when Runtime_Node =>
                  return A_Before_B;

               when others =>
                  return B_Before_A;
            end case;

         when Exec_Directory_Node =>
            case B_Type is
               when Project_Node_Types =>
                  if Projects_Before_Directories then
                     return B_Before_A;
                  else
                     return A_Before_B;
                  end if;

               when Directory_Node | Obj_Directory_Node | Lib_Directory_Node =>
                  return B_Before_A;

               when Exec_Directory_Node =>
                  return Alphabetical;

               when Runtime_Node =>
                  return A_Before_B;

               when others =>
                  return B_Before_A;
            end case;

         when Runtime_Node =>
            return B_Before_A;

         when File_Node =>
            case B_Type is
               when Project_Node_Types =>
                  if Projects_Before_Directories then
                     return B_Before_A;
                  else
                     return A_Before_B;
                  end if;

               when Obj_Directory_Node | Lib_Directory_Node =>
                  return A_Before_B;

               when others =>
                  return Alphabetical;
            end case;

         when others =>
            if B_Type = A_Type then
               return Alphabetical;
            else
               return B_Before_A;
            end if;
      end case;
   end Sort_Func;

   -------------------------
   -- Preferences_Changed --
   -------------------------

   procedure Preferences_Changed
     (Kernel : access Kernel_Handle_Record'Class;
      Data   : access Hooks_Data'Class)
   is
      Explorer : constant Project_Explorer :=
        Explorer_Views.Retrieve_View (Kernel);
      Pref : Preference;
   begin
      if Explorer /= null then
         Pref := Get_Pref (Data);
         Set_Font_And_Colors (Explorer.Tree, Fixed_Font => True, Pref => Pref);

         if Pref = null   --  multiple preferences updated
           or else Pref = Preference (Show_Flat_View)
           or else Pref = Preference (Show_Directories)
           or else Pref = Preference (Show_Hidden_Dirs)
           or else Pref = Preference (Show_Object_Dirs)
           or else Pref = Preference (Show_Empty_Dirs)
           or else Pref = Preference (Show_Runtime)
           or else Pref = Preference (Projects_Before_Directories)
         then
            Update_View (Explorer);
         end if;

         if Pref = Preference (Show_Absolute_Paths) then
            Update_Absolute_Paths (Explorer);
         end if;

      end if;
   end Preferences_Changed;

   --------------------
   -- Create_Toolbar --
   --------------------

   overriding procedure Create_Toolbar
     (View    : not null access Project_Explorer_Record;
      Toolbar : not null access Gtk.Toolbar.Gtk_Toolbar_Record'Class)
   is
   begin
      View.Build_Filter
        (Toolbar     => Toolbar,
         Hist_Prefix => "project_view",
         Tooltip     => -"Filter the contents of the project view",
         Placeholder => -"filter",
         Options     =>
           Has_Regexp or Has_Negate or Has_Whole_Word or Has_Fuzzy);
   end Create_Toolbar;

   -----------------
   -- Create_Menu --
   -----------------

   overriding procedure Create_Menu
     (View    : not null access Project_Explorer_Record;
      Menu    : not null access Gtk.Menu.Gtk_Menu_Record'Class)
   is
      K : constant Kernel_Handle := View.Kernel;
   begin
      Append_Menu (Menu, K, Show_Absolute_Paths);
      Append_Menu (Menu, K, Show_Flat_View);
      Append_Menu (Menu, K, Show_Directories);
      Append_Menu (Menu, K, Show_Hidden_Dirs);
      Append_Menu (Menu, K, Show_Object_Dirs);
      Append_Menu (Menu, K, Show_Empty_Dirs);
      Append_Menu (Menu, K, Show_Runtime);
      Append_Menu (Menu, K, Projects_Before_Directories);
   end Create_Menu;

   ----------------
   -- Is_Visible --
   ----------------

   function Is_Visible
     (Child_Model : Gtk.Tree_Model.Gtk_Tree_Model;
      Iter        : Gtk.Tree_Model.Gtk_Tree_Iter;
      Self        : Project_Explorer) return Boolean
   is
      File   : Virtual_File;
   begin
      case Get_Node_Type (-Child_Model, Iter) is
         when Project_Node_Types | File_Node =>
            File := Get_File_From_Node (-Child_Model, Iter);
            return Is_Visible (Self.Filter, File) /= Hide;

         when Directory_Node_Types =>
            if Show_Empty_Dirs.Get_Pref
              or else Has_Child (Child_Model, Iter)
            then
               File := Get_File_From_Node (-Child_Model, Iter);
               return Is_Visible (Self.Filter, File) /= Hide;
            else
               return False;
            end if;

         when Category_Node | Entity_Node | Dummy_Node | Runtime_Node =>
            return True;
      end case;
   end Is_Visible;

   ----------------
   -- Is_Visible --
   ----------------

   function Is_Visible
     (Self : Explorer_Filter; File : Virtual_File) return Filter_Type
   is
      C : Filter_Maps.Cursor;
   begin
      if Self.Pattern = null then
         return Show_Direct;
      end if;

      C := Self.Cache.Find (File);
      if Has_Element (C) then
         return Element (C);
      end if;
      return Hide;
   end Is_Visible;

   -----------------
   -- Set_Pattern --
   -----------------

   procedure Set_Pattern
     (Self    : in out Explorer_Filter;
      Kernel  : not null access Kernel_Handle_Record'Class;
      Pattern : Search_Pattern_Access)
   is
      Show_Abs_Paths : constant Boolean := Show_Absolute_Paths.Get_Pref;
      Flat_View : constant Boolean := Show_Flat_View.Get_Pref;

      procedure Mark_Project_And_Parents_Visible (P : Project_Type);
      --  mark the given project node and all its parents as visible

      procedure Mark_Project_And_Parents_Visible (P : Project_Type) is
         It : Project_Iterator;
         C  : Filter_Maps.Cursor;
      begin
         C := Self.Cache.Find (P.Project_Path);
         if Has_Element (C) and then Element (C) /= Hide then
            --  Already marked, nothing more to do
            return;
         end if;

         Self.Cache.Include (P.Project_Path, Show_Indirect);

         if not Flat_View then
            It := P.Find_All_Projects_Importing
              (Include_Self => False, Direct_Only => False);
            while Current (It) /= No_Project loop
               Mark_Project_And_Parents_Visible (Current (It));
               Next (It);
            end loop;
         end if;
      end Mark_Project_And_Parents_Visible;

      PIter : Project_Iterator;
      P     : Project_Type;
      Files : File_Array_Access;
      Found : Boolean;
      Prj_Filter : Filter_Type;
   begin
      GPS.Search.Free (Self.Pattern);
      Self.Pattern := Pattern;

      Self.Cache.Clear;

      if Pattern = null then
         --  No filter applied, make all visible
         return;
      end if;

      PIter := Get_Project (Kernel).Start
        (Direct_Only      => False,
         Include_Extended => True);
      while Current (PIter) /= No_Project loop
         P := Current (PIter);

         if Self.Pattern.Start (P.Name) /= GPS.Search.No_Match then
            Prj_Filter := Show_Direct;
            Mark_Project_And_Parents_Visible (P);
            Self.Cache.Include (P.Project_Path, Show_Direct);
         else
            Prj_Filter := Hide;
         end if;

         Files := P.Source_Files (Recursive => False);
         for F in Files'Range loop
            Found :=
              (Show_Abs_Paths and then Self.Pattern.Start
                 (Files (F).Display_Full_Name) /= GPS.Search.No_Match)
              or else
              (not Show_Abs_Paths and then Self.Pattern.Start
                 (Files (F).Display_Base_Name) /= GPS.Search.No_Match);

            if Found then
               if Prj_Filter = Hide then
                  Prj_Filter := Show_Indirect;
                  Mark_Project_And_Parents_Visible (P);
               end if;

               Self.Cache.Include (Files (F).Dir, Show_Indirect);
               Self.Cache.Include (Files (F), Show_Direct);
            end if;
         end loop;
         Unchecked_Free (Files);

         Next (PIter);
      end loop;
   end Set_Pattern;

   --------------------
   -- Filter_Changed --
   --------------------

   overriding procedure Filter_Changed
     (Self    : not null access Project_Explorer_Record;
      Pattern : in out GPS.Search.Search_Pattern_Access) is
   begin
      Set_Pattern (Self.Filter, Self.Kernel, Pattern);
      Self.Tree.Filter.Refilter;
   end Filter_Changed;

   -------------------
   -- Build_Context --
   -------------------

   overriding function Build_Context
     (Self  : not null access Explorer_Child_Record;
      Event : Gdk.Event.Gdk_Event := null)
      return Selection_Context
   is
      T         : constant Project_Explorer :=
        Project_Explorer (GPS_MDI_Child (Self).Get_Actual_Widget);
      Filter_Iter : constant Gtk_Tree_Iter :=
        Find_Iter_For_Event (T.Tree, Event);
      Iter        : Gtk_Tree_Iter;
      Filter_Path : Gtk_Tree_Path;
      Context : Selection_Context :=
        GPS_MDI_Child_Record (Self.all).Build_Context (Event);
   begin
      if Filter_Iter = Null_Iter then
         return Context;
      end if;

      Filter_Path := Get_Path (T.Tree.Get_Model, Filter_Iter);
      if not Path_Is_Selected (Get_Selection (T.Tree), Filter_Path) then
         Set_Cursor (T.Tree, Filter_Path, null, False);
      end if;
      Path_Free (Filter_Path);

      T.Tree.Convert_To_Store_Iter
        (Store_Iter => Iter, Filter_Iter => Filter_Iter);
      Project_Explorers_Common.Context_Factory
        (Context, T.Kernel, T.Tree.Model, Iter);
      return Context;
   end Build_Context;

   -------------
   -- Execute --
   -------------

   overriding procedure Execute
     (Hook   : Project_Changed_Hook_Record;
      Kernel : access Kernel_Handle_Record'Class)
   is
      pragma Unreferenced (Kernel);
   begin
      --  Destroy all the items in the tree.
      --  The next call to refresh via the "project_view_changed" signal will
      --  completely restore the tree.

      Clear (Hook.Explorer.Tree.Model);
   end Execute;

   -------------
   -- Execute --
   -------------

   overriding function Execute
     (Self    : access Toggle_Absolute_Path_Command;
      Context : Commands.Interactive.Interactive_Command_Context)
      return Commands.Command_Return_Type
   is
      pragma Unreferenced (Self);
      K : constant Kernel_Handle := Get_Kernel (Context.Context);
   begin
      Set_Pref (Show_Absolute_Paths, K.Get_Preferences,
                not Show_Absolute_Paths.Get_Pref);
      return Commands.Success;
   end Execute;

   ---------------------------
   -- Update_Absolute_Paths --
   ---------------------------

   procedure Update_Absolute_Paths
     (Explorer : access Gtk_Widget_Record'Class)
   is
      Exp : constant Project_Explorer := Project_Explorer (Explorer);
      Show_Abs_Paths : constant Boolean := Show_Absolute_Paths.Get_Pref;

      procedure Process_Node (Iter : Gtk_Tree_Iter; Project : Project_Type);
      --  Recursively process node

      ------------------
      -- Process_Node --
      ------------------

      procedure Process_Node (Iter : Gtk_Tree_Iter; Project : Project_Type) is
         It   : Gtk_Tree_Iter := Children (Exp.Tree.Model, Iter);
         Prj  : Project_Type := Project;
      begin
         case Get_Node_Type (Exp.Tree.Model, Iter) is
            when Project_Node_Types =>
               Prj := Get_Project_From_Node
                 (Exp.Tree.Model, Exp.Kernel, Iter, False);

            when Directory_Node_Types
               | File_Node | Category_Node | Entity_Node | Dummy_Node
               | Runtime_Node =>
               null;
         end case;

         while It /= Null_Iter loop
            case Get_Node_Type (Exp.Tree.Model, It) is
               when Project_Node_Types =>
                  Process_Node (It, No_Project);

               when Directory_Node_Types =>
                  Set (Exp.Tree.Model, It, Display_Name_Column,
                       Directory_Node_Text
                          (Show_Abs_Paths, Prj,
                           Get_File (Exp.Tree.Model, It, File_Column)));

               when others =>
                  null;
            end case;

            Next (Exp.Tree.Model, It);
         end loop;
      end Process_Node;

      Iter : Gtk_Tree_Iter := Get_Iter_First (Exp.Tree.Model);
      Sort : constant Gint := Freeze_Sort (Exp.Tree.Model);
   begin
      while Iter /= Null_Iter loop
         Process_Node (Iter, Get_Project (Exp.Kernel));
         Next (Exp.Tree.Model, Iter);
      end loop;

      Thaw_Sort (Exp.Tree.Model, Sort);
   end Update_Absolute_Paths;

   -----------------
   -- Update_View --
   -----------------

   procedure Update_View
     (Explorer : access Gtk_Widget_Record'Class)
   is
      Tree : constant Project_Explorer := Project_Explorer (Explorer);
      Pattern : Search_Pattern_Access := Tree.Filter.Pattern;
   begin
      --  Temporary clear the filter before rebuilding Tree.Model to avoid
      --  Storage_Error on Tree.Model.Clear call
      Tree.Filter.Cache.Clear;
      Tree.Filter.Pattern := null;
      Tree.Tree.Filter.Refilter;
      Tree.Tree.Model.Clear;
      Refresh (Explorer);
      --  Restore applied filter after Tree.Model rebuild
      Filter_Changed (Tree, Pattern);
   end Update_View;

   ---------------------
   -- Create_Contents --
   ---------------------

   overriding function Create_Contents
     (Tooltip  : not null access Explorer_Tooltips;
      Widget   : not null access Gtk.Widget.Gtk_Widget_Record'Class;
      X, Y     : Glib.Gint) return Gtk.Widget.Gtk_Widget
   is
      pragma Unreferenced (Widget);

      Filter_Path : Gtk_Tree_Path;
      Column     : Gtk_Tree_View_Column;
      Cell_X,
      Cell_Y     : Gint;
      Row_Found  : Boolean := False;
      Par, Filter_Iter, Iter  : Gtk_Tree_Iter;
      Node_Type  : Node_Types;
      File       : Virtual_File;
      Area       : Gdk_Rectangle;
      Label      : Gtk_Label;
      P          : Project_Type;
   begin
      Get_Path_At_Pos
        (Tooltip.Explorer.Tree, X, Y, Filter_Path,
         Column, Cell_X, Cell_Y, Row_Found);

      if not Row_Found then
         return null;

      else
         --  Now check that the cursor is over a text

         Filter_Iter :=
           Get_Iter (Tooltip.Explorer.Tree.Get_Model, Filter_Path);
         if Filter_Iter = Null_Iter then
            return null;
         end if;
      end if;

      Tooltip.Explorer.Tree.Filter.Convert_Iter_To_Child_Iter
        (Child_Iter => Iter, Filter_Iter => Filter_Iter);

      Get_Cell_Area (Tooltip.Explorer.Tree, Filter_Path, Column, Area);
      Path_Free (Filter_Path);

      Tooltip.Set_Tip_Area (Area);

      Node_Type := Get_Node_Type (Tooltip.Explorer.Tree.Model, Iter);

      case Node_Type is
         when Project_Node_Types =>
            --  Project or extended project full pathname
            File := Get_File (Tooltip.Explorer.Tree.Model, Iter, File_Column);
            Gtk_New (Label, File.Display_Full_Name);

         when Directory_Node_Types =>
            --  Directroy full pathname and project name
            --  Get parent node which is the project name
            Par := Parent (Tooltip.Explorer.Tree.Model, Iter);

            File := Get_File (Tooltip.Explorer.Tree.Model, Iter, File_Column);
            Gtk_New
              (Label, File.Display_Full_Name
               & ASCII.LF &
               (-"in project ") &
               Get_String
                 (Tooltip.Explorer.Tree.Model, Par, Display_Name_Column));

         when File_Node =>
            File := Get_File_From_Node (Tooltip.Explorer.Tree.Model, Iter);
            P := Get_Project_From_Node
              (Tooltip.Explorer.Tree.Model, Tooltip.Explorer.Kernel,
               Iter, Importing => False);
            Gtk_New
              (Label,
               File.Display_Full_Name
               & ASCII.LF &
               (-"in project ") & P.Name);

         when Entity_Node =>
            --  Entity (parameters) declared at Filename:line
            --  Get grand-parent node which is the filename node
            Par := Parent
              (Tooltip.Explorer.Tree.Model,
               Parent (Tooltip.Explorer.Tree.Model, Iter));

            Gtk_New (Label);
            Label.Set_Markup
              (Get_String
                 (Tooltip.Explorer.Tree.Model, Iter, Display_Name_Column)
               & ASCII.LF &
               (-"declared at ") &
               Get_String (Tooltip.Explorer.Tree.Model, Par,
                 Display_Name_Column)
               & ':' &
               Image (Integer
                 (Get_Int (Tooltip.Explorer.Tree.Model, Iter, Line_Column))));

         when others =>
            null;
      end case;

      return Gtk_Widget (Label);
   end Create_Contents;

   -------------------
   -- Expand_Row_Cb --
   -------------------

   procedure Expand_Row_Cb
     (Explorer    : access Gtk.Widget.Gtk_Widget_Record'Class;
      Filter_Iter : Gtk_Tree_Iter;
      Filter_Path : Gtk_Tree_Path)
   is
      T         : constant Project_Explorer := Project_Explorer (Explorer);
      Iter      : Gtk_Tree_Iter;
      Success   : Boolean;
      Dummy     : G_Source_Id;
      Sort_Col  : Gint;
      N_Type    : Node_Types;
      pragma Unreferenced (Success, Dummy);
   begin
      if T.Expanding or else Filter_Iter = Null_Iter then
         return;
      end if;

      T.Expanding := True;
      T.Tree.Convert_To_Store_Iter
        (Store_Iter => Iter, Filter_Iter => Filter_Iter);
      N_Type := Get_Node_Type (T.Tree.Model, Iter);
      Set_Node_Type (T.Tree.Model, Iter, N_Type, Expanded => True);

      Sort_Col := Freeze_Sort (T.Tree.Model);

      case N_Type is
         when Project_Node_Types =>
            if Has_Dummy_Iter (T.Tree.Model, Iter) then
               Refresh_Project_Node
                 (T, Iter, Flat_View => Show_Flat_View.Get_Pref);
               Success := Expand_Row (T.Tree, Filter_Path, Open_All => False);
            end if;

         when File_Node =>
            if Has_Dummy_Iter (T.Tree.Model, Iter) then
               Append_File_Info
                 (T.Kernel, T.Tree.Model, Iter,
                  Get_File_From_Node (T.Tree.Model, Iter), Sorted => False);
               Success := Expand_Row (T.Tree, Filter_Path, Open_All => False);
            end if;

         when Runtime_Node =>
            --  Following does nothing if info is aleeady there
            Append_Runtime_Info (T.Kernel, T.Tree.Model, Iter);
            Success := Expand_Row (T.Tree, Filter_Path, Open_All => False);

         when Directory_Node_Types | Category_Node | Entity_Node
            | Dummy_Node =>
            null;   --  nothing to do
      end case;

      Thaw_Sort (T.Tree.Model, Sort_Col);
      T.Expanding := False;

   exception
      when E : others =>
         Trace (Me, E);
         Thaw_Sort (T.Tree.Model, Sort_Col);
         T.Expanding := False;
   end Expand_Row_Cb;

   ---------------------
   -- Collapse_Row_Cb --
   ---------------------

   procedure Collapse_Row_Cb
     (Explorer    : access Gtk.Widget.Gtk_Widget_Record'Class;
      Filter_Iter : Gtk_Tree_Iter;
      Filter_Path : Gtk_Tree_Path)
   is
      pragma Unreferenced (Filter_Path);
      E : constant Project_Explorer := Project_Explorer (Explorer);
      Iter   : Gtk_Tree_Iter;
      N_Type : Node_Types;
   begin
      E.Tree.Convert_To_Store_Iter
         (Store_Iter => Iter, Filter_Iter => Filter_Iter);

      N_Type := Get_Node_Type (E.Tree.Model, Iter);
      Set_Node_Type   --  update the icon
        (E.Tree.Model, Iter, N_Type, Expanded => False);

      case N_Type is
         when File_Node =>
            --  Closing a file node should force a refresh of its
            --  contents the next time it is opened
            Remove_Child_Nodes (E.Tree.Model, Parent => Iter);
            Append_Dummy_Iter (E.Tree.Model, Iter);

         when others =>
            null;   --  nothing to do
      end case;

   end Collapse_Row_Cb;

   -------------
   -- Execute --
   -------------

   overriding procedure Execute
     (Hook   : Refresh_Hook_Record;
      Kernel : access Kernel_Handle_Record'Class)
   is
      pragma Unreferenced (Kernel);
   begin
      Refresh (Hook.Explorer);
   end Execute;

   -------------------------
   -- Directory_Node_Text --
   -------------------------

   function Directory_Node_Text
     (Show_Abs_Paths : Boolean;
      Project        : Project_Type;
      Dir            : Virtual_File) return String
   is
   begin
      if Show_Abs_Paths then
         return Dir.Display_Full_Name;
      else
         declare
            Rel : constant String :=
               +Relative_Path (Dir, Project.Project_Path.Dir);
         begin
            --  If there is in common is '/', we just use a full path
            --  instead, that looks better, especially for runtime files
            if Starts_With (Rel, "..")
              and then Greatest_Common_Path
                ((Dir, Project.Project_Path.Dir)).Full_Name.all = "/"
            then
               return Dir.Display_Full_Name;
            end if;

            if Rel = "" then
               return "";
            elsif Rel (Rel'Last) = '/' or else Rel (Rel'Last) = '\' then
               return Rel (Rel'First .. Rel'Last - 1);
            else
               return Rel;
            end if;
         end;
      end if;
   end Directory_Node_Text;

   -------------
   -- Refresh --
   -------------

   procedure Refresh (Explorer : access Gtk.Widget.Gtk_Widget_Record'Class) is
      T     : constant Project_Explorer := Project_Explorer (Explorer);
      Path_Start, Path_End : Gtk_Tree_Path;
      Success : Boolean;
      Id      : Gint;
   begin
      --  Cache the value for use in Sort_Func
      Boolean_User_Data.Set
        (T.Tree.Model,
         Projects_Before_Directories.Get_Pref,
         User_Data_Projects_Before_Directories);

      if Get_Project (T.Kernel) = No_Project then
         T.Tree.Model.Clear;
         return;
      end if;

      T.Tree.Filter.Ref;

      --  Store current settings (visible part, sort order,...)
      Id := Freeze_Sort (T.Tree.Model);
      T.Tree.Get_Visible_Range (Path_Start, Path_End, Success);

      --  Insert the nodes
      Refresh_Project_Node
        (Self      => T,
         Node      => Null_Iter,
         Flat_View => Show_Flat_View.Get_Pref);

      --  Restore initial settings

      if Success then
         T.Tree.Scroll_To_Cell
           (Path      => Path_Start,
            Column    => null,
            Use_Align => True,
            Row_Align => 0.0,
            Col_Align => 0.0);
         Path_Free (Path_Start);
         Path_Free (Path_End);
      end if;

      Thaw_Sort (T.Tree.Model, Id);
      T.Tree.Filter.Unref;
   end Refresh;

   -----------------------
   -- Find_Project_Node --
   -----------------------

   function Find_Project_Node
     (Self    : not null access Project_Explorer_Record'Class;
      Project : Project_Type) return Gtk_Tree_Iter
   is
      Flat_View : constant Boolean := Show_Flat_View.Get_Pref;
      Node     : Gtk_Tree_Iter;
      P        : Project_Type;
   begin
      if Project = No_Project then
         return Null_Iter;
      end if;

      if not Flat_View then
         Set_Pref (Show_Flat_View, Self.Kernel.Get_Preferences, True);
         Update_View (Self);
      end if;

      Node := Self.Tree.Model.Get_Iter_First;
      while Node /= Null_Iter loop
         P := Get_Project_From_Node
           (Self.Tree.Model, Self.Kernel, Node, Importing => False);
         if P = Project then
            return Node;
         end if;

         Self.Tree.Model.Next (Node);
      end loop;

      return Null_Iter;
   end Find_Project_Node;

   ------------------------
   -- For_Each_File_Node --
   ------------------------

   procedure For_Each_File_Node
     (Model    : Gtk_Tree_Store;
      Parent   : Gtk_Tree_Iter;
      Callback : not null access procedure (It : in out Gtk_Tree_Iter))
   is
      It, Current : Gtk_Tree_Iter;
   begin
      It := Model.Children (Parent);
      while It /= Null_Iter loop
         Current := It;
         Model.Next (It);
         case Get_Node_Type (Model, Current) is
            when File_Node      => Callback (Current);
            when Directory_Node =>
               For_Each_File_Node (Model, Current, Callback);
            when others         => null;
         end case;
      end loop;
   end For_Each_File_Node;

   --------------------------
   -- Refresh_Project_Node --
   --------------------------

   procedure Refresh_Project_Node
     (Self      : not null access Project_Explorer_Record'Class;
      Node      : Gtk_Tree_Iter;
      Flat_View : Boolean)
   is
      function Create_Or_Reuse_Project
        (P : Project_Type; Add_Dummy : Boolean := False) return Gtk_Tree_Iter;
      function Create_Or_Reuse_Directory
        (Dir : Directory_Info; Parent : Gtk_Tree_Iter) return Gtk_Tree_Iter;
      --  Create a new project node, or reuse one if it exists

      function Is_Hidden (Dir : Virtual_File) return Boolean;
      --  Return true if Dir contains an hidden directory (a directory matching
      --  the global GUI regexp for hidden directories).

      procedure Remove_If_Obsolete (C : in out Gtk_Tree_Iter);
      --  Remove C from the model if it matches a file which is no longer in
      --  the project.

      Show_Abs_Paths : constant Boolean := Show_Absolute_Paths.Get_Pref;
      Show_Obj_Dirs : constant Boolean := Show_Object_Dirs.Get_Pref;
      Show_Dirs : constant Boolean := Show_Directories.Get_Pref;

      Child   : Gtk_Tree_Iter;
      Files   : File_Array_Access;
      Project : Project_Type;
      Dirs    : Dirs_Files_Hash.Map;

      ---------------
      -- Is_Hidden --
      ---------------

      function Is_Hidden (Dir : Virtual_File) return Boolean is
         Show_Abs_Paths : constant Boolean := Show_Absolute_Paths.Get_Pref;
      begin
         return Is_Hidden
           (Self.Kernel, +Directory_Node_Text (Show_Abs_Paths, Project, Dir));
      end Is_Hidden;

      -----------------------------
      -- Create_Or_Reuse_Project --
      -----------------------------

      function Create_Or_Reuse_Project
        (P : Project_Type; Add_Dummy : Boolean := False) return Gtk_Tree_Iter
      is
         T : constant Node_Types := Compute_Project_Node_Type (Self, P);
      begin
         if Flat_View and then P = Get_Project (Self.Kernel) then
            Child := Create_Or_Reuse_Node
              (Model  => Self.Tree.Model,
               Parent => Node,
               Kind   => T,
               File   => P.Project_Path,
               Name   => P.Name & " (root project)",
               Add_Dummy => Add_Dummy);
         elsif P.Extending_Project /= No_Project then
            Child := Create_Or_Reuse_Node
              (Model  => Self.Tree.Model,
               Parent => Node,
               Kind   => T,
               File   => P.Project_Path,
               Name   => P.Name & " (extended)",
               Add_Dummy => Add_Dummy);
         else
            Child := Create_Or_Reuse_Node
              (Model  => Self.Tree.Model,
               Parent => Node,
               Kind   => T,
               File   => P.Project_Path,
               Name   => P.Name,
               Add_Dummy => Add_Dummy);
         end if;

         Set_File (Self.Tree.Model, Child, File_Column, P.Project_Path);

         --  If the node had been expanded before, we need to refresh its
         --  contents, since we might be called as part of project_view_changed

         if not Has_Dummy_Iter (Self.Tree.Model, Child) then
            Refresh_Project_Node (Self, Child, Flat_View => Flat_View);
         end if;

         return Child;
      end Create_Or_Reuse_Project;

      -------------------------------
      -- Create_Or_Reuse_Directory --
      -------------------------------

      function Create_Or_Reuse_Directory
        (Dir : Directory_Info; Parent : Gtk_Tree_Iter) return Gtk_Tree_Iter
      is
      begin
         return Create_Or_Reuse_Node
           (Model  => Self.Tree.Model,
            Parent => Parent,
            Kind   => Dir.Kind,
            File   => Dir.Directory,
            Name   =>
              Directory_Node_Text (Show_Abs_Paths, Project, Dir.Directory));
      end Create_Or_Reuse_Directory;

      ------------------------
      -- Remove_If_Obsolete --
      ------------------------

      procedure Remove_If_Obsolete (C : in out Gtk_Tree_Iter) is
         F : constant Virtual_File :=
           Get_File_From_Node (Self.Tree.Model, C);
         S : constant File_Info_Set :=
           Get_Registry (Self.Kernel).Tree.Info_Set (F);
      begin
         for N of S loop
            if File_Info'Class (N).Project = Project then
               return;
            end if;
         end loop;
         Self.Tree.Model.Remove (C);
      end Remove_If_Obsolete;

      Filter  : Filter_Type;
      Path    : Gtk_Tree_Path;
      Success : Boolean;
      pragma Unreferenced (Success);

   begin
      if Node = Null_Iter then
         if Flat_View then
            declare
               Iter : Project_Iterator := Get_Project (Self.Kernel).Start
                 (Direct_Only => False,
                  Include_Extended => True);
            begin
               while Current (Iter) /= No_Project loop
                  Filter := Is_Visible
                    (Self.Filter, Current (Iter).Project_Path);

                  if Filter = Show_Direct then
                     Child := Create_Or_Reuse_Project
                       (Current (Iter), Add_Dummy => True);
                  end if;

                  Next (Iter);
               end loop;
            end;
         else
            --  Create and expand the node for the root project
            Child := Create_Or_Reuse_Project
              (Get_Project (Self.Kernel), Add_Dummy => True);

            --  This only works if the tree is still associated with the model
            Path := Gtk_Tree_Path_New_First;
            Success := Expand_Row (Self.Tree, Path, False);
            Path_Free (Path);
         end if;
         return;
      end if;

      Project := Get_Project_From_Node
        (Self.Tree.Model, Self.Kernel, Node, Importing => False);
      Remove_Dummy_Iter (Self.Tree.Model, Node);

      --  Insert runtime files if requested

      if Project = Get_Project (Self.Kernel)
        and then Show_Runtime.Get_Pref
      then
         Child := Create_Or_Reuse_Node
           (Model  => Self.Tree.Model,
            Parent => Null_Iter,  --  always at toplevel
            Kind   => Runtime_Node,
            File   => No_File,
            Name   => "runtime",
            Add_Dummy => True);

         Remove_Child_Nodes (Self.Tree.Model, Parent => Child);
         Append_Dummy_Iter (Self.Tree.Model, Child);
      end if;

      --  Insert non-expanded nodes for imported projects

      if not Flat_View then
         declare
            Iter : Project_Iterator := Project.Start
              (Direct_Only => True, Include_Extended => True);
         begin
            while Current (Iter) /= No_Project loop
               if Current (Iter) /= Project then
                  Filter := Is_Visible
                    (Self.Filter, Current (Iter).Project_Path);

                  if Filter /= Hide then
                     Child := Create_Or_Reuse_Project
                       (Current (Iter), Add_Dummy => True);
                  end if;
               end if;

               Next (Iter);
            end loop;
         end;
      end if;

      --  Prepare list of directories

      if Show_Obj_Dirs then
         Dirs.Include
           ((Project.Object_Dir, Obj_Directory_Node), Files_List.Empty_List);

         if Project.Executables_Directory /= Project.Object_Dir then
            Dirs.Include
              ((Project.Executables_Directory, Exec_Directory_Node),
               Files_List.Empty_List);
         end if;

         if Project.Library_Directory /= Project.Object_Dir then
            Dirs.Include
              ((Project.Library_Directory, Lib_Directory_Node),
               Files_List.Empty_List);
         end if;
      end if;

      Files := Project.Source_Files (Recursive => False);

      if Show_Dirs then
         for Dir of Project.Source_Dirs loop
            Dirs.Include ((Dir, Directory_Node), Files_List.Empty_List);
         end loop;

         --  Prepare list of files

         for F in Files'Range loop
            Dirs ((Files (F).Dir, Directory_Node)).Append (Files (F));
         end loop;

         --  Remove obsolete directory nodes (which also removes all files at
         --  once, so is more efficient)
         declare
            Dir  : Virtual_File;
            Prev : Gtk_Tree_Iter;
            T    : Node_Types;
         begin
            Child := Self.Tree.Model.Children (Node);
            while Child /= Null_Iter loop
               T := Get_Node_Type (Self.Tree.Model, Child);
               Prev := Child;
               Self.Tree.Model.Next (Child);

               if T not in Project_Node_Types then
                  Dir := Get_File_From_Node (Self.Tree.Model, Prev);

                  if not Dirs.Contains ((Dir, T)) then
                     Self.Tree.Model.Remove (Prev);
                  end if;
               end if;
            end loop;
         end;
      end if;

      --  Remove obsolete file nodes

      For_Each_File_Node (Self.Tree.Model, Node, Remove_If_Obsolete'Access);

      --  Now insert directories and files (including object directories)

      declare
         Dir : Dirs_Files_Hash.Cursor := Dirs.First;
         Show_Hidden : constant Boolean := Show_Hidden_Dirs.Get_Pref;
         Previous : Directory_Info := (No_File, Dummy_Node);
      begin
         while Has_Element (Dir) loop
            if Show_Hidden or else not Is_Hidden (Key (Dir).Directory) then
               --  minor optimization, reuse dir if same as previous file
               if Key (Dir) /= Previous then
                  Previous := (Key (Dir).Directory, Key (Dir).Kind);
                  Child := Create_Or_Reuse_Directory (Key (Dir), Node);
               end if;

               for F of Dirs (Dir) loop
                  --  ??? This is O(n^2), since every time we insert a row
                  --  it will be searched next time.
                  Create_Or_Reuse_File
                    (Self.Tree.Model, Self.Kernel, Child, F);
               end loop;
            end if;

            Next (Dir);
         end loop;
      end;

      if not Show_Dirs then
         for F in Files'Range loop
            Create_Or_Reuse_File
              (Self.Tree.Model, Self.Kernel, Node, Files (F));
         end loop;
      end if;

      Unchecked_Free (Files);
   end Refresh_Project_Node;

   --------------------
   --  Jump_To_Node  --
   --------------------

   procedure Jump_To_Node
     (Explorer    : Project_Explorer;
      Target_Node : Gtk_Tree_Iter)
   is
      Path   : Gtk_Tree_Path;
      Parent : Gtk_Tree_Path;
      Filter_Path : Gtk_Tree_Path;

      procedure Expand_Recursive (Filter_Path : Gtk_Tree_Path);
      --  Expand Path and all parents of Path that are not expanded

      ----------------------
      -- Expand_Recursive --
      ----------------------

      procedure Expand_Recursive (Filter_Path : Gtk_Tree_Path) is
         Parent : constant Gtk_Tree_Path := Copy (Filter_Path);
         Dummy  : Boolean;
         pragma Warnings (Off, Dummy);
      begin
         Dummy := Up (Parent);

         if Dummy then
            if not Row_Expanded (Explorer.Tree, Parent) then
               Expand_Recursive (Parent);
            end if;
         end if;

         Path_Free (Parent);
         Dummy := Expand_Row (Explorer.Tree, Filter_Path, False);
      end Expand_Recursive;

   begin
      Grab_Focus (Explorer.Tree);

      Path := Get_Path (Explorer.Tree.Model, Target_Node);
      Filter_Path := Explorer.Tree.Filter.Convert_Child_Path_To_Path (Path);
      Parent := Copy (Filter_Path);
      if Up (Parent) then
         Expand_Recursive (Parent);
      end if;
      Path_Free (Parent);

      Set_Cursor (Explorer.Tree, Filter_Path, null, False);
      Scroll_To_Cell (Explorer.Tree, Filter_Path, null, True, 0.1, 0.1);

      Path_Free (Path);
      Path_Free (Filter_Path);
   end Jump_To_Node;

   -------------
   -- Execute --
   -------------

   overriding function Execute
     (Command : access Locate_File_In_Explorer_Command;
      Context : Interactive_Command_Context) return Command_Return_Type
   is
      Kernel   : constant Kernel_Handle := Get_Kernel (Context.Context);
      File     : constant Virtual_File := File_Information (Context.Context);
      S        : File_Info_Set;
      View     : constant Project_Explorer :=
        Explorer_Views.Get_Or_Create_View (Kernel);
      Node     : Gtk_Tree_Iter;
      Success  : Boolean;
      Filter_Path, Path : Gtk_Tree_Path;
      pragma Unreferenced (Command);

      procedure Select_If_Searched (C : in out Gtk_Tree_Iter);
      procedure Select_If_Searched (C : in out Gtk_Tree_Iter) is
      begin
         if not Success then
            if Get_File_From_Node (View.Tree.Model, C) = File then
               Jump_To_Node (View, C);
               Success := True;
            end if;
         end if;
      end Select_If_Searched;

   begin
      --  If the target node is not visible due to the current filter
      --  setting, clear the filter before jumping.

      if Is_Visible (View.Filter, File) = Hide then
         View.Set_Filter ("");
         View.Tree.Filter.Refilter;

         --  We use the "execute_again" mechanism here because the filter is
         --  applied not immediately but in an idle callback.
         return Execute_Again;
      end if;

      S := Get_Registry (Kernel).Tree.Info_Set (File);
      Node := Find_Project_Node
        (View, File_Info (S.First_Element).Project);

      if Node /= Null_Iter then
         --  Expand the project node, to compute its files
         Path := View.Tree.Model.Get_Path (Node);
         Filter_Path := View.Tree.Filter.Convert_Child_Path_To_Path (Path);
         Path_Free (Path);
         Success := View.Tree.Expand_Row (Filter_Path, False);
         Path_Free (Filter_Path);

         Success := False;
         For_Each_File_Node (View.Tree.Model, Node, Select_If_Searched'Access);
      end if;

      return Commands.Success;
   end Execute;

   -------------
   -- Execute --
   -------------

   overriding function Execute
     (Command : access Locate_Project_In_Explorer_Command;
      Context : Interactive_Command_Context) return Command_Return_Type
   is
      pragma Unreferenced (Command);
      Kernel   : constant Kernel_Handle := Get_Kernel (Context.Context);
      View     : constant Project_Explorer :=
        Explorer_Views.Get_Or_Create_View (Kernel);
      Node     : Gtk_Tree_Iter;
   begin
      Node := Find_Project_Node (View, Project_Information (Context.Context));
      if Node /= Null_Iter then
         Jump_To_Node (View, Node);
      end if;
      return Commands.Success;
   end Execute;

   ---------------------
   -- Register_Module --
   ---------------------

   procedure Register_Module
     (Kernel : access GPS.Kernel.Kernel_Handle_Record'Class)
   is
      Project_View_Filter   : constant Action_Filter :=
                                new Project_View_Filter_Record;
      Project_Node_Filter   : constant Action_Filter :=
                                new Project_Node_Filter_Record;
      Directory_Node_Filter : constant Action_Filter :=
                                new Directory_Node_Filter_Record;
      File_Node_Filter      : constant Action_Filter :=
                                new File_Node_Filter_Record;
      Entity_Node_Filter    : constant Action_Filter :=
                                new Entity_Node_Filter_Record;
      Command               : Interactive_Command_Access;

   begin
      Explorer_Views.Register_Module (Kernel => Kernel);

      Show_Flat_View := Kernel.Get_Preferences.Create_Invisible_Pref
        ("explorer-show-flat-view", False,
         Label => -"Show flat view");
      Show_Absolute_Paths := Kernel.Get_Preferences.Create_Invisible_Pref
        ("explorer-show-absolute-paths", False,
         Label => -"Show absolute paths");
      Show_Hidden_Dirs := Kernel.Get_Preferences.Create_Invisible_Pref
        ("explorer-show-hidden-directories", False,
         Label => -"Show hidden directories");
      Show_Empty_Dirs := Kernel.Get_Preferences.Create_Invisible_Pref
        ("explorer-show-empty-directories", True,
         Label => -"Show empty directories");
      Projects_Before_Directories :=
        Kernel.Get_Preferences.Create_Invisible_Pref
          ("explorer-show-projects-first", False,
           Label => -"Projects before directories",
           Doc =>
             -("Whether imported projects should occur before or after source"
             & " directories"));
      Show_Object_Dirs := Kernel.Get_Preferences.Create_Invisible_Pref
        ("explorer-show-object-dirs", True,
         Label => -"Show object directories");
      Show_Runtime := Kernel.Get_Preferences.Create_Invisible_Pref
        ("explorer-show-runtime", False,
         Label => "Show runtime files");
      Show_Directories := Kernel.Get_Preferences.Create_Invisible_Pref
        ("explorer-show-directories", True,
         Label => "Group by directories",
         Doc => -("If False, files are shown directly below the projects,"
           & " otherwise they are grouped by categories"));

      Register_Action
        (Kernel, "Locate file in explorer",
         new Locate_File_In_Explorer_Command,
         "Locate current file in project explorer",
         Lookup_Filter (Kernel, "File"), -"Project Explorer");

      Command := new Locate_File_In_Explorer_Command;
      Register_Contextual_Menu
        (Kernel, "Locate file in explorer",
         Action => Command,
         Filter => Lookup_Filter (Kernel, "In project")
                     and not Create (Module => Explorer_Module_Name),
         Label  => "Locate in Project View: %f");

      Command := new Locate_Project_In_Explorer_Command;
      Register_Contextual_Menu
        (Kernel, "Locate project in explorer",
         Action => Command,
         Filter => Lookup_Filter (Kernel, "Project only")
                     and not Create (Module => Explorer_Module_Name),
         Label  => "Locate in Project View: %p");

      Register_Action
        (Kernel, Toggle_Absolute_Path_Name,
         new Toggle_Absolute_Path_Command, Toggle_Absolute_Path_Tip,
         null, -"Project Explorer");

      Register_Filter
        (Kernel,
         Filter => Project_View_Filter,
         Name   => "Explorer_View");
      Register_Filter
        (Kernel,
         Filter => Project_Node_Filter,
         Name   => "Explorer_Project_Node");
      Register_Filter
        (Kernel,
         Filter => Directory_Node_Filter,
         Name   => "Explorer_Directory_Node");
      Register_Filter
        (Kernel,
         Filter => File_Node_Filter,
         Name   => "Explorer_File_Node");
      Register_Filter
        (Kernel,
         Filter => Entity_Node_Filter,
         Name   => "Explorer_Entity_Node");
   end Register_Module;

   ----------
   -- Hash --
   ----------

   function Hash (Key : Filesystem_String) return Ada.Containers.Hash_Type is
   begin
      return Ada.Strings.Hash (+Key);
   end Hash;

end Project_Explorers;
