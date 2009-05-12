-----------------------------------------------------------------------
--                               G P S                               --
--                                                                   --
--                Copyright (C) 2001-2009, AdaCore                   --
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

with String_List_Utils; use String_List_Utils;
with Unchecked_Deallocation;

package body Commands is

   procedure Enqueue
     (Queue         : Command_Queue;
      Action        : access Root_Command'Class;
      High_Priority : Boolean;
      Modify_Group  : Boolean);
   --  Internal version of Enqueue.
   --  Modify_Group indicates whether we should modify the current group.

   use Command_Queues;

   -----------------------
   -- Local subprograms --
   -----------------------

   procedure Execute_Next_Action (Queue : Command_Queue);
   --  Execute the next action in the queue, or do nothing if there is none

   function Default_Execute_Command
     (Command : Command_Access) return Command_Return_Type;
   --  Internal subprogram for the implementation of Launch_Synchronous

   procedure Change_Group (Queue : Command_Queue);
   --  Change the current group, so that following actions are not grouped
   --  in the same undo/redo group.

   ---------------
   -- New_Queue --
   ---------------

   function New_Queue return Command_Queue is
   begin
      return new Command_Queue_Record;
   end New_Queue;

   ----------------
   -- Free_Queue --
   ----------------

   procedure Free_Queue (Q : in out Command_Queue) is
      procedure Free_Queue_Access is
         new Unchecked_Deallocation (Command_Queue_Record, Command_Queue);
   begin
      if Q /= null then
         Free (Q.Undo_Queue);
         Free (Q.Redo_Queue);
         Free (Q.Queue_Change_Hook);

         Free (Q.The_Queue);
         Free (Q.Queue_Change_Hook, Free_Data => False);
         String_List.Free (Q.Hook_Identifiers);
         Free_Queue_Access (Q);
      end if;
   end Free_Queue;

   -----------------
   -- Empty_Queue --
   -----------------

   procedure Empty_Queue (Q : Command_Queue) is
      Node : List_Node;
   begin
      Free (Q.Undo_Queue);
      Free (Q.Redo_Queue);
      Free (Q.The_Queue);

      --  Execute the queue change hooks

      Node := First (Q.Queue_Change_Hook);

      while Node /= Null_Node loop
         Execute (Data (Node));
         Node := Next (Node);
      end loop;
   end Empty_Queue;

   ---------
   -- Ref --
   ---------

   procedure Ref (Command : access Root_Command'Class) is
   begin
      Command.Ref_Count := Command.Ref_Count + 1;
   end Ref;

   -----------
   -- Unref --
   -----------

   procedure Unref (Command : in out Command_Access) is
      procedure Unchecked_Free is new Unchecked_Deallocation
        (Root_Command'Class, Command_Access);
   begin
      if Command /= null then
         Command.Ref_Count := Command.Ref_Count - 1;
         if Command.Ref_Count = 0 then
            --  Do not free commands registered as actions, except if we are
            --  freeing the actions themselves
            Free (Command.Next_Commands);
            Free (Command.Alternate_Commands);
            Free (Command.all);
            Unchecked_Free (Command);
         end if;
      end if;
   end Unref;

   ----------
   -- Name --
   ----------

   function Name (Command : access Root_Command) return String is
      pragma Unreferenced (Command);
   begin
      return "Generic command";
   end Name;

   --------------
   -- Progress --
   --------------

   function Progress (Command : access Root_Command) return Progress_Record is
   begin
      return Command.Progress;
   end Progress;

   ------------------
   -- Set_Progress --
   ------------------

   procedure Set_Progress
     (Command  : access Root_Command;
      Progress : Progress_Record) is
   begin
      Command.Progress := Progress;
   end Set_Progress;

   ---------------
   -- Interrupt --
   ---------------

   procedure Interrupt (Command : in out Root_Command) is
      pragma Unreferenced (Command);
   begin
      null;
   end Interrupt;

   ----------
   -- Undo --
   ----------

   function Undo (Command : access Root_Command) return Boolean is
   begin
      Command_Finished (Command, False);
      return False;
   end Undo;

   -------------
   -- Enqueue --
   -------------

   procedure Enqueue
     (Queue         : Command_Queue;
      Action        : access Root_Command;
      High_Priority : Boolean := False) is
   begin
      Enqueue (Queue, Action, High_Priority, True);
   end Enqueue;

   -------------
   -- Enqueue --
   -------------

   procedure Enqueue
     (Queue         : Command_Queue;
      Action        : access Root_Command'Class;
      High_Priority : Boolean;
      Modify_Group  : Boolean) is
   begin
      if Queue = Null_Command_Queue then
         return;
      end if;

      Action.Queue := Queue;

      if Modify_Group then
         Action.Group := Queue.Current_Group_Number;
      end if;

      if High_Priority then
         Prepend (Queue.The_Queue, Command_Access (Action));
      else
         Append (Queue.The_Queue, Command_Access (Action));
      end if;

      if not Queue.Command_In_Progress then
         Execute_Next_Action (Queue);
      end if;
   end Enqueue;

   ------------------
   -- Get_Position --
   ------------------

   function Get_Position (Queue : Command_Queue) return Integer is
   begin
      return Queue.Position;
   end Get_Position;

   -------------------------
   -- Execute_Next_Action --
   -------------------------

   procedure Execute_Next_Action (Queue : Command_Queue) is
   begin
      --  If there is already a command running, then do nothing

      if Queue.Command_In_Progress then
         return;
      end if;

      --  If the queue is empty, set its state accordingly

      if Is_Empty (Queue.The_Queue) then
         Queue.Command_In_Progress := False;
         return;
      end if;

      Queue.Command_In_Progress := True;

      declare
         Action  : constant Command_Access := Head (Queue.The_Queue);
         Success : Boolean;
         Result  : Command_Return_Type;
         pragma Unreferenced (Success, Result);

      begin
         Next (Queue.The_Queue, Free_Data => False);

         case Action.Mode is
            when Normal | Undone =>
               Result := Execute (Action);

            when Done =>
               Success := Undo (Action);
         end case;
      end;
   end Execute_Next_Action;

   -----------------------------
   -- Command_Finished_Status --
   -----------------------------

   procedure Command_Finished_Status
     (Action  : access Root_Command'Class;
      Success : in out Boolean)
   is
      Queue : Command_Queue renames Action.Queue;
      Node  : List_Node;

   begin
      if Queue = null then
         --  If we are not calling the commands in "Queue" mode, do not execute
         --  the Next/Alternate command.
         return;
      end if;

      Node := First (Action.Next_Commands);

      if Action.Group_Fail then
         if Node /= Null_Node and then Data (Node).Group_Fail then
            --  Next action still part of the group fail, record status and
            --  keep going.
            Action.Queue.Stored_Status :=
              Action.Queue.Stored_Status and then Success;
            Success := True;

         else
            --  We reach the end of a group fail section, the status of the
            --  last action is set to false if one of the grouped action
            --  failed.
            Success := Success and then Action.Queue.Stored_Status;
            Action.Queue.Stored_Status := True;
         end if;
      end if;

      if not Success then
         Node := First (Action.Alternate_Commands);
      end if;

      Queue.Command_In_Progress := False;

      --  Copy all actions from the proper list pointed to by Node into the
      --  queue.

      while Node /= Null_Node loop
         Prepend (Queue.The_Queue, Data (Node));
         Data (Node).Queue := Queue;
         Node := Next (Node);
      end loop;

      --  And release them from the current list

      if Success then
         Free (Action.Next_Commands, Free_Data => False);
         Free (Action.Alternate_Commands);
      else
         Free (Action.Alternate_Commands, Free_Data => False);
         Free (Action.Next_Commands);
      end if;

      Action.Next_Commands := Null_List;
      Action.Alternate_Commands := Null_List;

      case Action.Mode is
         when Normal =>
            Action.Mode := Done;
            Prepend (Queue.Undo_Queue, Command_Access (Action));
            --  When a normal command is finished, purge the redo queue
            Free (Queue.Redo_Queue);
            Queue.Position := Queue.Position + 1;

         when Done =>
            Action.Mode := Undone;
            Prepend (Queue.Redo_Queue, Command_Access (Action));
            Queue.Position := Queue.Position - 1;

         when Undone =>
            Action.Mode := Done;
            Prepend (Queue.Undo_Queue, Command_Access (Action));
            Queue.Position := Queue.Position + 1;
      end case;

      --  Execute the registered hooks

      Node := First (Queue.Queue_Change_Hook);

      while Node /= Null_Node loop
         Execute (Data (Node));
         Node := Next (Node);
      end loop;

      Execute_Next_Action (Action.Queue);
   end Command_Finished_Status;

   ----------------------
   -- Command_Finished --
   ----------------------

   procedure Command_Finished
     (Action  : access Root_Command'Class;
      Success : Boolean)
   is
      S : Boolean := Success;
   begin
      Command_Finished_Status (Action, S);
   end Command_Finished;

   ---------------------------
   -- Get_Queue_Change_Hook --
   ---------------------------

   function Get_Queue_Change_Hook
     (Queue : Command_Queue) return Command_Queues.List is
   begin
      return Queue.Queue_Change_Hook;
   end Get_Queue_Change_Hook;

   ---------------------------
   -- Add_Queue_Change_Hook --
   ---------------------------

   procedure Add_Queue_Change_Hook
     (Queue      : Command_Queue;
      Command    : Command_Access;
      Identifier : String)
   is
      Id        : String_List.List_Node;
      Hook_Node : List_Node;

   begin
      Hook_Node := First (Queue.Queue_Change_Hook);
      Id := String_List.First (Queue.Hook_Identifiers);

      while Hook_Node /= Null_Node loop
         if String_List.Data (Id) = Identifier then
            Set_Data (Hook_Node, Command);
            return;
         end if;

         Hook_Node := Next (Hook_Node);
         Id := String_List.Next (Id);
      end loop;

      Append (Queue.Queue_Change_Hook, Command);
      String_List.Append (Queue.Hook_Identifiers, Identifier);
   end Add_Queue_Change_Hook;

   -------------
   -- Execute --
   -------------

   procedure Execute (Command : access Root_Command) is
      Success : Command_Return_Type;
      pragma Unreferenced (Success);
   begin
      Success := Execute (Command_Access (Command));
   end Execute;

   ----------------------------
   -- Is_Continuation_Action --
   ----------------------------

   function Is_Continuation_Action
     (Action : access Root_Command) return Boolean is
   begin
      return Action.Group_Fail;
   end Is_Continuation_Action;

   -----------------------------
   -- Add_Continuation_Action --
   -----------------------------

   procedure Add_Continuation_Action
     (Item   : access Root_Command'Class;
      Action : access Root_Command'Class) is
   begin
      Item.Group_Fail := True;
      Action.Group_Fail := True;
      Prepend (Item.Next_Commands, Command_Access (Action));
   end Add_Continuation_Action;

   ----------------------------
   -- Add_Consequence_Action --
   ----------------------------

   procedure Add_Consequence_Action
     (Item   : access Root_Command'Class;
      Action : access Root_Command'Class) is
   begin
      Prepend (Item.Next_Commands, Command_Access (Action));
   end Add_Consequence_Action;

   --------------------------
   -- Add_Alternate_Action --
   --------------------------

   procedure Add_Alternate_Action
     (Item   : access Root_Command'Class;
      Action : access Root_Command'Class) is
   begin
      Prepend (Item.Alternate_Commands, Command_Access (Action));
   end Add_Alternate_Action;

   --------------------------
   -- Get_Previous_Command --
   --------------------------

   function Get_Previous_Command
     (Queue : Command_Queue) return Command_Access is
   begin
      if not Is_Empty (Queue.Undo_Queue) then
         return Head (Queue.Undo_Queue);
      else
         return null;
      end if;
   end Get_Previous_Command;

   ----------------------
   -- Get_Next_Command --
   ----------------------

   function Get_Next_Command
     (Queue : Command_Queue) return Command_Access is
   begin
      if not Is_Empty (Queue.Redo_Queue) then
         return Head (Queue.Redo_Queue);
      else
         return null;
      end if;
   end Get_Next_Command;

   ----------
   -- Undo --
   ----------

   procedure Undo (Queue : Command_Queue) is
      Action : Command_Access;
      Group  : Natural := 0;
   begin
      while not Is_Empty (Queue.Undo_Queue) loop
         Action := Head (Queue.Undo_Queue);

         exit when Group /= 0 and then Group /= Action.Group;

         Queue.Group_Level := 0;
         Change_Group (Queue);

         Group := Action.Group;

         Next (Queue.Undo_Queue, Free_Data => False);
         Enqueue (Queue, Action, False, False);

         exit when Group = 0;
      end loop;
   end Undo;

   ----------
   -- Redo --
   ----------

   procedure Redo (Queue : Command_Queue) is
      Action : Command_Access;
      Group  : Natural := 0;
   begin
      while not Is_Empty (Queue.Redo_Queue) loop
         Action := Head (Queue.Redo_Queue);

         exit when Group /= 0 and then Group /= Action.Group;

         Queue.Group_Level := 0;
         Change_Group (Queue);

         Group := Action.Group;

         Next (Queue.Redo_Queue, Free_Data => False);
         Enqueue (Queue, Action, False, False);

         exit when Group = 0;
      end loop;
   end Redo;

   ----------------------
   -- Undo_Queue_Empty --
   ----------------------

   function Undo_Queue_Empty (Queue : Command_Queue) return Boolean is
   begin
      return Is_Empty (Queue.Undo_Queue);
   end Undo_Queue_Empty;

   ----------------------
   -- Redo_Queue_Empty --
   ----------------------

   function Redo_Queue_Empty (Queue : Command_Queue) return Boolean is
   begin
      return Is_Empty (Queue.Redo_Queue);
   end Redo_Queue_Empty;

   -----------------------------
   -- Get_Consequence_Actions --
   -----------------------------

   function Get_Consequence_Actions
     (Item : access Root_Command'Class) return Command_Queues.List is
   begin
      return Item.Next_Commands;
   end Get_Consequence_Actions;

   ---------------------------
   -- Get_Alternate_Actions --
   ---------------------------

   function Get_Alternate_Actions
     (Item : access Root_Command'Class) return Command_Queues.List is
   begin
      return Item.Alternate_Commands;
   end Get_Alternate_Actions;

   ------------------------------
   -- Free_Consequence_Actions --
   ------------------------------

   procedure Free_Consequence_Actions
     (Item      : access Root_Command'Class;
      Free_Data : Boolean;
      Free_List : Boolean)
   is
      Empty : Command_Queues.List;
   begin
      if Free_Data then
         Command_Queues.Free (Item.Next_Commands);
      else
         if Free_List then
            Command_Queues.Free (Item.Next_Commands, False);
         end if;

         Item.Next_Commands := Empty;
      end if;
   end Free_Consequence_Actions;

   ----------------------------
   -- Free_Alternate_Actions --
   ----------------------------

   procedure Free_Alternate_Actions
     (Item      : access Root_Command'Class;
      Free_Data : Boolean;
      Free_List : Boolean)
   is
      Empty : Command_Queues.List;
   begin
      if Free_Data then
         Command_Queues.Free (Item.Alternate_Commands);
      else
         if Free_List then
            Command_Queues.Free (Item.Alternate_Commands, False);
         end if;

         Item.Alternate_Commands := Empty;
      end if;
   end Free_Alternate_Actions;

   --------------------------------
   -- Launch_Synchronous_Generic --
   --------------------------------

   procedure Launch_Synchronous_Generic
     (Command : access Root_Command'Class;
      Wait    : Duration := 0.0)
   is
      Next_Actions : List_Node;
      Result       : Command_Return_Type;
   begin
      loop
         Result := Execute_Command (Command_Access (Command));

         exit when Result = Success or else Result = Failure;

         if Wait /= 0.0 then
            delay Wait;
         end if;
      end loop;

      if Result = Success then
         Next_Actions := First (Get_Consequence_Actions (Command));

      else
         Next_Actions := First (Get_Alternate_Actions (Command));
      end if;

      --  ??? Should we really use a recursive implementation here
      while Next_Actions /= Null_Node loop
         Launch_Synchronous_Generic (Data (Next_Actions), Wait);
         Next_Actions := Next (Next_Actions);
      end loop;
   end Launch_Synchronous_Generic;

   -----------------------------
   -- Default_Execute_Command --
   -----------------------------

   function Default_Execute_Command
     (Command : Command_Access) return Command_Return_Type is
   begin
      return Execute (Command);
   end Default_Execute_Command;

   ------------------------
   -- Launch_Synchronous --
   ------------------------

   procedure Launch_Synchronous
     (Command : access Root_Command'Class;
      Wait    : Duration := 0.0)
   is
      procedure Internal is new Launch_Synchronous_Generic
        (Default_Execute_Command);
   begin
      Internal (Command, Wait);
   end Launch_Synchronous;

   ----------
   -- Free --
   ----------

   procedure Free (X : in out Root_Command) is
      pragma Unreferenced (X);
   begin
      null;
   end Free;

   -----------------
   -- Start_Group --
   -----------------

   procedure Start_Group (Q : Command_Queue) is
   begin
      if Q /= null then
         Q.Group_Level := Q.Group_Level + 1;
         Change_Group (Q);
         Q.Current_Group_Number := Q.Last_Group_Number;
      end if;
   end Start_Group;

   ---------------
   -- End_Group --
   ---------------

   procedure End_Group (Q : Command_Queue) is
   begin
      if Q /= null and then Q.Group_Level > 0 then
         Q.Group_Level := Q.Group_Level - 1;
      end if;
   end End_Group;

   ------------------
   -- Change_Group --
   ------------------

   procedure Change_Group (Queue : Command_Queue) is
   begin
      if Queue.Last_Group_Number = Natural'Last then
         Queue.Last_Group_Number := 1;
      else
         Queue.Last_Group_Number := Queue.Last_Group_Number + 1;
      end if;
   end Change_Group;

   --------------------------
   -- Debug_Get_Undo_Queue --
   --------------------------

   function Debug_Get_Undo_Queue
     (Q : Command_Queue) return Command_Queues.List is
   begin
      return Q.Undo_Queue;
   end Debug_Get_Undo_Queue;

   --------------------------
   -- Debug_Get_Redo_Queue --
   --------------------------

   function Debug_Get_Redo_Queue
     (Q : Command_Queue) return Command_Queues.List is
   begin
      return Q.Redo_Queue;
   end Debug_Get_Redo_Queue;

   ---------------------
   -- Debug_Get_Group --
   ---------------------

   function Debug_Get_Group
     (C : Command_Access) return Natural is
   begin
      return C.Group;
   end Debug_Get_Group;

end Commands;
