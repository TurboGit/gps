with Gtk.Window; use Gtk.Window;
with Gtk.Box; use Gtk.Box;
with Gtk.Menu_Bar; use Gtk.Menu_Bar;
with Gtk.Menu_Item; use Gtk.Menu_Item;
with Gtk.Menu; use Gtk.Menu;
with Gtk.Handle_Box; use Gtk.Handle_Box;
with Gtk.Toolbar; use Gtk.Toolbar;
with Gtk.Pixmap; use Gtk.Pixmap;
with Gtk.Widget; use Gtk.Widget;
with Gtk.Notebook; use Gtk.Notebook;
with Gtk.Frame; use Gtk.Frame;
with Gtk.Label; use Gtk.Label;
with Gtk.Scrolled_Window; use Gtk.Scrolled_Window;
with Gtk.Ctree; use Gtk.Ctree;
with Gtk.Clist; use Gtk.Clist;
with Gtk.Status_Bar; use Gtk.Status_Bar;
with Gtk.Combo; use Gtk.Combo;
with Gtk.GEntry; use Gtk.GEntry;
with Gtk.Button; use Gtk.Button;
package Gui_Builder_Pkg is

   type Gui_Builder_Record is new Gtk_Window_Record with record
      Vbox4 : Gtk_Vbox;
      Menubar1 : Gtk_Menu_Bar;
      Menuitem13 : Gtk_Menu_Item;
      Menu1 : Gtk_Menu;
      Menuitem14 : Gtk_Menu_Item;
      Menuitem15 : Gtk_Menu_Item;
      Menuitem16 : Gtk_Menu_Item;
      Menuitem17 : Gtk_Menu_Item;
      Hbox1 : Gtk_Hbox;
      Vbox10 : Gtk_Vbox;
      Handlebox5 : Gtk_Handle_Box;
      Toolbar7 : Gtk_Toolbar;
      Button15 : Gtk_Widget;
      Button16 : Gtk_Widget;
      Button17 : Gtk_Widget;
      Handlebox6 : Gtk_Handle_Box;
      Notebook10 : Gtk_Notebook;
      Frame27 : Gtk_Frame;
      Toolbar8 : Gtk_Toolbar;
      Togglebutton28 : Gtk_Widget;
      Togglebutton29 : Gtk_Widget;
      Togglebutton30 : Gtk_Widget;
      Togglebutton31 : Gtk_Widget;
      Togglebutton32 : Gtk_Widget;
      Togglebutton33 : Gtk_Widget;
      Togglebutton34 : Gtk_Widget;
      Togglebutton35 : Gtk_Widget;
      Togglebutton36 : Gtk_Widget;
      Togglebutton37 : Gtk_Widget;
      Togglebutton38 : Gtk_Widget;
      Togglebutton39 : Gtk_Widget;
      Togglebutton40 : Gtk_Widget;
      Togglebutton41 : Gtk_Widget;
      Label74 : Gtk_Label;
      Frame28 : Gtk_Frame;
      Label75 : Gtk_Label;
      Frame29 : Gtk_Frame;
      Label76 : Gtk_Label;
      Frame30 : Gtk_Frame;
      Label77 : Gtk_Label;
      Frame31 : Gtk_Frame;
      Label78 : Gtk_Label;
      Scrolledwindow16 : Gtk_Scrolled_Window;
      Ctree2 : Gtk_Ctree;
      Label79 : Gtk_Label;
      Label80 : Gtk_Label;
      Statusbar2 : Gtk_Statusbar;
      Vbox11 : Gtk_Vbox;
      Combo3 : Gtk_Combo;
      Entry2 : Gtk_Entry;
      Notebook11 : Gtk_Notebook;
      Scrolledwindow17 : Gtk_Scrolled_Window;
      Clist9 : Gtk_Clist;
      Label81 : Gtk_Label;
      Label82 : Gtk_Label;
      Label83 : Gtk_Label;
      Scrolledwindow18 : Gtk_Scrolled_Window;
      Clist10 : Gtk_Clist;
      Label84 : Gtk_Label;
      Label85 : Gtk_Label;
      Label86 : Gtk_Label;
   end record;
   type Gui_Builder_Access is access all Gui_Builder_Record'Class;

   procedure Gtk_New (Gui_Builder : out Gui_Builder_Access);
   procedure Initialize (Gui_Builder : access Gui_Builder_Record'Class);

   Gui_Builder : Gui_Builder_Access;

end Gui_Builder_Pkg;
