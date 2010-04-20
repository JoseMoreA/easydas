/**Definition of the Step "Upload" from the new source dialog*/


(function() {
	//Private Attributes
	var panel;
	var label = "";
	var id;
	
	var dialog;
	
	//Private Methods
	var createPanel = function() {
		panel = $('<div class="body"/>');
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
			return panel;
		},
		initPanel: function(metadata) {
			
		},
		getPanelData: function(metadata) {
			
			
		}
	}
	
	easyDAS.NewSourceDialog.Steps[id] = self;
}());
