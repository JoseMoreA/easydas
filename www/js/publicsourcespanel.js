/**
 * @author bernat
 */
/**mysourcespanel.js
 * 
 * Defines the my sources panel class. 
 * 
 */

var easyDAS = (easyDAS)?easyDAS:{};

(function() {
	//Private Attributes
		//config options
		var label = "All Sources";
		var id ="public_souces_panel";
		
		//DOM references
		var panel;
		var table_container;
		
	//Private Methods
		//HTML
		
		
		//DOM creation
		var createPanel = function() {
			panel = $('<div id="'+id+'"></div>');
			table_container = $('<div class="sources_table_container" />').appendTo(panel);
			return panel;
		};
		
		//Communication
		var getSourcesInfo = function(callback) {
			$.get('cgi-bin/admin.pl', {cmd: 'get_all_sources'}, callback, 'json');
		};

		
	//Public Attributes
		
	var self = {
		//Public Methods
		init: function(params){
			var disabled;
			if (params) {
				//update any parameter
				label = params.label || label;
				id = params.id || id;//+getTime();
				disabled = (params.disabled != undefined)?params.disabled:'false'; //Cannot use the above sintax because it's a boolean value  
			}
			//register it
			easyDAS.Controller.registerTab({
				'label': label,
				'id': id,
				'getPanel': self.getPanel,
				'disabled': disabled
			});
		},
		getPanel: function(){
			if (!panel) {
				panel = createPanel();
			}
			//TODO: 
			//	- we want to recreate the sources table every time it's called so it aways stays in sync?
			//  - or have refresh button?
			//  - or have a timed cache?
			
			//add the throbber
			easyDAS.markAsWaiting(table_container, "Loading Sources...");
			//get the sources
			getSourcesInfo(function(sources) {
				table_container.html(easyDAS.SourcesTable.createTable(sources, false, false)); //and create the table and add it to the table container 
			});
			return panel;
		}
	};
	
	//initialize the instance
	self.init();
		
	//Save it into the easyDAS namespace
	easyDAS.MySourcesPanel = self;
}());


