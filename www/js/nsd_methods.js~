/**Definition of the Step "Methods" from the new source dialog*/


(function() {
	//Private Attributes
	var panel;
	var label = "Methods";
	var id = 'methods';
	
	var ontology = 'ECO';

	var dialog;
	
	var termSelector = easyDAS.ontologyPicker(ontology); //a reference to the ontologyPicker
	
	//DOM REFS
	var table;
	
	//Private Methods
	var createPanel = function() {
		panel = $('<div class="body"/>');
		
		//create an interface to add the methods information
		var fs = $('<fieldset class="types"><legend alt="Assign ontology terms to types">Methods</legend></fieldset>').appendTo(panel);
		table = $('<table class="preview_table table">');
		table.append('<thead><tr><th colspan=2>Identifier</th><th>Label</th><th>CV Id</th></tr></thead>');
		var tbody = $('<tbody />').appendTo(table);
		
		var data = dialog.metadata.methods;
		for (var nline = 0, ndata = data.length; nline < ndata; nline++) {
			tbody.append(methodHTML(data[nline]));
		}
		fs.append(table);
		
		//initialize the "edit" buttons
		$('.edit_method', table).live('click', function(event, element){
			var method_row = $(event.target).parent().parent();
			method_row.addClass("selected");
			var method = getMethodInfo(method_row);
			var buttonOffset = $(event.target).offset();
			termSelector.setPosition(buttonOffset.left + 10, buttonOffset.top + 5);
			termSelector.select(method, function(method){
				setMethodInfo(method_row, method)
				method_row.removeClass("selected");
			});
			return false;
		});
	};
	
	var methodHTML = function(method){
		var row = $('<tr />');
		row.append('<td><span class="term_id" >' + method.id + '</span></td>');
		row.append('<td class="no_left_border"><div class="edit_button edit_method" /></td>');
		row.append('<td class="fixed_width_10em"><span class="term_label">' + (method.label || '') + '</span></td>')
		row.append('<td class="fixed_width_10em"><span class="term_cvId">' + (method.cvId || '') + '</span></td>')
		return row;
	};
	
	/**This function collects the info for a method from the methods table.
	 *
	 * @param {Object} method_row - a jQuery object "pointing" at the row in the methods table
	 */
	var getMethodInfo = function(method_row){
		return {
			name: method_row.find('.term_id').text(),
			label: method_row.find('.term_label').text(),
			cvId: method_row.find('.term_cvId').text()
		}
	};
	/**This function sets the info for a method from the methods table.
	 *
	 * @param {Object} method_row - a jQuery object "pointing" at the row in the methods table
	 * @param {Object} method_info - an object containingn the info for the method (name, label and cvId)
	 */
	var setMethodInfo = function(method_row, method_info){
		method_row.find('.term_id').text(method_info.name);
		method_row.find('.term_label').text(method_info.label);
		method_row.find('.term_cvId').text(method_info.cvId);
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
				dialog = _dialog;
				createPanel();
				
			}
			return panel;
		},
		initPanel: function(metadata) {
			
		},
		getPanelData: function(){
			var new_methods = [];
			$('tbody tr', table).each(function(i, el){
				new_methods.push({
					"id": $('.term_id', el).text(),
					"label": $('.term_label', el).text(),
					"cvId": $('.term_cvId', el).text()
				})
			});
			dialog.metadata.methods = new_methods;
		}
	}
	
	easyDAS.NewSourceDialog.Steps[id] = self;
}());
