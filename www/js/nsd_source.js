/**Definition of the Step "Upload" from the new source dialog*/


(function() {
	//Private Attributes
	var panel;
	var label = "Source";
	var id = 'source';

	var dialog;
	
	var form;
	
	var help = easyDAS.Help.tooltipButtonHTML; //the function to add help to the elements
	
	//DOM REFERENCES
	var source_name_input,
		source_title_input,
		source_mantainer_input,
		source_description_input,
		source_doc_href_input,
		source_coordinates_button,
		source_coordinates_info;

	
	//Private Methods
	var createPanel = function() {
		panel = $('<div class="body"/>');
		source_name_input = $('<input id="source_name_input" name="source_name" size="25" class="required" />');
		var s_name = $('<p><label for="source_name">Name<span class="star">*</span></label></p>')
			.append(source_name_input)
			.append(help('define_source_name'));
		source_title_input = $('<input id="source_title_input" name="source_title" size="25" class="required" />');
		var s_title = $('<p><label for="source_title">Title<span class="star">*</span></label></p>')
			.append(source_title_input)
			.append(help('define_source_title'));
		source_mantainer_input = $('<input id="source_mantainer_input" name="source_mantainer" size="25" class="required email" />');
		var s_mantainer = $('<p><label for="source_mantainer">Maintainer<span class="star">*</span></label></p>')
			.append(source_mantainer_input)
			.append(help('define_source_mantainer'));
		source_description_input = $('<textarea id="source_description_input" name="source_description" cols="25" class="" />');
		var s_description = $('<p><label for="source_description">Description</label></p>')
			.append(source_description_input)
			.append(help('define_source_description'));
		source_doc_href_input = $('<input id="source_doc_href_input" name="source_doc_href" size="25" class="" />');
		var s_doc_href = $('<p><label for="source_doc_href">More Information URL</label></p>')
			.append(source_doc_href_input)
			.append(help('define_source_name'));

		source_coordinates_button = $('<div class="edit_button edit_coordinates" />');
		source_coordinates_info = $('<span id="source_coordinates" class="" >Not Specified</span>');
		var s_coordinates = $('<p><label for="source_doc_href">Coordinates System</label></p>')
			.append(source_coordinates_button)
			.append(source_coordinates_info)
			.append(help('define_source_coordinates'));
		
		
		form = $('<form />').appendTo(panel);
		var fs = $('<fieldset class="aligned_fields"><legend>Source Information</legend></fieldset>').appendTo(form);
		
		fs.append(s_name)
			 .append(s_title)
			 .append(s_mantainer)
			 .append(s_doc_href)
			 .append(s_description)
			 .append(s_coordinates);
		
		 	
	};
	
	
	var compare = function(old_data, new_data, field_name){
		if (old_data[field_name] != new_data[field_name]) {
			old_data[field_name] = new_data[field_name];
			old_data["forced_" + field_name] = 1;
		}
	};
	
	var checkCoordinates = function() {
		var ok = true;
		if(!source_coordinates_info.data('coordSys')) {
			ok = confirm("No coordinates system has been selected for this source. While the coordinates system is not required, specifying it ensures that the source will be easy to integrate with other data sources. Do you want to continue without a coordinate sytem?");
		}
		return ok;
	};
	
	
	var self = {
		//Public Attributes
		
		
		//Public Methods
		id: function() {
			return id;
		},
		label: function() {
			return label;
		},
		getPanel: function(_dialog) {
			if(!panel) {
				createPanel();
				dialog = _dialog;
			}
			self.initPanel();
			return panel;
		},
		initPanel: function(metadata) {
			form.validate();
			self.setPanelData();

			//It shouldn't be necessary to repeat that binding, but is seems like it's getting lost
			source_coordinates_button.click(function(){
					easyDAS.coordinatesSelector.show(source_coordinates_info.val(), function(coordSys){
						source_coordinates_info.data('coordSys', coordSys);
						source_coordinates_info.html(coordSys.content);
					});
					var offset = source_coordinates_button.offset();
					easyDAS.coordinatesSelector.center();
					
				});
								
			
		},
		setPanelData: function(){
			panel.values(dialog.metadata.source);
		},
		getPanelData: function(metadata) {
			if (form.valid() && checkCoordinates()) {
				var new_data = panel.values();
				//compare each value to mark it as user forced
				compare(dialog.metadata.source, new_data, "source_name");
				compare(dialog.metadata.source, new_data, "source_title");
				compare(dialog.metadata.source, new_data, "source_mantainer");
				compare(dialog.metadata.source, new_data, "source_description");
				compare(dialog.metadata.source, new_data, "source_doc_href");
				dialog.metadata.source.coordinates_system = source_coordinates_info.data('coordSys'); //Get the coordiates system info
			} else {
				return 'no_valid';
			}			
		}
	}
	
	easyDAS.NewSourceDialog.Steps[id] = self;
}());
