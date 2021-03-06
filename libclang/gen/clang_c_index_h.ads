pragma Ada_2012;
pragma Style_Checks (Off);

with Interfaces.C; use Interfaces.C;
with System;
with Interfaces.C.Strings;
with clang_c_CXString_h;
--  with time_h;
with Interfaces.C.Extensions;
with stddef_h;
with clang_c_CXErrorCode_h;

package clang_c_Index_h is

   Version : String (1 .. 10) := "8.0.0     ";
   --  A 10-byte string identifying the version of the API. Used to make
   --  an unique identifier in our on-disk cache. This is intentionally
   --  placed in this automatically generated file to force us to update
   --  it with each regeneration.

   CINDEX_VERSION_MAJOR : constant := 0;  --  /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:34
   CINDEX_VERSION_MINOR : constant := 50;  --  /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:35
   --  arg-macro: function CINDEX_VERSION_ENCODE (major, minor)
   --    return  ((major) * 10000) + ((minor) * 1);
   --  unsupported macro: CINDEX_VERSION CINDEX_VERSION_ENCODE( CINDEX_VERSION_MAJOR, CINDEX_VERSION_MINOR )
   --  unsupported macro: CINDEX_VERSION_STRINGIZE_(major,minor) #major"."#minor
   --  arg-macro: procedure CINDEX_VERSION_STRINGIZE (major, minor)
   --    CINDEX_VERSION_STRINGIZE_(major, minor)
   --  unsupported macro: CINDEX_VERSION_STRING CINDEX_VERSION_STRINGIZE( CINDEX_VERSION_MAJOR, CINDEX_VERSION_MINOR)

   type CXIndex is new System.Address;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:81

   type CXTargetInfoImpl is null record;   -- incomplete struct

   type CXTargetInfo is access all CXTargetInfoImpl;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:87

   type CXTranslationUnitImpl is null record;   -- incomplete struct

   type CXTranslationUnit is access all CXTranslationUnitImpl;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:92

   type CXClientData is new System.Address;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:98

   type CXUnsavedFile is record
      Filename : Interfaces.C.Strings.chars_ptr;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:113
      Contents : Interfaces.C.Strings.chars_ptr;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:118
      Length : aliased unsigned_long;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:123
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:107

   type CXAvailabilityKind is 
     (CXAvailability_Available,
      CXAvailability_Deprecated,
      CXAvailability_NotAvailable,
      CXAvailability_NotAccessible)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:131

   type CXVersion is record
      Major : aliased int;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:160
      Minor : aliased int;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:166
      Subminor : aliased int;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:172
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:155

   type CXCursor_ExceptionSpecificationKind is 
     (CXCursor_ExceptionSpecificationKind_None,
      CXCursor_ExceptionSpecificationKind_DynamicNone,
      CXCursor_ExceptionSpecificationKind_Dynamic,
      CXCursor_ExceptionSpecificationKind_MSAny,
      CXCursor_ExceptionSpecificationKind_BasicNoexcept,
      CXCursor_ExceptionSpecificationKind_ComputedNoexcept,
      CXCursor_ExceptionSpecificationKind_Unevaluated,
      CXCursor_ExceptionSpecificationKind_Uninstantiated,
      CXCursor_ExceptionSpecificationKind_Unparsed)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:180

   function clang_createIndex (excludeDeclarationsFromPCH : int; displayDiagnostics : int) return CXIndex  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:267
   with Import => True, 
        Convention => C, 
        External_Name => "clang_createIndex";

   procedure clang_disposeIndex (index : CXIndex)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:276
   with Import => True, 
        Convention => C, 
        External_Name => "clang_disposeIndex";

   type CXGlobalOptFlags is 
     (CXGlobalOpt_None,
      CXGlobalOpt_ThreadBackgroundPriorityForIndexing,
      CXGlobalOpt_ThreadBackgroundPriorityForEditing,
      CXGlobalOpt_ThreadBackgroundPriorityForAll)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:310

   procedure clang_CXIndex_setGlobalOptions (arg1 : CXIndex; options : unsigned)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:325
   with Import => True, 
        Convention => C, 
        External_Name => "clang_CXIndex_setGlobalOptions";

   function clang_CXIndex_getGlobalOptions (arg1 : CXIndex) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:333
   with Import => True, 
        Convention => C, 
        External_Name => "clang_CXIndex_getGlobalOptions";

   procedure clang_CXIndex_setInvocationEmissionPathOption (arg1 : CXIndex; Path : Interfaces.C.Strings.chars_ptr)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:343
   with Import => True, 
        Convention => C, 
        External_Name => "clang_CXIndex_setInvocationEmissionPathOption";

   type CXFile is new System.Address;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:354

   function clang_getFileName (SFile : CXFile) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:359
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getFileName";

--     function clang_getFileTime (SFile : CXFile) return time_h.time_t  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:364
--     with Import => True, 
--          Convention => C, 
--          External_Name => "clang_getFileTime";

   --  skipped anonymous struct anon_4

   type CXFileUniqueID_data_array is array (0 .. 2) of aliased Extensions.unsigned_long_long;
   type CXFileUniqueID is record
      data : aliased CXFileUniqueID_data_array;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:371
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:372

   function clang_getFileUniqueID (file : CXFile; outID : access CXFileUniqueID) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:382
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getFileUniqueID";

   function clang_isFileMultipleIncludeGuarded (tu : CXTranslationUnit; file : CXFile) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:390
   with Import => True, 
        Convention => C, 
        External_Name => "clang_isFileMultipleIncludeGuarded";

   function clang_getFile (tu : CXTranslationUnit; file_name : Interfaces.C.Strings.chars_ptr) return CXFile  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:402
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getFile";

   function clang_getFileContents
     (tu : CXTranslationUnit;
      file : CXFile;
      size : access stddef_h.size_t) return Interfaces.C.Strings.chars_ptr  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:417
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getFileContents";

   function clang_File_isEqual (file1 : CXFile; file2 : CXFile) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:424
   with Import => True, 
        Convention => C, 
        External_Name => "clang_File_isEqual";

   function clang_File_tryGetRealPathName (file : CXFile) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:431
   with Import => True, 
        Convention => C, 
        External_Name => "clang_File_tryGetRealPathName";

   --  skipped anonymous struct anon_5

   type CXSourceLocation_ptr_data_array is array (0 .. 1) of System.Address;
   type CXSourceLocation is record
      ptr_data : CXSourceLocation_ptr_data_array;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:458
      int_data : aliased unsigned;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:459
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:460

   --  skipped anonymous struct anon_6

   type CXSourceRange_ptr_data_array is array (0 .. 1) of System.Address;
   type CXSourceRange is record
      ptr_data : CXSourceRange_ptr_data_array;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:469
      begin_int_data : aliased unsigned;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:470
      end_int_data : aliased unsigned;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:471
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:472

   function clang_getNullLocation return CXSourceLocation  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:477
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getNullLocation";

   function clang_equalLocations (loc1 : CXSourceLocation; loc2 : CXSourceLocation) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:487
   with Import => True, 
        Convention => C, 
        External_Name => "clang_equalLocations";

   function clang_getLocation
     (tu : CXTranslationUnit;
      file : CXFile;
      line : unsigned;
      column : unsigned) return CXSourceLocation  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:494
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getLocation";

   function clang_getLocationForOffset
     (tu : CXTranslationUnit;
      file : CXFile;
      offset : unsigned) return CXSourceLocation  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:502
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getLocationForOffset";

   function clang_Location_isInSystemHeader (location : CXSourceLocation) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:509
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Location_isInSystemHeader";

   function clang_Location_isFromMainFile (location : CXSourceLocation) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:515
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Location_isFromMainFile";

   function clang_getNullRange return CXSourceRange  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:520
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getNullRange";

   function clang_getRange (c_begin : CXSourceLocation; c_end : CXSourceLocation) return CXSourceRange  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:526
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getRange";

   function clang_equalRanges (range1 : CXSourceRange; range2 : CXSourceRange) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:534
   with Import => True, 
        Convention => C, 
        External_Name => "clang_equalRanges";

   function clang_Range_isNull (c_range : CXSourceRange) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:540
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Range_isNull";

   procedure clang_getExpansionLocation
     (location : CXSourceLocation;
      file : System.Address;
      line : access unsigned;
      column : access unsigned;
      offset : access unsigned)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:564
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getExpansionLocation";

   procedure clang_getPresumedLocation
     (location : CXSourceLocation;
      filename : access clang_c_CXString_h.CXString;
      line : access unsigned;
      column : access unsigned)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:610
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getPresumedLocation";

   procedure clang_getInstantiationLocation
     (location : CXSourceLocation;
      file : System.Address;
      line : access unsigned;
      column : access unsigned;
      offset : access unsigned)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:623
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getInstantiationLocation";

   procedure clang_getSpellingLocation
     (location : CXSourceLocation;
      file : System.Address;
      line : access unsigned;
      column : access unsigned;
      offset : access unsigned)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:651
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getSpellingLocation";

   procedure clang_getFileLocation
     (location : CXSourceLocation;
      file : System.Address;
      line : access unsigned;
      column : access unsigned;
      offset : access unsigned)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:680
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getFileLocation";

   function clang_getRangeStart (c_range : CXSourceRange) return CXSourceLocation  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:690
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getRangeStart";

   function clang_getRangeEnd (c_range : CXSourceRange) return CXSourceLocation  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:696
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getRangeEnd";

   --  skipped anonymous struct anon_7

   type CXSourceRangeList is record
      count : aliased unsigned;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:703
      ranges : access CXSourceRange;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:707
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:708

   function clang_getSkippedRanges (tu : CXTranslationUnit; file : CXFile) return access CXSourceRangeList  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:716
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getSkippedRanges";

   function clang_getAllSkippedRanges (tu : CXTranslationUnit) return access CXSourceRangeList  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:726
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getAllSkippedRanges";

   procedure clang_disposeSourceRangeList (ranges : access CXSourceRangeList)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:731
   with Import => True, 
        Convention => C, 
        External_Name => "clang_disposeSourceRangeList";

   type CXDiagnosticSeverity is 
     (CXDiagnostic_Ignored,
      CXDiagnostic_Note,
      CXDiagnostic_Warning,
      CXDiagnostic_Error,
      CXDiagnostic_Fatal)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:746

   type CXDiagnostic is new System.Address;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:782

   type CXDiagnosticSet is new System.Address;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:787

   function clang_getNumDiagnosticsInSet (Diags : CXDiagnosticSet) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:792
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getNumDiagnosticsInSet";

   function clang_getDiagnosticInSet (Diags : CXDiagnosticSet; Index : unsigned) return CXDiagnostic  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:803
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getDiagnosticInSet";

   type CXLoadDiag_Error is 
     (CXLoadDiag_None,
      CXLoadDiag_Unknown,
      CXLoadDiag_CannotLoad,
      CXLoadDiag_InvalidFile)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:810

   function clang_loadDiagnostics
     (file : Interfaces.C.Strings.chars_ptr;
      error : access CXLoadDiag_Error;
      errorString : access clang_c_CXString_h.CXString) return CXDiagnosticSet  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:848
   with Import => True, 
        Convention => C, 
        External_Name => "clang_loadDiagnostics";

   procedure clang_disposeDiagnosticSet (Diags : CXDiagnosticSet)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:855
   with Import => True, 
        Convention => C, 
        External_Name => "clang_disposeDiagnosticSet";

   function clang_getChildDiagnostics (D : CXDiagnostic) return CXDiagnosticSet  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:863
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getChildDiagnostics";

   function clang_getNumDiagnostics (Unit : CXTranslationUnit) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:869
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getNumDiagnostics";

   function clang_getDiagnostic (Unit : CXTranslationUnit; Index : unsigned) return CXDiagnostic  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:880
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getDiagnostic";

   function clang_getDiagnosticSetFromTU (Unit : CXTranslationUnit) return CXDiagnosticSet  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:890
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getDiagnosticSetFromTU";

   procedure clang_disposeDiagnostic (Diagnostic : CXDiagnostic)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:895
   with Import => True, 
        Convention => C, 
        External_Name => "clang_disposeDiagnostic";

   subtype CXDiagnosticDisplayOptions is unsigned;
   CXDiagnostic_DisplaySourceLocation : constant unsigned := 1;
   CXDiagnostic_DisplayColumn : constant unsigned := 2;
   CXDiagnostic_DisplaySourceRanges : constant unsigned := 4;
   CXDiagnostic_DisplayOption : constant unsigned := 8;
   CXDiagnostic_DisplayCategoryId : constant unsigned := 16;
   CXDiagnostic_DisplayCategoryName : constant unsigned := 32;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:903

   function clang_formatDiagnostic (Diagnostic : CXDiagnostic; Options : unsigned) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:980
   with Import => True, 
        Convention => C, 
        External_Name => "clang_formatDiagnostic";

   function clang_defaultDiagnosticDisplayOptions return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:990
   with Import => True, 
        Convention => C, 
        External_Name => "clang_defaultDiagnosticDisplayOptions";

   function clang_getDiagnosticSeverity (arg1 : CXDiagnostic) return CXDiagnosticSeverity  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:996
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getDiagnosticSeverity";

   function clang_getDiagnosticLocation (arg1 : CXDiagnostic) return CXSourceLocation  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1004
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getDiagnosticLocation";

   function clang_getDiagnosticSpelling (arg1 : CXDiagnostic) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1009
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getDiagnosticSpelling";

   function clang_getDiagnosticOption (Diag : CXDiagnostic; Disable : access clang_c_CXString_h.CXString) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1023
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getDiagnosticOption";

   function clang_getDiagnosticCategory (arg1 : CXDiagnostic) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1036
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getDiagnosticCategory";

   function clang_getDiagnosticCategoryName (Category : unsigned) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1049
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getDiagnosticCategoryName";

   function clang_getDiagnosticCategoryText (arg1 : CXDiagnostic) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1056
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getDiagnosticCategoryText";

   function clang_getDiagnosticNumRanges (arg1 : CXDiagnostic) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1062
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getDiagnosticNumRanges";

   function clang_getDiagnosticRange (Diagnostic : CXDiagnostic; c_Range : unsigned) return CXSourceRange  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1077
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getDiagnosticRange";

   function clang_getDiagnosticNumFixIts (Diagnostic : CXDiagnostic) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1084
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getDiagnosticNumFixIts";

   function clang_getDiagnosticFixIt
     (Diagnostic : CXDiagnostic;
      FixIt : unsigned;
      ReplacementRange : access CXSourceRange) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1111
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getDiagnosticFixIt";

   function clang_getTranslationUnitSpelling (CTUnit : CXTranslationUnit) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1133
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getTranslationUnitSpelling";

   function clang_createTranslationUnitFromSourceFile
     (CIdx : CXIndex;
      source_filename : Interfaces.C.Strings.chars_ptr;
      num_clang_command_line_args : int;
      clang_command_line_args : System.Address;
      num_unsaved_files : unsigned;
      unsaved_files : access CXUnsavedFile) return CXTranslationUnit  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1175
   with Import => True, 
        Convention => C, 
        External_Name => "clang_createTranslationUnitFromSourceFile";

   function clang_createTranslationUnit (CIdx : CXIndex; ast_filename : Interfaces.C.Strings.chars_ptr) return CXTranslationUnit  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1189
   with Import => True, 
        Convention => C, 
        External_Name => "clang_createTranslationUnit";

   function clang_createTranslationUnit2
     (CIdx : CXIndex;
      ast_filename : Interfaces.C.Strings.chars_ptr;
      out_TU : System.Address) return clang_c_CXErrorCode_h.CXErrorCode  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1201
   with Import => True, 
        Convention => C, 
        External_Name => "clang_createTranslationUnit2";

   subtype CXTranslationUnit_Flags is unsigned;
   CXTranslationUnit_None : constant unsigned := 0;
   CXTranslationUnit_DetailedPreprocessingRecord : constant unsigned := 1;
   CXTranslationUnit_Incomplete : constant unsigned := 2;
   CXTranslationUnit_PrecompiledPreamble : constant unsigned := 4;
   CXTranslationUnit_CacheCompletionResults : constant unsigned := 8;
   CXTranslationUnit_ForSerialization : constant unsigned := 16;
   CXTranslationUnit_CXXChainedPCH : constant unsigned := 32;
   CXTranslationUnit_SkipFunctionBodies : constant unsigned := 64;
   CXTranslationUnit_IncludeBriefCommentsInCodeCompletion : constant unsigned := 128;
   CXTranslationUnit_CreatePreambleOnFirstParse : constant unsigned := 256;
   CXTranslationUnit_KeepGoing : constant unsigned := 512;
   CXTranslationUnit_SingleFileParse : constant unsigned := 1024;
   CXTranslationUnit_LimitSkipFunctionBodiesToPreamble : constant unsigned := 2048;
   CXTranslationUnit_IncludeAttributedTypes : constant unsigned := 4096;
   CXTranslationUnit_VisitImplicitAttributes : constant unsigned := 8192;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1213

   function clang_defaultEditingTranslationUnitOptions return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1359
   with Import => True, 
        Convention => C, 
        External_Name => "clang_defaultEditingTranslationUnitOptions";

   function clang_parseTranslationUnit
     (CIdx : CXIndex;
      source_filename : Interfaces.C.Strings.chars_ptr;
      command_line_args : System.Address;
      num_command_line_args : int;
      unsaved_files : access CXUnsavedFile;
      num_unsaved_files : unsigned;
      options : unsigned) return CXTranslationUnit  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1368
   with Import => True, 
        Convention => C, 
        External_Name => "clang_parseTranslationUnit";

   function clang_parseTranslationUnit2
     (CIdx : CXIndex;
      source_filename : Interfaces.C.Strings.chars_ptr;
      command_line_args : System.Address;
      num_command_line_args : int;
      unsaved_files : access CXUnsavedFile;
      num_unsaved_files : unsigned;
      options : unsigned;
      out_TU : System.Address) return clang_c_CXErrorCode_h.CXErrorCode  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1421
   with Import => True, 
        Convention => C, 
        External_Name => "clang_parseTranslationUnit2";

   function clang_parseTranslationUnit2FullArgv
     (CIdx : CXIndex;
      source_filename : Interfaces.C.Strings.chars_ptr;
      command_line_args : System.Address;
      num_command_line_args : int;
      unsaved_files : access CXUnsavedFile;
      num_unsaved_files : unsigned;
      options : unsigned;
      out_TU : System.Address) return clang_c_CXErrorCode_h.CXErrorCode  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1435
   with Import => True, 
        Convention => C, 
        External_Name => "clang_parseTranslationUnit2FullArgv";

   type CXSaveTranslationUnit_Flags is 
     (CXSaveTranslationUnit_None)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1448

   function clang_defaultSaveOptions (TU : CXTranslationUnit) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1464
   with Import => True, 
        Convention => C, 
        External_Name => "clang_defaultSaveOptions";

   type CXSaveError is 
     (CXSaveError_None,
      CXSaveError_Unknown,
      CXSaveError_TranslationErrors,
      CXSaveError_InvalidTU)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1470

   function clang_saveTranslationUnit
     (TU : CXTranslationUnit;
      FileName : Interfaces.C.Strings.chars_ptr;
      options : unsigned) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1524
   with Import => True, 
        Convention => C, 
        External_Name => "clang_saveTranslationUnit";

   function clang_suspendTranslationUnit (arg1 : CXTranslationUnit) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1535
   with Import => True, 
        Convention => C, 
        External_Name => "clang_suspendTranslationUnit";

   procedure clang_disposeTranslationUnit (arg1 : CXTranslationUnit)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1540
   with Import => True, 
        Convention => C, 
        External_Name => "clang_disposeTranslationUnit";

   type CXReparse_Flags is 
     (CXReparse_None)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1549

   function clang_defaultReparseOptions (TU : CXTranslationUnit) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1566
   with Import => True, 
        Convention => C, 
        External_Name => "clang_defaultReparseOptions";

   function clang_reparseTranslationUnit
     (TU : CXTranslationUnit;
      num_unsaved_files : unsigned;
      unsaved_files : access CXUnsavedFile;
      options : unsigned) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1607
   with Import => True, 
        Convention => C, 
        External_Name => "clang_reparseTranslationUnit";

   subtype CXTUResourceUsageKind is unsigned;
   CXTUResourceUsage_AST : constant unsigned := 1;
   CXTUResourceUsage_Identifiers : constant unsigned := 2;
   CXTUResourceUsage_Selectors : constant unsigned := 3;
   CXTUResourceUsage_GlobalCompletionResults : constant unsigned := 4;
   CXTUResourceUsage_SourceManagerContentCache : constant unsigned := 5;
   CXTUResourceUsage_AST_SideTables : constant unsigned := 6;
   CXTUResourceUsage_SourceManager_Membuffer_Malloc : constant unsigned := 7;
   CXTUResourceUsage_SourceManager_Membuffer_MMap : constant unsigned := 8;
   CXTUResourceUsage_ExternalASTSource_Membuffer_Malloc : constant unsigned := 9;
   CXTUResourceUsage_ExternalASTSource_Membuffer_MMap : constant unsigned := 10;
   CXTUResourceUsage_Preprocessor : constant unsigned := 11;
   CXTUResourceUsage_PreprocessingRecord : constant unsigned := 12;
   CXTUResourceUsage_SourceManager_DataStructures : constant unsigned := 13;
   CXTUResourceUsage_Preprocessor_HeaderSearch : constant unsigned := 14;
   CXTUResourceUsage_MEMORY_IN_BYTES_BEGIN : constant unsigned := 1;
   CXTUResourceUsage_MEMORY_IN_BYTES_END : constant unsigned := 14;
   CXTUResourceUsage_First : constant unsigned := 1;
   CXTUResourceUsage_Last : constant unsigned := 14;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1615

   function clang_getTUResourceUsageName (kind : CXTUResourceUsageKind) return Interfaces.C.Strings.chars_ptr  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1643
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getTUResourceUsageName";

   type CXTUResourceUsageEntry is record
      kind : aliased CXTUResourceUsageKind;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1647
      amount : aliased unsigned_long;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1650
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1645

   type CXTUResourceUsage is record
      data : System.Address;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1658
      numEntries : aliased unsigned;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1661
      entries : access CXTUResourceUsageEntry;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1665
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1656

   function clang_getCXTUResourceUsage (TU : CXTranslationUnit) return CXTUResourceUsage  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1673
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCXTUResourceUsage";

   procedure clang_disposeCXTUResourceUsage (usage : CXTUResourceUsage)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1675
   with Import => True, 
        Convention => C, 
        External_Name => "clang_disposeCXTUResourceUsage";

   function clang_getTranslationUnitTargetInfo (CTUnit : CXTranslationUnit) return CXTargetInfo  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1683
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getTranslationUnitTargetInfo";

   procedure clang_TargetInfo_dispose (Info : CXTargetInfo)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1689
   with Import => True, 
        Convention => C, 
        External_Name => "clang_TargetInfo_dispose";

   function clang_TargetInfo_getTriple (Info : CXTargetInfo) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1697
   with Import => True, 
        Convention => C, 
        External_Name => "clang_TargetInfo_getTriple";

   function clang_TargetInfo_getPointerWidth (Info : CXTargetInfo) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1705
   with Import => True, 
        Convention => C, 
        External_Name => "clang_TargetInfo_getPointerWidth";

   subtype CXCursorKind is unsigned;
   CXCursor_UnexposedDecl : constant unsigned := 1;
   CXCursor_StructDecl : constant unsigned := 2;
   CXCursor_UnionDecl : constant unsigned := 3;
   CXCursor_ClassDecl : constant unsigned := 4;
   CXCursor_EnumDecl : constant unsigned := 5;
   CXCursor_FieldDecl : constant unsigned := 6;
   CXCursor_EnumConstantDecl : constant unsigned := 7;
   CXCursor_FunctionDecl : constant unsigned := 8;
   CXCursor_VarDecl : constant unsigned := 9;
   CXCursor_ParmDecl : constant unsigned := 10;
   CXCursor_ObjCInterfaceDecl : constant unsigned := 11;
   CXCursor_ObjCCategoryDecl : constant unsigned := 12;
   CXCursor_ObjCProtocolDecl : constant unsigned := 13;
   CXCursor_ObjCPropertyDecl : constant unsigned := 14;
   CXCursor_ObjCIvarDecl : constant unsigned := 15;
   CXCursor_ObjCInstanceMethodDecl : constant unsigned := 16;
   CXCursor_ObjCClassMethodDecl : constant unsigned := 17;
   CXCursor_ObjCImplementationDecl : constant unsigned := 18;
   CXCursor_ObjCCategoryImplDecl : constant unsigned := 19;
   CXCursor_TypedefDecl : constant unsigned := 20;
   CXCursor_CXXMethod : constant unsigned := 21;
   CXCursor_Namespace : constant unsigned := 22;
   CXCursor_LinkageSpec : constant unsigned := 23;
   CXCursor_Constructor : constant unsigned := 24;
   CXCursor_Destructor : constant unsigned := 25;
   CXCursor_ConversionFunction : constant unsigned := 26;
   CXCursor_TemplateTypeParameter : constant unsigned := 27;
   CXCursor_NonTypeTemplateParameter : constant unsigned := 28;
   CXCursor_TemplateTemplateParameter : constant unsigned := 29;
   CXCursor_FunctionTemplate : constant unsigned := 30;
   CXCursor_ClassTemplate : constant unsigned := 31;
   CXCursor_ClassTemplatePartialSpecialization : constant unsigned := 32;
   CXCursor_NamespaceAlias : constant unsigned := 33;
   CXCursor_UsingDirective : constant unsigned := 34;
   CXCursor_UsingDeclaration : constant unsigned := 35;
   CXCursor_TypeAliasDecl : constant unsigned := 36;
   CXCursor_ObjCSynthesizeDecl : constant unsigned := 37;
   CXCursor_ObjCDynamicDecl : constant unsigned := 38;
   CXCursor_CXXAccessSpecifier : constant unsigned := 39;
   CXCursor_FirstDecl : constant unsigned := 1;
   CXCursor_LastDecl : constant unsigned := 39;
   CXCursor_FirstRef : constant unsigned := 40;
   CXCursor_ObjCSuperClassRef : constant unsigned := 40;
   CXCursor_ObjCProtocolRef : constant unsigned := 41;
   CXCursor_ObjCClassRef : constant unsigned := 42;
   CXCursor_TypeRef : constant unsigned := 43;
   CXCursor_CXXBaseSpecifier : constant unsigned := 44;
   CXCursor_TemplateRef : constant unsigned := 45;
   CXCursor_NamespaceRef : constant unsigned := 46;
   CXCursor_MemberRef : constant unsigned := 47;
   CXCursor_LabelRef : constant unsigned := 48;
   CXCursor_OverloadedDeclRef : constant unsigned := 49;
   CXCursor_VariableRef : constant unsigned := 50;
   CXCursor_LastRef : constant unsigned := 50;
   CXCursor_FirstInvalid : constant unsigned := 70;
   CXCursor_InvalidFile : constant unsigned := 70;
   CXCursor_NoDeclFound : constant unsigned := 71;
   CXCursor_NotImplemented : constant unsigned := 72;
   CXCursor_InvalidCode : constant unsigned := 73;
   CXCursor_LastInvalid : constant unsigned := 73;
   CXCursor_FirstExpr : constant unsigned := 100;
   CXCursor_UnexposedExpr : constant unsigned := 100;
   CXCursor_DeclRefExpr : constant unsigned := 101;
   CXCursor_MemberRefExpr : constant unsigned := 102;
   CXCursor_CallExpr : constant unsigned := 103;
   CXCursor_ObjCMessageExpr : constant unsigned := 104;
   CXCursor_BlockExpr : constant unsigned := 105;
   CXCursor_IntegerLiteral : constant unsigned := 106;
   CXCursor_FloatingLiteral : constant unsigned := 107;
   CXCursor_ImaginaryLiteral : constant unsigned := 108;
   CXCursor_StringLiteral : constant unsigned := 109;
   CXCursor_CharacterLiteral : constant unsigned := 110;
   CXCursor_ParenExpr : constant unsigned := 111;
   CXCursor_UnaryOperator : constant unsigned := 112;
   CXCursor_ArraySubscriptExpr : constant unsigned := 113;
   CXCursor_BinaryOperator : constant unsigned := 114;
   CXCursor_CompoundAssignOperator : constant unsigned := 115;
   CXCursor_ConditionalOperator : constant unsigned := 116;
   CXCursor_CStyleCastExpr : constant unsigned := 117;
   CXCursor_CompoundLiteralExpr : constant unsigned := 118;
   CXCursor_InitListExpr : constant unsigned := 119;
   CXCursor_AddrLabelExpr : constant unsigned := 120;
   CXCursor_StmtExpr : constant unsigned := 121;
   CXCursor_GenericSelectionExpr : constant unsigned := 122;
   CXCursor_GNUNullExpr : constant unsigned := 123;
   CXCursor_CXXStaticCastExpr : constant unsigned := 124;
   CXCursor_CXXDynamicCastExpr : constant unsigned := 125;
   CXCursor_CXXReinterpretCastExpr : constant unsigned := 126;
   CXCursor_CXXConstCastExpr : constant unsigned := 127;
   CXCursor_CXXFunctionalCastExpr : constant unsigned := 128;
   CXCursor_CXXTypeidExpr : constant unsigned := 129;
   CXCursor_CXXBoolLiteralExpr : constant unsigned := 130;
   CXCursor_CXXNullPtrLiteralExpr : constant unsigned := 131;
   CXCursor_CXXThisExpr : constant unsigned := 132;
   CXCursor_CXXThrowExpr : constant unsigned := 133;
   CXCursor_CXXNewExpr : constant unsigned := 134;
   CXCursor_CXXDeleteExpr : constant unsigned := 135;
   CXCursor_UnaryExpr : constant unsigned := 136;
   CXCursor_ObjCStringLiteral : constant unsigned := 137;
   CXCursor_ObjCEncodeExpr : constant unsigned := 138;
   CXCursor_ObjCSelectorExpr : constant unsigned := 139;
   CXCursor_ObjCProtocolExpr : constant unsigned := 140;
   CXCursor_ObjCBridgedCastExpr : constant unsigned := 141;
   CXCursor_PackExpansionExpr : constant unsigned := 142;
   CXCursor_SizeOfPackExpr : constant unsigned := 143;
   CXCursor_LambdaExpr : constant unsigned := 144;
   CXCursor_ObjCBoolLiteralExpr : constant unsigned := 145;
   CXCursor_ObjCSelfExpr : constant unsigned := 146;
   CXCursor_OMPArraySectionExpr : constant unsigned := 147;
   CXCursor_ObjCAvailabilityCheckExpr : constant unsigned := 148;
   CXCursor_FixedPointLiteral : constant unsigned := 149;
   CXCursor_LastExpr : constant unsigned := 149;
   CXCursor_FirstStmt : constant unsigned := 200;
   CXCursor_UnexposedStmt : constant unsigned := 200;
   CXCursor_LabelStmt : constant unsigned := 201;
   CXCursor_CompoundStmt : constant unsigned := 202;
   CXCursor_CaseStmt : constant unsigned := 203;
   CXCursor_DefaultStmt : constant unsigned := 204;
   CXCursor_IfStmt : constant unsigned := 205;
   CXCursor_SwitchStmt : constant unsigned := 206;
   CXCursor_WhileStmt : constant unsigned := 207;
   CXCursor_DoStmt : constant unsigned := 208;
   CXCursor_ForStmt : constant unsigned := 209;
   CXCursor_GotoStmt : constant unsigned := 210;
   CXCursor_IndirectGotoStmt : constant unsigned := 211;
   CXCursor_ContinueStmt : constant unsigned := 212;
   CXCursor_BreakStmt : constant unsigned := 213;
   CXCursor_ReturnStmt : constant unsigned := 214;
   CXCursor_GCCAsmStmt : constant unsigned := 215;
   CXCursor_AsmStmt : constant unsigned := 215;
   CXCursor_ObjCAtTryStmt : constant unsigned := 216;
   CXCursor_ObjCAtCatchStmt : constant unsigned := 217;
   CXCursor_ObjCAtFinallyStmt : constant unsigned := 218;
   CXCursor_ObjCAtThrowStmt : constant unsigned := 219;
   CXCursor_ObjCAtSynchronizedStmt : constant unsigned := 220;
   CXCursor_ObjCAutoreleasePoolStmt : constant unsigned := 221;
   CXCursor_ObjCForCollectionStmt : constant unsigned := 222;
   CXCursor_CXXCatchStmt : constant unsigned := 223;
   CXCursor_CXXTryStmt : constant unsigned := 224;
   CXCursor_CXXForRangeStmt : constant unsigned := 225;
   CXCursor_SEHTryStmt : constant unsigned := 226;
   CXCursor_SEHExceptStmt : constant unsigned := 227;
   CXCursor_SEHFinallyStmt : constant unsigned := 228;
   CXCursor_MSAsmStmt : constant unsigned := 229;
   CXCursor_NullStmt : constant unsigned := 230;
   CXCursor_DeclStmt : constant unsigned := 231;
   CXCursor_OMPParallelDirective : constant unsigned := 232;
   CXCursor_OMPSimdDirective : constant unsigned := 233;
   CXCursor_OMPForDirective : constant unsigned := 234;
   CXCursor_OMPSectionsDirective : constant unsigned := 235;
   CXCursor_OMPSectionDirective : constant unsigned := 236;
   CXCursor_OMPSingleDirective : constant unsigned := 237;
   CXCursor_OMPParallelForDirective : constant unsigned := 238;
   CXCursor_OMPParallelSectionsDirective : constant unsigned := 239;
   CXCursor_OMPTaskDirective : constant unsigned := 240;
   CXCursor_OMPMasterDirective : constant unsigned := 241;
   CXCursor_OMPCriticalDirective : constant unsigned := 242;
   CXCursor_OMPTaskyieldDirective : constant unsigned := 243;
   CXCursor_OMPBarrierDirective : constant unsigned := 244;
   CXCursor_OMPTaskwaitDirective : constant unsigned := 245;
   CXCursor_OMPFlushDirective : constant unsigned := 246;
   CXCursor_SEHLeaveStmt : constant unsigned := 247;
   CXCursor_OMPOrderedDirective : constant unsigned := 248;
   CXCursor_OMPAtomicDirective : constant unsigned := 249;
   CXCursor_OMPForSimdDirective : constant unsigned := 250;
   CXCursor_OMPParallelForSimdDirective : constant unsigned := 251;
   CXCursor_OMPTargetDirective : constant unsigned := 252;
   CXCursor_OMPTeamsDirective : constant unsigned := 253;
   CXCursor_OMPTaskgroupDirective : constant unsigned := 254;
   CXCursor_OMPCancellationPointDirective : constant unsigned := 255;
   CXCursor_OMPCancelDirective : constant unsigned := 256;
   CXCursor_OMPTargetDataDirective : constant unsigned := 257;
   CXCursor_OMPTaskLoopDirective : constant unsigned := 258;
   CXCursor_OMPTaskLoopSimdDirective : constant unsigned := 259;
   CXCursor_OMPDistributeDirective : constant unsigned := 260;
   CXCursor_OMPTargetEnterDataDirective : constant unsigned := 261;
   CXCursor_OMPTargetExitDataDirective : constant unsigned := 262;
   CXCursor_OMPTargetParallelDirective : constant unsigned := 263;
   CXCursor_OMPTargetParallelForDirective : constant unsigned := 264;
   CXCursor_OMPTargetUpdateDirective : constant unsigned := 265;
   CXCursor_OMPDistributeParallelForDirective : constant unsigned := 266;
   CXCursor_OMPDistributeParallelForSimdDirective : constant unsigned := 267;
   CXCursor_OMPDistributeSimdDirective : constant unsigned := 268;
   CXCursor_OMPTargetParallelForSimdDirective : constant unsigned := 269;
   CXCursor_OMPTargetSimdDirective : constant unsigned := 270;
   CXCursor_OMPTeamsDistributeDirective : constant unsigned := 271;
   CXCursor_OMPTeamsDistributeSimdDirective : constant unsigned := 272;
   CXCursor_OMPTeamsDistributeParallelForSimdDirective : constant unsigned := 273;
   CXCursor_OMPTeamsDistributeParallelForDirective : constant unsigned := 274;
   CXCursor_OMPTargetTeamsDirective : constant unsigned := 275;
   CXCursor_OMPTargetTeamsDistributeDirective : constant unsigned := 276;
   CXCursor_OMPTargetTeamsDistributeParallelForDirective : constant unsigned := 277;
   CXCursor_OMPTargetTeamsDistributeParallelForSimdDirective : constant unsigned := 278;
   CXCursor_OMPTargetTeamsDistributeSimdDirective : constant unsigned := 279;
   CXCursor_LastStmt : constant unsigned := 279;
   CXCursor_TranslationUnit : constant unsigned := 300;
   CXCursor_FirstAttr : constant unsigned := 400;
   CXCursor_UnexposedAttr : constant unsigned := 400;
   CXCursor_IBActionAttr : constant unsigned := 401;
   CXCursor_IBOutletAttr : constant unsigned := 402;
   CXCursor_IBOutletCollectionAttr : constant unsigned := 403;
   CXCursor_CXXFinalAttr : constant unsigned := 404;
   CXCursor_CXXOverrideAttr : constant unsigned := 405;
   CXCursor_AnnotateAttr : constant unsigned := 406;
   CXCursor_AsmLabelAttr : constant unsigned := 407;
   CXCursor_PackedAttr : constant unsigned := 408;
   CXCursor_PureAttr : constant unsigned := 409;
   CXCursor_ConstAttr : constant unsigned := 410;
   CXCursor_NoDuplicateAttr : constant unsigned := 411;
   CXCursor_CUDAConstantAttr : constant unsigned := 412;
   CXCursor_CUDADeviceAttr : constant unsigned := 413;
   CXCursor_CUDAGlobalAttr : constant unsigned := 414;
   CXCursor_CUDAHostAttr : constant unsigned := 415;
   CXCursor_CUDASharedAttr : constant unsigned := 416;
   CXCursor_VisibilityAttr : constant unsigned := 417;
   CXCursor_DLLExport : constant unsigned := 418;
   CXCursor_DLLImport : constant unsigned := 419;
   CXCursor_NSReturnsRetained : constant unsigned := 420;
   CXCursor_NSReturnsNotRetained : constant unsigned := 421;
   CXCursor_NSReturnsAutoreleased : constant unsigned := 422;
   CXCursor_NSConsumesSelf : constant unsigned := 423;
   CXCursor_NSConsumed : constant unsigned := 424;
   CXCursor_ObjCException : constant unsigned := 425;
   CXCursor_ObjCNSObject : constant unsigned := 426;
   CXCursor_ObjCIndependentClass : constant unsigned := 427;
   CXCursor_ObjCPreciseLifetime : constant unsigned := 428;
   CXCursor_ObjCReturnsInnerPointer : constant unsigned := 429;
   CXCursor_ObjCRequiresSuper : constant unsigned := 430;
   CXCursor_ObjCRootClass : constant unsigned := 431;
   CXCursor_ObjCSubclassingRestricted : constant unsigned := 432;
   CXCursor_ObjCExplicitProtocolImpl : constant unsigned := 433;
   CXCursor_ObjCDesignatedInitializer : constant unsigned := 434;
   CXCursor_ObjCRuntimeVisible : constant unsigned := 435;
   CXCursor_ObjCBoxable : constant unsigned := 436;
   CXCursor_FlagEnum : constant unsigned := 437;
   CXCursor_LastAttr : constant unsigned := 437;
   CXCursor_PreprocessingDirective : constant unsigned := 500;
   CXCursor_MacroDefinition : constant unsigned := 501;
   CXCursor_MacroExpansion : constant unsigned := 502;
   CXCursor_MacroInstantiation : constant unsigned := 502;
   CXCursor_InclusionDirective : constant unsigned := 503;
   CXCursor_FirstPreprocessing : constant unsigned := 500;
   CXCursor_LastPreprocessing : constant unsigned := 503;
   CXCursor_ModuleImportDecl : constant unsigned := 600;
   CXCursor_TypeAliasTemplateDecl : constant unsigned := 601;
   CXCursor_StaticAssert : constant unsigned := 602;
   CXCursor_FriendDecl : constant unsigned := 603;
   CXCursor_FirstExtraDecl : constant unsigned := 600;
   CXCursor_LastExtraDecl : constant unsigned := 603;
   CXCursor_OverloadCandidate : constant unsigned := 700;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:1714

   CXCursor_MIN_VALUE : constant CXCursorKind := 1;
   CXCursor_MAX_VALUE : constant CXCursorKind := 700;

   --  skipped anonymous struct anon_8

   type CXCursor_data_array is array (0 .. 2) of System.Address;
   type CXCursor is record
      kind : aliased CXCursorKind;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2642
      xdata : aliased int;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2643
      data : CXCursor_data_array;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2644
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2645

   function clang_getNullCursor return CXCursor  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2656
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getNullCursor";

   function clang_getTranslationUnitCursor (arg1 : CXTranslationUnit) return CXCursor  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2664
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getTranslationUnitCursor";

   function clang_equalCursors (arg1 : CXCursor; arg2 : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2669
   with Import => True, 
        Convention => C, 
        External_Name => "clang_equalCursors";

   function clang_Cursor_isNull (cursor : CXCursor) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2674
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_isNull";

   function clang_hashCursor (arg1 : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2679
   with Import => True, 
        Convention => C, 
        External_Name => "clang_hashCursor";

   function clang_getCursorKind (arg1 : CXCursor) return CXCursorKind  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2684
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursorKind";

   function clang_isDeclaration (arg1 : CXCursorKind) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2689
   with Import => True, 
        Convention => C, 
        External_Name => "clang_isDeclaration";

   function clang_isInvalidDeclaration (arg1 : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2699
   with Import => True, 
        Convention => C, 
        External_Name => "clang_isInvalidDeclaration";

   function clang_isReference (arg1 : CXCursorKind) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2709
   with Import => True, 
        Convention => C, 
        External_Name => "clang_isReference";

   function clang_isExpression (arg1 : CXCursorKind) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2714
   with Import => True, 
        Convention => C, 
        External_Name => "clang_isExpression";

   function clang_isStatement (arg1 : CXCursorKind) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2719
   with Import => True, 
        Convention => C, 
        External_Name => "clang_isStatement";

   function clang_isAttribute (arg1 : CXCursorKind) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2724
   with Import => True, 
        Convention => C, 
        External_Name => "clang_isAttribute";

   function clang_Cursor_hasAttrs (C : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2729
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_hasAttrs";

   function clang_isInvalid (arg1 : CXCursorKind) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2735
   with Import => True, 
        Convention => C, 
        External_Name => "clang_isInvalid";

   function clang_isTranslationUnit (arg1 : CXCursorKind) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2741
   with Import => True, 
        Convention => C, 
        External_Name => "clang_isTranslationUnit";

   function clang_isPreprocessing (arg1 : CXCursorKind) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2747
   with Import => True, 
        Convention => C, 
        External_Name => "clang_isPreprocessing";

   function clang_isUnexposed (arg1 : CXCursorKind) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2753
   with Import => True, 
        Convention => C, 
        External_Name => "clang_isUnexposed";

   type CXLinkageKind is 
     (CXLinkage_Invalid,
      CXLinkage_NoLinkage,
      CXLinkage_Internal,
      CXLinkage_UniqueExternal,
      CXLinkage_External)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2758

   function clang_getCursorLinkage (cursor : CXCursor) return CXLinkageKind  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2779
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursorLinkage";

   type CXVisibilityKind is 
     (CXVisibility_Invalid,
      CXVisibility_Hidden,
      CXVisibility_Protected,
      CXVisibility_Default)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2781

   function clang_getCursorVisibility (cursor : CXCursor) return CXVisibilityKind  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2805
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursorVisibility";

   function clang_getCursorAvailability (cursor : CXCursor) return CXAvailabilityKind  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2816
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursorAvailability";

   type CXPlatformAvailability is record
      Platform : aliased clang_c_CXString_h.CXString;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2829
      Introduced : aliased CXVersion;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2833
      Deprecated : aliased CXVersion;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2838
      Obsoleted : aliased CXVersion;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2843
      Unavailable : aliased int;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2847
      Message : aliased clang_c_CXString_h.CXString;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2852
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2822

   function clang_getCursorPlatformAvailability
     (cursor : CXCursor;
      always_deprecated : access int;
      deprecated_message : access clang_c_CXString_h.CXString;
      always_unavailable : access int;
      unavailable_message : access clang_c_CXString_h.CXString;
      availability : access CXPlatformAvailability;
      availability_size : int) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2892
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursorPlatformAvailability";

   procedure clang_disposeCXPlatformAvailability (availability : access CXPlatformAvailability)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2904
   with Import => True, 
        Convention => C, 
        External_Name => "clang_disposeCXPlatformAvailability";

   type CXLanguageKind is 
     (CXLanguage_Invalid,
      CXLanguage_C,
      CXLanguage_ObjC,
      CXLanguage_CPlusPlus)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2909

   function clang_getCursorLanguage (cursor : CXCursor) return CXLanguageKind  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2919
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursorLanguage";

   type CXTLSKind is 
     (CXTLS_None,
      CXTLS_Dynamic,
      CXTLS_Static)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2925

   function clang_getCursorTLSKind (cursor : CXCursor) return CXTLSKind  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2935
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursorTLSKind";

   function clang_Cursor_getTranslationUnit (arg1 : CXCursor) return CXTranslationUnit  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2940
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_getTranslationUnit";

   type CXCursorSetImpl is null record;   -- incomplete struct

   type CXCursorSet is access all CXCursorSetImpl;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2945

   function clang_createCXCursorSet return CXCursorSet  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2950
   with Import => True, 
        Convention => C, 
        External_Name => "clang_createCXCursorSet";

   procedure clang_disposeCXCursorSet (cset : CXCursorSet)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2955
   with Import => True, 
        Convention => C, 
        External_Name => "clang_disposeCXCursorSet";

   function clang_CXCursorSet_contains (cset : CXCursorSet; cursor : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2962
   with Import => True, 
        Convention => C, 
        External_Name => "clang_CXCursorSet_contains";

   function clang_CXCursorSet_insert (cset : CXCursorSet; cursor : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:2970
   with Import => True, 
        Convention => C, 
        External_Name => "clang_CXCursorSet_insert";

   function clang_getCursorSemanticParent (cursor : CXCursor) return CXCursor  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3006
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursorSemanticParent";

   function clang_getCursorLexicalParent (cursor : CXCursor) return CXCursor  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3042
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursorLexicalParent";

   procedure clang_getOverriddenCursors
     (cursor : CXCursor;
      overridden : System.Address;
      num_overridden : access unsigned)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3087
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getOverriddenCursors";

   procedure clang_disposeOverriddenCursors (overridden : access CXCursor)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3095
   with Import => True, 
        Convention => C, 
        External_Name => "clang_disposeOverriddenCursors";

   function clang_getIncludedFile (cursor : CXCursor) return CXFile  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3101
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getIncludedFile";

   function clang_getCursor (arg1 : CXTranslationUnit; arg2 : CXSourceLocation) return CXCursor  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3133
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursor";

   function clang_getCursorLocation (arg1 : CXCursor) return CXSourceLocation  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3145
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursorLocation";

   function clang_getCursorExtent (arg1 : CXCursor) return CXSourceRange  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3158
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursorExtent";

   subtype CXTypeKind is unsigned;
   CXType_Invalid : constant unsigned := 0;
   CXType_Unexposed : constant unsigned := 1;
   CXType_Void : constant unsigned := 2;
   CXType_Bool : constant unsigned := 3;
   CXType_Char_U : constant unsigned := 4;
   CXType_UChar : constant unsigned := 5;
   CXType_Char16 : constant unsigned := 6;
   CXType_Char32 : constant unsigned := 7;
   CXType_UShort : constant unsigned := 8;
   CXType_UInt : constant unsigned := 9;
   CXType_ULong : constant unsigned := 10;
   CXType_ULongLong : constant unsigned := 11;
   CXType_UInt128 : constant unsigned := 12;
   CXType_Char_S : constant unsigned := 13;
   CXType_SChar : constant unsigned := 14;
   CXType_WChar : constant unsigned := 15;
   CXType_Short : constant unsigned := 16;
   CXType_Int : constant unsigned := 17;
   CXType_Long : constant unsigned := 18;
   CXType_LongLong : constant unsigned := 19;
   CXType_Int128 : constant unsigned := 20;
   CXType_Float : constant unsigned := 21;
   CXType_Double : constant unsigned := 22;
   CXType_LongDouble : constant unsigned := 23;
   CXType_NullPtr : constant unsigned := 24;
   CXType_Overload : constant unsigned := 25;
   CXType_Dependent : constant unsigned := 26;
   CXType_ObjCId : constant unsigned := 27;
   CXType_ObjCClass : constant unsigned := 28;
   CXType_ObjCSel : constant unsigned := 29;
   CXType_Float128 : constant unsigned := 30;
   CXType_Half : constant unsigned := 31;
   CXType_Float16 : constant unsigned := 32;
   CXType_ShortAccum : constant unsigned := 33;
   CXType_Accum : constant unsigned := 34;
   CXType_LongAccum : constant unsigned := 35;
   CXType_UShortAccum : constant unsigned := 36;
   CXType_UAccum : constant unsigned := 37;
   CXType_ULongAccum : constant unsigned := 38;
   CXType_FirstBuiltin : constant unsigned := 2;
   CXType_LastBuiltin : constant unsigned := 38;
   CXType_Complex : constant unsigned := 100;
   CXType_Pointer : constant unsigned := 101;
   CXType_BlockPointer : constant unsigned := 102;
   CXType_LValueReference : constant unsigned := 103;
   CXType_RValueReference : constant unsigned := 104;
   CXType_Record : constant unsigned := 105;
   CXType_Enum : constant unsigned := 106;
   CXType_Typedef : constant unsigned := 107;
   CXType_ObjCInterface : constant unsigned := 108;
   CXType_ObjCObjectPointer : constant unsigned := 109;
   CXType_FunctionNoProto : constant unsigned := 110;
   CXType_FunctionProto : constant unsigned := 111;
   CXType_ConstantArray : constant unsigned := 112;
   CXType_Vector : constant unsigned := 113;
   CXType_IncompleteArray : constant unsigned := 114;
   CXType_VariableArray : constant unsigned := 115;
   CXType_DependentSizedArray : constant unsigned := 116;
   CXType_MemberPointer : constant unsigned := 117;
   CXType_Auto : constant unsigned := 118;
   CXType_Elaborated : constant unsigned := 119;
   CXType_Pipe : constant unsigned := 120;
   CXType_OCLImage1dRO : constant unsigned := 121;
   CXType_OCLImage1dArrayRO : constant unsigned := 122;
   CXType_OCLImage1dBufferRO : constant unsigned := 123;
   CXType_OCLImage2dRO : constant unsigned := 124;
   CXType_OCLImage2dArrayRO : constant unsigned := 125;
   CXType_OCLImage2dDepthRO : constant unsigned := 126;
   CXType_OCLImage2dArrayDepthRO : constant unsigned := 127;
   CXType_OCLImage2dMSAARO : constant unsigned := 128;
   CXType_OCLImage2dArrayMSAARO : constant unsigned := 129;
   CXType_OCLImage2dMSAADepthRO : constant unsigned := 130;
   CXType_OCLImage2dArrayMSAADepthRO : constant unsigned := 131;
   CXType_OCLImage3dRO : constant unsigned := 132;
   CXType_OCLImage1dWO : constant unsigned := 133;
   CXType_OCLImage1dArrayWO : constant unsigned := 134;
   CXType_OCLImage1dBufferWO : constant unsigned := 135;
   CXType_OCLImage2dWO : constant unsigned := 136;
   CXType_OCLImage2dArrayWO : constant unsigned := 137;
   CXType_OCLImage2dDepthWO : constant unsigned := 138;
   CXType_OCLImage2dArrayDepthWO : constant unsigned := 139;
   CXType_OCLImage2dMSAAWO : constant unsigned := 140;
   CXType_OCLImage2dArrayMSAAWO : constant unsigned := 141;
   CXType_OCLImage2dMSAADepthWO : constant unsigned := 142;
   CXType_OCLImage2dArrayMSAADepthWO : constant unsigned := 143;
   CXType_OCLImage3dWO : constant unsigned := 144;
   CXType_OCLImage1dRW : constant unsigned := 145;
   CXType_OCLImage1dArrayRW : constant unsigned := 146;
   CXType_OCLImage1dBufferRW : constant unsigned := 147;
   CXType_OCLImage2dRW : constant unsigned := 148;
   CXType_OCLImage2dArrayRW : constant unsigned := 149;
   CXType_OCLImage2dDepthRW : constant unsigned := 150;
   CXType_OCLImage2dArrayDepthRW : constant unsigned := 151;
   CXType_OCLImage2dMSAARW : constant unsigned := 152;
   CXType_OCLImage2dArrayMSAARW : constant unsigned := 153;
   CXType_OCLImage2dMSAADepthRW : constant unsigned := 154;
   CXType_OCLImage2dArrayMSAADepthRW : constant unsigned := 155;
   CXType_OCLImage3dRW : constant unsigned := 156;
   CXType_OCLSampler : constant unsigned := 157;
   CXType_OCLEvent : constant unsigned := 158;
   CXType_OCLQueue : constant unsigned := 159;
   CXType_OCLReserveID : constant unsigned := 160;
   CXType_ObjCObject : constant unsigned := 161;
   CXType_ObjCTypeParam : constant unsigned := 162;
   CXType_Attributed : constant unsigned := 163;
   CXType_OCLIntelSubgroupAVCMcePayload : constant unsigned := 164;
   CXType_OCLIntelSubgroupAVCImePayload : constant unsigned := 165;
   CXType_OCLIntelSubgroupAVCRefPayload : constant unsigned := 166;
   CXType_OCLIntelSubgroupAVCSicPayload : constant unsigned := 167;
   CXType_OCLIntelSubgroupAVCMceResult : constant unsigned := 168;
   CXType_OCLIntelSubgroupAVCImeResult : constant unsigned := 169;
   CXType_OCLIntelSubgroupAVCRefResult : constant unsigned := 170;
   CXType_OCLIntelSubgroupAVCSicResult : constant unsigned := 171;
   CXType_OCLIntelSubgroupAVCImeResultSingleRefStreamout : constant unsigned := 172;
   CXType_OCLIntelSubgroupAVCImeResultDualRefStreamout : constant unsigned := 173;
   CXType_OCLIntelSubgroupAVCImeSingleRefStreamin : constant unsigned := 174;
   CXType_OCLIntelSubgroupAVCImeDualRefStreamin : constant unsigned := 175;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3173

   subtype CXCallingConv is unsigned;
   CXCallingConv_Default : constant unsigned := 0;
   CXCallingConv_C : constant unsigned := 1;
   CXCallingConv_X86StdCall : constant unsigned := 2;
   CXCallingConv_X86FastCall : constant unsigned := 3;
   CXCallingConv_X86ThisCall : constant unsigned := 4;
   CXCallingConv_X86Pascal : constant unsigned := 5;
   CXCallingConv_AAPCS : constant unsigned := 6;
   CXCallingConv_AAPCS_VFP : constant unsigned := 7;
   CXCallingConv_X86RegCall : constant unsigned := 8;
   CXCallingConv_IntelOclBicc : constant unsigned := 9;
   CXCallingConv_Win64 : constant unsigned := 10;
   CXCallingConv_X86_64Win64 : constant unsigned := 10;
   CXCallingConv_X86_64SysV : constant unsigned := 11;
   CXCallingConv_X86VectorCall : constant unsigned := 12;
   CXCallingConv_Swift : constant unsigned := 13;
   CXCallingConv_PreserveMost : constant unsigned := 14;
   CXCallingConv_PreserveAll : constant unsigned := 15;
   CXCallingConv_AArch64VectorCall : constant unsigned := 16;
   CXCallingConv_Invalid : constant unsigned := 100;
   CXCallingConv_Unexposed : constant unsigned := 200;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3320

   --  skipped anonymous struct anon_9

   type CXType_data_array is array (0 .. 1) of System.Address;
   type CXType is record
      kind : aliased CXTypeKind;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3350
      data : CXType_data_array;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3351
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3352

   function clang_getCursorType (C : CXCursor) return CXType  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3357
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursorType";

   function clang_getTypeSpelling (CT : CXType) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3365
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getTypeSpelling";

   function clang_getTypedefDeclUnderlyingType (C : CXCursor) return CXType  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3373
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getTypedefDeclUnderlyingType";

   function clang_getEnumDeclIntegerType (C : CXCursor) return CXType  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3381
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getEnumDeclIntegerType";

   function clang_getEnumConstantDeclValue (C : CXCursor) return Long_Long_Integer  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3391
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getEnumConstantDeclValue";

   function clang_getEnumConstantDeclUnsignedValue (C : CXCursor) return Extensions.unsigned_long_long  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3401
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getEnumConstantDeclUnsignedValue";

   function clang_getFieldDeclBitWidth (C : CXCursor) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3408
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getFieldDeclBitWidth";

   function clang_Cursor_getNumArguments (C : CXCursor) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3417
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_getNumArguments";

   function clang_Cursor_getArgument (C : CXCursor; i : unsigned) return CXCursor  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3426
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_getArgument";

   type CXTemplateArgumentKind is 
     (CXTemplateArgumentKind_Null,
      CXTemplateArgumentKind_Type,
      CXTemplateArgumentKind_Declaration,
      CXTemplateArgumentKind_NullPtr,
      CXTemplateArgumentKind_Integral,
      CXTemplateArgumentKind_Template,
      CXTemplateArgumentKind_TemplateExpansion,
      CXTemplateArgumentKind_Expression,
      CXTemplateArgumentKind_Pack,
      CXTemplateArgumentKind_Invalid)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3434

   function clang_Cursor_getNumTemplateArguments (C : CXCursor) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3464
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_getNumTemplateArguments";

   function clang_Cursor_getTemplateArgumentKind (C : CXCursor; I : unsigned) return CXTemplateArgumentKind  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3482
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_getTemplateArgumentKind";

   function clang_Cursor_getTemplateArgumentType (C : CXCursor; I : unsigned) return CXType  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3503
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_getTemplateArgumentType";

   function clang_Cursor_getTemplateArgumentValue (C : CXCursor; I : unsigned) return Long_Long_Integer  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3523
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_getTemplateArgumentValue";

   function clang_Cursor_getTemplateArgumentUnsignedValue (C : CXCursor; I : unsigned) return Extensions.unsigned_long_long  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3543
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_getTemplateArgumentUnsignedValue";

   function clang_equalTypes (A : CXType; B : CXType) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3552
   with Import => True, 
        Convention => C, 
        External_Name => "clang_equalTypes";

   function clang_getCanonicalType (T : CXType) return CXType  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3562
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCanonicalType";

   function clang_isConstQualifiedType (T : CXType) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3569
   with Import => True, 
        Convention => C, 
        External_Name => "clang_isConstQualifiedType";

   function clang_Cursor_isMacroFunctionLike (C : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3575
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_isMacroFunctionLike";

   function clang_Cursor_isMacroBuiltin (C : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3581
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_isMacroBuiltin";

   function clang_Cursor_isFunctionInlined (C : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3587
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_isFunctionInlined";

   function clang_isVolatileQualifiedType (T : CXType) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3594
   with Import => True, 
        Convention => C, 
        External_Name => "clang_isVolatileQualifiedType";

   function clang_isRestrictQualifiedType (T : CXType) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3601
   with Import => True, 
        Convention => C, 
        External_Name => "clang_isRestrictQualifiedType";

   function clang_getAddressSpace (T : CXType) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3606
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getAddressSpace";

   function clang_getTypedefName (CT : CXType) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3611
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getTypedefName";

   function clang_getPointeeType (T : CXType) return CXType  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3616
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getPointeeType";

   function clang_getTypeDeclaration (T : CXType) return CXCursor  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3621
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getTypeDeclaration";

   function clang_getDeclObjCTypeEncoding (C : CXCursor) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3626
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getDeclObjCTypeEncoding";

   function clang_Type_getObjCEncoding (c_type : CXType) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3631
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Type_getObjCEncoding";

   function clang_getTypeKindSpelling (K : CXTypeKind) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3636
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getTypeKindSpelling";

   function clang_getFunctionTypeCallingConv (T : CXType) return CXCallingConv  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3643
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getFunctionTypeCallingConv";

   function clang_getResultType (T : CXType) return CXType  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3650
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getResultType";

   function clang_getExceptionSpecificationType (T : CXType) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3658
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getExceptionSpecificationType";

   function clang_getNumArgTypes (T : CXType) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3666
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getNumArgTypes";

   function clang_getArgType (T : CXType; i : unsigned) return CXType  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3674
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getArgType";

   function clang_Type_getObjCObjectBaseType (T : CXType) return CXType  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3681
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Type_getObjCObjectBaseType";

   function clang_Type_getNumObjCProtocolRefs (T : CXType) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3688
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Type_getNumObjCProtocolRefs";

   function clang_Type_getObjCProtocolDecl (T : CXType; i : unsigned) return CXCursor  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3696
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Type_getObjCProtocolDecl";

   function clang_Type_getNumObjCTypeArgs (T : CXType) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3703
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Type_getNumObjCTypeArgs";

   function clang_Type_getObjCTypeArg (T : CXType; i : unsigned) return CXType  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3711
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Type_getObjCTypeArg";

   function clang_isFunctionTypeVariadic (T : CXType) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3716
   with Import => True, 
        Convention => C, 
        External_Name => "clang_isFunctionTypeVariadic";

   function clang_getCursorResultType (C : CXCursor) return CXType  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3723
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursorResultType";

   function clang_getCursorExceptionSpecificationType (C : CXCursor) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3731
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursorExceptionSpecificationType";

   function clang_isPODType (T : CXType) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3737
   with Import => True, 
        Convention => C, 
        External_Name => "clang_isPODType";

   function clang_getElementType (T : CXType) return CXType  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3745
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getElementType";

   function clang_getNumElements (T : CXType) return Long_Long_Integer  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3753
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getNumElements";

   function clang_getArrayElementType (T : CXType) return CXType  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3760
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getArrayElementType";

   function clang_getArraySize (T : CXType) return Long_Long_Integer  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3767
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getArraySize";

   function clang_Type_getNamedType (T : CXType) return CXType  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3774
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Type_getNamedType";

   function clang_Type_isTransparentTagTypedef (T : CXType) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3784
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Type_isTransparentTagTypedef";

   type CXTypeNullabilityKind is 
     (CXTypeNullability_NonNull,
      CXTypeNullability_Nullable,
      CXTypeNullability_Unspecified,
      CXTypeNullability_Invalid)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3786

   function clang_Type_getNullability (T : CXType) return CXTypeNullabilityKind  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3811
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Type_getNullability";

   subtype CXTypeLayoutError is int;
   CXTypeLayoutError_Invalid : constant int := -1;
   CXTypeLayoutError_Incomplete : constant int := -2;
   CXTypeLayoutError_Dependent : constant int := -3;
   CXTypeLayoutError_NotConstantSize : constant int := -4;
   CXTypeLayoutError_InvalidFieldName : constant int := -5;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3821

   function clang_Type_getAlignOf (T : CXType) return Long_Long_Integer  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3856
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Type_getAlignOf";

   function clang_Type_getClassType (T : CXType) return CXType  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3863
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Type_getClassType";

   function clang_Type_getSizeOf (T : CXType) return Long_Long_Integer  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3874
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Type_getSizeOf";

   function clang_Type_getOffsetOf (T : CXType; S : Interfaces.C.Strings.chars_ptr) return Long_Long_Integer  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3889
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Type_getOffsetOf";

   function clang_Type_getModifiedType (T : CXType) return CXType  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3896
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Type_getModifiedType";

   function clang_Cursor_getOffsetOfField (C : CXCursor) return Long_Long_Integer  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3911
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_getOffsetOfField";

   function clang_Cursor_isAnonymous (C : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3917
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_isAnonymous";

   type CXRefQualifierKind is 
     (CXRefQualifier_None,
      CXRefQualifier_LValue,
      CXRefQualifier_RValue)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3919

   function clang_Type_getNumTemplateArguments (T : CXType) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3932
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Type_getNumTemplateArguments";

   function clang_Type_getTemplateArgumentAsType (T : CXType; i : unsigned) return CXType  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3941
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Type_getTemplateArgumentAsType";

   function clang_Type_getCXXRefQualifier (T : CXType) return CXRefQualifierKind  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3949
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Type_getCXXRefQualifier";

   function clang_Cursor_isBitField (C : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3955
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_isBitField";

   function clang_isVirtualBase (arg1 : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3961
   with Import => True, 
        Convention => C, 
        External_Name => "clang_isVirtualBase";

   type CX_CXXAccessSpecifier is 
     (CX_CXXInvalidAccessSpecifier,
      CX_CXXPublic,
      CX_CXXProtected,
      CX_CXXPrivate)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3967

   function clang_getCXXAccessSpecifier (arg1 : CXCursor) return CX_CXXAccessSpecifier  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3981
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCXXAccessSpecifier";

   type CX_StorageClass is 
     (CX_SC_Invalid,
      CX_SC_None,
      CX_SC_Extern,
      CX_SC_Static,
      CX_SC_PrivateExtern,
      CX_SC_OpenCLWorkGroupLocal,
      CX_SC_Auto,
      CX_SC_Register)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:3987

   function clang_Cursor_getStorageClass (arg1 : CXCursor) return CX_StorageClass  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4004
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_getStorageClass";

   function clang_getNumOverloadedDecls (cursor : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4015
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getNumOverloadedDecls";

   function clang_getOverloadedDecl (cursor : CXCursor; index : unsigned) return CXCursor  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4031
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getOverloadedDecl";

   function clang_getIBOutletCollectionType (arg1 : CXCursor) return CXType  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4049
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getIBOutletCollectionType";

   type CXChildVisitResult is 
     (CXChildVisit_Break,
      CXChildVisit_Continue,
      CXChildVisit_Recurse)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4071

   type CXCursorVisitor is access function
        (arg1 : CXCursor;
         arg2 : CXCursor;
         arg3 : CXClientData) return CXChildVisitResult
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4100

   function clang_visitChildren
     (parent : CXCursor;
      visitor : CXCursorVisitor;
      client_data : CXClientData) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4126
   with Import => True, 
        Convention => C, 
        External_Name => "clang_visitChildren";

   function clang_getCursorUSR (arg1 : CXCursor) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4177
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursorUSR";

   function clang_constructUSR_ObjCClass (class_name : Interfaces.C.Strings.chars_ptr) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4182
   with Import => True, 
        Convention => C, 
        External_Name => "clang_constructUSR_ObjCClass";

   function clang_constructUSR_ObjCCategory (class_name : Interfaces.C.Strings.chars_ptr; category_name : Interfaces.C.Strings.chars_ptr) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4188
   with Import => True, 
        Convention => C, 
        External_Name => "clang_constructUSR_ObjCCategory";

   function clang_constructUSR_ObjCProtocol (protocol_name : Interfaces.C.Strings.chars_ptr) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4195
   with Import => True, 
        Convention => C, 
        External_Name => "clang_constructUSR_ObjCProtocol";

   function clang_constructUSR_ObjCIvar (name : Interfaces.C.Strings.chars_ptr; classUSR : clang_c_CXString_h.CXString) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4201
   with Import => True, 
        Convention => C, 
        External_Name => "clang_constructUSR_ObjCIvar";

   function clang_constructUSR_ObjCMethod
     (name : Interfaces.C.Strings.chars_ptr;
      isInstanceMethod : unsigned;
      classUSR : clang_c_CXString_h.CXString) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4208
   with Import => True, 
        Convention => C, 
        External_Name => "clang_constructUSR_ObjCMethod";

   function clang_constructUSR_ObjCProperty (property : Interfaces.C.Strings.chars_ptr; classUSR : clang_c_CXString_h.CXString) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4216
   with Import => True, 
        Convention => C, 
        External_Name => "clang_constructUSR_ObjCProperty";

   function clang_getCursorSpelling (arg1 : CXCursor) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4222
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursorSpelling";

   function clang_Cursor_getSpellingNameRange
     (arg1 : CXCursor;
      pieceIndex : unsigned;
      options : unsigned) return CXSourceRange  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4235
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_getSpellingNameRange";

   type CXPrintingPolicy is new System.Address;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4243

   subtype CXPrintingPolicyProperty is unsigned;
   CXPrintingPolicy_Indentation : constant unsigned := 0;
   CXPrintingPolicy_SuppressSpecifiers : constant unsigned := 1;
   CXPrintingPolicy_SuppressTagKeyword : constant unsigned := 2;
   CXPrintingPolicy_IncludeTagDefinition : constant unsigned := 3;
   CXPrintingPolicy_SuppressScope : constant unsigned := 4;
   CXPrintingPolicy_SuppressUnwrittenScope : constant unsigned := 5;
   CXPrintingPolicy_SuppressInitializers : constant unsigned := 6;
   CXPrintingPolicy_ConstantArraySizeAsWritten : constant unsigned := 7;
   CXPrintingPolicy_AnonymousTagLocations : constant unsigned := 8;
   CXPrintingPolicy_SuppressStrongLifetime : constant unsigned := 9;
   CXPrintingPolicy_SuppressLifetimeQualifiers : constant unsigned := 10;
   CXPrintingPolicy_SuppressTemplateArgsInCXXConstructors : constant unsigned := 11;
   CXPrintingPolicy_Bool : constant unsigned := 12;
   CXPrintingPolicy_Restrict : constant unsigned := 13;
   CXPrintingPolicy_Alignof : constant unsigned := 14;
   CXPrintingPolicy_UnderscoreAlignof : constant unsigned := 15;
   CXPrintingPolicy_UseVoidForZeroParams : constant unsigned := 16;
   CXPrintingPolicy_TerseOutput : constant unsigned := 17;
   CXPrintingPolicy_PolishForDeclaration : constant unsigned := 18;
   CXPrintingPolicy_Half : constant unsigned := 19;
   CXPrintingPolicy_MSWChar : constant unsigned := 20;
   CXPrintingPolicy_IncludeNewlines : constant unsigned := 21;
   CXPrintingPolicy_MSVCFormatting : constant unsigned := 22;
   CXPrintingPolicy_ConstantsAsWritten : constant unsigned := 23;
   CXPrintingPolicy_SuppressImplicitBase : constant unsigned := 24;
   CXPrintingPolicy_FullyQualifiedName : constant unsigned := 25;
   CXPrintingPolicy_LastProperty : constant unsigned := 25;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4250

   function clang_PrintingPolicy_getProperty (Policy : CXPrintingPolicy; Property : CXPrintingPolicyProperty) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4285
   with Import => True, 
        Convention => C, 
        External_Name => "clang_PrintingPolicy_getProperty";

   procedure clang_PrintingPolicy_setProperty
     (Policy : CXPrintingPolicy;
      Property : CXPrintingPolicyProperty;
      Value : unsigned)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4291
   with Import => True, 
        Convention => C, 
        External_Name => "clang_PrintingPolicy_setProperty";

   function clang_getCursorPrintingPolicy (arg1 : CXCursor) return CXPrintingPolicy  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4301
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursorPrintingPolicy";

   procedure clang_PrintingPolicy_dispose (Policy : CXPrintingPolicy)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4306
   with Import => True, 
        Convention => C, 
        External_Name => "clang_PrintingPolicy_dispose";

   function clang_getCursorPrettyPrinted (Cursor : CXCursor; Policy : CXPrintingPolicy) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4319
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursorPrettyPrinted";

   function clang_getCursorDisplayName (arg1 : CXCursor) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4329
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursorDisplayName";

   function clang_getCursorReferenced (arg1 : CXCursor) return CXCursor  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4341
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursorReferenced";

   function clang_getCursorDefinition (arg1 : CXCursor) return CXCursor  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4371
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursorDefinition";

   function clang_isCursorDefinition (arg1 : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4377
   with Import => True, 
        Convention => C, 
        External_Name => "clang_isCursorDefinition";

   function clang_getCanonicalCursor (arg1 : CXCursor) return CXCursor  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4403
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCanonicalCursor";

   function clang_Cursor_getObjCSelectorIndex (arg1 : CXCursor) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4416
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_getObjCSelectorIndex";

   function clang_Cursor_isDynamicCall (C : CXCursor) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4429
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_isDynamicCall";

   function clang_Cursor_getReceiverType (C : CXCursor) return CXType  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4435
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_getReceiverType";

   subtype CXObjCPropertyAttrKind is unsigned;
   CXObjCPropertyAttr_noattr : constant unsigned := 0;
   CXObjCPropertyAttr_readonly : constant unsigned := 1;
   CXObjCPropertyAttr_getter : constant unsigned := 2;
   CXObjCPropertyAttr_assign : constant unsigned := 4;
   CXObjCPropertyAttr_readwrite : constant unsigned := 8;
   CXObjCPropertyAttr_retain : constant unsigned := 16;
   CXObjCPropertyAttr_copy : constant unsigned := 32;
   CXObjCPropertyAttr_nonatomic : constant unsigned := 64;
   CXObjCPropertyAttr_setter : constant unsigned := 128;
   CXObjCPropertyAttr_atomic : constant unsigned := 256;
   CXObjCPropertyAttr_weak : constant unsigned := 512;
   CXObjCPropertyAttr_strong : constant unsigned := 1024;
   CXObjCPropertyAttr_unsafe_unretained : constant unsigned := 2048;
   CXObjCPropertyAttr_class : constant unsigned := 4096;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4455

   function clang_Cursor_getObjCPropertyAttributes (C : CXCursor; reserved : unsigned) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4464
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_getObjCPropertyAttributes";

   function clang_Cursor_getObjCPropertyGetterName (C : CXCursor) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4471
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_getObjCPropertyGetterName";

   function clang_Cursor_getObjCPropertySetterName (C : CXCursor) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4477
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_getObjCPropertySetterName";

   subtype CXObjCDeclQualifierKind is unsigned;
   CXObjCDeclQualifier_None : constant unsigned := 0;
   CXObjCDeclQualifier_In : constant unsigned := 1;
   CXObjCDeclQualifier_Inout : constant unsigned := 2;
   CXObjCDeclQualifier_Out : constant unsigned := 4;
   CXObjCDeclQualifier_Bycopy : constant unsigned := 8;
   CXObjCDeclQualifier_Byref : constant unsigned := 16;
   CXObjCDeclQualifier_Oneway : constant unsigned := 32;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4491

   function clang_Cursor_getObjCDeclQualifiers (C : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4499
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_getObjCDeclQualifiers";

   function clang_Cursor_isObjCOptional (C : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4506
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_isObjCOptional";

   function clang_Cursor_isVariadic (C : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4511
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_isVariadic";

   function clang_Cursor_isExternalSymbol
     (C : CXCursor;
      language : access clang_c_CXString_h.CXString;
      definedIn : access clang_c_CXString_h.CXString;
      isGenerated : access unsigned) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4526
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_isExternalSymbol";

   function clang_Cursor_getCommentRange (C : CXCursor) return CXSourceRange  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4535
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_getCommentRange";

   function clang_Cursor_getRawCommentText (C : CXCursor) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4541
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_getRawCommentText";

   function clang_Cursor_getBriefCommentText (C : CXCursor) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4548
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_getBriefCommentText";

   function clang_Cursor_getMangling (arg1 : CXCursor) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4562
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_getMangling";

   function clang_Cursor_getCXXManglings (arg1 : CXCursor) return access clang_c_CXString_h.CXStringSet  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4568
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_getCXXManglings";

   function clang_Cursor_getObjCManglings (arg1 : CXCursor) return access clang_c_CXString_h.CXStringSet  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4574
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_getObjCManglings";

   type CXModule is new System.Address;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4588

   function clang_Cursor_getModule (C : CXCursor) return CXModule  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4593
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_getModule";

   function clang_getModuleForFile (arg1 : CXTranslationUnit; arg2 : CXFile) return CXModule  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4599
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getModuleForFile";

   function clang_Module_getASTFile (Module : CXModule) return CXFile  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4606
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Module_getASTFile";

   function clang_Module_getParent (Module : CXModule) return CXModule  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4614
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Module_getParent";

   function clang_Module_getName (Module : CXModule) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4622
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Module_getName";

   function clang_Module_getFullName (Module : CXModule) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4629
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Module_getFullName";

   function clang_Module_isSystem (Module : CXModule) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4636
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Module_isSystem";

   function clang_Module_getNumTopLevelHeaders (arg1 : CXTranslationUnit; Module : CXModule) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4643
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Module_getNumTopLevelHeaders";

   function clang_Module_getTopLevelHeader
     (arg1 : CXTranslationUnit;
      Module : CXModule;
      Index : unsigned) return CXFile  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4654
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Module_getTopLevelHeader";

   function clang_CXXConstructor_isConvertingConstructor (C : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4673
   with Import => True, 
        Convention => C, 
        External_Name => "clang_CXXConstructor_isConvertingConstructor";

   function clang_CXXConstructor_isCopyConstructor (C : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4678
   with Import => True, 
        Convention => C, 
        External_Name => "clang_CXXConstructor_isCopyConstructor";

   function clang_CXXConstructor_isDefaultConstructor (C : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4683
   with Import => True, 
        Convention => C, 
        External_Name => "clang_CXXConstructor_isDefaultConstructor";

   function clang_CXXConstructor_isMoveConstructor (C : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4688
   with Import => True, 
        Convention => C, 
        External_Name => "clang_CXXConstructor_isMoveConstructor";

   function clang_CXXField_isMutable (C : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4693
   with Import => True, 
        Convention => C, 
        External_Name => "clang_CXXField_isMutable";

   function clang_CXXMethod_isDefaulted (C : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4698
   with Import => True, 
        Convention => C, 
        External_Name => "clang_CXXMethod_isDefaulted";

   function clang_CXXMethod_isPureVirtual (C : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4704
   with Import => True, 
        Convention => C, 
        External_Name => "clang_CXXMethod_isPureVirtual";

   function clang_CXXMethod_isStatic (C : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4710
   with Import => True, 
        Convention => C, 
        External_Name => "clang_CXXMethod_isStatic";

   function clang_CXXMethod_isVirtual (C : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4717
   with Import => True, 
        Convention => C, 
        External_Name => "clang_CXXMethod_isVirtual";

   function clang_CXXRecord_isAbstract (C : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4723
   with Import => True, 
        Convention => C, 
        External_Name => "clang_CXXRecord_isAbstract";

   function clang_EnumDecl_isScoped (C : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4728
   with Import => True, 
        Convention => C, 
        External_Name => "clang_EnumDecl_isScoped";

   function clang_CXXMethod_isConst (C : CXCursor) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4734
   with Import => True, 
        Convention => C, 
        External_Name => "clang_CXXMethod_isConst";

   function clang_getTemplateCursorKind (C : CXCursor) return CXCursorKind  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4753
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getTemplateCursorKind";

   function clang_getSpecializedCursorTemplate (C : CXCursor) return CXCursor  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4783
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getSpecializedCursorTemplate";

   function clang_getCursorReferenceNameRange
     (C : CXCursor;
      NameFlags : unsigned;
      PieceIndex : unsigned) return CXSourceRange  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4803
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursorReferenceNameRange";

   subtype CXNameRefFlags is unsigned;
   CXNameRange_WantQualifier : constant unsigned := 1;
   CXNameRange_WantTemplateArgs : constant unsigned := 2;
   CXNameRange_WantSinglePiece : constant unsigned := 4;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4807

   type CXTokenKind is 
     (CXToken_Punctuation,
      CXToken_Keyword,
      CXToken_Identifier,
      CXToken_Literal,
      CXToken_Comment)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4850

   --  skipped anonymous struct anon_12

   type CXToken_int_data_array is array (0 .. 3) of aliased unsigned;
   type CXToken is record
      int_data : aliased CXToken_int_data_array;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4881
      ptr_data : System.Address;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4882
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4883

   function clang_getToken (TU : CXTranslationUnit; Location : CXSourceLocation) return access CXToken  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4896
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getToken";

   function clang_getTokenKind (arg1 : CXToken) return CXTokenKind  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4902
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getTokenKind";

   function clang_getTokenSpelling (arg1 : CXTranslationUnit; arg2 : CXToken) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4910
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getTokenSpelling";

   function clang_getTokenLocation (arg1 : CXTranslationUnit; arg2 : CXToken) return CXSourceLocation  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4915
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getTokenLocation";

   function clang_getTokenExtent (arg1 : CXTranslationUnit; arg2 : CXToken) return CXSourceRange  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4921
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getTokenExtent";

   procedure clang_tokenize
     (TU : CXTranslationUnit;
      c_Range : CXSourceRange;
      Tokens : System.Address;
      NumTokens : access unsigned)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4940
   with Import => True, 
        Convention => C, 
        External_Name => "clang_tokenize";

   procedure clang_annotateTokens
     (TU : CXTranslationUnit;
      Tokens : access CXToken;
      NumTokens : unsigned;
      Cursors : access CXCursor)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4973
   with Import => True, 
        Convention => C, 
        External_Name => "clang_annotateTokens";

   procedure clang_disposeTokens
     (TU : CXTranslationUnit;
      Tokens : access CXToken;
      NumTokens : unsigned)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4980
   with Import => True, 
        Convention => C, 
        External_Name => "clang_disposeTokens";

   function clang_getCursorKindSpelling (Kind : CXCursorKind) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4997
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursorKindSpelling";

   procedure clang_getDefinitionSpellingAndExtent
     (arg1 : CXCursor;
      startBuf : System.Address;
      endBuf : System.Address;
      startLine : access unsigned;
      startColumn : access unsigned;
      endLine : access unsigned;
      endColumn : access unsigned)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:4998
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getDefinitionSpellingAndExtent";

   procedure clang_enableStackTraces  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5005
   with Import => True, 
        Convention => C, 
        External_Name => "clang_enableStackTraces";

   procedure clang_executeOnThread
     (fn : access procedure (arg1 : System.Address);
      user_data : System.Address;
      stack_size : unsigned)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5006
   with Import => True, 
        Convention => C, 
        External_Name => "clang_executeOnThread";

   type CXCompletionString is new System.Address;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5038

   --  skipped anonymous struct anon_13

   type CXCompletionResult is record
      CursorKind : aliased CXCursorKind;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5054
      CompletionString : CXCompletionString;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5060
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5061

   type CXCompletionChunkKind is 
     (CXCompletionChunk_Optional,
      CXCompletionChunk_TypedText,
      CXCompletionChunk_Text,
      CXCompletionChunk_Placeholder,
      CXCompletionChunk_Informative,
      CXCompletionChunk_CurrentParameter,
      CXCompletionChunk_LeftParen,
      CXCompletionChunk_RightParen,
      CXCompletionChunk_LeftBracket,
      CXCompletionChunk_RightBracket,
      CXCompletionChunk_LeftBrace,
      CXCompletionChunk_RightBrace,
      CXCompletionChunk_LeftAngle,
      CXCompletionChunk_RightAngle,
      CXCompletionChunk_Comma,
      CXCompletionChunk_ResultType,
      CXCompletionChunk_Colon,
      CXCompletionChunk_SemiColon,
      CXCompletionChunk_Equal,
      CXCompletionChunk_HorizontalSpace,
      CXCompletionChunk_VerticalSpace)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5070

   function clang_getCompletionChunkKind (completion_string : CXCompletionString; chunk_number : unsigned) return CXCompletionChunkKind  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5244
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCompletionChunkKind";

   function clang_getCompletionChunkText (completion_string : CXCompletionString; chunk_number : unsigned) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5258
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCompletionChunkText";

   function clang_getCompletionChunkCompletionString (completion_string : CXCompletionString; chunk_number : unsigned) return CXCompletionString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5273
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCompletionChunkCompletionString";

   function clang_getNumCompletionChunks (completion_string : CXCompletionString) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5280
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getNumCompletionChunks";

   function clang_getCompletionPriority (completion_string : CXCompletionString) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5295
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCompletionPriority";

   function clang_getCompletionAvailability (completion_string : CXCompletionString) return CXAvailabilityKind  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5306
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCompletionAvailability";

   function clang_getCompletionNumAnnotations (completion_string : CXCompletionString) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5318
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCompletionNumAnnotations";

   function clang_getCompletionAnnotation (completion_string : CXCompletionString; annotation_number : unsigned) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5332
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCompletionAnnotation";

   function clang_getCompletionParent (completion_string : CXCompletionString; kind : access CXCursorKind) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5352
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCompletionParent";

   function clang_getCompletionBriefComment (completion_string : CXCompletionString) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5360
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCompletionBriefComment";

   function clang_getCursorCompletionString (cursor : CXCursor) return CXCompletionString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5372
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCursorCompletionString";

   --  skipped anonymous struct anon_14

   type CXCodeCompleteResults is record
      Results : access CXCompletionResult;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5385
      NumResults : aliased unsigned;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5391
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5392

   function clang_getCompletionNumFixIts (results : access CXCodeCompleteResults; completion_index : unsigned) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5408
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCompletionNumFixIts";

   function clang_getCompletionFixIt
     (results : access CXCodeCompleteResults;
      completion_index : unsigned;
      fixit_index : unsigned;
      replacement_range : access CXSourceRange) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5454
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getCompletionFixIt";

   subtype CXCodeComplete_Flags is unsigned;
   CXCodeComplete_IncludeMacros : constant unsigned := 1;
   CXCodeComplete_IncludeCodePatterns : constant unsigned := 2;
   CXCodeComplete_IncludeBriefComments : constant unsigned := 4;
   CXCodeComplete_SkipPreamble : constant unsigned := 8;
   CXCodeComplete_IncludeCompletionsWithFixIts : constant unsigned := 16;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5465

   subtype CXCompletionContext is unsigned;
   CXCompletionContext_Unexposed : constant unsigned := 0;
   CXCompletionContext_AnyType : constant unsigned := 1;
   CXCompletionContext_AnyValue : constant unsigned := 2;
   CXCompletionContext_ObjCObjectValue : constant unsigned := 4;
   CXCompletionContext_ObjCSelectorValue : constant unsigned := 8;
   CXCompletionContext_CXXClassTypeValue : constant unsigned := 16;
   CXCompletionContext_DotMemberAccess : constant unsigned := 32;
   CXCompletionContext_ArrowMemberAccess : constant unsigned := 64;
   CXCompletionContext_ObjCPropertyAccess : constant unsigned := 128;
   CXCompletionContext_EnumTag : constant unsigned := 256;
   CXCompletionContext_UnionTag : constant unsigned := 512;
   CXCompletionContext_StructTag : constant unsigned := 1024;
   CXCompletionContext_ClassTag : constant unsigned := 2048;
   CXCompletionContext_Namespace : constant unsigned := 4096;
   CXCompletionContext_NestedNameSpecifier : constant unsigned := 8192;
   CXCompletionContext_ObjCInterface : constant unsigned := 16384;
   CXCompletionContext_ObjCProtocol : constant unsigned := 32768;
   CXCompletionContext_ObjCCategory : constant unsigned := 65536;
   CXCompletionContext_ObjCInstanceMessage : constant unsigned := 131072;
   CXCompletionContext_ObjCClassMessage : constant unsigned := 262144;
   CXCompletionContext_ObjCSelectorName : constant unsigned := 524288;
   CXCompletionContext_MacroName : constant unsigned := 1048576;
   CXCompletionContext_NaturalLanguage : constant unsigned := 2097152;
   CXCompletionContext_IncludedFile : constant unsigned := 4194304;
   CXCompletionContext_Unknown : constant unsigned := 8388607;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5504

   function clang_defaultCodeCompleteOptions return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5638
   with Import => True, 
        Convention => C, 
        External_Name => "clang_defaultCodeCompleteOptions";

   function clang_codeCompleteAt
     (TU : CXTranslationUnit;
      complete_filename : Interfaces.C.Strings.chars_ptr;
      complete_line : unsigned;
      complete_column : unsigned;
      unsaved_files : access CXUnsavedFile;
      num_unsaved_files : unsigned;
      options : unsigned) return access CXCodeCompleteResults  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5709
   with Import => True, 
        Convention => C, 
        External_Name => "clang_codeCompleteAt";

   procedure clang_sortCodeCompletionResults (Results : access CXCompletionResult; NumResults : unsigned)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5725
   with Import => True, 
        Convention => C, 
        External_Name => "clang_sortCodeCompletionResults";

   procedure clang_disposeCodeCompleteResults (Results : access CXCodeCompleteResults)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5732
   with Import => True, 
        Convention => C, 
        External_Name => "clang_disposeCodeCompleteResults";

   function clang_codeCompleteGetNumDiagnostics (Results : access CXCodeCompleteResults) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5739
   with Import => True, 
        Convention => C, 
        External_Name => "clang_codeCompleteGetNumDiagnostics";

   function clang_codeCompleteGetDiagnostic (Results : access CXCodeCompleteResults; Index : unsigned) return CXDiagnostic  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5751
   with Import => True, 
        Convention => C, 
        External_Name => "clang_codeCompleteGetDiagnostic";

   function clang_codeCompleteGetContexts (Results : access CXCodeCompleteResults) return Extensions.unsigned_long_long  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5764
   with Import => True, 
        Convention => C, 
        External_Name => "clang_codeCompleteGetContexts";

   function clang_codeCompleteGetContainerKind (Results : access CXCodeCompleteResults; IsIncomplete : access unsigned) return CXCursorKind  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5784
   with Import => True, 
        Convention => C, 
        External_Name => "clang_codeCompleteGetContainerKind";

   function clang_codeCompleteGetContainerUSR (Results : access CXCodeCompleteResults) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5798
   with Import => True, 
        Convention => C, 
        External_Name => "clang_codeCompleteGetContainerUSR";

   function clang_codeCompleteGetObjCSelector (Results : access CXCodeCompleteResults) return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5812
   with Import => True, 
        Convention => C, 
        External_Name => "clang_codeCompleteGetObjCSelector";

   function clang_getClangVersion return clang_c_CXString_h.CXString  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5828
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getClangVersion";

   procedure clang_toggleCrashRecovery (isEnabled : unsigned)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5836
   with Import => True, 
        Convention => C, 
        External_Name => "clang_toggleCrashRecovery";

   type CXInclusionVisitor is access procedure
        (arg1 : CXFile;
         arg2 : access CXSourceLocation;
         arg3 : unsigned;
         arg4 : CXClientData)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5849

   procedure clang_getInclusions
     (tu : CXTranslationUnit;
      visitor : CXInclusionVisitor;
      client_data : CXClientData)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5860
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getInclusions";

   subtype CXEvalResultKind is unsigned;
   CXEval_Int : constant unsigned := 1;
   CXEval_Float : constant unsigned := 2;
   CXEval_ObjCStrLiteral : constant unsigned := 3;
   CXEval_StrLiteral : constant unsigned := 4;
   CXEval_CFStr : constant unsigned := 5;
   CXEval_Other : constant unsigned := 6;
   CXEval_UnExposed : constant unsigned := 0;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5874

   type CXEvalResult is new System.Address;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5879

   function clang_Cursor_Evaluate (C : CXCursor) return CXEvalResult  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5886
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Cursor_Evaluate";

   function clang_EvalResult_getKind (E : CXEvalResult) return CXEvalResultKind  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5891
   with Import => True, 
        Convention => C, 
        External_Name => "clang_EvalResult_getKind";

   function clang_EvalResult_getAsInt (E : CXEvalResult) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5897
   with Import => True, 
        Convention => C, 
        External_Name => "clang_EvalResult_getAsInt";

   function clang_EvalResult_getAsLongLong (E : CXEvalResult) return Long_Long_Integer  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5904
   with Import => True, 
        Convention => C, 
        External_Name => "clang_EvalResult_getAsLongLong";

   function clang_EvalResult_isUnsignedInt (E : CXEvalResult) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5910
   with Import => True, 
        Convention => C, 
        External_Name => "clang_EvalResult_isUnsignedInt";

   function clang_EvalResult_getAsUnsigned (E : CXEvalResult) return Extensions.unsigned_long_long  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5916
   with Import => True, 
        Convention => C, 
        External_Name => "clang_EvalResult_getAsUnsigned";

   function clang_EvalResult_getAsDouble (E : CXEvalResult) return double  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5922
   with Import => True, 
        Convention => C, 
        External_Name => "clang_EvalResult_getAsDouble";

   function clang_EvalResult_getAsStr (E : CXEvalResult) return Interfaces.C.Strings.chars_ptr  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5930
   with Import => True, 
        Convention => C, 
        External_Name => "clang_EvalResult_getAsStr";

   procedure clang_EvalResult_dispose (E : CXEvalResult)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5935
   with Import => True, 
        Convention => C, 
        External_Name => "clang_EvalResult_dispose";

   type CXRemapping is new System.Address;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5948

   function clang_getRemappings (path : Interfaces.C.Strings.chars_ptr) return CXRemapping  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5958
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getRemappings";

   function clang_getRemappingsFromFileList (filePaths : System.Address; numFiles : unsigned) return CXRemapping  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5971
   with Import => True, 
        Convention => C, 
        External_Name => "clang_getRemappingsFromFileList";

   function clang_remap_getNumFiles (arg1 : CXRemapping) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5977
   with Import => True, 
        Convention => C, 
        External_Name => "clang_remap_getNumFiles";

   procedure clang_remap_getFilenames
     (arg1 : CXRemapping;
      index : unsigned;
      original : access clang_c_CXString_h.CXString;
      transformed : access clang_c_CXString_h.CXString)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5987
   with Import => True, 
        Convention => C, 
        External_Name => "clang_remap_getFilenames";

   procedure clang_remap_dispose (arg1 : CXRemapping)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:5993
   with Import => True, 
        Convention => C, 
        External_Name => "clang_remap_dispose";

   type CXVisitorResult is 
     (CXVisit_Break,
      CXVisit_Continue)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6004

   type CXCursorAndRangeVisitor is record
      context : System.Address;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6010
      visit : access function
           (arg1 : System.Address;
            arg2 : CXCursor;
            arg3 : CXSourceRange) return CXVisitorResult;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6011
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6009

   type CXResult is 
     (CXResult_Success,
      CXResult_Invalid,
      CXResult_VisitBreak)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6029

   function clang_findReferencesInFile
     (cursor : CXCursor;
      file : CXFile;
      visitor : CXCursorAndRangeVisitor) return CXResult  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6045
   with Import => True, 
        Convention => C, 
        External_Name => "clang_findReferencesInFile";

   function clang_findIncludesInFile
     (TU : CXTranslationUnit;
      file : CXFile;
      visitor : CXCursorAndRangeVisitor) return CXResult  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6060
   with Import => True, 
        Convention => C, 
        External_Name => "clang_findIncludesInFile";

   type CXIdxClientFile is new System.Address;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6084

   type CXIdxClientEntity is new System.Address;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6089

   type CXIdxClientContainer is new System.Address;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6095

   type CXIdxClientASTFile is new System.Address;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6101

   --  skipped anonymous struct anon_17

   type CXIdxLoc_ptr_data_array is array (0 .. 1) of System.Address;
   type CXIdxLoc is record
      ptr_data : CXIdxLoc_ptr_data_array;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6107
      int_data : aliased unsigned;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6108
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6109

   --  skipped anonymous struct anon_18

   type CXIdxIncludedFileInfo is record
      hashLoc : aliased CXIdxLoc;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6118
      filename : Interfaces.C.Strings.chars_ptr;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6122
      file : CXFile;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6126
      isImport : aliased int;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6127
      isAngled : aliased int;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6128
      isModuleImport : aliased int;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6133
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6134

   --  skipped anonymous struct anon_19

   type CXIdxImportedASTFileInfo is record
      file : CXFile;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6143
      module : CXModule;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6147
      loc : aliased CXIdxLoc;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6151
      isImplicit : aliased int;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6156
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6158

   type CXIdxEntityKind is 
     (CXIdxEntity_Unexposed,
      CXIdxEntity_Typedef,
      CXIdxEntity_Function,
      CXIdxEntity_Variable,
      CXIdxEntity_Field,
      CXIdxEntity_EnumConstant,
      CXIdxEntity_ObjCClass,
      CXIdxEntity_ObjCProtocol,
      CXIdxEntity_ObjCCategory,
      CXIdxEntity_ObjCInstanceMethod,
      CXIdxEntity_ObjCClassMethod,
      CXIdxEntity_ObjCProperty,
      CXIdxEntity_ObjCIvar,
      CXIdxEntity_Enum,
      CXIdxEntity_Struct,
      CXIdxEntity_Union,
      CXIdxEntity_CXXClass,
      CXIdxEntity_CXXNamespace,
      CXIdxEntity_CXXNamespaceAlias,
      CXIdxEntity_CXXStaticVariable,
      CXIdxEntity_CXXStaticMethod,
      CXIdxEntity_CXXInstanceMethod,
      CXIdxEntity_CXXConstructor,
      CXIdxEntity_CXXDestructor,
      CXIdxEntity_CXXConversionFunction,
      CXIdxEntity_CXXTypeAlias,
      CXIdxEntity_CXXInterface)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6193

   type CXIdxEntityLanguage is 
     (CXIdxEntityLang_None,
      CXIdxEntityLang_C,
      CXIdxEntityLang_ObjC,
      CXIdxEntityLang_CXX,
      CXIdxEntityLang_Swift)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6201

   type CXIdxEntityCXXTemplateKind is 
     (CXIdxEntity_NonTemplate,
      CXIdxEntity_Template,
      CXIdxEntity_TemplatePartialSpecialization,
      CXIdxEntity_TemplateSpecialization)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6218

   type CXIdxAttrKind is 
     (CXIdxAttr_Unexposed,
      CXIdxAttr_IBAction,
      CXIdxAttr_IBOutlet,
      CXIdxAttr_IBOutletCollection)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6225

   --  skipped anonymous struct anon_24

   type CXIdxAttrInfo is record
      kind : aliased CXIdxAttrKind;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6228
      cursor : aliased CXCursor;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6229
      loc : aliased CXIdxLoc;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6230
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6231

   --  skipped anonymous struct anon_25

   type CXIdxEntityInfo is record
      kind : aliased CXIdxEntityKind;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6234
      templateKind : aliased CXIdxEntityCXXTemplateKind;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6235
      lang : aliased CXIdxEntityLanguage;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6236
      name : Interfaces.C.Strings.chars_ptr;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6237
      USR : Interfaces.C.Strings.chars_ptr;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6238
      cursor : aliased CXCursor;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6239
      attributes : System.Address;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6240
      numAttributes : aliased unsigned;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6241
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6242

   --  skipped anonymous struct anon_26

   type CXIdxContainerInfo is record
      cursor : aliased CXCursor;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6245
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6246

   --  skipped anonymous struct anon_27

   type CXIdxIBOutletCollectionAttrInfo is record
      attrInfo : access constant CXIdxAttrInfo;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6249
      objcClass : access constant CXIdxEntityInfo;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6250
      classCursor : aliased CXCursor;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6251
      classLoc : aliased CXIdxLoc;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6252
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6253

   subtype CXIdxDeclInfoFlags is unsigned;
   CXIdxDeclFlag_Skipped : constant unsigned := 1;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6257

   --  skipped anonymous struct anon_29

   type CXIdxDeclInfo is record
      entityInfo : access constant CXIdxEntityInfo;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6260
      cursor : aliased CXCursor;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6261
      loc : aliased CXIdxLoc;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6262
      semanticContainer : access constant CXIdxContainerInfo;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6263
      lexicalContainer : access constant CXIdxContainerInfo;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6268
      isRedeclaration : aliased int;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6269
      isDefinition : aliased int;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6270
      isContainer : aliased int;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6271
      declAsContainer : access constant CXIdxContainerInfo;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6272
      isImplicit : aliased int;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6277
      attributes : System.Address;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6278
      numAttributes : aliased unsigned;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6279
      flags : aliased unsigned;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6281
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6283

   type CXIdxObjCContainerKind is 
     (CXIdxObjCContainer_ForwardRef,
      CXIdxObjCContainer_Interface,
      CXIdxObjCContainer_Implementation)
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6289

   --  skipped anonymous struct anon_31

   type CXIdxObjCContainerDeclInfo is record
      declInfo : access constant CXIdxDeclInfo;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6292
      kind : aliased CXIdxObjCContainerKind;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6293
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6294

   --  skipped anonymous struct anon_32

   type CXIdxBaseClassInfo is record
      base : access constant CXIdxEntityInfo;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6297
      cursor : aliased CXCursor;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6298
      loc : aliased CXIdxLoc;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6299
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6300

   --  skipped anonymous struct anon_33

   type CXIdxObjCProtocolRefInfo is record
      protocol : access constant CXIdxEntityInfo;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6303
      cursor : aliased CXCursor;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6304
      loc : aliased CXIdxLoc;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6305
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6306

   --  skipped anonymous struct anon_34

   type CXIdxObjCProtocolRefListInfo is record
      protocols : System.Address;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6309
      numProtocols : aliased unsigned;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6310
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6311

   --  skipped anonymous struct anon_35

   type CXIdxObjCInterfaceDeclInfo is record
      containerInfo : access constant CXIdxObjCContainerDeclInfo;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6314
      superInfo : access constant CXIdxBaseClassInfo;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6315
      protocols : access constant CXIdxObjCProtocolRefListInfo;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6316
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6317

   --  skipped anonymous struct anon_36

   type CXIdxObjCCategoryDeclInfo is record
      containerInfo : access constant CXIdxObjCContainerDeclInfo;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6320
      objcClass : access constant CXIdxEntityInfo;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6321
      classCursor : aliased CXCursor;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6322
      classLoc : aliased CXIdxLoc;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6323
      protocols : access constant CXIdxObjCProtocolRefListInfo;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6324
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6325

   --  skipped anonymous struct anon_37

   type CXIdxObjCPropertyDeclInfo is record
      declInfo : access constant CXIdxDeclInfo;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6328
      getter : access constant CXIdxEntityInfo;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6329
      setter : access constant CXIdxEntityInfo;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6330
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6331

   --  skipped anonymous struct anon_38

   type CXIdxCXXClassDeclInfo is record
      declInfo : access constant CXIdxDeclInfo;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6334
      bases : System.Address;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6335
      numBases : aliased unsigned;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6336
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6337

   subtype CXIdxEntityRefKind is unsigned;
   CXIdxEntityRef_Direct : constant unsigned := 1;
   CXIdxEntityRef_Implicit : constant unsigned := 2;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6355

   subtype CXSymbolRole is unsigned;
   CXSymbolRole_None : constant unsigned := 0;
   CXSymbolRole_Declaration : constant unsigned := 1;
   CXSymbolRole_Definition : constant unsigned := 2;
   CXSymbolRole_Reference : constant unsigned := 4;
   CXSymbolRole_Read : constant unsigned := 8;
   CXSymbolRole_Write : constant unsigned := 16;
   CXSymbolRole_Call : constant unsigned := 32;
   CXSymbolRole_Dynamic : constant unsigned := 64;
   CXSymbolRole_AddressOf : constant unsigned := 128;
   CXSymbolRole_Implicit : constant unsigned := 256;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6374

   --  skipped anonymous struct anon_41

   type CXIdxEntityRefInfo is record
      kind : aliased CXIdxEntityRefKind;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6380
      cursor : aliased CXCursor;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6384
      loc : aliased CXIdxLoc;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6385
      referencedEntity : access constant CXIdxEntityInfo;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6389
      parentEntity : access constant CXIdxEntityInfo;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6401
      container : access constant CXIdxContainerInfo;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6405
      role : aliased CXSymbolRole;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6409
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6410

   --  skipped anonymous struct anon_42

   type IndexerCallbacks is record
      abortQuery : access function (arg1 : CXClientData; arg2 : System.Address) return int;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6421
      diagnostic : access procedure
           (arg1 : CXClientData;
            arg2 : CXDiagnosticSet;
            arg3 : System.Address);  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6427
      enteredMainFile : access function
           (arg1 : CXClientData;
            arg2 : CXFile;
            arg3 : System.Address) return CXIdxClientFile;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6430
      ppIncludedFile : access function (arg1 : CXClientData; arg2 : access constant CXIdxIncludedFileInfo) return CXIdxClientFile;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6436
      importedASTFile : access function (arg1 : CXClientData; arg2 : access constant CXIdxImportedASTFileInfo) return CXIdxClientASTFile;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6447
      startedTranslationUnit : access function (arg1 : CXClientData; arg2 : System.Address) return CXIdxClientContainer;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6453
      indexDeclaration : access procedure (arg1 : CXClientData; arg2 : access constant CXIdxDeclInfo);  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6456
      indexEntityReference : access procedure (arg1 : CXClientData; arg2 : access constant CXIdxEntityRefInfo);  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6462
   end record
   with Convention => C_Pass_By_Copy;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6464

   function clang_index_isEntityObjCContainerKind (arg1 : CXIdxEntityKind) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6466
   with Import => True, 
        Convention => C, 
        External_Name => "clang_index_isEntityObjCContainerKind";

   function clang_index_getObjCContainerDeclInfo (arg1 : access constant CXIdxDeclInfo) return access constant CXIdxObjCContainerDeclInfo  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6468
   with Import => True, 
        Convention => C, 
        External_Name => "clang_index_getObjCContainerDeclInfo";

   function clang_index_getObjCInterfaceDeclInfo (arg1 : access constant CXIdxDeclInfo) return access constant CXIdxObjCInterfaceDeclInfo  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6471
   with Import => True, 
        Convention => C, 
        External_Name => "clang_index_getObjCInterfaceDeclInfo";

   function clang_index_getObjCCategoryDeclInfo (arg1 : access constant CXIdxDeclInfo) return access constant CXIdxObjCCategoryDeclInfo  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6475
   with Import => True, 
        Convention => C, 
        External_Name => "clang_index_getObjCCategoryDeclInfo";

   function clang_index_getObjCProtocolRefListInfo (arg1 : access constant CXIdxDeclInfo) return access constant CXIdxObjCProtocolRefListInfo  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6478
   with Import => True, 
        Convention => C, 
        External_Name => "clang_index_getObjCProtocolRefListInfo";

   function clang_index_getObjCPropertyDeclInfo (arg1 : access constant CXIdxDeclInfo) return access constant CXIdxObjCPropertyDeclInfo  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6481
   with Import => True, 
        Convention => C, 
        External_Name => "clang_index_getObjCPropertyDeclInfo";

   function clang_index_getIBOutletCollectionAttrInfo (arg1 : access constant CXIdxAttrInfo) return access constant CXIdxIBOutletCollectionAttrInfo  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6484
   with Import => True, 
        Convention => C, 
        External_Name => "clang_index_getIBOutletCollectionAttrInfo";

   function clang_index_getCXXClassDeclInfo (arg1 : access constant CXIdxDeclInfo) return access constant CXIdxCXXClassDeclInfo  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6487
   with Import => True, 
        Convention => C, 
        External_Name => "clang_index_getCXXClassDeclInfo";

   function clang_index_getClientContainer (arg1 : access constant CXIdxContainerInfo) return CXIdxClientContainer  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6494
   with Import => True, 
        Convention => C, 
        External_Name => "clang_index_getClientContainer";

   procedure clang_index_setClientContainer (arg1 : access constant CXIdxContainerInfo; arg2 : CXIdxClientContainer)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6501
   with Import => True, 
        Convention => C, 
        External_Name => "clang_index_setClientContainer";

   function clang_index_getClientEntity (arg1 : access constant CXIdxEntityInfo) return CXIdxClientEntity  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6507
   with Import => True, 
        Convention => C, 
        External_Name => "clang_index_getClientEntity";

   procedure clang_index_setClientEntity (arg1 : access constant CXIdxEntityInfo; arg2 : CXIdxClientEntity)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6513
   with Import => True, 
        Convention => C, 
        External_Name => "clang_index_setClientEntity";

   type CXIndexAction is new System.Address;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6519

   function clang_IndexAction_create (CIdx : CXIndex) return CXIndexAction  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6527
   with Import => True, 
        Convention => C, 
        External_Name => "clang_IndexAction_create";

   procedure clang_IndexAction_dispose (arg1 : CXIndexAction)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6535
   with Import => True, 
        Convention => C, 
        External_Name => "clang_IndexAction_dispose";

   subtype CXIndexOptFlags is unsigned;
   CXIndexOpt_None : constant unsigned := 0;
   CXIndexOpt_SuppressRedundantRefs : constant unsigned := 1;
   CXIndexOpt_IndexFunctionLocalSymbols : constant unsigned := 2;
   CXIndexOpt_IndexImplicitTemplateInstantiations : constant unsigned := 4;
   CXIndexOpt_SuppressWarnings : constant unsigned := 8;
   CXIndexOpt_SkipParsedBodiesInSession : constant unsigned := 16;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6574

   function clang_indexSourceFile
     (arg1 : CXIndexAction;
      client_data : CXClientData;
      index_callbacks : access IndexerCallbacks;
      index_callbacks_size : unsigned;
      index_options : unsigned;
      source_filename : Interfaces.C.Strings.chars_ptr;
      command_line_args : System.Address;
      num_command_line_args : int;
      unsaved_files : access CXUnsavedFile;
      num_unsaved_files : unsigned;
      out_TU : System.Address;
      TU_options : unsigned) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6601
   with Import => True, 
        Convention => C, 
        External_Name => "clang_indexSourceFile";

   function clang_indexSourceFileFullArgv
     (arg1 : CXIndexAction;
      client_data : CXClientData;
      index_callbacks : access IndexerCallbacks;
      index_callbacks_size : unsigned;
      index_options : unsigned;
      source_filename : Interfaces.C.Strings.chars_ptr;
      command_line_args : System.Address;
      num_command_line_args : int;
      unsaved_files : access CXUnsavedFile;
      num_unsaved_files : unsigned;
      out_TU : System.Address;
      TU_options : unsigned) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6619
   with Import => True, 
        Convention => C, 
        External_Name => "clang_indexSourceFileFullArgv";

   function clang_indexTranslationUnit
     (arg1 : CXIndexAction;
      client_data : CXClientData;
      index_callbacks : access IndexerCallbacks;
      index_callbacks_size : unsigned;
      index_options : unsigned;
      arg6 : CXTranslationUnit) return int  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6642
   with Import => True, 
        Convention => C, 
        External_Name => "clang_indexTranslationUnit";

   procedure clang_indexLoc_getFileLocation
     (loc : CXIdxLoc;
      indexFile : System.Address;
      file : System.Address;
      line : access unsigned;
      column : access unsigned;
      offset : access unsigned)  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6657
   with Import => True, 
        Convention => C, 
        External_Name => "clang_indexLoc_getFileLocation";

   function clang_indexLoc_getCXSourceLocation (loc : CXIdxLoc) return CXSourceLocation  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6668
   with Import => True, 
        Convention => C, 
        External_Name => "clang_indexLoc_getCXSourceLocation";

   type CXFieldVisitor is access function (arg1 : CXCursor; arg2 : CXClientData) return CXVisitorResult
   with Convention => C;  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6681

   function clang_Type_visitFields
     (T : CXType;
      visitor : CXFieldVisitor;
      client_data : CXClientData) return unsigned  -- /export/work/reznik/ancr/src/gps/libclang/cfe-8.0.0.src/include/clang-c/Index.h:6703
   with Import => True, 
        Convention => C, 
        External_Name => "clang_Type_visitFields";

end clang_c_Index_h;
