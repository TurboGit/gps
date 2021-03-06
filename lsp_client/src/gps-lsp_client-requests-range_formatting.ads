------------------------------------------------------------------------------
--                               GNAT Studio                                --
--                                                                          --
--                       Copyright (C) 2020, AdaCore                        --
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

with GNATCOLL.VFS;

package GPS.LSP_Client.Requests.Range_Formatting is

   type Abstract_Range_Formatting_Request is
     abstract new LSP_Request with record
      Text_Document     : GNATCOLL.VFS.Virtual_File;
      Span              : LSP.Messages.Span;
      Indentation_Level : Integer;
      Use_Tabs          : Boolean;
   end record;

   function Params
     (Self : Abstract_Range_Formatting_Request)
      return LSP.Messages.DocumentRangeFormattingParams;
   --  Return parameters of the request to be sent to the server.

   procedure On_Result_Message
     (Self   : in out Abstract_Range_Formatting_Request;
      Result : LSP.Messages.TextEdit_Vector) is abstract;
   --  Called when a result response is received from the server.

   overriding function Method
     (Self : Abstract_Range_Formatting_Request) return String;

   overriding procedure Params
     (Self   : Abstract_Range_Formatting_Request;
      Stream : not null access LSP.JSON_Streams.JSON_Stream'Class);

   overriding procedure On_Result_Message
     (Self   : in out Abstract_Range_Formatting_Request;
      Stream : not null access LSP.JSON_Streams.JSON_Stream'Class);

end GPS.LSP_Client.Requests.Range_Formatting;
