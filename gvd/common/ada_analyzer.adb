with String_Utils;            use String_Utils;
with Ada.Characters.Handling; use Ada.Characters.Handling;
with GNAT.IO;                 use GNAT.IO;
with Ada.Unchecked_Deallocation;

package body Ada_Analyzer is

   use Basic_Types;

   -----------------
   -- Local types --
   -----------------

   subtype Token_Class_Literal is
     Token_Type range Tok_Integer_Literal .. Tok_Operator_Symbol;
   --  Literal

   subtype Token_Class_Declk is
     Token_Type range Tok_Entry .. Tok_Procedure;
   --  Keywords which start a declaration

   ----------------------
   -- Local procedures --
   ----------------------

   function Get_Token (S : String) return Token_Type;
   --  Return a token_Type given a string.
   --  For efficiency, S is assumed to start at index 1.

   function Is_Library_Level (Stack : Token_Stack.Simple_Stack) return Boolean;
   --  Return True if the current scope in Stack is a library level package.

   function Is_Word_Char (C : Character) return Boolean;
   --  Return whether C is a word character (alphanumeric or underscore).
   pragma Inline (Is_Word_Char);

   function Next_Char  (P : Natural) return Natural;
   --  Return the next char in buffer. P is the current character.
   pragma Inline (Next_Char);

   function Prev_Char (P : Natural) return Natural;
   --  Return the previous char in buffer. P is the current character.
   pragma Inline (Prev_Char);

   procedure Replace_Text
     (Buffer  : in out Extended_Line_Buffer;
      First   : Natural;
      Last    : Natural;
      Replace : String);
   --  Replace the slice First .. Last - 1 in Buffer by Replace.

   ------------------
   -- Is_Word_Char --
   ------------------

   function Is_Word_Char (C : Character) return Boolean is
   begin
      return C = '_' or else Is_Alphanumeric (C);
   end Is_Word_Char;

   ---------------
   -- Next_Char --
   ---------------

   function Next_Char (P : Natural) return Natural is
   begin
      return P + 1;
   end Next_Char;

   ---------------
   -- Get_Token --
   ---------------

   function Get_Token (S : String) return Token_Type is
   begin
      if S'Length = 1 then
         return Tok_Identifier;
      end if;

      --  Use a case statement instead of a loop for efficiency

      case S (1) is
         when 'a' =>
            case S (2) is
               when 'b' =>
                  if S (3 .. S'Last) = "ort" then
                     return Tok_Abort;
                  elsif S (3 .. S'Last) = "s" then
                     return Tok_Abs;
                  elsif S (3 .. S'Last) = "stract" then
                     return Tok_Abstract;
                  end if;

               when 'c' =>
                  if S (3 .. S'Last) = "cept" then
                     return Tok_Accept;
                  elsif S (3 .. S'Last) = "cess" then
                     return Tok_Access;
                  end if;

               when 'l' =>
                  if S (3 .. S'Last) = "l" then
                     return Tok_All;
                  elsif S (3 .. S'Last) = "iased" then
                     return Tok_Aliased;
                  end if;

               when 'n' =>
                  if S (3 .. S'Last) = "d" then
                     return Tok_And;
                  end if;

               when 'r' =>
                  if S (3 .. S'Last) = "ray" then
                     return Tok_Array;
                  end if;

               when 't' =>
                  if S'Length = 2 then
                     return Tok_At;
                  end if;

               when others =>
                  return Tok_Identifier;
            end case;

         when 'b' =>
            if S (2 .. S'Last) = "egin" then
               return Tok_Begin;
            elsif S (2 .. S'Last) = "ody" then
               return Tok_Body;
            end if;

         when 'c' =>
            if S (2 .. S'Last) = "ase" then
               return Tok_Case;
            elsif S (2 .. S'Last) = "onstant" then
               return Tok_Constant;
            end if;

         when 'd' =>
            if S (2) = 'e' then
               if S (3 .. S'Last) = "clare" then
                  return Tok_Declare;
               elsif S (3 .. S'Last) = "lay" then
                  return Tok_Delay;
               elsif S (3 .. S'Last) = "lta" then
                  return Tok_Delta;
               end if;

            elsif S (2 .. S'Last) = "idgits" then
               return Tok_Digits;
            elsif S (2 .. S'Last) = "o" then
               return Tok_Do;
            end if;

         when 'e' =>
            if S (2 .. S'Last) = "lse" then
               return Tok_Else;
            elsif S (2 .. S'Last) = "lsif" then
               return Tok_Elsif;
            elsif S (2 .. S'Last) = "nd" then
               return Tok_End;
            elsif S (2 .. S'Last) = "ntry" then
               return Tok_Entry;
            elsif S (2 .. S'Last) = "xception" then
               return Tok_Exception;
            elsif S (2 .. S'Last) = "xit" then
               return Tok_Exit;
            end if;

         when 'f' =>
            if S (2 .. S'Last) = "or" then
               return Tok_For;
            elsif S (2 .. S'Last) = "unction" then
               return Tok_Function;
            end if;

         when 'g' =>
            if S (2 .. S'Last) = "eneric" then
               return Tok_Generic;
            elsif S (2 .. S'Last) = "oto" then
               return Tok_Goto;
            end if;

         when 'i' =>
            if S (2 .. S'Last) = "f" then
               return Tok_If;
            elsif S (2 .. S'Last) = "n" then
               return Tok_In;
            elsif S (2 .. S'Last) = "s" then
               return Tok_Is;
            end if;

         when 'l' =>
            if S (2 .. S'Last) = "imited" then
               return Tok_Limited;
            elsif S (2 .. S'Last) = "oop" then
               return Tok_Loop;
            end if;

         when 'm' =>
            if S (2 .. S'Last) = "od" then
               return Tok_Mod;
            end if;

         when 'n' =>
            if S (2 .. S'Last) = "ew" then
               return Tok_New;
            elsif S (2 .. S'Last) = "ot" then
               return Tok_Not;
            elsif S (2 .. S'Last) = "ull" then
               return Tok_Null;
            end if;

         when 'o' =>
            if S (2 .. S'Last) = "thers" then
               return Tok_Others;
            elsif S (2 .. S'Last) = "ut" then
               return Tok_Out;
            elsif S (2 .. S'Last) = "f" then
               return Tok_Of;
            elsif S (2 .. S'Last) = "r" then
               return Tok_Or;
            end if;

         when 'p' =>
            if S (2) = 'r' then
               if S (3 .. S'Last) = "agma" then
                  return Tok_Pragma;
               elsif S (3 .. S'Last) = "ivate" then
                  return Tok_Private;
               elsif S (3 .. S'Last) = "ocedure" then
                  return Tok_Procedure;
               elsif S (3 .. S'Last) = "otected" then
                  return Tok_Protected;
               end if;

            elsif S (2 .. S'Last) = "ackage" then
               return Tok_Package;
            end if;

         when 'r' =>
            if S (2) = 'a' then
               if S (3 .. S'Last) = "ise" then
                  return Tok_Raise;
               elsif S (3 .. S'Last) = "nge" then
                  return Tok_Range;
               end if;

            elsif S (2) = 'e' then
               if S (3 .. S'Last) = "cord" then
                  return Tok_Record;
               elsif S (3 .. S'Last) = "m" then
                  return Tok_Rem;
               elsif S (3 .. S'Last) = "names" then
                  return Tok_Renames;
               elsif S (3 .. S'Last) = "queue" then
                  return Tok_Requeue;
               elsif S (3 .. S'Last) = "turn" then
                  return Tok_Return;
               elsif S (3 .. S'Last) = "verse" then
                  return Tok_Reverse;
               end if;
            end if;

         when 's' =>
            if S (2 .. S'Last) = "elect" then
               return Tok_Select;
            elsif S (2 .. S'Last) = "eparate" then
               return Tok_Separate;
            elsif S (2 .. S'Last) = "ubtype" then
               return Tok_Subtype;
            end if;

         when 't' =>
            if S (2 .. S'Last) = "agged" then
               return Tok_Tagged;
            elsif S (2 .. S'Last) = "ask" then
               return Tok_Task;
            elsif S (2 .. S'Last) = "erminate" then
               return Tok_Terminate;
            elsif S (2 .. S'Last) = "hen" then
               return Tok_Then;
            elsif S (2 .. S'Last) = "ype" then
               return Tok_Type;
            end if;

         when 'u' =>
            if S (2 .. S'Last) = "ntil" then
               return Tok_Until;
            elsif S (2 .. S'Last) = "se" then
               return Tok_Use;
            end if;

         when 'w' =>
            if S (2 .. S'Last) = "hen" then
               return Tok_When;
            elsif S (2 .. S'Last) = "hile" then
               return Tok_While;
            elsif S (2 .. S'Last) = "ith" then
               return Tok_With;
            end if;

         when 'x' =>
            if S (2 .. S'Last) = "or" then
               return Tok_Xor;
            end if;

         when others =>
            return Tok_Identifier;
      end case;

      return Tok_Identifier;
   end Get_Token;

   ---------------
   -- Prev_Char --
   ---------------

   function Prev_Char (P : Natural) return Natural is
   begin
      return P - 1;
   end Prev_Char;

   ----------------------
   -- Is_Library_Level --
   ----------------------

   function Is_Library_Level
     (Stack : Token_Stack.Simple_Stack) return Boolean
   is
      Tmp : Token_Stack.Simple_Stack;
   begin
      Tmp := Stack;

      while Tmp /= null and then Tmp.Val.Token /= No_Token loop
         if Tmp.Val.Token /= Tok_Package then
            return False;
         end if;

         Tmp := Tmp.Next;
      end loop;

      return True;
   end Is_Library_Level;

   ------------------------
   -- Analyze_Ada_Source --
   ------------------------

   procedure Analyze_Ada_Source
     (Buffer           : Unchecked_String_Access;
      Buffer_Length    : Natural;
      New_Buffer       : in out Extended_Line_Buffer;
      Indent_Params    : Indent_Parameters;
      Reserved_Casing  : Casing_Type           := Lower;
      Ident_Casing     : Casing_Type           := Mixed;
      Format_Operators : Boolean               := True;
      Indent           : Boolean               := True;
      Constructs       : Construct_List_Access := null;
      Current_Indent   : out Natural;
      Prev_Indent      : out Natural;
      Callback         : Entity_Callback := null)
   is
      ---------------
      -- Constants --
      ---------------

      None   : constant := -1;
      Spaces : constant String (1 .. 512) := (others => ' ');
      --  Use to handle indentation in procedure Do_Indent below.

      Default_Extended : Extended_Token;
      --  Use default values to initialize this pseudo constant.

      Indent_Level    : Natural renames Indent_Params.Indent_Level;
      Indent_Continue : Natural renames Indent_Params.Indent_Continue;
      Indent_Decl     : Natural renames Indent_Params.Indent_Decl;
      Indent_Return   : Natural renames Indent_Params.Indent_Return;
      Indent_Renames  : Natural renames Indent_Params.Indent_Renames;
      Indent_With     : Natural renames Indent_Params.Indent_With;
      Indent_Use      : Natural renames Indent_Params.Indent_Use;
      Indent_Record   : Natural renames Indent_Params.Indent_Record;

      ---------------
      -- Variables --
      ---------------

      Line_Count          : Integer           := 1;
      Str                 : String (1 .. 1024);
      Str_Len             : Natural           := 0;
      Current             : Natural;
      Prec                : Natural           := 1;
      Token_Prec          : Natural           := 0;
      Start_Of_Line       : Natural;
      Prev_Spaces         : Integer           := 0;
      Num_Spaces          : Integer           := 0;
      Indent_Done         : Boolean           := False;
      Num_Parens          : Integer           := 0;
      In_Generic          : Boolean           := False;
      Subprogram_Decl     : Boolean           := False;
      Syntax_Error        : Boolean           := False;
      Started             : Boolean           := False;
      Token               : Token_Type;
      Prev_Token          : Token_Type        := No_Token;
      Tokens              : Token_Stack.Simple_Stack;
      Indents             : Indent_Stack.Simple_Stack;
      Top_Token           : Token_Stack.Generic_Type_Access;
      Casing              : Casing_Type;

      procedure Handle_Reserved_Word (Reserved : Token_Type);
      --  Handle reserved words.

      procedure Next_Word (P : in out Natural);
      --  Starting at Buffer (P), find the location of the next word
      --  and set P accordingly.
      --  Formatting of operators is performed by this procedure.
      --  The following variables are accessed read-only:
      --    Buffer, Tokens, Num_Spaces, Indent_Continue
      --  The following variables are read and modified:
      --    New_Buffer, Num_Parens, Line_Count, Indents, Indent_Done,
      --    Prev_Token.

      function End_Of_Word (P : Natural) return Natural;
      --  Return the end of the word pointed by P.

      function Line_Start (P : Natural) return Natural;
      --  Return the start of the line pointed by P.

      function Line_End (P : Natural) return Natural;
      --  Return the end of the line pointed by P.

      function Next_Line (P : Natural) return Natural;
      --  Return the start of the next line.

      procedure New_Line (Count : in out Natural);
      pragma Inline (New_Line);
      --  Increment Count and poll if needed (e.g for graphic events).

      procedure Do_Indent
        (Prec       : Natural;
         Num_Spaces : Integer);
      --  Perform indentation by inserting spaces in the buffer.

      --------------------
      -- Stack Routines --
      --------------------

      procedure Pop
        (Stack : in out Token_Stack.Simple_Stack; Value : out Extended_Token);
      --  Pop Value on top of Stack.

      procedure Pop (Stack : in out Token_Stack.Simple_Stack);
      --  Pop Value on top of Stack. Ignore returned value.

      ---------------
      -- Do_Indent --
      ---------------

      procedure Do_Indent
        (Prec       : Natural;
         Num_Spaces : Integer)
      is
         Start       : Natural;
         Indentation : Integer;
         Index       : Natural;

      begin
         if not Indent_Done then
            Start := Line_Start (Prec);
            Index := Start;

            while Buffer (Index) = ' ' or else Buffer (Index) = ASCII.HT loop
               Index := Index + 1;
            end loop;

            if Top (Indents).all = None then
               Indentation := Num_Spaces;
            else
               Indentation := Top (Indents).all;
            end if;

            if Indent then
               Replace_Text
                 (New_Buffer, Start, Index, Spaces (1 .. Indentation));
            end if;

            Indent_Done := True;
            Prev_Spaces := Indentation;
         end if;
      end Do_Indent;

      -----------------
      -- End_Of_Word --
      -----------------

      function End_Of_Word (P : Natural) return Natural is
         Tmp : Natural := P;
      begin
         while Tmp < Buffer_Length
           and then Is_Word_Char (Buffer (Next_Char (Tmp)))
         loop
            Tmp := Next_Char (Tmp);
         end loop;

         return Tmp;
      end End_Of_Word;

      ----------------
      -- Line_Start --
      ----------------

      function Line_Start (P : Natural) return Natural is
      begin
         for J in reverse Buffer'First .. P loop
            if Buffer (J) = ASCII.LF or else Buffer (J) = ASCII.CR then
               return J + 1;
            end if;
         end loop;

         return Buffer'First;
      end Line_Start;

      --------------
      -- Line_End --
      --------------

      function Line_End (P : Natural) return Natural is
      begin
         for J in P .. Buffer_Length loop
            if Buffer (J) = ASCII.LF or else Buffer (J) = ASCII.CR then
               return J - 1;
            end if;
         end loop;

         return Buffer_Length;
      end Line_End;

      ---------------
      -- Next_Line --
      ---------------

      function Next_Line (P : Natural) return Natural is
      begin
         for J in P .. Buffer_Length - 1 loop
            if Buffer (J) = ASCII.LF then
               return J + 1;
            end if;
         end loop;

         return Buffer_Length;
      end Next_Line;

      --------------
      -- New_Line --
      --------------

      procedure New_Line (Count : in out Natural) is
      begin
         Count := Count + 1;
      end New_Line;

      ---------
      -- Pop --
      ---------

      procedure Pop
        (Stack : in out Token_Stack.Simple_Stack;
         Value : out Extended_Token)
      is
         Column : Natural;
         Info   : Construct_Access;

      begin
         Token_Stack.Pop (Stack, Value);

         --  Tok_Record will be taken into account by Tok_Type if needed.
         --  Tok_Case inside a type definition should also not be recorded.
         --  Build next entry of Constructs

         if Value.Token /= Tok_Record
           and then Constructs /= null
           and then
             (Value.Token /= Tok_Case or else Top (Stack).Token /= Tok_Record)
           and then (Value.Token /= Tok_Type or else not In_Generic)
         then
            Column             := Prec - Line_Start (Prec) + 1;
            Info               := Constructs.Current;
            Constructs.Current := new Construct_Information;

            if Constructs.First = null then
               Constructs.First := Constructs.Current;
            else
               Constructs.Current.Prev := Info;
               Constructs.Current.Next := Info.Next;
               Info.Next               := Constructs.Current;
            end if;

            Constructs.Last := Constructs.Current;

            if Value.Tagged_Type then
               Constructs.Current.Category := Cat_Class;
            elsif Value.Record_Type then
               Constructs.Current.Category := Cat_Structure;
            else
               case Value.Token is
                  when Tok_Package =>
                     Constructs.Current.Category := Cat_Package;
                  when Tok_Procedure =>
                     Constructs.Current.Category := Cat_Procedure;
                  when Tok_Function =>
                     Constructs.Current.Category := Cat_Function;
                  when Tok_Task =>
                     Constructs.Current.Category := Cat_Task;
                  when Tok_Protected =>
                     Constructs.Current.Category := Cat_Protected;
                  when Tok_Entry =>
                     Constructs.Current.Category := Cat_Entry;

                  when Tok_Type =>
                     Constructs.Current.Category := Cat_Type;
                  when Tok_Subtype =>
                     Constructs.Current.Category := Cat_Subtype;
                  when Tok_For =>
                     Constructs.Current.Category := Cat_Representation_Clause;
                  when Tok_Identifier =>
                     if Is_Library_Level (Stack) then
                        Constructs.Current.Category := Cat_Variable;
                     else
                        Constructs.Current.Category := Cat_Local_Variable;
                     end if;

                  when Tok_With =>
                     Constructs.Current.Category := Cat_With;
                  when Tok_Use =>
                     Constructs.Current.Category := Cat_Use;

                  when Tok_Loop =>
                     Constructs.Current.Category := Cat_Loop_Statement;
                  when Tok_Then =>
                     Constructs.Current.Category := Cat_If_Statement;
                  when Tok_Case =>
                     Constructs.Current.Category := Cat_Case_Statement;
                  when Tok_Select =>
                     Constructs.Current.Category := Cat_Select_Statement;
                  when Tok_Do =>
                     Constructs.Current.Category := Cat_Accept_Statement;
                  when Tok_Declare =>
                     Constructs.Current.Category := Cat_Declare_Block;
                  when Tok_Begin =>
                     Constructs.Current.Category := Cat_Simple_Block;
                  when Tok_Exception =>
                     Constructs.Current.Category := Cat_Exception_Handler;

                  when others =>
                     Constructs.Current.Category := Cat_Unknown;
               end case;
            end if;

            if Value.Ident_Len > 0 then
               Constructs.Current.Name :=
                 new String' (Value.Identifier (1 .. Value.Ident_Len));
            end if;

            if Value.Profile_Start /= 0 then
               Constructs.Current.Profile :=
                 new String'
                   (Buffer (Value.Profile_Start .. Value.Profile_End));
            end if;

            Constructs.Current.Sloc_Start     := Value.Sloc;
            Constructs.Current.Sloc_End       := (Line_Count, Column, Prec);
            Constructs.Current.Is_Declaration :=
              Subprogram_Decl or else Value.Type_Declaration;
         end if;
      end Pop;

      procedure Pop (Stack : in out Token_Stack.Simple_Stack) is
         Value : Extended_Token;
      begin
         Pop (Stack, Value);
      end Pop;

      --------------------------
      -- Handle_Reserved_Word --
      --------------------------

      procedure Handle_Reserved_Word (Reserved : Token_Type) is
         Temp          : Extended_Token;
         Top_Token     : Token_Stack.Generic_Type_Access := Top (Tokens);
         Start_Of_Line : Natural;

      begin
         Temp.Token       := Reserved;
         Start_Of_Line    := Line_Start (Prec);
         Temp.Sloc.Line   := Line_Count;
         Temp.Sloc.Column := Prec - Start_Of_Line + 1;
         Temp.Sloc.Index  := Prec;

         if Callback /= null then
            Callback
              (Ent_Reserved_Word,
               Temp.Sloc, (Line_Count, Current - Start_Of_Line + 1, Current));
         end if;

         --  Note: the order of the following conditions is important

         if Reserved = Tok_Body then
            Subprogram_Decl := False;

         elsif Reserved = Tok_Tagged then
            if Top_Token.Token = Tok_Type then
               Top_Token.Tagged_Type := True;
            end if;

         elsif Prev_Token /= Tok_End and then Reserved = Tok_Case then
            Do_Indent (Prec, Num_Spaces);
            Push (Tokens, Temp);
            Num_Spaces := Num_Spaces + Indent_Level;

         elsif Prev_Token /= Tok_End and then
           (Reserved = Tok_If
             or else Reserved = Tok_For
             or else Reserved = Tok_While)
         then
            Push (Tokens, Temp);

         elsif Reserved = Tok_Renames then
            if not Top_Token.Declaration
              and then (Top_Token.Token = Tok_Function
                or else Top_Token.Token = Tok_Procedure
                or else Top_Token.Token = Tok_Package)
            then
               --  Terminate current subprogram declaration, e.g:
               --  procedure ... renames ...;

               Subprogram_Decl := False;
               Pop (Tokens);
               Do_Indent (Prec, Num_Spaces + Indent_Renames);
            end if;

         elsif Prev_Token = Tok_Is
           and then Top_Token.Token /= Tok_Type
           and then Top_Token.Token /= Tok_Subtype
           and then (Reserved = Tok_New
             or else Reserved = Tok_Abstract
             or else Reserved = Tok_Separate)
         then
            --  Nothing to pop if we are inside a generic definition, e.g:
            --  generic
            --     with package ... is new ...;

            if not In_Generic then
               Pop (Tokens);
            end if;

            --  unindent since this is a declaration, e.g:
            --  package ... is new ...;
            --  function ... is abstract;
            --  function ... is separate;

            Num_Spaces := Num_Spaces - Indent_Level;

            if Num_Spaces < 0 then
               Num_Spaces := 0;
               Syntax_Error := True;
            end if;

         elsif Reserved = Tok_Function
           or else Reserved = Tok_Procedure
           or else Reserved = Tok_Package
           or else Reserved = Tok_Task
           or else Reserved = Tok_Protected
           or else Reserved = Tok_Entry
         then
            if Reserved /= Tok_Package then
               Subprogram_Decl := True;
               Num_Parens      := 0;
            end if;

            if not In_Generic then
               if not Top_Token.Declaration
                 and then (Top_Token.Token = Tok_Function
                           or else Top_Token.Token = Tok_Procedure)
               then
                  --  There was a function declaration, e.g:
                  --
                  --  procedure xxx ();
                  --  procedure ...
                  Pop (Tokens);
               end if;

               Push (Tokens, Temp);

            elsif Prev_Token /= Tok_With then
               --  unindent after a generic declaration, e.g:
               --
               --  generic
               --     with procedure xxx;
               --     with function xxx;
               --     with package xxx;
               --  package xxx is

               Num_Spaces := Num_Spaces - Indent_Level;

               if Num_Spaces < 0 then
                  Num_Spaces := 0;
                  Syntax_Error := True;
               end if;

               In_Generic := False;
               Push (Tokens, Temp);
            end if;

         elsif Reserved = Tok_Return
           and then Subprogram_Decl
         then
            --  function A (....)
            --      return B;  <- use Indent_Return additional spaces

            Do_Indent (Prec, Num_Spaces + Indent_Return);

         elsif Reserved = Tok_End or else Reserved = Tok_Elsif then
            --  unindent after end of elsif, e.g:
            --
            --  if xxx then
            --     xxx
            --  elsif xxx then
            --     xxx
            --  end if;

            if Reserved = Tok_End then
               case Top_Token.Token is
                  when Tok_Exception =>
                     --  Undo additional level of indentation, as in:
                     --     ...
                     --  exception
                     --     when =>
                     --        null;
                     --  end;

                     Num_Spaces := Num_Spaces - Indent_Level;

                     --  End of subprogram
                     Pop (Tokens);

                  when Tok_Case =>
                     Num_Spaces := Num_Spaces - Indent_Level;

                  when Tok_Record =>
                     --  If the "record" keyword was on its own line

                     if Top_Token.Record_Start_New_Line then
                        Do_Indent (Prec, Num_Spaces - Indent_Level);
                        Num_Spaces := Num_Spaces - Indent_Record;
                     end if;

                  when others =>
                     null;
               end case;

               Pop (Tokens);
            end if;

            Num_Spaces := Num_Spaces - Indent_Level;

            if Num_Spaces < 0 then
               Num_Spaces   := 0;
               Syntax_Error := True;
            end if;

         elsif Reserved = Tok_With then
            if not In_Generic then
               if Top_Token.Token = No_Token then
                  Push (Tokens, Temp);

               elsif Top_Token.Token = Tok_Type then
                  Top_Token.Tagged_Type := True;
               end if;
            end if;

         elsif Reserved = Tok_Use and then
           (Top_Token.Token = No_Token or else
             (Top_Token.Token /= Tok_For
               and then Top_Token.Token /= Tok_Record))
         then
            Push (Tokens, Temp);

         elsif     Reserved = Tok_Is
           or else Reserved = Tok_Declare
           or else Reserved = Tok_Begin
           or else Reserved = Tok_Do
           or else (Prev_Token /= Tok_Or  and then Reserved = Tok_Else)
           or else (Prev_Token /= Tok_And and then Reserved = Tok_Then)
           or else (Prev_Token /= Tok_End and then Reserved = Tok_Select)
           or else (Top_Token.Token = Tok_Select and then Reserved = Tok_Or)
           or else (Prev_Token /= Tok_End and then Reserved = Tok_Loop)
           or else (Prev_Token /= Tok_End and then Prev_Token /= Tok_Null
                      and then Reserved = Tok_Record)
           or else ((Top_Token.Token = Tok_Exception
                       or else Top_Token.Token = Tok_Case)
                     and then Reserved = Tok_When)
           or else (Top_Token.Declaration
                      and then Reserved = Tok_Private
                      and then Prev_Token /= Tok_Is
                      and then Prev_Token /= Tok_Limited
                      and then Prev_Token /= Tok_With)
         then
            --  unindent for this reserved word, and then indent again, e.g:
            --
            --  procedure xxx is
            --     ...
            --  begin    <--
            --     ...

            if Reserved = Tok_Select then
               --  Start of a select statement
               Push (Tokens, Temp);

            elsif Top_Token.Token = Tok_If
              and then Reserved = Tok_Then
            then
               --  Notify that we're past the 'if' condition

               Top_Token.Token := Tok_Then;

            elsif Reserved = Tok_Do then
               Push (Tokens, Temp);

            elsif Reserved = Tok_Loop then
               if Top_Token.Token = Tok_While
                 or else Top_Token.Token = Tok_For
               then
                  --  Replace token since this is a loop construct
                  --  but keep the original source location.

                  Top_Token.Token := Tok_Loop;

               else
                  Push (Tokens, Temp);
               end if;

            elsif Reserved = Tok_Declare then
               Temp.Declaration := True;
               Push (Tokens, Temp);

            elsif Reserved = Tok_Is then
               if not In_Generic then
                  case Top_Token.Token is
                     when Tok_Case | Tok_Type | Tok_Subtype =>
                        null;

                     when others =>
                        Subprogram_Decl := False;
                        Top_Token.Declaration := True;
                  end case;
               end if;

            elsif Reserved = Tok_Else
              or else (Top_Token.Token = Tok_Select
                       and then Reserved = Tok_Then)
              or else Reserved = Tok_Begin
              or else Reserved = Tok_Record
              or else Reserved = Tok_When
              or else Reserved = Tok_Or
              or else Reserved = Tok_Private
            then
               if Reserved = Tok_Begin then
                  if Top_Token.Declaration then
                     Num_Spaces := Num_Spaces - Indent_Level;
                     Top_Token.Declaration := False;
                  else
                     Push (Tokens, Temp);
                  end if;

               elsif Reserved = Tok_Record then
                  --  Is "record" the first keyword on the line ?
                  --  If True, we are in a case like:
                  --     type A is
                  --        record    --  from Indent_Record
                  --           null;
                  --        end record;

                  if not Indent_Done then
                     Temp.Record_Start_New_Line := True;
                     Num_Spaces := Num_Spaces + Indent_Record;
                     Do_Indent (Prec, Num_Spaces);
                  end if;

                  if Top_Token.Token = Tok_Type then
                     Top_Token.Record_Type := True;
                     Num_Spaces := Num_Spaces + Indent_Level;
                  end if;

                  Push (Tokens, Temp);

               else
                  Num_Spaces := Num_Spaces - Indent_Level;
               end if;

               if Num_Spaces < 0 then
                  Num_Spaces   := 0;
                  Syntax_Error := True;
               end if;
            end if;

            if Top_Token.Token /= Tok_Type
              and then Top_Token.Token /= Tok_Subtype
            then
               Do_Indent (Prec, Num_Spaces);
               Num_Spaces := Num_Spaces + Indent_Level;
            end if;

         elsif Reserved = Tok_Or
           or else Reserved = Tok_And
         then
            --  "and then", "or else", "and" and "or" should get an extra
            --  indentation on line start, e.g:
            --  if ...
            --    and then ...

            Do_Indent (Prec, Num_Spaces + Indent_Continue);

         elsif Reserved = Tok_Generic then
            --  Indent before a generic entity, e.g:
            --
            --  generic
            --     type ...;

            Do_Indent (Prec, Num_Spaces);
            Num_Spaces := Num_Spaces + Indent_Level;
            In_Generic := True;

         elsif (Reserved = Tok_Type
                and then Prev_Token /= Tok_With    --  with type
                and then Prev_Token /= Tok_Use)    --  use type
           or else Reserved = Tok_Subtype
         then
            --  Entering a type declaration/definition.

            if Prev_Token = Tok_Task               --  task type
              or else Prev_Token = Tok_Protected   --  protected type
            then
               Top_Token.Type_Declaration := True;
            else
               Push (Tokens, Temp);
            end if;

         elsif Reserved = Tok_Exception then
            if Top_Token.Token /= Tok_Identifier then
               Num_Spaces := Num_Spaces - Indent_Level;
               Do_Indent (Prec, Num_Spaces);
               Num_Spaces := Num_Spaces + 2 * Indent_Level;
               Push (Tokens, Temp);
            end if;
         end if;

      exception
         when Token_Stack.Stack_Empty =>
            Syntax_Error := True;
      end Handle_Reserved_Word;

      ---------------
      -- Next_Word --
      ---------------

      procedure Next_Word (P : in out Natural) is
         Comma         : String := ", ";
         Spaces        : String := "    ";
         End_Of_Line   : Natural;
         Start_Of_Line : Natural;
         Long          : Natural;
         First         : Natural;
         Last          : Natural;
         Offs          : Natural;
         Insert_Spaces : Boolean;
         Char          : Character;
         Padding       : Integer := 0;
         Top_Token     : Token_Stack.Generic_Type_Access;
         Previous_Line : constant Natural := Line_Count;

         procedure Handle_Two_Chars (Second_Char : Character);
         --  Handle a two char operator, whose second char is Second_Char.

         procedure Handle_Two_Chars (Second_Char : Character) is
         begin
            Last := P + 2;

            if Buffer (Prev_Char (P)) = ' ' then
               Offs := 2;
               Long := 2;

            else
               Long := 3;
            end if;

            P := Next_Char (P);

            if P < Buffer_Length and then Buffer (Next_Char (P)) /= ' ' then
               Long := Long + 1;
            end if;

            Spaces (3) := Second_Char;
         end Handle_Two_Chars;

      begin
         Start_Of_Line := Line_Start (P);
         End_Of_Line   := Line_End (Start_Of_Line);

         if New_Buffer.Current /= null then
            if New_Buffer.Current.Line'First = Start_Of_Line then
               Padding :=
                 New_Buffer.Current.Line'Length - New_Buffer.Current.Len;
            else
               Padding := 0;
               Indent_Done := False;
            end if;
         end if;

         loop
            --  Skip blank lines

            if Buffer (P) = ASCII.LF or else Buffer (P) = ASCII.CR then
               while P < Buffer_Length and then
                 (Buffer (P) = ASCII.LF or else Buffer (P) = ASCII.CR)
               loop
                  if Buffer (P) = ASCII.LF then
                     New_Line (Line_Count);
                  end if;

                  P := Next_Char (P);
               end loop;

               Start_Of_Line := P;
               Padding       := 0;
               Indent_Done   := False;
               End_Of_Line   := Line_End (Start_Of_Line);
            end if;

            --  Skip comments

            if Buffer (P) = '-' and then Buffer (Next_Char (P)) = '-' then
               declare
                  Prev_Line       : constant Natural := Line_Count;
                  Prev_Start_Line : constant Natural := Start_Of_Line;
               begin
                  First := P;

                  while Buffer (P) = '-'
                    and then Buffer (Next_Char (P)) = '-'
                  loop
                     --  Following line commented because it is too disruptive,
                     --  e.g:
                     --  procedure F  --  multiline
                     --               --  comment should be aligned properly
                     --  ??? Do_Indent (P, Num_Spaces);

                     P := Next_Line (Next_Char (P));
                     New_Line (Line_Count);
                  end loop;

                  Last := Prev_Char (P);

                  if P < Buffer_Length and then Buffer (P) = ASCII.LF then
                     P := Last;
                  end if;

                  Start_Of_Line := P;
                  End_Of_Line   := Line_End (P);
                  Padding       := 0;
                  Indent_Done   := False;

                  if Callback /= null then
                     Callback
                       (Ent_Comment,
                        (Prev_Line, First - Prev_Start_Line + 1, First),
                        (Line_Count - 1, Last - Line_Start (Last) + 1, Last));
                  end if;
               end;
            end if;

            exit when P = Buffer_Length or else Is_Word_Char (Buffer (P));

            case Buffer (P) is
               when '(' =>
                  Prev_Token := Tok_Left_Paren;
                  Char := Buffer (Prev_Char (P));

                  if Indent_Done then
                     if Format_Operators
                       and then Char /= ' ' and then Char /= '('
                     then
                        Spaces (2) := Buffer (P);
                        Replace_Text (New_Buffer, P, P + 1, Spaces (1 .. 2));
                        Padding := Padding + 1;
                     end if;

                  else
                     --  Indent with 2 extra spaces if the '(' is the first
                     --  non blank character on the line

                     Do_Indent (P, Num_Spaces + Indent_Continue);

                     if Indent then
                        Padding := New_Buffer.Current.Line'Length
                          - New_Buffer.Current.Len;
                     end if;
                  end if;

                  Top_Token := Top (Tokens);

                  if Num_Parens = 0
                    and then Top_Token.Token in Token_Class_Declk
                    and then Top_Token.Profile_Start = 0
                    and then Subprogram_Decl
                  then
                     Top_Token.Profile_Start := P;
                  end if;

                  Push (Indents, P - Start_Of_Line + Padding + 1);
                  Num_Parens := Num_Parens + 1;

               when ')' =>
                  Prev_Token := Tok_Right_Paren;

                  if Indents = null then
                     --  Syntax error
                     null;
                  else
                     Pop (Indents);
                     Num_Parens := Num_Parens - 1;

                     Top_Token := Top (Tokens);

                     if Num_Parens = 0
                       and then Top_Token.Token in Token_Class_Declk
                       and then Top_Token.Profile_End = 0
                       and then Subprogram_Decl
                     then
                        Top_Token.Profile_End := P;
                     end if;
                  end if;

               when '"' =>
                  declare
                     Len : Natural;
                  begin
                     First := P;
                     P     := Next_Char (P);

                     while P <= End_Of_Line and then Buffer (P) /= '"' loop
                        P := Next_Char (P);
                     end loop;

                     Top_Token := Top (Tokens);

                     if Top_Token.Token in Token_Class_Declk
                       and then Top_Token.Ident_Len = 0
                     then
                        --  This is an operator symbol, e.g function ">=" (...)

                        Prev_Token := Tok_Operator_Symbol;
                        Len := P - First + 1;
                        Top_Token.Identifier (1 .. Len) := Buffer (First .. P);
                        Top_Token.Ident_Len := Len;

                     else
                        Prev_Token := Tok_String_Literal;
                     end if;

                     if Callback /= null then
                        Callback
                          (Ent_String,
                           (Line_Count, First - Start_Of_Line + 1, First),
                           (Line_Count, P - Start_Of_Line + 1, P));
                     end if;
                  end;

               when '&' | '+' | '-' | '*' | '/' | ':' | '<' | '>' | '=' |
                    '|' | '.'
               =>
                  Spaces (2) := Buffer (P);
                  Spaces (3) := ' ';
                  First := P;
                  Last  := P + 1;
                  Offs  := 1;

                  case Buffer (P) is
                     when '+' | '-' =>
                        if Buffer (P) = '-' then
                           Prev_Token := Tok_Minus;
                        else
                           Prev_Token := Tok_Plus;
                        end if;

                        if To_Upper (Buffer (Prev_Char (P))) /= 'E'
                          or else Buffer (Prev_Char (Prev_Char (P)))
                            not in '0' .. '9'
                        then
                           Prev_Token    := Tok_Integer_Literal;
                           Insert_Spaces := True;
                        else
                           Insert_Spaces := False;
                        end if;

                     when '&' | '|' =>
                        if Buffer (P) = '&' then
                           Prev_Token := Tok_Ampersand;
                        else
                           Prev_Token := Tok_Vertical_Bar;
                        end if;

                        Insert_Spaces := True;

                     when '/' | ':' =>
                        Insert_Spaces := True;

                        if Buffer (Next_Char (P)) = '=' then
                           Handle_Two_Chars ('=');

                           if Buffer (P) = '/' then
                              Prev_Token := Tok_Not_Equal;
                           else
                              Prev_Token := Tok_Colon_Equal;
                           end if;

                        elsif Buffer (P) = '/' then
                           Prev_Token := Tok_Slash;
                        else
                           Prev_Token := Tok_Colon;
                           Top_Token  := Top (Tokens);

                           if Top_Token.Declaration then
                              --  This is a variable declaration

                              declare
                                 Val : Extended_Token;
                              begin
                                 Val.Token       := Tok_Identifier;
                                 Val.Sloc.Line   := Previous_Line;
                                 Val.Sloc.Column :=
                                   Token_Prec - Line_Start (Token_Prec) + 1;
                                 Val.Sloc.Index  := Token_Prec;
                                 Val.Identifier (1 .. Str_Len) :=
                                   Str (1 .. Str_Len);
                                 Val.Ident_Len := Str_Len;
                                 Push (Tokens, Val);
                              end;
                           end if;
                        end if;

                     when '*' =>
                        Insert_Spaces := Buffer (Prev_Char (P)) /= '*';

                        if Buffer (Next_Char (P)) = '*' then
                           Handle_Two_Chars ('*');
                           Prev_Token := Tok_Double_Asterisk;
                        else
                           Prev_Token := Tok_Asterisk;
                        end if;

                     when '.' =>
                        Insert_Spaces := Buffer (Next_Char (P)) = '.';

                        if Insert_Spaces then
                           Handle_Two_Chars ('.');
                           Prev_Token := Tok_Dot_Dot;
                        else
                           Prev_Token := Tok_Dot;
                        end if;

                     when '<' =>
                        case Buffer (Next_Char (P)) is
                           when '=' =>
                              Insert_Spaces := True;
                              Prev_Token    := Tok_Less_Equal;
                              Handle_Two_Chars ('=');

                           when '<' =>
                              Prev_Token    := Tok_Less_Less;
                              Insert_Spaces := False;
                              Handle_Two_Chars ('<');

                           when '>' =>
                              Prev_Token    := Tok_Box;
                              Insert_Spaces := False;
                              Handle_Two_Chars ('>');

                           when others =>
                              Prev_Token    := Tok_Less;
                              Insert_Spaces := True;
                        end case;

                     when '>' =>
                        case Buffer (Next_Char (P)) is
                           when '=' =>
                              Insert_Spaces := True;
                              Prev_Token    := Tok_Greater_Equal;
                              Handle_Two_Chars ('=');

                           when '>' =>
                              Prev_Token    := Tok_Greater_Greater;
                              Insert_Spaces := False;
                              Handle_Two_Chars ('>');

                           when others =>
                              Prev_Token    := Tok_Greater;
                              Insert_Spaces := True;
                        end case;

                     when '=' =>
                        Insert_Spaces := True;

                        if Buffer (Next_Char (P)) = '>' then
                           Prev_Token := Tok_Arrow;
                           Handle_Two_Chars ('>');
                        else
                           Prev_Token := Tok_Equal;
                        end if;

                     when others =>
                        null;
                  end case;

                  if Buffer (Prev_Char (P)) = ' ' then
                     First := First - 1;
                  end if;

                  if Spaces (3) = ' ' then
                     if Buffer (Next_Char (P)) = ' '
                       or else Last - 1 = End_Of_Line
                     then
                        Long := 2;
                     else
                        Long := 3;
                     end if;
                  end if;

                  if Format_Operators and then Insert_Spaces and then
                    (Buffer (Prev_Char (P)) /= ' '
                      or else Long /= Last - P + 1)
                  then
                     Replace_Text
                       (New_Buffer, First, Last,
                        Spaces (Offs .. Offs + Long - 1));
                  end if;

               when ',' | ';' =>
                  Top_Token := Top (Tokens);

                  if Buffer (P) = ';' then
                     Prev_Token := Tok_Semicolon;

                     if Num_Parens = 0 then
                        if Subprogram_Decl
                          or else Top_Token.Token = Tok_Subtype
                          or else Top_Token.Token = Tok_For
                        then
                           if not In_Generic then
                              --  subprogram spec or type decl or repr. clause,
                              --  e.g:
                              --  procedure xxx (...);
                              --  type ... is ...;
                              --  for ... use ...;

                              Pop (Tokens);
                           end if;

                           Subprogram_Decl := False;

                        elsif Top_Token.Token = Tok_With
                          or else Top_Token.Token = Tok_Use
                          or else Top_Token.Token = Tok_Identifier
                          or else Top_Token.Token = Tok_Type
                        then
                           Pop (Tokens);
                        end if;
                     end if;

                  else
                     Prev_Token := Tok_Comma;

                     if Top_Token.Token = Tok_With
                       or else Top_Token.Token = Tok_Use
                     then
                        declare
                           Val : Extended_Token;
                        begin
                           --  Create a separate entry for each with clause:
                           --  with a, b;
                           --  will get two entries: one for a, one for b.

                           Val.Token := Top_Token.Token;
                           Pop (Tokens);
                           Val.Sloc.Line   := Line_Count;
                           Val.Sloc.Column := Prec - Line_Start (Prec) + 2;
                           Val.Sloc.Index  := Prec + 1;
                           Val.Ident_Len := 0;
                           Push (Tokens, Val);
                        end;
                     end if;
                  end if;

                  Char := Buffer (Next_Char (P));

                  if Format_Operators
                    and then Char /= ' ' and then P /= End_Of_Line
                  then
                     Comma (1) := Buffer (P);
                     Replace_Text (New_Buffer, P, P + 1, Comma (1 .. 2));
                  end if;

               when ''' =>
                  --  Apostrophe. This can either be the start of a character
                  --  literal, an isolated apostrophe used in a qualified
                  --  expression or an attribute. We treat it as a character
                  --  literal if it does not follow a right parenthesis,
                  --  identifier, the keyword ALL or a literal. This means that
                  --  we correctly treat constructs like:
                  --    A := Character'('A');

                  if Prev_Token = Tok_Identifier
                     or else Prev_Token = Tok_Right_Paren
                     or else Prev_Token = Tok_All
                     or else Prev_Token in Token_Class_Literal
                  then
                     Prev_Token := Tok_Apostrophe;
                  else
                     First := P;
                     P     := Next_Char (Next_Char (P));

                     while P <= End_Of_Line
                       and then Buffer (P) /= '''
                     loop
                        P := Next_Char (P);
                     end loop;

                     Prev_Token := Tok_Char_Literal;

                     if Callback /= null then
                        Callback
                          (Ent_Character,
                           (Line_Count, First - Start_Of_Line + 1, First),
                           (Line_Count, P - Start_Of_Line + 1, P));
                     end if;
                  end if;

               when others =>
                  null;
            end case;

            P := Next_Char (P);
         end loop;
      end Next_Word;

   begin  --  Analyze_Ada_Source
      --  Push a dummy token so that stack will never be empty.
      Push (Tokens, Default_Extended);

      --  Push a dummy indentation so that stack will never be empty.
      Push (Indents, None);

      Next_Word (Prec);
      Current := End_Of_Word (Prec);

      while Current < Buffer_Length loop
         Str_Len := Current - Prec + 1;

         for J in Prec .. Current loop
            Str (J - Prec + 1) := To_Lower (Buffer (J));
         end loop;

         Token := Get_Token (Str (1 .. Str_Len));

         if Token = Tok_Identifier then
            Top_Token := Top (Tokens);

            if (Top_Token.Token in Token_Class_Declk
                or else Top_Token.Token = Tok_With)
              and then Top_Token.Ident_Len = 0
            then
               --  Store enclosing entity name

               Top_Token.Identifier (1 .. Str_Len) := Buffer (Prec .. Current);
               Top_Token.Ident_Len := Str_Len;
            end if;

            Casing := Ident_Casing;

            if Callback /= null then
               Start_Of_Line := Line_Start (Prec);
               Callback
                 (Ent_Identifier,
                  (Line_Count, Prec - Start_Of_Line + 1, Prec),
                  (Line_Count, Current - Start_Of_Line + 1, Current));
            end if;

         elsif Prev_Token = Tok_Apostrophe
           and then (Token = Tok_Delta or else Token = Tok_Digits
                     or else Token = Tok_Range or else Token = Tok_Access)
         then
            --  This token should not be considered as a reserved word

            Casing := Ident_Casing;

            if Callback /= null then
               Start_Of_Line := Line_Start (Prec);
               Callback
                 (Ent_Identifier,
                  (Line_Count, Prec - Start_Of_Line + 1, Prec),
                  (Line_Count, Current - Start_Of_Line + 1, Current));
            end if;

         else
            Casing := Reserved_Casing;
            Handle_Reserved_Word (Token);
         end if;

         case Casing is
            when Unchanged =>
               null;

            when Upper =>
               for J in 1 .. Str_Len loop
                  Str (J) := To_Upper (Str (J));
               end loop;

               Replace_Text
                 (New_Buffer, Prec, Current + 1, Str (1 .. Str_Len));

            when Lower =>
               --  Str already contains lowercase characters.

               Replace_Text
                 (New_Buffer, Prec, Current + 1, Str (1 .. Str_Len));

            when Mixed =>
               Mixed_Case (Str (1 .. Str_Len));
               Replace_Text
                 (New_Buffer, Prec, Current + 1, Str (1 .. Str_Len));
         end case;

         if Started then
            if Prev_Token = Tok_Comma then
               if Top (Tokens).Token = Tok_Declare then
                  --  Inside a declare block, indent broken lines specially
                  --  declare
                  --     A,
                  --         B : Integer;

                  Do_Indent (Prec, Num_Spaces + Indent_Decl);

               elsif Top (Tokens).Token = Tok_With then
                  --  Indent continuation lines in with clauses:
                  --  with Package1,
                  --     Package2;  --  from Indent_With

                  Do_Indent (Prec, Num_Spaces + Indent_With);

               elsif Top (Tokens).Token = Tok_Use then
                  --  Ditto for use clauses:
                  --  use Package1,
                  --    Package2;  --  from Indent_Use

                  Do_Indent (Prec, Num_Spaces + Indent_Use);
               else
                  --  Default case, simply use Num_Spaces

                  Do_Indent (Prec, Num_Spaces);
               end if;
            else
               --  Default case, simply use Num_Spaces

               Do_Indent (Prec, Num_Spaces);
            end if;

         else
            Started := True;
         end if;

         Token_Prec      := Prec;
         Prec            := Current + 1;
         Prev_Token      := Token;
         Next_Word (Prec);
         Current := End_Of_Word (Prec);
      end loop;

      if Prev_Spaces < 0 then
         Prev_Indent := 0;
      else
         Prev_Indent := Prev_Spaces;
      end if;

      if Top (Indents).all = None then
         Current_Indent := Num_Spaces;
      else
         Current_Indent := Top (Indents).all;
      end if;

      Clear (Tokens);
      Clear (Indents);

   exception
      when others =>
         Prev_Indent    := 0;
         Current_Indent := 0;
         Clear (Tokens);
         Clear (Indents);
   end Analyze_Ada_Source;

   --------------------
   -- To_Line_Buffer --
   --------------------

   function To_Line_Buffer (Buffer : String) return Extended_Line_Buffer is
      B     : Extended_Line_Buffer;
      Index : Natural := Buffer'First;
      First : Natural;
      Tmp   : Line_Buffer;
      Prev  : Line_Buffer;
      pragma Warnings (Off, Prev);
      --  GNAT will issue a "warning: "Prev" may be null" which cannot occur
      --  since Prev is set to Tmp at the end of each iteration.

   begin
      loop
         exit when Index >= Buffer'Length;

         First := Index;
         Skip_To_Char (Buffer, Index, ASCII.LF);
         Tmp := new Line_Buffer_Record;

         if First = Buffer'First then
            B.First   := Tmp;
            B.Current := B.First;

         else
            Prev.Next := Tmp;
         end if;

         if Index < Buffer'Length and then Buffer (Index + 1) = ASCII.CR then
            Index := Index + 1;
         end if;

         Tmp.Line := new String' (Buffer (First .. Index));
         Tmp.Len  := Tmp.Line'Length;

         Index := Index + 1;
         Prev := Tmp;
      end loop;

      return B;
   end To_Line_Buffer;

   -----------
   -- Print --
   -----------

   procedure Print (Buffer : Extended_Line_Buffer) is
      Tmp : Line_Buffer := Buffer.First;
   begin
      loop
         exit when Tmp = null;
         Put (Tmp.Line.all);
         Tmp := Tmp.Next;
      end loop;
   end Print;

   ----------
   -- Free --
   ----------

   procedure Free (Buffer : in out Extended_Line_Buffer) is
      Tmp  : Line_Buffer := Buffer.First;
      Prev : Line_Buffer;

   begin
      loop
         exit when Tmp = null;
         Prev := Tmp;
         Tmp := Tmp.Next;
         Free (Prev.Line);
         Free (Prev);
      end loop;
   end Free;

   ------------------
   -- Replace_Text --
   ------------------

   procedure Replace_Text
     (Buffer  : in out Extended_Line_Buffer;
      First   : Natural;
      Last    : Natural;
      Replace : String)
   is
      S          : String_Access;
      F, L       : Natural;
      Line_First : Natural;
      Line_Last  : Natural;
      Padding    : Integer;

   begin
      if Buffer.First = null then
         --  No replacing actually requested
         return;
      end if;

      if Buffer.Current.Line'First + Buffer.Current.Len - 1 < First then
         loop
            Buffer.Current := Buffer.Current.Next;

            exit when Buffer.Current.Line'First + Buffer.Current.Len > First;
         end loop;
      end if;

      Padding := Buffer.Current.Line'Length - Buffer.Current.Len;
      F       := First + Padding;
      L       := Last  + Padding;

      if Last - First = Replace'Length then
         --  Simple case, no need to reallocate buffer

         Buffer.Current.Line (F .. L - 1) := Replace;

      else
         Line_First := Buffer.Current.Line'First;
         Line_Last  := Buffer.Current.Line'Last;

         S := new String
           (Line_First .. Line_Last - ((Last - First) - Replace'Length));
         S (Line_First .. F - 1) := Buffer.Current.Line (Line_First .. F - 1);
         S (F .. F + Replace'Length - 1) := Replace;
         S (F + Replace'Length .. S'Last) :=
           Buffer.Current.Line (L .. Buffer.Current.Line'Last);

         Free (Buffer.Current.Line);
         Buffer.Current.Line := S;
      end if;
   end Replace_Text;

end Ada_Analyzer;
