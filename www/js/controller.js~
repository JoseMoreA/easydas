/**
 * @author bernat
 */
/**This is the controller of easyDAS. It handles the interactions between the different modules and part of the communication with the servers*/

var easyDAS = (easyDAS)?easyDAS:{};

(function() {
	//Private Attributes
		//State
		var started = false;
		var current_tab;
		var current_panel;
		
		//Data Objects
		var tabs = []; //An array of tabs 
	
		//References to the DOM
		var main_el; //This is the main container containing almost all the non-floating easyDAS UI elements. (except for login button and panel)
		var login_el; //This element contains the login related UI elements
		var tabs_el; //This is the element containing the tabs
		var panel_container_el; //The element directly containing the panels
		
		//Utility
		var num_tabs=0; //The number of tabs in the controller
	
	//Private Methods
		//HTML
		var htmlTabContent = function(tab) {
			return '<span class="label">'+tab.label+'</span>';
		};
		var htmlTab = function(tab) {
			return '<li id="admin_tab_'+num_tabs+'" class="tab" />';
		};
	
		//EVENTS
			/**Sets the "live" events. Live events are applied to any matching element created at any moment*/
			var setLiveEvents=function() {
				return;
			};
	
		//GUI
			//TABS
			/**Parses the tabs array and updates the curret tabs if needed*/ 
			var redrawTabs = function() {
				for(var i=0, l=tabs.length; i<l; ++i) {
					var tab = tabs[i];
					if(!tab.drawn || tab.changed) drawTab(tab); //if !drawn, draw it
					(tab.disabled)?$(tab.el).addClass('disabled'):$(tab.el).removeClass('disabled');
				}
			};
			/**draws a tab. if the tab has an element, then that's the e used to draw the tab
			 * 
			 * @param {Object} tab
			 */
			var drawTab = function(tab) {
				tab.el || createTabDiv(tab);
				tab.el.html(htmlTabContent(tab));
			};
			var createTabDiv = function(tab) {
				tab.el = $(htmlTab(tab)); //create the DOM structure
				tab.el.appendTo(tabs_el); //And append it to the tabs container
				initTab(tab);
			};
			var initTab = function(tab){
				tab.el.click(function(ev){
					!tab.disabled && self.selectTab(tab);
				});
			};
			
		
	
	
		//Utility
		var getTab = function(id) {
			for(var i=0, l=tabs.length; i<l; ++i) if(tabs[i].id==id) return tabs[i];
			return undefined;
		};

	var fieldName = function(id) {
		var edf = easyDAS.Config.FeatureDataFields;
		for(var i=0, l= edf.length; i<l; ++i) {
			if(edf[i].id==id) return edf[i].name;
		}	
		return undefined;
	};
	
	var self = {
		//Public Attributes
		
		
		//Public Methods
		init: function(params){
			main_el = params.main_el;
			tabs_el = params.tabs_el;
			panel_container_el = params.panel_container_el;
			
			setLiveEvents();
		},
		start: function(){
			//Build the interface
			redrawTabs();
			self.selectFirstAvailableTab();
			started = true;
		},
		//TABS
		registerTab: function(tab){
			tabs[tabs.length] = tab;
			started && redrawTabs();
		},
		disableTab: function(tab_id){
			var tab = getTab(tab_id);
			tab.disabled = true;
			self.selectFirstAvailableTab();
			started && redrawTabs();
		},
		enableTab: function(tab_id){
			getTab(tab_id).disabled = false;
			started && redrawTabs();
		},
		selectTab: function(tab){
			if (typeof tab == 'string') { //of the parameter was the tab_id, get the tab 
				tab = getTab(tab);
			}
			current_tab = tab;
			$('li.selected', tabs_el).removeClass('selected');
			$(tab.el).addClass('selected');
			self.showPanel(tab.getPanel)
		},
		selectFirstAvailableTab: function(){
			for (var i = 0, l = tabs.length; i < l; ++i) {
				if (!tabs[i].disabled) {
					self.selectTab(tabs[i]);
					return;
				}
			}
		},
		showPanel: function(panel_function){
			current_panel=panel_function();
			panel_container_el.html(current_panel);
		},
		//Source Managing
		/**Begins the source ceation process.*/
		
		/**This method sends a command to the server
		 * to create the source based on the current source definition
	 	*/
		createSource: function(metadata){
			if (self.metadataIsComplete(metadata)) {
				var data = {
					cmd: 'create_source',
					metadata: JSON.stringify(metadata)
				};
				var callback = function(data, textStatus){
					if (!data || data.error) {
						if (data.error.id == 'source_name_not_unique') {
							if (easyDAS.username != undefined) {
								var replace = confirm(data.error.msg + "\n Do you want to replace it?");
								if (replace) {
									self.removeSource(data.error.additional_info, function(){
										metadata.error = undefined;
										self.createSource(metadata);
									});
								}
								else {
									easyDAS.NewSourceDialog.setStep(2);
								}
							}
							else { //if the user is anonymous theres not much to do. The source can not be changed
								alert(data.error.msg);
								easyDAS.NewSourceDialog.setStep(2);
							}
						}
						else {
							alert(data.error_info.msg || "An error occurred");
						}
					}
					else {
						easyDAS.NewSourceDialog.closeWizard();
						easyDAS.SourceCreatedDialog.start(data);
					}
				};
				$.post('cgi-bin/easyDAS.pl', data, callback, 'json');
			}
			else {
				return
			}
			return false;
			
		},
		/**Check if metadata contains all the needed easyDAS fields to create a new source. Tell the user otherwise.*/
		metadataIsComplete: function(metadata){
			var present = {};
			var fail = [];
			var needed = ['id', 'type_id', 'segment_id']; //method_id
			//check mapping
			var map = metadata.parsing.mapping;
			for (var mi = 0, ml = map.length; mi < ml; ++mi) {
				present[map[mi].easyDAS_field] = 1;
			}
			//check defaults
			var def = metadata.defaults;
			for (var di = 0, dl = def.length; di < dl; ++di) {
				present[def[di].field] = 1;
			}
			//Check we've got all the needed ones
			var valid = true;
			for (var i = 0, l = needed.length; i < l; ++i) {
				if (!present[needed[i]]) {
					valid = false;
					fail[fail.length] = i;
				}
			}
			if (!valid) {
				var msg = "Some of the required fields are not assigned. Please assign them using 'Mapping' or 'Defaults':\n";
				for (var j = 0, k = fail.length; j < k; ++j) {
					var id = needed[fail[j]];
					msg += " - " + (fieldName(id) || id) + "\n";
				}
				alert(msg);
			}
			return valid;
		},
		removeSource: function(id, callback){
			$.get('cgi-bin/admin.pl', {
				cmd: 'remove_source',
				source_id: id
			}, function(response){
				if (response.error) {
					alert("There was an error when trying to delete the source \"" + name + "\": " + response.error.msg);
				}
				else {
					if (current_panel.redraw && typeof(current_panel.redraw) == 'function') {
						if(response.sources) {
							current_panel.redraw(response.sources);	
						} else {
							current_panel.redaw();
						}
						
					}
					callback(response);
				}
			}, 'json');
		}
	};
	
	//Save it into the easyDAS namespace
	easyDAS.Controller = self;
}());

