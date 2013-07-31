------------------------------------------------------------------------------
--                                  G P S                                   --
--                                                                          --
--                     Copyright (C) 2005-2013, AdaCore                     --
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

--  This package helps build simple views that are associated with a single
--  window, that are saved in the desktop, and have a simple menu in Tools/
--  to open them.
--  This package must be instanciated at library-level

with GPS.Kernel.Modules;
with GPS.Kernel.MDI;
with Glib.Object;
with XML_Utils;
with Gtkada.Handlers;
with Gtk.Box;
with Gtk.Menu;
private with Gtk.Toggle_Tool_Button;
with Gtk.Toolbar;
with Gtk.Tool_Item;
with Gtk.Widget;
private with Gtkada.Search_Entry;
with Gtkada.MDI;
with Histories;

package Generic_Views is

   -----------------
   -- View_Record --
   -----------------

   type View_Record is new Gtk.Box.Gtk_Box_Record with private;
   type Abstract_View_Access is access all View_Record'Class;

   procedure Save_To_XML
     (View : access View_Record;
      XML  : in out XML_Utils.Node_Ptr) is null;
   --  Saves View's attributes to an XML node.
   --  Node has already been created (and the proper tag name set), but this
   --  procedure can add attributes or child nodes to it as needed.

   procedure Load_From_XML
     (View : access View_Record; XML : XML_Utils.Node_Ptr) is null;
   --  Initialize View from XML. XML is the contents of the desktop node for
   --  the View, and was generated by Save_To_XML.

   procedure Create_Toolbar
     (View    : not null access View_Record;
      Toolbar : not null access Gtk.Toolbar.Gtk_Toolbar_Record'Class)
     is null;
   --  If the view needs a local toolbar, this function is called when the
   --  toolbar needs to be filled. It is not called if Local_Toolbar is set to
   --  null in the instantiation of the generic below.
   --  This toolbar should contain operations that apply to the current view,
   --  but not settings or preferences for that view (use Create_Menu for the
   --  latter).

   procedure Create_Menu
     (View    : not null access View_Record;
      Menu    : not null access Gtk.Menu.Gtk_Menu_Record'Class) is null;
   --  Fill the menu created by the local configuration menu (see Local_Config
   --  in the generic formal parameters below).
   --  This menu should contain entries that configure the current view.

   procedure Append_Toolbar
     (Self      : not null access View_Record;
      Toolbar   : not null access Gtk.Toolbar.Gtk_Toolbar_Record'Class;
      Item      : not null access Gtk.Tool_Item.Gtk_Tool_Item_Record'Class;
      Is_Filter : Boolean := False);
   --  Appends an item to the local toolbar.
   --  If Is_Filter is True, the item will be right-aligned.
   --  It is better to use this procedure than Gtk.Toolbar.Insert, since the
   --  latter makes it harder to know how to append items to the left or to
   --  the right.

   function Kernel
     (Self : not null access View_Record'Class)
      return GPS.Kernel.Kernel_Handle;
   pragma Inline (Kernel);
   --  Return the kernel stored in Self

   procedure Set_Kernel
     (View   : not null access View_Record'Class;
      Kernel : not null access GPS.Kernel.Kernel_Handle_Record'Class);
   --  Set the Kernel field (needed only internally from the generic, where
   --  we can directly access the kernel field)

   ------------------------------
   -- Search and filter fields --
   ------------------------------

   type Filter_Options is record
      Regexp : Boolean;
      Negate : Boolean;
   end record;

   type Filter_Options_Mask is mod Natural'Last;
   Has_Regexp : constant Filter_Options_Mask := 2 ** 0;
   Has_Negate : constant Filter_Options_Mask := 2 ** 1;

   procedure Build_Filter
     (Self        : not null access View_Record;
      Toolbar     : not null access Gtk.Toolbar.Gtk_Toolbar_Record'Class;
      Hist_Prefix : Histories.History_Key;
      Tooltip     : String := "";
      Placeholder : String := "";
      Options     : Filter_Options_Mask := 0);
   --  Build a search field which provides a standard look-and-feel:
   --     * rounded corner (through the theme)
   --     * "clear" icon
   --     * placeholder text
   --     * tooltip
   --     * a number of predefined options
   --     * remember option settings across sessions (through Hist_Prefix)
   --  Whenever the pattern is changed (or cleared), Self.Filter_Changed is
   --  called.
   --  Nothing is done if the filter panel has already been built.
   --  This function should be called from Create_Toolbar.

   procedure Filter_Changed
     (Self    : not null access View_Record;
      Pattern : String;
      Options : Filter_Options) is null;
   --  Called when the user has changed the filter applied to the view. Some
   --  of the patterns in Options might be irrelevant, depending on the
   --  mask set in Build_Filter.

   ------------------
   -- Simple_Views --
   ------------------

   generic
      Module_Name : String;
      --  The name of the module, and name used in the desktop file. It mustn't
      --  contain any space.

      View_Name   : String;
      --  Name of MDI window that is used to create the view

      type Formal_View_Record is new View_Record with private;
      --  Type of the widget representing the view

      type Formal_MDI_Child is new GPS.Kernel.MDI.GPS_MDI_Child_Record
        with private;
      --  The type of MDI child, in case the view needs to use a specialized
      --  type, for instance to add drag-and-drop capabilities

      Reuse_If_Exist : Boolean;
      --  If True a single MDI child will be created and shared

      with function Initialize
        (View : access Formal_View_Record'Class)
         return Gtk.Widget.Gtk_Widget is <>;
      --  Function used to create the view itself.
      --  The Gtk_Widget returned, if non-null, is the Focus Widget to pass
      --  to the MDI.

      Local_Toolbar : Boolean := False;
      --  Whether the view should contain a local toolbar. If it does, the
      --  toolbar will be filled by calling the Create_Toolbar primitive
      --  operation on the view.

      Local_Config : Boolean := False;
      --  If true, a button will be displayed to show the configuration menu
      --  for the view. If true, this also forces the use of a local toolbar.

      Position : Gtkada.MDI.Child_Position := Gtkada.MDI.Position_Bottom;
      --  The preferred position for newly created views.

      Group  : Gtkada.MDI.Child_Group := GPS.Kernel.MDI.Group_View;
      --  The group for newly created views.

      Commands_Category : String := "Views";
      --  Name of the category in the Key Shortcuts editor for the commands
      --  declared in this package. If this is the empty string, no command is
      --  registered.

      MDI_Flags : Gtkada.MDI.Child_Flags := Gtkada.MDI.All_Buttons;
      --  Special flags used when creating the MDI window.

      Areas : Gtkada.MDI.Allowed_Areas := Gtkada.MDI.Both;
      --  Where is the view allowed to go ?

   package Simple_Views is

      type View_Access is access all Formal_View_Record'Class;

      procedure Register_Module
        (Kernel      : access GPS.Kernel.Kernel_Handle_Record'Class;
         ID          : GPS.Kernel.Modules.Module_ID := null;
         Menu_Name   : String := "Views/" & View_Name;
         Before_Menu : String := "");
      --  Register the module. This sets it up for proper desktop handling, as
      --  well as create a menu in Tools/ so that the user can open the view.
      --  ID can be passed in parameter if a special tagged type needs to be
      --  used.
      --  Menu_Name is the name of the menu, in tools, that is used to create
      --  the view.
      --  If Before_Menu is not empty, the menu entry will be added before it.

      function Get_Module return GPS.Kernel.Modules.Module_ID;
      --  Return the module ID corresponding to that view

      function Get_Or_Create_View
        (Kernel : access GPS.Kernel.Kernel_Handle_Record'Class;
         Focus  : Boolean := True)
         return View_Access;
      --  Return the view (create a new one if necessary, or always if
      --  Reuse_If_Exist is False).
      --  The view gets the focus automatically if Focus is True.

      function Retrieve_View
        (Kernel : access GPS.Kernel.Kernel_Handle_Record'Class)
         return View_Access;
      --  Retrieve any of the existing views.

      function View_From_Widget
        (Widget : not null access Glib.Object.GObject_Record'Class)
         return View_Access;
      --  WHen using a local toolbar, the actual widget stored in the child is
      --  not the formal view itself. This function can be used in all cases
      --  to convert from a Child.Get_Widget to a Formal_View

      function Child_From_View
        (View : not null access Formal_View_Record'Class)
         return Gtkada.MDI.MDI_Child;
      --  Return the MDI Child containing view.

      procedure Register_Open_Menu
        (Kernel    : access GPS.Kernel.Kernel_Handle_Record'Class;
         Menu_Name : String;
         Item_Name : String;
         Before    : String := "");
      --  Creates a new toplevel menu used to open the view. One such menu is
      --  already created by Register_Module, so this procedure is only useful
      --  for additional menus to open the same view.

   private
      --  The following subprograms need to be in the spec so that we can get
      --  access to them from callbacks in the body

      procedure On_Open_View
        (Widget : access Glib.Object.GObject_Record'Class;
         Kernel : GPS.Kernel.Kernel_Handle);
      On_Open_View_Access : constant
        GPS.Kernel.MDI.Kernel_Callback.Marshallers.Void_Marshaller.Handler :=
          On_Open_View'Access;
      --  Create a new view if none exists, or raise the existing one

      function Load_Desktop
        (MDI  : Gtkada.MDI.MDI_Window;
         Node : XML_Utils.Node_Ptr;
         User : GPS.Kernel.Kernel_Handle) return Gtkada.MDI.MDI_Child;
      Load_Desktop_Access : constant
        GPS.Kernel.MDI.Load_Desktop_Function := Load_Desktop'Access;
      function Save_Desktop
        (Widget : access Gtk.Widget.Gtk_Widget_Record'Class;
         User   : GPS.Kernel.Kernel_Handle) return XML_Utils.Node_Ptr;
      Save_Desktop_Access : constant
        GPS.Kernel.MDI.Save_Desktop_Function := Save_Desktop'Access;
      --  Support functions for the MDI

      procedure On_Display_Local_Config
        (View : access Gtk.Widget.Gtk_Widget_Record'Class);
      On_Display_Local_Config_Access : constant
        Gtkada.Handlers.Widget_Callback.Simple_Handler :=
          On_Display_Local_Config'Access;
      --  Called to display the local config menu

      function On_Delete_Event
        (Box : access Gtk.Widget.Gtk_Widget_Record'Class) return Boolean;
      On_Delete_Event_Access : constant
        Gtkada.Handlers.Return_Callback.Simple_Handler :=
          On_Delete_Event'Access;
      --  Propagate the delete event to the view
   end Simple_Views;

private
   type Filter_Panel_Record is new Gtk.Tool_Item.Gtk_Tool_Item_Record
     with record
      Pattern : Gtkada.Search_Entry.Gtkada_Search_Entry;
      Regexp  : Gtk.Toggle_Tool_Button.Gtk_Toggle_Tool_Button;
      Negate  : Gtk.Toggle_Tool_Button.Gtk_Toggle_Tool_Button;
     end record;
   type Filter_Panel is access all Filter_Panel_Record'Class;

   type View_Record is new Gtk.Box.Gtk_Box_Record with record
      Kernel : GPS.Kernel.Kernel_Handle;
      Filter : Filter_Panel;   --  might be null
   end record;

end Generic_Views;
