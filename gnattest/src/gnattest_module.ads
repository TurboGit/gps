-----------------------------------------------------------------------
--                               G P S                               --
--                                                                   --
--                    Copyright (C) 2011, AdaCore                    --
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

--  This package defines the module for GNATTest integration.
with Basic_Types;
with Entities;
with GPS.Kernel;

with Ada.Strings.Unbounded;

package GNATTest_Module is

   procedure Register_Module
     (Kernel : access GPS.Kernel.Kernel_Handle_Record'Class);
   --  Register the module into the list

   procedure Find
     (Entity          : Entities.Entity_Information;
      To_Test         : Boolean;
      Unit_Name       : out Ada.Strings.Unbounded.Unbounded_String;
      Subprogram_Name : out Ada.Strings.Unbounded.Unbounded_String;
      Line            : out Natural;
      Column          : out Basic_Types.Visible_Column_Type);

end GNATTest_Module;
