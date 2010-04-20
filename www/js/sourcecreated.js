/**
 * @author bernat gel
 */

/**Contains the definition of the new DAS source dialog*/ 

var easyDAS = (easyDAS)?easyDAS:{};


(function() {
	//Private Attributes
	var dialog = undefined;
		
	
	//Private functions
	var createDialog = function() {
		dialog = easyDAS.UI.dialog({title: 'Source Created'});
		//Top Label
		
		//Buttons
		close = $('<button class="center">Close</button>').click(self.close);
		
		dialog.addButton(close);
	};

	var resetDialog = function(){
		//TODO: CHANGE!!!!!
		var metadata = self.metadata;
		var content = $('\
					<p>Source Name: <span id="use_source_name"></span></p>\
					<p>Number of Features: <span id="num_features"></span></p>\
					<p>Number of Types:<span id="num_types"></span></p>\
					<p>Number of Segments:<span id="num_segments"></span></p>\
					<p>Source URL: <span id="source_url"></span></p>\
					<p>Features Command: <span id="features_command"></span></p>\
					<p>Types Command: <span id="types_command"></span></p>\
					<p>View in: Ensembl GenExp ...</p>\
			');
		
		dialog.body(content);
			
		$('#use_source_name', content).html(metadata.source.source_name);
		$('#num_features', content).html(metadata.created_source.num_features);
		$('#num_types', content).html(metadata.created_source.num_types);
		$('#num_segments', content).html(metadata.created_source.num_segments);
		$('#source_url', content).html('<a href="' + metadata.created_source.source_url + '">' + metadata.created_source.source_url + '</a>');
		$('#features_command', content).html('<a href="' + metadata.created_source.source_url + '/features">' + metadata.created_source.source_url + '/features</a>');
		$('#types_command', content).html('<a href="' + metadata.created_source.source_url + '/types">' + metadata.created_source.source_url + '/types</a>');
		
	
		return;
	};
	
	
	
	var self = {
		//Public Attributes
		metadata: undefined,
		
		//Public Methods
		start: function(metadata) {
			self.metadata = metadata;
			if(!dialog) {
				createDialog();
			}
			resetDialog();
			dialog.show();
		},
		close: function() {
			dialog.hide();
		}
	}
	easyDAS.SourceCreatedDialog = self;
	
	
	
}());

	
