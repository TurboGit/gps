-----------------------------------------------------------------------
--                                                                   --
--                     Copyright (C) 2001                            --
--                          ACT-Europe                               --
--                                                                   --
-- This library is free software; you can redistribute it and/or     --
-- modify it under the terms of the GNU General Public               --
-- License as published by the Free Software Foundation; either      --
-- version 2 of the License, or (at your option) any later version.  --
--                                                                   --
-- This library is distributed in the hope that it will be useful,   --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of    --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU --
-- General Public License for more details.                          --
--                                                                   --
-- You should have received a copy of the GNU General Public         --
-- License along with this library; if not, write to the             --
-- Free Software Foundation, Inc., 59 Temple Place - Suite 330,      --
-- Boston, MA 02111-1307, USA.                                       --
--                                                                   --
-- As a special exception, if other files instantiate generics from  --
-- this unit, or you link this unit with other files to produce an   --
-- executable, this  unit  does not  by itself cause  the resulting  --
-- executable to be covered by the GNU General Public License. This  --
-- exception does not however invalidate any other reasons why the   --
-- executable file  might be covered by the  GNU Public License.     --
-----------------------------------------------------------------------

with Ada.Text_IO;       use Ada.Text_IO;
with Ada.Strings.Fixed;

with Gtk.Main;

package body Search_Callback is

   package Natural_IO is new Integer_IO (Natural);

   Continue : Boolean;

   ------------------
   -- Abort_Search --
   ------------------

   procedure Abort_Search is
   begin
      Continue := False;
   end Abort_Search;

   --------------
   -- Callback --
   --------------

   function Callback
     (Match_Found : Boolean;
      File        : String;
      Line_Nr     : Positive    := 1;
      Line_Text   : String      := "";
      Sub_Matches : Match_Array := (0 => No_Match))
      return Boolean
   is
      Dummy : Boolean;

      Parentheses : String (Line_Text'Range);

      use Ada.Strings;

      Location : constant String :=
        File & ':' & Fixed.Trim (Positive'Image (Line_Nr), Left);
   begin
      if Match_Found then
         Put_Line (Location & ':' & Line_Text);

         if Sub_Matches (0) /= No_Match then
            for K in Sub_Matches'Range loop
               Natural_IO.Put (K, Width => Location'Length);
               Parentheses := (others => ' ');

               if Sub_Matches (K) /= No_Match then
                  Parentheses
                    (Sub_Matches (K).First .. Sub_Matches (K).Last) :=
                      (others => '#');
               end if;

               Put_Line ('>' & Parentheses & '<');
            end loop;
         end if;
      end if;

      while Gtk.Main.Events_Pending loop
         Dummy := Gtk.Main.Main_Iteration;
      end loop;

      if Continue then
         return True;
      else
         Put_Line ("--- ABORTING !!!");
         return False;
      end if;
   end Callback;

   ------------------
   -- Reset_Search --
   ------------------

   procedure Reset_Search is
   begin
      Continue := True;
   end Reset_Search;

end Search_Callback;
