/**Definition of the Step "Upload" from the new source dialog*/


(function() {
	//Private Attributes
	var panel;
	var label = "File Type";
	var id = 'file_type';
	
	var current_format;
	

	//DOM refences
	var dialog;
	
	

	var filename;
	var file_type_selector;
	var change_filetype_button;
	var options_fieldset;
	var options_panel;
	var preview_panel;


	
	
	//Private Methods
		//HTML
					   
					   	
		//END HTML
	var createPanel = function() {
		panel = $('<div class="body"/>');
		var filefs = $('<fieldset><legend>File</legend></fieldset>').appendTo(panel);
		var filename_label = $('<p><label for="original_filename">File Name: </label><span class="file_name" name="original_filename"></span></p>').appendTo(filefs);
		filename = $('<span class="file_name" name="original_filename"></span>').appendTo(filename_label);
		var par = $('<p><label for="parser_type">File Type</label></p>')
								.appendTo(filefs);
		filetype_selector = $(easyDAS.UI.fileTypesSelector({id: 'parser_type'})).appendTo(par)
				.change(function(ev){
					current_format = ev.currentTarget.value;
					changeFileType();
		});
		//change_filetype_button = $('<button class="define_source_update">Apply</button>').appendTo(par);
		options_fieldset = $('<fieldset   disabled="disabled" ><legend>Options</legend></fieldset>').appendTo(panel);
		options_panel= $('<div />').appendTo(options_fieldset);
		
		var prev_fieldset = $('<fieldset><legend>Preview</legend></fieldset>').appendTo(panel);
		preview_panel = $('<div class="scrolling" />').appendTo(prev_fieldset);
	};
	
	var changeFileType = function() {
		//FIX: do it well
		updateOptions();
		
		//Store the old file_type metadata in "memory"
		
		//Change the file type (forced)
		dialog.metadata.forced_parser_type = filetype_selector.val();
		
		//and (if no memory available) retest
		
		updatePreview();
	};
	
	
	var createDataRow = function(data, num_cells){
		var row = $('<tr>');
		for (var i = 0, len = data.length; i < len; i++) {
			row.append('<td>' + data[i] + '</td>');
		}
		for (var j = data.length; j < num_cells; j++) {
			row.append('<td></td>');
		}
		return row;
	};
	
	var createDataHeader = function(data) {
		var row = $('<tr>');
		for (var i = 0, len = data.length; i < len; i++) {
			row.append('<th>' + data[i].name + '</th>');
		}
		return row;
	};
	
	var populatePreviewPanel = function(metadata) {
		var preview = $('<table class="preview_table" \>');
		var thead = $('<thead />').appendTo(preview);
		$(createDataHeader(metadata.parsing.data_fields)).appendTo(thead);
		var tbody = $('<tbody />').appendTo(preview);
		
		var data = metadata.parsing.data;
		for (var nline = 0, ndata = data.length; nline < ndata && nline <10; nline++) {
			tbody.append(createDataRow(data[nline], metadata.parsing.data_fields.length));
		}
		
		preview_panel.html(preview);
	};

	var updatePreview = function() {
		var metadata = dialog.metadata;

		easyDAS.markAsWaiting(preview_panel, "Reloading data...");
		
		var callback = function(metadata) {
			populatePreviewPanel(metadata);
			updateOptions();
		};
		retest(callback);		
	};


	var updateOptions = function() {
		//Check if the current filetype has options
		var format = self.FileFormats[current_format];
		if(format.hasConfig()) {
			//store the old config options, if necessary
			options_panel.html(format.getConfigForm());
			format.setFormData();
		} else {
			//if the format has no config option, disable the panel
			options_panel.html('This format have no configuration options');
			
		}
	};




	//Retest file. Send the metadata to the server to retest the file with taking any modifications made into account
	var retest = function(callback) {
		var meta = dialog.metadata;
		
		var process_response = function(data) {
			if (!data || data.error) {
				alert(data.error.msg || "An error occurred");
			}
			else {
				dialog.metadata = data;
				callback(data);
			}
		};
		var data = {
			cmd: 'retest',
			metadata: JSON.stringify(meta)
		};
		$.get('cgi-bin/easyDAS.pl', data, process_response, 'json');
	}



	
	//File type specific functions
		//helping private functions
		var getSeparatorSelector = function() {
			var opt = easyDAS.Config.CSV_Separators; //is this really config or should be stored in this file?
			var radio = $('<div />');
			for(var i=0, len=opt.length; i<len; ++i) {
				$('<input type="radio" name="separator" value="'+opt[i].id+'">'+opt[i].name+'</input>').appendTo(radio);
			}
			return radio;
		};
	
		//GFF
		var gff_config = {
			hasConfig: function() {return true;},
			getConfigForm: function() {
				//return the form to be embedded on the options panel
				var pan = $('<div\>');
				gff_config.unquote = $('<input type="checkbox" name="unquote" value="unquote">')
							.appendTo(pan)
							.change(function(ev) {
								gff_config.getFormData();
								updatePreview();
							});
				pan.append('<label for="unquote">Remove quotation marks</label>');
				return pan;
			},
			getFormData: function() {
				var meta = dialog.metadata;
				meta.parsing.remove_quotes = gff_config.unquote.is(':checked');

			},
			setFormData: function() {
				gff_config.unquote.attr('checked', dialog.metadata.parsing.remove_quotes);
			}
		};
		//CSV
		var csv_config = {
			hasConfig: function() {return true;},
			getConfigForm: function() {
				var update = function() {
					csv_config.getFormData();
					updatePreview();
				};
				//return the form to be embedded on the options panel
				var pan = $('<div\>');
				csv_config.separator = getSeparatorSelector();
				pan.append('<label for="separator">Separator: &nbsp;</label>').append(csv_config.separator);
				pan.append('<input type="checkbox" name="unquote" value="unquote"><label for="unquote">Remove quotation marks</label>');
				pan.append('<input type="checkbox" name="has_header" value="header"><label for="has_header">The first line is the headers</label>');

				pan.change(update);
				return pan;
			},
			getFormData: function() {
				var meta = dialog.metadata;
				var sep_char = $('input[name="separator"]:checked', csv_config.separator).val();

				meta.parsing.forced_separator = 1;
				meta.parsing.separator = config2server(sep_char);

			},
			setFormData: function() {
				var metadata = dialog.metadata;
				var sep = metadata.parsing.separator;
				$('input[name="separator"][value="'+server2config(sep)+'"]', csv_config.separator).attr('checked', true);
	
				
			}
		};
	

//FIX TODO: Those function translate the separator names between the server and the client. Translations are hardcoded.
	//Seperator Functions
	var config2server = function(ch) {
		switch(ch) {
			case 'comma': return ',';
			case 'semicolon': return ';';
			case 'colon': return ':';
			case 'tab': return '	';
		}
	};

	var server2config = function(ch) {
		switch(ch) {
			case ',': return 'comma';
			case ';': return 'semicolon';
			case ':': return 'colon';
			case '	': return 'tab';
		}
	};

	//** FER SERVER 2 CONFIG!
	
	
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
			return panel;
		},
		initPanel: function(_metadata) {
			dialog.metadata = _metadata;
			//FIXME: If there was no format guessing success, that's not an error. Notify it here
			current_format = dialog.metadata.parsing.parser_type;
			filename.html(dialog.metadata.original_filename);
			filetype_selector.val(current_format);
			
			updateOptions();
			updatePreview();
			
		},
		getPanelData: function() {
			return;
		},
		FileFormats: {
			'CSV': csv_config,
			'GFF': gff_config
		}
	};
	
	easyDAS.NewSourceDialog.Steps[id] = self;
}());
