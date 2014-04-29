"""
This plug-in adds support for GMC (the GNAT Modeling Compiler) which generates
Ada (SPARK 2014?) and C code from Simulink models.

=========================================
THIS IS WORK IN PROGRESS
As it is this module does not perform anything useful. It defines
the Simulink language, which you can use in your project, but expects
.mdl files to be a JSON definition compatible with
GPS.Browsers.Diagram.load_json. The JSON is loaded into a browser when
you open a .mdl file, for instance from the Project view.
=========================================

"""

import GPS
import GPS.Browsers
import gps_utils
import modules
import os.path
import os_utils
import re
import json

#############
# Constants #
#############

block_start = "Block (\w_)+(/(\w_)+)*"
block_end = "End " + block_start
# Annotation patterns for a block id

gmc_name = "gmc"
# The name of the GMC executable

gmc_exec = os_utils.locate_exec_on_path(gmc_name)
# The GMC executable

header = "Copyright (C) Project P Consortium"
# A predefined header which tags each generated file

languages = ["ada", "c"]
# The target languages currently supported by GMC

###############
# Definitions #
###############

# Matlab and Simulink languages

language_defs = r"""<?xml version='1.0' ?>
  <GPS>
    <Language>
      <Name>Matlab</Name>
      <Body_Suffix>.m</Body_Suffix>
      <Obj_Suffix>-</Obj_Suffix>
    </Language>
    <Language>
      <Name>Simulink</Name>
      <Body_Suffix>.mdl</Body_Suffix>
      <Obj_Suffix>-</Obj_Suffix>
    </Language>
  </GPS>"""

GPS.parse_xml(language_defs)

# Various project-related attributes

project_defs = """<?xml version='1.0' ?>
  <GPS>
    <project_attribute
     package="GMC"
     name="Source_Model"
     editor_page="GMC"
     label="Source model"
     description="The Simulink model to compile and view"
     hide_in="wizard library_wizard">
       <string type="file" filter="project"/>
    </project_attribute>

    <project_attribute
     package="GMC"
     name="Output_Dir"
     editor_page="GMC"
     label="Output directory"
     description="The location of all generated files"
     hide_in="wizard library_wizard">
       <string type="directory"/>
    </project_attribute>

    <tool
     name="GMC"
     package="GMC"
     index="Simulink">
      <language>Simulink</language>
      <switches lines="3">
        <title line="1">Files</title>
        <title line="2">Generation</title>
        <title line="3">Output</title>

        <field
         line="1"
         label="Matlab file"
         switch="-m"
         separator=" "
         as-file="true"
         tip="Provides variable declarations of the Matlab workspace"/>
        <field
         line="1"
         label="Decoration file"
         switch="-t"
         separator=" "
         as-file="true"
         tip="Provides Simulink block typing information"/>
        <field
         line="1"
         label="Reference file"
         switch="-b"
         separator=" "
         as-file="true"
         tip="Ask Matteo"/>

        <combo
         line="2"
         label="Target language"
         switch="-l"
         separator=" "
         tip="The language used by GMC to produce the generated files">
           <combo-entry label="Ada" value="ada"/>
           <combo-entry label="C" value="c"/>
        </combo>
        <check
         line="2"
         label="Flatten model"
         switch="--full-flatten"
         tip="Ask Matteo"/>

        <radio line="3">
          <radio-entry
           label="Delete"
           switch="-c"
           tip="Delete contents of output directory between compilations"/>
          <radio-entry
           label="Preserve"
           switch="-i"
           tip="Preserve contents of output directory between compilations"/>
        </radio>
      </switches>
    </tool>
  </GPS>
"""


class GMC_Diagram(GPS.Browsers.Diagram):
    def on_selection_changed(self, item, *args):
        if item is None:
            GPS.Console().write("clear selection\n")
        else:
            GPS.Console().write(
                "selection_changed item=%s selected=%s\n" % (
                    item, self.is_selected(item=item)))


class GMC_Diagram_View(GPS.Browsers.View):
    def __init__(self, file, module):
        """
        A browser that shows the contents of a simulink file.
        :param GPS.File file: the file associated with the browser.
        :param modules.Module module: the module
        """
        self.file = file
        diagrams = GPS.Browsers.Diagram.load_json(
            file.name(), diagramFactory=GMC_Diagram)
        self.create(
            diagrams[0],
            title=os.path.basename(file.name()),
            save_desktop=module._save_desktop)
        self.set_read_only(True)
        self.set_background(
            GPS.Browsers.View.Background.GRID,
            GPS.Browsers.Style(stroke="rgba(200,200,200,0.8)"))
        self.scale_to_fit(max_scale=1.0)

    def on_item_clicked(self, topitem, item, x, y, *args):
        GPS.Console().write(
            "clicked on %s (%s), at %s,%s\n" % (topitem, item, x, y))

    def on_item_double_clicked(self, topitem, item, x, y, *args):
        GPS.Console().write(
            "double_clicked on %s (%s), at %s,%s\n" % (topitem, item, x, y))

    def on_create_context(self, context, topitem, item, x, y, *args):
        GPS.Console().write(
            "create_context on %s (%s), at %s,%s\n" % (topitem, item, x, y))
        context._simulink_item = item

    def on_key(self, topitem, item, key, *args):
        GPS.Console().write("key on %s (%s): %s\n" % (topitem, item, key))


class GMC_Module(modules.Module):

    # fl_to_obj_map
    #    type : dictionary
    #    key  : GPS.File - a generated file
    #    value: dictionary
    #       key  : integer - line number
    #       value: list
    #          element: GPS.Browsers.View.Item - a graphical object
    # File-by-file, line-by-line map which links source code to corresponding
    # graphical objects.

    # gen_files
    #    type   : list
    #    element: GPS.File - a generated file
    # List of all generated files in a particular target language pertaning to
    # a model.

    # lang_info
    #    type : dictionary
    #    key  : String - the target language
    #    value: Language
    # Table of target language-specific information

    # MDL_file
    #    type: GPS.File
    # The current model file being navigated

    # obj_to_fl_map
    #    type : dictionary
    #    key  : GPS.Browsers.View.Item - a graphical object
    #    value: dictionary
    #       key  : GPS.File  - generated file
    #       value: list
    #          element: integer - line number
    # Graphical object to file-by-file, line-by-line map

    def __add_fl_to_obj_entry(self, gen_file, line_num, graph_obj):
        """
        Add a single entry in map fl_to_obj.
        :param GPS.File gen_file: a generated file
        :param integer line_num: the current line in the generated file
        :param GPS.Browsers.View.Item graph_obj: a graphical object
        """
        # Ensure that all parts of map fl_to_obj are initialized

        if not fl_to_obj_map:
            fl_to_obj_map = {}

        if gen_file not in fl_to_obj_map:
            fl_to_obj_map[gen_file] = {}

        if line_num not in fl_to_obj_map[gen_file]:
            fl_to_obj_map[gen_file][line_num] = ()

        # Create a new entry

        fl_to_obj_mal[gen_file][line_num].append(graph_obj)

    def __add_obj_to_fl_entry(self, gen_file, line_num, graph_obj):
        """
        Add a single entry in map obj_to_fl.
        :param GPS.File gen_file: a generated file
        :param integer line_num: the current line in the generated file
        :param GPS.Browsers.View.Item graph_obj: a graphical object
        """
        # Ensure that all parts of map obj_to_fl are initialized

        if not obj_to_fl_map:
            obj_to_fl_map = {}

        if graph_obj not in obj_to_fl_map:
            obj_to_fl_map[graph_obj] = {}

        if gen_file not in obj_to_fl_map[graph_obj]:
            obj_to_fl_map[graph_obj][gen_file] = ()

        # Create a new entry

        obj_to_fl_map[graph_obj][gen_file].append(line_num)

    def __build_language_info(self):
        """
        Create a repository of target language-specific information. This data
        is used in detecting generated files and parse block annotations.
        """
        self.lang_info = {
            "ada": Language("ada", "--", ""),
            "c": Language("c", "/*", "*/")}

    def __build_navigation_maps(self):
        """
        Establish the mapping between graphical objects and source locations in
        generated files. The resulting maps are the core of editor and diagram
        navigation.
        """
        def build_id_to_obj_map():
            """
            Establish a mapping between block ids and graphical objects.
            :return dictionary: a mapping between String block ids to
                GPS.Browsers.View.Item.
            """
            pass

        def build_navigation_map(gen_file, id_to_obj_map):
            """
            Establish the mapping between graphical objects and source
            locations in a single generated file.
            :param GPS.File: a generated file
            :param dictionary: a mapping between String block ids to
                GPS.Browsers.View.Item.
            """
            # Local declarations

            graph_objs = []
            # List of graphical objects currently visible from the stand point
            # of a source code line. The list is maintained in a stack-like
            # fasion.

            # Remove all previous entries from the two maps concerning the
            # generated file as they will be replaced with new ones.

            fl_to_obj_map[gen_file] = None
            for item in obj_to_fl_map:
                if file in obj_to_fl_map[item]:
                    obj_to_fl_map[item][file] = None

            # Open the generated file and parse its contents. For each block
            # annotation, create a mapping of the form:
            #
            #    file, line => graphical object
            #    graphical object => file, line
            #
            # For a single non-empty source code line, create a mapping of the
            # form:
            #
            #    file, line => graphical object 1, graphical object N

            lang = lang_info[gen_file.language()]
            line_num = 0

            phys_file = open(gen_file.name())
            for line in phys_file:
                line_num = line_num + 1

                is_start_annot = lang.__is_block_start_annot(line)
                is_end_annot = lang.__is_block_end_annot(line)

                # The current line denotes a block annotation

                if is_start_annot and is_end_annot:
                    graph_obj = id_to_obj_map[lang.__block_id(line)]

                    # Add entries in both maps

                    self.__add_fl_to_obj_entry(gen_file, line_num, graph_obj)
                    self.__add_obj_to_fl_entry(gen_file, line_num, graph_obj)

                    # A source code line may be associated with several blocks
                    # in which case it must be mapped to all the relevant
                    # graphical objects.
                    #
                    #    <Block 1>
                    #    <Block 2>
                    #    source code line - associated with Block 1 and 2
                    #    <End Block 2>
                    #    source code line - associated with Block 1
                    #    <End Block 1>
                    #
                    # To accomodate this, graphical objects are maintained in a
                    # local stack-line list.

                    if is_start_annot:
                        if not graph_obj in graph_objs:
                            graph_objs.append(graph_obj)

                    else:
                        if graph_obj in graph_objs:
                            graph_objs.remove(graph_obj)

                # Otherwise the current line denotes a source statement, a
                # comment or a blank line. Either way, the line is mapped to
                # all of the graphical objects which correspond to open blocks.

                else:
                    for graph_obj in graph_objs:
                        self.__add_fl_to_obj_entry(
                            gen_file, line_num, graph_obj)

            close(phys_file)

        # Start of processing for __build_navigation_maps

        # The navigation maps are populated only when GMC already compiled the
        # model file and GPS is displaying the visual equivalent of the model.

        if self.gen_files and self.__diagram_view():
            id_to_obj_map = build_id_to_obj_map

            for gen_file in gen_files:
                if self.__present(gen_file):
                    build_navigation_map(gen_file, id_to_obj_map)

    def __compile_MDL(self, MDL_file):
        """
        Compile a model file with GMC to generate source files in a particular
        target language.
        :param GPS.File MDL_file: the model file to be compiled
        """
        # Compile the file when it is physically present on disk

        if self.__present(MDL_file):
            self.MDL_file = MDL_file

    def contextual_filter(self, context):
        """
        A filter that can be used to decide whether to display a contextual
        menu entry. It only does so when the contextual menu is for a simulink
        browser.
        """
        return hasattr(context, "_simulink_item")

    def __diagram_viewer(self):
        """
        Obtain the diagram viewer in charge of visualizing a model.
        :return GMC_Diagram_View:
        """
        # Return the diagram viewer displaying the current model file

        if self.MDI_file:
            return GPS.MDI.get(self.MDI_file.name())

        return None

    def __handle_editor_event(self):
        """
        Process an editor event and perform the appropriate navigation action
        if applicable.
        """
        pass

    def __handle_viewer_event(self):
        """
        Process a diagram viewer event and perform the appropriate navigation
        action if applicable.
        """
        pass

    def load_desktop(self, view, data):
        try:
            info = json.loads(data)
            if not isinstance(info, dict):
                return None
        except:
            return None

        v = GMC_Diagram_View(file=GPS.File(info["file"]), module=self)
        v.scale = info["scale"]
        v.topleft = info["topleft"]

        return GPS.MDI.get_by_child(v)

    def __on_open_file_action_hook(self, hook, file, *args):
        """Handles "open file" events"""
        if file.language() == 'simulink':
            v = GMC_Diagram_View(file=file, module=self)
            return True
        return False

    def __present(self, file):
        """
        Determine whether a file is physically present on disk. If this is not
        the case, issue an error dialog.
        :param GPS.File file: the file to be tested
        :return Boolean:
        """
        if os.path.exists(file.name()):
            return True

        # ??? produce a dialog here ???
        return False

    def save_desktop(self, child):
        view = child.get_child()
        info = {"file": view.file.name(),
                "scale": view.scale,
                "topleft": view.topleft}
        return json.dumps(info)

    def setup(self):
        """
        Setup the module only when the GMC executable is available on the path.
        This action registeres the Matlab and Simulink languages along with the
        various project attributes.
        """
        if gmc_exec:
            GPS.parse_xml(project_defs)

            GPS.Hook('open_file_action_hook').add(
                self.__on_open_file_action_hook, last=False)

            self.__build_language_info()

            gps_utils.make_interactive(
                callback=self.show_source_for_item,
                filter=self.contextual_filter,
                name='simulink show source for item',
                contextual='Simulink/Show source')

    def show_source_for_item(self):
        """
        A callback for a contextual menu
        """
        GPS.Console().write('Showing source code is not implemented yet\n')

    def __visualize_MDL(self, MDL_file):
        """
        Create the visual representation of a model file.
        :param GPS.File MDL_file: the model file to visualize
        """
        pass


class Language:

    # block_end
    #    type: String
    # A regexp denoting the end of a block annotation

    # block_start
    #    type: String
    # A regexp denoting the start of a block annotation

    # header
    #    type: String
    # A header annotation which appears at the beginning of each generated file

    # name
    #    type: String
    # The name of the language

    def __init__(self, name, comment_start, comment_end):
        """
        Construct a new language characterized by various attributes.
        :param String name: the name of the language
        :param String comment_start: the prefix of a comment
        :param String comment_end: the suffix of a comment
        """
        ce = " " + comment_end
        cs = comment_start + " "

        self.name = name
        self.header = cs + header + ce
        self.block_start = cs + block_start + ce
        self.block_end = cs + block_end + ce

    def __block_id(self, line):
        """
        Extract the id of a block from a line that denotes a block annotation.
        :param String line: a line denoting a block annotation
        :return String: the id of the block
        """
        return re.match(block_start, line)

    def __is_block_end_annot(self, line):
        """
        Determine whether a line denotes the end of a block annotation.
        :param String line: the line to test
        :return Boolean:
        """
        return re.match(block_end, line) is not None

    def __is_block_start_annot(self, line):
        """
        Determine whether a line denotes the beginning of a block annotation.
        :param String line: the line to test
        :return: Boolean
        """
        return re.match(block_start, line) is not None
