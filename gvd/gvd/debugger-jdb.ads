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

--  This is the implementation of Debugger for the Java Debugger (Jdb).
--  See debugger.ads for complete documentation on this package.

with GNAT.OS_Lib;
with Debugger;
with Gtk.Window;
with GNAT.Regpat;
with Odd.Types;

package Debugger.Jdb is

   type Jdb_Debugger is new Debugger.Debugger_Root with private;

   procedure Spawn
     (Debugger        : access Jdb_Debugger;
      Executable      : String;
      Arguments       : GNAT.OS_Lib.Argument_List;
      Proxy           : Process_Proxies.Process_Proxy_Access;
      Window          : Gtk.Window.Gtk_Window;
      Remote_Host     : String := "";
      Remote_Target   : String := "";
      Remote_Protocol : String := "";
      Debugger_Name   : String := "");

   procedure Initialize (Debugger : access Jdb_Debugger);

   procedure Close (Debugger : access Jdb_Debugger);

   procedure Wait_Prompt (Debugger : access Jdb_Debugger);

   function Highlighting_Pattern
     (Debugger : access Jdb_Debugger) return GNAT.Regpat.Pattern_Matcher;

   procedure Display_Prompt
     (Debugger        : access Jdb_Debugger;
      Wait_For_Prompt : Boolean := True);

   function Type_Of
     (Debugger : access Jdb_Debugger;
      Entity   : String) return String;

   function Value_Of
     (Debugger : access Jdb_Debugger;
      Entity   : String;
      Format   : Value_Format := Decimal) return String;

   function Info_Locals (Debugger : access Jdb_Debugger) return String;

   function Info_Args (Debugger : access Jdb_Debugger) return String;

   function Info_Registers (Debugger : access Jdb_Debugger) return String;

   procedure Set_Executable
     (Debugger   : access Jdb_Debugger;
      Executable : String);

   procedure Run
     (Debugger : access Jdb_Debugger;
      Display  : Boolean := False);

   procedure Start
     (Debugger : access Jdb_Debugger;
      Display  : Boolean := False);

   procedure Step_Into
     (Debugger : access Jdb_Debugger;
      Display  : Boolean := False);

   procedure Step_Over
     (Debugger : access Jdb_Debugger;
      Display  : Boolean := False);

   procedure Continue
     (Debugger : access Jdb_Debugger;
      Display  : Boolean := False);

   procedure Interrupt (Debugger : access Jdb_Debugger);

   function Is_Execution_Command
     (Debugger : access Jdb_Debugger;
      Command : String) return Boolean;

   function Is_Context_Command
     (Debugger : access Jdb_Debugger;
      Command  : String) return Boolean;

   function Is_Break_Command
     (Debugger : access Jdb_Debugger;
      Command : String) return Boolean;

   procedure Stack_Down
     (Debugger : access Jdb_Debugger;
      Display  : Boolean := False);

   procedure Stack_Up
     (Debugger : access Jdb_Debugger;
      Display  : Boolean := False);

   procedure Stack_Frame
     (Debugger : access Jdb_Debugger;
      Frame    : Positive;
      Display  : Boolean := False);

   procedure Break_Subprogram
     (Debugger  : access Jdb_Debugger;
      Name      : String;
      Temporary : Boolean := False;
      Display   : Boolean := False);

   procedure Break_Source
     (Debugger  : access Jdb_Debugger;
      File      : String;
      Line      : Positive;
      Temporary : Boolean := False;
      Display   : Boolean := False);

   procedure Break_Exception
     (Debugger  : access Jdb_Debugger;
      Name      : String  := "";
      Temporary : Boolean := False;
      Unhandled : Boolean := False;
      Display   : Boolean := False);

   procedure Break_Address
     (Debugger   : access Jdb_Debugger;
      Address    : String;
      Temporary  : Boolean := False;
      Display    : Boolean := False);

   procedure Break_Regexp
     (Debugger   : access Jdb_Debugger;
      Regexp     : String;
      Temporary  : Boolean := False;
      Display    : Boolean := False);

   procedure Enable_Breakpoint
     (Debugger : access Jdb_Debugger;
      Num      : Integer;
      Enable   : Boolean := True;
      Display  : Boolean := False);

   procedure Remove_Breakpoint
     (Debugger : access Jdb_Debugger;
      Num      : Integer;
      Display  : Boolean := False);

   procedure Finish
     (Debugger : access Jdb_Debugger;
      Display  : Boolean := False);

   procedure Backtrace
     (Debugger : access Jdb_Debugger;
      Value    : out Backtrace_Array;
      Len      : out Natural);

   function Info_Threads
     (Debugger : access Jdb_Debugger)
      return Language.Thread_Information_Array;

   function Line_Contains_Code
     (Debugger : access Jdb_Debugger;
      File     : String;
      Line     : Positive) return Line_Kind;

   function List_Breakpoints
     (Debugger  : access Jdb_Debugger)
     return Odd.Types.Breakpoint_Array;

   procedure Send_Completed
     (Debugger : access Jdb_Debugger;
      Cmd      : String);

private

   function Send
     (Debugger        : access Jdb_Debugger;
      Cmd             : String;
      Display         : Boolean := False;
      Empty_Buffer    : Boolean := True;
      Wait_For_Prompt : Boolean := True;
      Is_Internal     : Boolean := False)
     return String;

   type Jdb_Debugger is new Debugger.Debugger_Root with record
      Main_Class : GNAT.OS_Lib.String_Access;
      Frame      : Natural := 1;
      --  Current frame displayed.
   end record;

end Debugger.Jdb;
