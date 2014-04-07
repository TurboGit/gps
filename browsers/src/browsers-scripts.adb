------------------------------------------------------------------------------
--                                  G P S                                   --
--                                                                          --
--                     Copyright (C) 2014, AdaCore                          --
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

with Cairo.Pattern;           use Cairo, Cairo.Pattern;
with Glib;                    use Glib;
with Glib.Object;             use Glib.Object;
with Gdk.RGBA;                use Gdk.RGBA;
with Generic_Views;
with GNATCOLL.Scripts;        use GNATCOLL.Scripts;
with GNATCOLL.Scripts.Gtkada; use GNATCOLL.Scripts.Gtkada;
with GNATCOLL.Traces;         use GNATCOLL.Traces;
with GNATCOLL.Utils;          use GNATCOLL.Utils;
with GNAT.Strings;            use GNAT.Strings;
with Gtkada.Canvas_View;      use Gtkada.Canvas_View;
with Gtkada.MDI;              use Gtkada.MDI;
with Gtkada.Style;            use Gtkada.Style;
with Gtk.Box;                 use Gtk.Box;
with Gtk.Enums;               use Gtk.Enums;
with Gtk.Scrolled_Window;     use Gtk.Scrolled_Window;
with Gtk.Widget;              use Gtk.Widget;
with GPS.Kernel;              use GPS.Kernel;
with GPS.Kernel.MDI;          use GPS.Kernel.MDI;
with GPS.Kernel.Modules;      use GPS.Kernel.Modules;
with GPS.Kernel.Scripts;      use GPS.Kernel.Scripts;
with Pango.Enums;             use Pango.Enums;
with Pango.Font;              use Pango.Font;

package body Browsers.Scripts is
   Me : constant Trace_Handle := Create ("BROWSERS");

   type Browsers_Scripts_Module is new Module_ID_Record with record
      View_Class : Class_Type;
      Item_Class : Class_Type;
   end record;
   Module : access Browsers_Scripts_Module'Class;

   P_Stroke             : constant := 2;
   P_Fill               : constant := 3;
   P_Line_Width         : constant := 4;
   P_Dashes             : constant := 5;
   P_Sloppy             : constant := 6;
   P_Font_Name          : constant := 7;
   P_Font_Underline     : constant := 8;
   P_Font_Strikethrough : constant := 9;
   P_Font_Color         : constant := 10;
   P_Font_LS            : constant := 11;
   P_Font_Halign        : constant := 12;
   P_Font_Valign        : constant := 13;
   P_Arrow_From_Head    : constant := 14;
   P_Arrow_From_Length  : constant := 15;
   P_Arrow_From_Angle   : constant := 16;
   P_Arrow_From_Stroke  : constant := 17;
   P_Arrow_From_Fill    : constant := 18;
   P_Arrow_From_Width   : constant := 19;
   P_Arrow_To_Head      : constant := 20;
   P_Arrow_To_Length    : constant := 21;
   P_Arrow_To_Angle     : constant := 22;
   P_Arrow_To_Stroke    : constant := 23;
   P_Arrow_To_Fill      : constant := 24;
   P_Arrow_To_Width     : constant := 25;
   P_Symbol_From_Name   : constant := 26;
   P_Symbol_From_Stroke : constant := 27;
   P_Symbol_From_Dist   : constant := 28;
   P_Symbol_From_Width  : constant := 29;
   P_Symbol_To_Name     : constant := 30;
   P_Symbol_To_Stroke   : constant := 31;
   P_Symbol_To_Dist     : constant := 32;
   P_Symbol_To_Width    : constant := 33;
   --  All the parameters to GPS.Browsers.Style.__init__

   PA_Item              : constant := 2;
   PA_Align             : constant := 3;
   PA_Margin            : constant := 4;
   PA_Float             : constant := 5;
   PA_Overflow          : constant := 6;
   --  All the parameter to GPS.Browsers.Item.add

   L_From               : constant := 2;
   L_To                 : constant := 3;
   L_Style              : constant := 4;
   L_Routing            : constant := 5;
   L_From_X             : constant := 6;
   L_From_Y             : constant := 7;
   L_From_Side          : constant := 8;
   L_To_X               : constant := 9;
   L_To_Y               : constant := 10;
   L_To_Side            : constant := 11;
   L_Label              : constant := 12;
   L_From_Label         : constant := 13;
   L_To_Label           : constant := 14;
   --  All the parameters for GPS.Browsers.Link

   type Style_Properties_Record is new Instance_Property_Record with record
      Style : Drawing_Style;
   end record;

   procedure Set_Style (Inst : Class_Instance; Style : Drawing_Style);
   function Get_Style (Inst : Class_Instance) return Drawing_Style;
   --  Set or get the style associated with an instance of GPS.Browsers.Style

   subtype Model_Type is List_Canvas_Model;

   type Model_Properties_Record is new Instance_Property_Record with record
      Model : Model_Type;
      --  ??? Needs to be freed when no longer used by either a view or the
      --  python object.
   end record;

   procedure Set_Model (Inst : Class_Instance; Model : Model_Type);
   function Get_Model (Inst : Class_Instance) return Model_Type;
   --  Set or get the style associated with an instance of GPS.Browsers.Style

   type Item_Properties_Record is new Instance_Property_Record with record
      Item : Abstract_Item;
      --  ??? Who owns the item, if the python class lasts longer than the
      --  canvas model ?
   end record;

   procedure Set_Item
     (Inst : Class_Instance;
      Item : access Abstract_Item_Record'Class);
   function Get_Item (Inst : Class_Instance) return Abstract_Item;
   --  Set or get the style associated with an instance of GPS.Browsers.Item

   procedure Style_Handler
     (Data : in out Callback_Data'Class; Command : String);
   procedure Rect_Item_Handler
     (Data : in out Callback_Data'Class; Command : String);
   procedure Ellipse_Handler
     (Data : in out Callback_Data'Class; Command : String);
   procedure Item_Handler
     (Data : in out Callback_Data'Class; Command : String);
   procedure Polyline_Handler
     (Data : in out Callback_Data'Class; Command : String);
   procedure Text_Handler
     (Data : in out Callback_Data'Class; Command : String);
   procedure Hr_Handler
     (Data : in out Callback_Data'Class; Command : String);
   procedure Link_Handler
     (Data : in out Callback_Data'Class; Command : String);
   procedure Diagram_Handler
     (Data : in out Callback_Data'Class; Command : String);
   procedure View_Handler
     (Data : in out Callback_Data'Class; Command : String);
   --  Handles all commands for the python classes in this package.

   type Browser_View_Record is new Generic_Views.View_Record with record
      View : Canvas_View;
   end record;

   function Initialize
     (Self : access Browser_View_Record'Class) return Gtk_Widget;
   --  Create a new browser

   package Browser_Views is new Generic_Views.Simple_Views
     (Module_Name        => "browsers",
      View_Name          => "Browser",
      Formal_View_Record => Browser_View_Record,
      Formal_MDI_Child   => GPS.Kernel.MDI.GPS_MDI_Child_Record,
      Reuse_If_Exist     => False,
      Initialize         => Initialize,
      Position           => Position_Automatic,
      Group              => Group_Default,
      Commands_Category  => "Browsers");
   use Browser_Views;
   subtype Browser_View is Browser_Views.View_Access;

   function Points_From_Param
     (Data : Callback_Data'Class;
      N    : Positive) return Item_Point_Array;
   --  Extract a list of point from a parameter to a python function

   ---------------
   -- Set_Style --
   ---------------

   procedure Set_Style (Inst : Class_Instance; Style : Drawing_Style) is
   begin
      Set_Data
        (Inst, "Browsers.Style",
         Style_Properties_Record'(Style => Style));
   end Set_Style;

   ---------------
   -- Get_Style --
   ---------------

   function Get_Style (Inst : Class_Instance) return Drawing_Style is
      Data : constant Instance_Property := Get_Data (Inst, "Browsers.Style");
   begin
      if Data = null then
         return No_Drawing_Style;
      else
         return Style_Properties_Record (Data.all).Style;
      end if;
   end Get_Style;

   --------------
   -- Set_Item --
   --------------

   procedure Set_Item
     (Inst : Class_Instance;
      Item : access Abstract_Item_Record'Class)
   is
   begin
      Set_Data (Inst, "Browsers.Item",
                Item_Properties_Record'(Item => Abstract_Item (Item)));
   end Set_Item;

   --------------
   -- Get_Item --
   --------------

   function Get_Item (Inst : Class_Instance) return Abstract_Item is
      Data : constant Instance_Property := Get_Data (Inst, "Browsers.Item");
   begin
      if Data = null then
         return null;
      else
         return Item_Properties_Record (Data.all).Item;
      end if;
   end Get_Item;

   ---------------
   -- Set_Model --
   ---------------

   procedure Set_Model (Inst : Class_Instance; Model : Model_Type) is
   begin
      Set_Data
        (Inst, "Browsers.Diagram", Model_Properties_Record'(Model => Model));
   end Set_Model;

   ---------------
   -- Get_Model --
   ---------------

   function Get_Model (Inst : Class_Instance) return Model_Type is
      Data : constant Instance_Property := Get_Data (Inst, "Browsers.Diagram");
   begin
      if Data = null then
         return null;
      else
         return Model_Properties_Record (Data.all).Model;
      end if;
   end Get_Model;

   ---------------------
   -- Diagram_Handler --
   ---------------------

   procedure Diagram_Handler
     (Data : in out Callback_Data'Class; Command : String)
   is
      Inst  : constant Class_Instance := Nth_Arg (Data, 1);
      Model : Model_Type;
      Item  : Abstract_Item;
   begin
      if Command = Constructor_Method then
         Gtk_New (Model);
         Set_Model (Inst, Model);

      elsif Command = "add" then
         Model := Get_Model (Inst);
         Item  := Get_Item (Nth_Arg (Data, PA_Item));
         Model.Add (Item);
      end if;
   end Diagram_Handler;

   ----------------
   -- Initialize --
   ----------------

   function Initialize
     (Self : access Browser_View_Record'Class) return Gtk_Widget
   is
      Scrolled : Gtk_Scrolled_Window;
   begin
      Initialize_Vbox (Self, Homogeneous => False);

      Gtk_New (Scrolled);
      Scrolled.Set_Policy (Policy_Automatic, Policy_Automatic);

      Self.Pack_Start (Scrolled);

      Gtk_New (Self.View);
      Scrolled.Add (Self.View);

      return Gtk_Widget (Self.View);
   end Initialize;

   ------------------
   -- View_Handler --
   ------------------

   procedure View_Handler
     (Data : in out Callback_Data'Class; Command : String)
   is
      Inst   : Class_Instance;
      Script : constant Scripting_Language := Get_Script (Data);
      View   : Browser_View;
      Model  : Model_Type;
      C      : MDI_Child;
   begin
      if Command = Constructor_Method then
         Set_Error_Msg (Data, "Use GPS.Browsers.View.get to retrieve a view");

      elsif Command = "create" then
         Model := Get_Model (Nth_Arg (Data, 1));
         View := Browser_Views.Get_Or_Create_View (Get_Kernel (Data));
         View.View.Set_Model (Model);

         C := Browser_Views.Child_From_View (View);
         C.Set_Title (Nth_Arg (Data, 2));

         Inst := New_Instance (Script, Module.View_Class);
         Set_Data (Inst, Widget => GObject (View));
         Set_Return_Value (Data, Inst);
      end if;
   end View_Handler;

   ------------------
   -- Item_Handler --
   ------------------

   procedure Item_Handler
     (Data : in out Callback_Data'Class; Command : String)
   is
      Inst : Class_Instance;
      M    : Margins := No_Margins;
      Item : Container_Item;
      X, Y : Gdouble := Gdouble'First;
   begin
      if Command = Constructor_Method then
         Set_Error_Msg (Data, "GPS.Browsers.Item is an abstract class");

      elsif Command = "set_position" then
         Inst := Nth_Arg (Data, 1);

         if Nth_Arg (Data, 2, Float'First) /= Float'First then
            X := Gdouble (Nth_Arg (Data, 2, Float'First));
         end if;

         if Nth_Arg (Data, 3, Float'First) /= Float'First then
            Y := Gdouble (Nth_Arg (Data, 3, Float'First));
         end if;

         Canvas_Item (Get_Item (Inst)).Set_Position ((X, Y));

      elsif Command = "set_min_size" then
         Inst := Nth_Arg (Data, 1);

         Container_Item (Get_Item (Inst)).Set_Min_Size
           (Min_Width  => Gdouble (Nth_Arg (Data, 2, 1.0)),
            Min_Height => Gdouble (Nth_Arg (Data, 3, 1.0)));

      elsif Command = "add" then
         Inst := Nth_Arg (Data, 1);
         Item  := Container_Item (Get_Item ((Nth_Arg (Data, PA_Item))));

         begin
            declare
               L : constant List_Instance'Class := Nth_Arg (Data, PA_Margin);
               C : constant Integer := Number_Of_Arguments (L);
            begin
               if C >= 1 then
                  M.Top := Gdouble (Float'(Nth_Arg (L, 1, 1.0)));
               end if;

               if C >= 2 then
                  M.Right := Gdouble (Float'(Nth_Arg (L, 2, 1.0)));
               end if;

               if C >= 3 then
                  M.Bottom := Gdouble (Float'(Nth_Arg (L, 3, 1.0)));
               end if;

               if C >= 4 then
                  M.Left := Gdouble (Float'(Nth_Arg (L, 4)));
               end if;
            end;
         exception
            when Invalid_Parameter =>
               null;
         end;

         Container_Item (Get_Item (Inst)).Add_Child
           (Item,
            Align => Alignment_Style'Val
              (Nth_Arg (Data, PA_Align, Alignment_Style'Pos (Align_Start))),
            Margin => M,
            Float  => Nth_Arg (Data, PA_Float, False),
            Overflow => Overflow_Style'Val
              (Nth_Arg
                   (Data, PA_Overflow,
                    Overflow_Style'Pos (Overflow_Prevent))));

      elsif Command = "set_child_layout" then
         Inst := Nth_Arg (Data, 1);
         Container_Item (Get_Item (Inst)).Set_Child_Layout
           (Child_Layout_Strategy'Val
              (Nth_Arg (Data, 2, Child_Layout_Strategy'Pos (Vertical_Stack))));
      end if;
   end Item_Handler;

   -------------------
   -- Style_Handler --
   -------------------

   procedure Style_Handler
     (Data : in out Callback_Data'Class; Command : String)
   is
      Inst  : Class_Instance;
      Style : Drawing_Style;

      function Color_From_Param
        (N : Positive; Default : Gdk_RGBA := Null_RGBA) return Gdk_RGBA;
      function Pattern_From_Param (N : Positive) return Cairo_Pattern;
      function List_From_Param (N : Positive) return Dash_Array;

      function Val (S : String) return Gdouble;

      function Val (S : String) return Gdouble is
      begin
         return Gdouble'Value (S);
      exception
         when Constraint_Error =>
            return 0.0;
      end Val;

      function Color_From_Param
        (N : Positive; Default : Gdk_RGBA := Null_RGBA) return Gdk_RGBA
      is
         V       : constant String := Nth_Arg (Data, N, "--");
         C       : Gdk_RGBA;
         Success : Boolean;
      begin
         if V = "--" then
            return Default;
         elsif V = "" then
            return Null_RGBA;
         else
            Parse (C, V, Success);
            if not Success then
               C := Black_RGBA;
            end if;
            return C;
         end if;
      end Color_From_Param;

      function Pattern_From_Param (N : Positive) return Cairo_Pattern is
         V : constant String := Nth_Arg (Data, N, "");
         C       : Gdk_RGBA;
         Success : Boolean;
         P       : Cairo_Pattern;
         Str     : String_List_Access;
         S       : Integer;
      begin
         if V = "" then
            return Cairo.Null_Pattern;
         end if;

         if Starts_With (V, "linear ") then
            Str := Split (V, ' ');
            if Str'Length >= 5 then
               P := Create_Linear
                 (X0  => Val (Str (Str'First + 1).all),
                  Y0  => Val (Str (Str'First + 2).all),
                  X1  => Val (Str (Str'First + 3).all),
                  Y1  => Val (Str (Str'First + 4).all));

               S := Str'First + 5;
               while S < Str'Length loop
                  Parse (C, Str (S + 1).all, Success);
                  if Success then
                     Add_Color_Stop_Rgba
                       (P,
                        Offset => Val (Str (S).all),
                        Red    => C.Red,
                        Green  => C.Green,
                        Blue   => C.Blue,
                        Alpha  => C.Alpha);
                  end if;

                  S := S + 2;
               end loop;

               Free (Str);

               return P;
            else
               return Cairo.Null_Pattern;
            end if;

         else
            Parse (C, V, Success);
            if not Success then
               return Cairo.Null_Pattern;
            else
               return Create_Rgba_Pattern (C);
            end if;
         end if;
      end Pattern_From_Param;

      function List_From_Param (N : Positive) return Dash_Array is
      begin
         declare
            L : constant List_Instance'Class := Nth_Arg (Data, N);
            R : Dash_Array (1 .. Number_Of_Arguments (L));
         begin
            for P in R'Range loop
               R (P) := Gdouble (Float'(Nth_Arg (L, P)));
            end loop;
            return R;
         end;

      exception
         when Invalid_Parameter =>
            return Cairo.No_Dashes;
      end List_From_Param;

   begin
      if Command = Constructor_Method then
         Inst := Nth_Arg (Data, 1);

         Style := Gtk_New
           (Stroke     => Color_From_Param (P_Stroke, Black_RGBA),
            Fill       => Pattern_From_Param (P_Fill),
            Dashes     => List_From_Param (P_Dashes),
            Line_Width => Gdouble (Nth_Arg (Data, P_Line_Width, 1.0)),
            Sloppy     => Nth_Arg (Data, P_Sloppy, False),
            Font => (Name  => From_String
                       (Nth_Arg (Data, P_Font_Name, "sans 9")),
                     Underline => Underline'Val
                       (Integer'(Nth_Arg (Data, P_Font_Underline,
                        Underline'Pos (Pango_Underline_None)))),
                     Strikethrough =>
                       Nth_Arg (Data, P_Font_Strikethrough, False),
                     Color => Color_From_Param (P_Font_Color, Black_RGBA),
                     Line_Spacing => Gint (Nth_Arg (Data, P_Font_LS, 0)),
                     Halign => Alignment'Val
                       (Integer'(Nth_Arg (Data, P_Font_Halign,
                        Alignment'Pos (Pango_Align_Left)))),
                     Valign => Gdouble (Nth_Arg (Data, P_Font_Valign, 0.0))
                    ),
            Arrow_From =>
              (Head  => Arrow_Head'Val
                 (Nth_Arg (Data, P_Arrow_From_Head, Arrow_Head'Pos (None))),
               Length => Gdouble (Nth_Arg (Data, P_Arrow_From_Length, 8.0)),
               Angle => Gdouble (Nth_Arg (Data, P_Arrow_From_Angle, 0.4)),
               Stroke => Color_From_Param (P_Arrow_From_Stroke, Black_RGBA),
               Line_Width => Gdouble (Nth_Arg (Data, P_Arrow_From_Width, 1.0)),
               Fill   => Color_From_Param (P_Arrow_From_Fill)),

            Arrow_To =>
              (Head  => Arrow_Head'Val
                   (Nth_Arg (Data, P_Arrow_To_Head, Arrow_Head'Pos (None))),
               Length => Gdouble (Nth_Arg (Data, P_Arrow_To_Length, 8.0)),
               Angle => Gdouble (Nth_Arg (Data, P_Arrow_To_Angle, 0.4)),
               Stroke => Color_From_Param (P_Arrow_To_Stroke, Black_RGBA),
               Line_Width => Gdouble (Nth_Arg (Data, P_Arrow_To_Width, 1.0)),
               Fill   => Color_From_Param (P_Arrow_To_Fill)),

            Symbol_From =>
              (Name  => Symbol_Name'Val
                  (Nth_Arg (Data, P_Symbol_From_Name, Symbol_Name'Pos (None))),
               Stroke => Color_From_Param (P_Symbol_From_Stroke, Black_RGBA),
               Line_Width =>
                 Gdouble (Nth_Arg (Data, P_Symbol_From_Width, 1.0)),
               Distance => Gdouble (Nth_Arg (Data, P_Symbol_From_Dist, 16.0))),

            Symbol_To =>
              (Name  => Symbol_Name'Val
                  (Nth_Arg (Data, P_Symbol_To_Name, Symbol_Name'Pos (None))),
               Stroke => Color_From_Param (P_Symbol_To_Stroke, Black_RGBA),
               Line_Width => Gdouble (Nth_Arg (Data, P_Symbol_To_Width, 1.0)),
               Distance => Gdouble (Nth_Arg (Data, P_Symbol_To_Dist, 16.0)))
           );

         Set_Style (Inst, Style);
      end if;

   exception
      when E : others =>
         Trace (Me, E);
   end Style_Handler;

   -----------------------
   -- Rect_Item_Handler --
   -----------------------

   procedure Rect_Item_Handler
     (Data : in out Callback_Data'Class; Command : String)
   is
      Inst : Class_Instance;
      Item : Rect_Item;
   begin
      if Command = Constructor_Method then
         Inst := Nth_Arg (Data, 1);
         Item := Gtk_New_Rect
           (Style  => Get_Style (Nth_Arg (Data, 2)),
            Width  => Gdouble (Nth_Arg (Data, 3, -1.0)),
            Height => Gdouble (Nth_Arg (Data, 4, -1.0)),
            Radius => Gdouble (Nth_Arg (Data, 5, 0.0)));
         Set_Item (Inst, Item);
      end if;
   end Rect_Item_Handler;

   ---------------------
   -- Ellipse_Handler --
   ---------------------

   procedure Ellipse_Handler
     (Data : in out Callback_Data'Class; Command : String)
   is
      Inst : Class_Instance;
      Item : Ellipse_Item;
   begin
      if Command = Constructor_Method then
         Inst := Nth_Arg (Data, 1);
         Item := Gtk_New_Ellipse
           (Style  => Get_Style (Nth_Arg (Data, 2)),
            Width  => Gdouble (Nth_Arg (Data, 3, -1.0)),
            Height => Gdouble (Nth_Arg (Data, 4, -1.0)));
         Set_Item (Inst, Item);
      end if;
   end Ellipse_Handler;

   -----------------------
   -- Points_From_Param --
   -----------------------

   function Points_From_Param
     (Data : Callback_Data'Class;
      N    : Positive) return Item_Point_Array
   is
      L : constant List_Instance'Class := Nth_Arg (Data, N);
      Points : Item_Point_Array (1 .. Number_Of_Arguments (L) / 2);
      Index  : Integer := Points'First;
   begin
      for P in Points'Range loop
         Points (P) := (X => Gdouble (Float'(Nth_Arg (L, Index))),
                        Y => Gdouble (Float'(Nth_Arg (L, Index + 1))));
         Index := Index + 2;
      end loop;
      return Points;
   end Points_From_Param;

   ----------------------
   -- Polyline_Handler --
   ----------------------

   procedure Polyline_Handler
     (Data : in out Callback_Data'Class; Command : String)
   is
      Inst : Class_Instance;
      Item : Polyline_Item;
   begin
      if Command = Constructor_Method then
         Inst := Nth_Arg (Data, 1);
         Item := Gtk_New_Polyline
           (Style  => Get_Style (Nth_Arg (Data, 2)),
            Points => Points_From_Param (Data, 3),
            Close  => Nth_Arg (Data, 4, False));
         Set_Item (Inst, Item);
      end if;
   end Polyline_Handler;

   ------------------
   -- Text_Handler --
   ------------------

   procedure Text_Handler
     (Data : in out Callback_Data'Class; Command : String)
   is
      Inst : Class_Instance;
      Item : Text_Item;
   begin
      if Command = Constructor_Method then
         Item := Gtk_New_Text
           (Style    => Get_Style (Nth_Arg (Data, 2)),
            Text     => Nth_Arg (Data, 3),
            Directed => Text_Arrow_Direction'Val
              (Nth_Arg (Data, 4, Text_Arrow_Direction'Pos (No_Text_Arrow))));

         Inst := Nth_Arg (Data, 1);
         Set_Item (Inst, Item);
      end if;
   end Text_Handler;

   ----------------
   -- Hr_Handler --
   ----------------

   procedure Hr_Handler
     (Data : in out Callback_Data'Class; Command : String)
   is
      Inst : Class_Instance;
      Item : Hr_Item;
   begin
      if Command = Constructor_Method then
         Item := Gtk_New_Hr
           (Style    => Get_Style (Nth_Arg (Data, 2)),
            Text     => Nth_Arg (Data, 3, ""));
         Inst := Nth_Arg (Data, 1);
         Set_Item (Inst, Item);
      end if;
   end Hr_Handler;

   ------------------
   -- Link_Handler --
   ------------------

   procedure Link_Handler
     (Data : in out Callback_Data'Class; Command : String)
   is
      Inst, Inst2  : Class_Instance;
      Link  : Canvas_Link;
      Label, Label_From, Label_To : Container_Item;
   begin
      if Command = Constructor_Method then
         Inst2 := Nth_Arg (Data, L_Label, Allow_Null => True);
         if Inst2 /= No_Class_Instance then
            Label := Container_Item (Get_Item (Inst2));
         end if;

         Inst2 := Nth_Arg (Data, L_From_Label, Allow_Null => True);
         if Inst2 /= No_Class_Instance then
            Label_From := Container_Item (Get_Item (Inst2));
         end if;

         Inst2 := Nth_Arg (Data, L_To_Label, Allow_Null => True);
         if Inst2 /= No_Class_Instance then
            Label_To := Container_Item (Get_Item (Inst2));
         end if;

         Link := Gtk_New
           (From        => Get_Item (Nth_Arg (Data, L_From)),
            To          => Get_Item (Nth_Arg (Data, L_To)),
            Style       => Get_Style (Nth_Arg (Data, L_Style)),
            Label       => Label,
            Label_From  => Label_From,
            Label_To    => Label_To,
            Routing     => Route_Style'Val
              (Nth_Arg (Data, L_Routing, Route_Style'Pos (Straight))),
            Anchor_From =>
              (X   => Gdouble (Nth_Arg (Data, L_From_X, 0.5)),
               Y   => Gdouble (Nth_Arg (Data, L_From_Y, 0.5)),
               Toplevel_Side => Side_Attachment'Val
                 (Nth_Arg (Data, L_From_Side, Side_Attachment'Pos (Auto)))),
            Anchor_To   =>
              (X   => Gdouble (Nth_Arg (Data, L_To_X, 0.5)),
               Y   => Gdouble (Nth_Arg (Data, L_To_Y, 0.5)),
               Toplevel_Side => Side_Attachment'Val
                 (Nth_Arg (Data, L_To_Side, Side_Attachment'Pos (Auto)))));

         Inst := Nth_Arg (Data, 1);
         Set_Item (Inst, Link);

      elsif Command = "set_waypoints" then
         Inst := Nth_Arg (Data, 1);
         Canvas_Link (Get_Item (Inst)).Set_Waypoints
           (Points   => Points_From_Param (Data, 2),
            Relative => Nth_Arg (Data, 3, False));
      end if;
   end Link_Handler;

   ---------------------
   -- Register_Module --
   ---------------------

   procedure Register_Module
     (Kernel : not null access GPS.Kernel.Kernel_Handle_Record'Class)
   is
      BModule : constant Module_Type :=
        Kernel.Scripts.Lookup_Module ("@.Browsers");
      Style_Class : constant Class_Type :=
        Kernel.Scripts.New_Class ("Style", Module => BModule);
      Diagram_Class : constant Class_Type :=
        Kernel.Scripts.New_Class ("Diagram", Module => BModule);
      Rect_Item, Ellipse_Item, Polyline, Text, Hr, Link : Class_Type;
   begin
      Module := new Browsers_Scripts_Module;
      Browser_Views.Register_Module (Kernel, Module_ID (Module));

      Module.View_Class := Kernel.Scripts.New_Class
        ("View",
         Module => BModule,
         Base   => Get_GUI_Class (Kernel));
      Module.Item_Class := Kernel.Scripts.New_Class
        ("Item", Module => BModule);

      Rect_Item := Kernel.Scripts.New_Class
        ("RectItem", Module => BModule, Base => Module.Item_Class);
      Ellipse_Item := Kernel.Scripts.New_Class
        ("EllipseItem", Module => BModule, Base => Module.Item_Class);
      Polyline := Kernel.Scripts.New_Class
        ("PolylineItem", Module => BModule, Base => Module.Item_Class);
      Text := Kernel.Scripts.New_Class
        ("TextItem", Module => BModule, Base => Module.Item_Class);
      Hr := Kernel.Scripts.New_Class
        ("HrItem", Module => BModule, Base => Module.Item_Class);
      Link := Kernel.Scripts.New_Class
        ("Link", Module => BModule);

      Register_Command
        (Kernel.Scripts,
         Constructor_Method,
         Params  =>
           (P_Stroke             => Param ("stroke", True),
            P_Fill               => Param ("fill", True),
            P_Line_Width         => Param ("lineWidth", True),
            P_Dashes             => Param ("dashes", True),
            P_Sloppy             => Param ("sloppy", True),
            P_Font_Name          => Param ("fontName", True),
            P_Font_Underline     => Param ("fontUnderline", True),
            P_Font_Strikethrough => Param ("fontStrike", True),
            P_Font_Color         => Param ("fontColor", True),
            P_Font_LS            => Param ("fontLineSpacing", True),
            P_Font_Halign        => Param ("fontHalign", True),
            P_Font_Valign        => Param ("fontValign", True),
            P_Arrow_From_Head    => Param ("arrowFrom", True),
            P_Arrow_From_Length  => Param ("arrowFromLength", True),
            P_Arrow_From_Angle   => Param ("arrowFromAngle", True),
            P_Arrow_From_Stroke  => Param ("arrowFromStroke", True),
            P_Arrow_From_Fill    => Param ("arrowFromFill", True),
            P_Arrow_From_Width   => Param ("arrowFromWidth", True),
            P_Arrow_To_Head      => Param ("arrowTo", True),
            P_Arrow_To_Length    => Param ("arrowToLength", True),
            P_Arrow_To_Angle     => Param ("arrowToAngle", True),
            P_Arrow_To_Stroke    => Param ("arrowToStroke", True),
            P_Arrow_To_Fill      => Param ("arrowToFill",  True),
            P_Arrow_To_Width     => Param ("arrowToWidth", True),
            P_Symbol_From_Name   => Param ("symbolFrom", True),
            P_Symbol_From_Stroke => Param ("symbolFromStroke", True),
            P_Symbol_From_Dist   => Param ("symbolFromDist", True),
            P_Symbol_From_Width  => Param ("symbolFromWidth", True),
            P_Symbol_To_Name     => Param ("symbolTo", True),
            P_Symbol_To_Stroke   => Param ("symbolToStroke", True),
            P_Symbol_To_Dist     => Param ("symbolToDist", True),
            P_Symbol_To_Width    => Param ("symbolToWidth", True)),
         Class   => Style_Class,
         Handler => Style_Handler'Access);

      Register_Command
        (Kernel.Scripts,
         Constructor_Method,
         Class   => Diagram_Class,
         Handler => Diagram_Handler'Access);
      Register_Command
        (Kernel.Scripts,
         "add",
         Params  => (2 => Param ("item")),
         Class   => Diagram_Class,
         Handler => Diagram_Handler'Access);

      Register_Command
        (Kernel.Scripts,
         Constructor_Method,
         Class   => Module.View_Class,
         Handler => View_Handler'Access);
      Register_Command
        (Kernel.Scripts,
         "create",
         Class   => Module.View_Class,
         Static_Method => True,
         Params  => (1 => Param ("diagram"),
                     2 => Param ("title")),
         Handler => View_Handler'Access);

      Register_Command
        (Kernel.Scripts,
         Constructor_Method,
         Class   => Module.Item_Class,
         Handler => Item_Handler'Access);
      Register_Command
        (Kernel.Scripts,
         "set_position",
         Params  => (Param ("x", Optional => True),
                     Param ("y", Optional => True)),
         Class   => Module.Item_Class,
         Handler => Item_Handler'Access);
      Register_Command
        (Kernel.Scripts,
         "set_child_layout",
         Params  => (1 => Param ("layout")),
         Class   => Module.Item_Class,
         Handler => Item_Handler'Access);
      Register_Command
        (Kernel.Scripts,
         "set_min_size",
         Params  => (1 => Param ("width", Optional => True),
                     2 => Param ("height", Optional => True)),
         Class   => Module.Item_Class,
         Handler => Item_Handler'Access);
      Register_Command
        (Kernel.Scripts,
         "add",
         Params  => (PA_Item     => Param ("item"),
                     PA_Align    => Param ("align", Optional => True),
                     PA_Margin   => Param ("margin", Optional => True),
                     PA_Float    => Param ("float",  Optional => True),
                     PA_Overflow => Param ("overflow", Optional => True)),
         Class   => Module.Item_Class,
         Handler => Item_Handler'Access);

      Register_Command
        (Kernel.Scripts,
         Constructor_Method,
         Params  => (Param ("style"),
                     Param ("width",  Optional => True),
                     Param ("height", Optional => True),
                     Param ("radius", Optional => True)),
         Class   => Rect_Item,
         Handler => Rect_Item_Handler'Access);

      Register_Command
        (Kernel.Scripts,
         Constructor_Method,
         Params  => (Param ("style"),
                     Param ("width",  Optional => True),
                     Param ("height", Optional => True)),
         Class   => Ellipse_Item,
         Handler => Ellipse_Handler'Access);

      Register_Command
        (Kernel.Scripts,
         Constructor_Method,
         Params  => (Param ("style"),
                     Param ("points"),
                     Param ("close", Optional => True)),
         Class   => Polyline,
         Handler => Polyline_Handler'Access);

      Register_Command
        (Kernel.Scripts,
         Constructor_Method,
         Params  => (Param ("style"),
                     Param ("text"),
                     Param ("directed", Optional => True)),
         Class   => Text,
         Handler => Text_Handler'Access);

      Register_Command
        (Kernel.Scripts,
         Constructor_Method,
         Params  => (Param ("style"),
                     Param ("text", Optional => True)),
         Class   => Hr,
         Handler => Hr_Handler'Access);

      Register_Command
        (Kernel.Scripts,
         Constructor_Method,
         Params  => (L_From       => Param ("origin"),
                     L_To         => Param ("to"),
                     L_Style      => Param ("style"),
                     L_Routing    => Param ("routing",   Optional => True),
                     L_Label      => Param ("label",     Optional => True),
                     L_From_X     => Param ("fromX",     Optional => True),
                     L_From_Y     => Param ("fromY",     Optional => True),
                     L_From_Side  => Param ("fromSide",  Optional => True),
                     L_From_Label => Param ("fromLabel", Optional => True),
                     L_To_X       => Param ("toX",       Optional => True),
                     L_To_Y       => Param ("toY",       Optional => True),
                     L_To_Label   => Param ("toLabel",   Optional => True),
                     L_To_Side    => Param ("toSide",    Optional => True)),
         Class   => Link,
         Handler => Link_Handler'Access);
      Register_Command
        (Kernel.Scripts,
         "set_waypoints",
         Params  => (Param ("points"),
                     Param ("relative", Optional => True)),
         Class   => Link,
         Handler => Link_Handler'Access);

   end Register_Module;

end Browsers.Scripts;
