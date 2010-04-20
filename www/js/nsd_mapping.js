/**Definition of the Step "Mapping" from the new source dialog*/


(function() {
	//Private Attributes
	var panel;
	var label = "Mapping";
	var id = "mapping";
	
	var dialog;
	
	var help = easyDAS.Help.tooltipButtonHTML; //the function to add help to the elements
	
	//Private Methods
	var createPanel = function() {
		panel = $('<div class="body"/>');
		panel.append('<p class="help_text">Please specify the mapping between you data and the DAS concepts</p>');
		
		mapping_form = $(mappingFormHTML());
		panel.append(mapping_form);
		
		//initialize the form
		//$('#define_source_form #num_data_lines', mapping_form).values(dialog.metadata.parsing); //set the number oflines value
		//initialize the add select buttons.
		$('.add_data_field_selector', mapping_form).click(function(event, element){
			$(event.target).parent().children('select:first').clone().insertBefore(event.target); //clone the select
		});
		
	};
	
	
	//Mapping creation
	/**  Mapping  **/
	var mappingFormHTML = function(){
		var metadata = dialog.metadata;
		//create the interface to map metadata->parsing->data_fields to easyDAS->config->FeatureDataFields
		var map = metadata.parsing.mapping;
		var mapping = '<fieldset id="data_mapping_form" class="scrolling mapping">\
							   <legend alt="Assign your variables to its corresponding easyDAS fields">Data Mapping</legend>';
		//mapping += '<p><label for="num_data_lines">Lines to show: </label>'+help('mapping_num_lines')+'<input id="num_data_lines" name="num_data_lines" size="5" class="required number"/><button class="define_source_update">Apply</button></p>';
		
		mapping += '<table class="preview_table">';
		var fields = metadata.parsing.data_fields;
		var len = fields.length;
		//create the table header
		mapping += '<thead><tr>';
		for (var i = 0; i < len; i++) {
			mapping += '<th>' + fields[i].name + '</th>';
		}
		mapping += '</tr>';
		//create the selectors line
		//TODO: What if there's more than one mapping or the same data
		mapping += '<tr>';
		for (var i = 0; i < len; i++) {
			mapping += '<th class="selector_cell">' + createMappingSelectors(metadata, i) + '<br><span class="add_data_field_selector link_like">add...</span></th>';
		}
		mapping += '</tr></thead>';
		
		mapping += '<tbody>'
		//And add the sample data
		var data = metadata.parsing.data;
		for (var nline = 0, ndata = data.length; nline < ndata; nline++) {
			mapping += '<tr>';
			for (var i = 0; i < len; i++) {
				mapping += '<td>' + data[nline][i] + '</td>';
			}
			mapping += '</tr>';
		}
		mapping +='</tbody>';
		mapping += '</table>';
		mapping += '</fieldset>';
		return mapping;
	};
	
	var findDataFields = function(fields, data_field) {
		var found = false, map = [];
		for(i=0, l=fields.length; i<l; i++) {
			if(fields[i].data_field == data_field) {
				map[map.length] = fields[i].easyDAS_field;
			}
		}
		return map;
	};
	var selectedOption = function(fields, option) {
		var found = false, pos = -1;
		for(i=0, l=fields.length; !found && i<l; i++) {
			if(fields[i].id == option) {
				found = true;
				pos = i;
			}
		}
		return pos;
	};
	var getFeatureDataFieldsSelector = function(metadata, data_field_num, selected) {
		var f = metadata.easyDAS_fields;
		var selected_option = (selected?selectedOption(f, selected):-1)
		var select = '<select class="data_field_selector" data_field="'+data_field_num+'">';
		select += '<option value="none" '+(selected_option!=-1?'':'selected="true"')+'>None</option>';
		for(var i= 0, l=f.length; i<l; i++) {
			select += '<option value="'+f[i].id+'" '+(selected_option==i?'selected="true"':'')+'>'+f[i].name+'</option>';
		}
		select += '</select>';
		return select;
			
	};
	var createMappingSelectors = function(metadata, num_field) {
		var easyDAS_fields = findDataFields(metadata.parsing.mapping, num_field);
		var html = "";
		if(easyDAS_fields.length > 0) {
			for(var f=0; f<easyDAS_fields.length; f++) {
				html += getFeatureDataFieldsSelector(metadata, num_field, easyDAS_fields[f]);		
			}
		} else {
			html += getFeatureDataFieldsSelector(metadata, num_field);
		}
		return html;
	};
	
	
	var compare = function(old_data, new_data, field_name){
		if (old_data[field_name] != new_data[field_name]) {
			old_data[field_name] = new_data[field_name];
			old_data["forced_" + field_name] = 1;
		}
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
			//if(!panel) { recreate the form from scratch
			
				dialog = _dialog;
				createPanel();
			//}
			dialog.canFinish(true);
			return panel;
		},
		initPanel: function() {
			
		},
		
		getPanelData: function() {
			var metadata = dialog.metadata;
			var new_data = $("#define_source_form #data_mapping_form", panel).values();
			//compare each value to mark it as user forced
			compare(metadata.parsing, new_data, "num_data_lines");
			//get the mapping info
			var new_mapping = [];
			$('.data_field_selector', panel).each(function(i, el){
				if ($(el).val() != 'none') { //the 'none' selectors will be ignored
					new_mapping.push({
						"easyDAS_field": $(el).val(),
						"data_field": parseInt($(el).attr('data_field'))
					})
				}
			});
			metadata.parsing.mapping = new_mapping;
					
		}
	}
	
	easyDAS.NewSourceDialog.Steps[id] = self;
}());
