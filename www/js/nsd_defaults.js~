/**Definition of the Step "Defaults" from the new source dialog*/


(function() {
	//Private Attributes
	var panel;
	var label = "Desfaults";
	var id = "defaults";
	
	//DOM REFERENCES
	var dialog;
	var table;
	var tbody;
	
	
	//Private Methods
	var createPanel = function() {
		panel = $('<div class="body"/>');
		var fs = $('<fieldset class="defaults"><legend alt="Set the default values to be applied to the das source">Defaults</legend></fieldset>').appendTo(panel);
		table = $('<table class="defaults_table preview_table">').appendTo(fs);
		table.append('<thead><tr><th>Field</th><th>Condition</th><th>Value</th></tr></thead>');
		tbody = $('<tbody />').appendTo(table);
		
		//Add the data to the table
		var data = dialog.metadata.defaults;
		for (var nline = 0, ndata = data.length; nline < ndata; nline++) {
			addRow(data[nline]);
			
		}
		fs.append(table);
		var addrow = $('<div class="add_default link_like">Add a row...</div>').click(addRow).appendTo(fs); 
	};
	
	var conditions = [{id: 'is_empty',name: "is empty"},
					  {id: 'always',name: "always"},
				];
	
	var addRow = function(def){
		var tr = $('<tr />');
		tr.append('<td>'+easyDAS.UI.easyDASFieldsSelector({cls: ['default_field'], selected: def.field, add_none: true})+'</td>');
                tr.append('<td>'+easyDAS.UI.selector({cls: ['default_condition'], selected: def.condition, options: conditions})+'</td>');
		tr.append('<td><input class="default_value" value="'+((def.value)?def.value:'')+'"></input></td>');		
		tbody.append(tr);

	};

	var addDefaultsRow = function() {
		addRow({field: 'none', condition: conditions[0].id, value: ''});
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
			//The panel should be recreated everytime, since creation is where data is set.
			//if(!panel) {
				dialog = _dialog;
				createPanel();
			//}
			return panel;
		},
		initPanel: function(metadata) {
			//Do nothing, tha panel is initialized on creation
		},
		getPanelData: function(metadata) {
			var new_defaults = [];
			//for each row in the defaults table, read it
			$('tr', tbody).each(function(i, el){
				if ($('.default_field', el).val() != 'none') {
					new_defaults.push({
						"value": $('.default_value', el).val(),
						"field": $('.default_field', el).val(),
						"condition": $('.default_condition', el).val()
					});
				}
			});
			dialog.metadata.defaults = new_defaults;			
		}
	}
	
	easyDAS.NewSourceDialog.Steps[id] = self;
}());
