/**
 * @author bernat gel
 */

/**
 * a selector for coordinates
 */
var easyDAS = (easyDAS)?easyDAS:{};

(function() {
	//Private fields
	var callback;
	var mainPanel;
	var coordinates;
	
	var filterOrg;
	var filterSource;
	var filterAuth;
	
	var ok_button;
	
	var contentPanel;
	//private functions
	var showUI = function(item) {
		if(!mainPanel) {
			mainPanel = createMainPanel();
			getCoordinates(coordinatesReceived);
		}
		cs.setItem(item);
		setCallback();
		mainPanel.show();
	};
	var createMainPanel = function() {
			//var panel = $('<div id="coordSelector" class="dialog floating round shadow"></div>').appendTo($('body'));
			//panel.append('<div class="title_bar round">Select a Coordinates System</div>');
			var dialog = easyDAS.UI.dialog({
				title: "Select a Coordinates System",
				modal: true,
				draggable: true,
				base_zindex: 600
			});
			dialog.addButton($('<button id="coordSelCancel">Cancel</button>').click(dialog.hide));
			ok_button = $('<button id="coordSelOk">Ok</button>');
			dialog.addButton(ok_button);
			
				
			var content = dialog.body($('<div class="content"></div>'));
			
			var filters = $('<fieldset class="aligned_fields"><legend>Filter By</legend></fieldset>').appendTo(content);
			filters.append('<label for="coordSelFilterOrganism">Organism:</label><select id="coordSelFilterOrganism" disabled="disabled"><option></option></select><br>');
			filters.append('<label for="coordSelFilterSource">Source:</label><select id="coordSelFilterSource" disabled="disabled"><option></option></select><br>');
			filters.append('<label for="coordSelFilterAuthority">Authority:</label><select id="coordSelFilterAuthority" disabled="disabled"><option></option></select><br>');
			
			content.append('<fieldset class=""><legend>Available Coordinates Systems</legend>'
							+'<select  size=10 id="coordSelAvailableCoords" style="width: 100%"><option value="loading"><span class="loading">Loading...</span></option></select>'
							+'</fieldset>');
			easyDAS.markAsWaiting($(".loading", content), "Loading Coordinates Systems...");
			
			var current = $('<fieldset id="coordSelCurrent" class="aligned_fields"><legend>Selected Coordinates System</legend></fieldset>').appendTo(content);
			current.append('<p><label for="coordSelCurrentOrganism" >Organism:</label><span id="coordSelCurrentOrganism" class="field current_coordSel_field" /></p>');
			current.append('<p><label for="coordSelCurrentSource" >Source:</label><span id="coordSelCurrentSource" class="field current_coordSel_field" /></p>');
			current.append('<p><label for="coordSelCurrentAuthority" >Authority:</label><span id="coordSelCurrentAuthority" class="field current_coordSel_field" /></p>');
			current.append('<p><label for="coordSelCurrentVersion" >Version:</label><span id="coordSelCurrentVersion" class="field current_coordSel_field" /></p>');
			
			
			//initialize
			
			$('#coordSelFilterOrganism').change(function() {
				//filterOrg = $('option:selected', this).text();
				filterOrg = $(this).val();
				cs.updateFilteredList();
			});
			$('#coordSelFilterSource').change(function() {
				filterSource = $(this).val(); //$('option:selected', this).text();
				cs.updateFilteredList();
			});
			$('#coordSelFilterAuthority').change(function() {
				filterAuth = $(this).val(); //$('option:selected', this).text();
				cs.updateFilteredList();
			});
			$('#coordSelAvailableCoords').change(function() {
				cs.setItem($('#coordSelAvailableCoords option:selected').data('coordSys'));
			});
			//begin showing the browse panel
			
			
			
			
			return dialog;
		};
		var setCallback = function() {
			ok_button.click(function() {
				callback($('#coordSelCurrent').data('coordSys'));
				mainPanel.hide();
			});
		};
		var getCoordinates = function(callback) {
			$.getJSON('cgi-bin/coordinates.pl', {cmd: 'get_coordinates'}, function(response){
				coordinates = response.coordinates;
				callback();
			});
			
		};
		var coordinatesReceived = function() {
			//Set up the filter selectors
			var orgs = {};
			var sources = {};
			var auths = {};
			
			var organism = $('#coordSelFilterOrganism');
			var source = $('#coordSelFilterSource');
			var authority = $('#coordSelFilterAuthority');
			
			for(var i=0, l=coordinates.length; i<l; ++i) {
				var c=coordinates[i];
				if(c.taxid && !orgs[c.taxid]) {
					orgs[c.taxid] = {id: c.taxid, name: c.organism};
				}
				if(c.source && !sources[c.source]) {
					sources[c.source] = {id: c.source};
				}
				if(c.authority && !auths[c.authority]) {
					auths[c.authority] = {id: c.authority};
				}
			}
			
			var appendOption = function(select, ind, val) {
				$('<option value="'+val.id+'">'+((val.name)?val.name+' ('+val.id+')':val.id)+'</option>').appendTo(select);
			};
			jQuery.each(orgs, function(ind, val) {appendOption(organism, ind, val);});
			jQuery.each(auths, function(ind, val) {appendOption(authority, ind, val);});
			jQuery.each(sources, function(ind, val) {appendOption(source, ind, val);});
			organism.removeAttr('disabled');
			authority.removeAttr('disabled');
			source.removeAttr('disabled');
			
			//and update the list
			cs.updateFilteredList();

			//and recenter it
			cs.center();
		};
	//public API
	var cs = {
		show: function(item, fn) {
			callback = fn;
			showUI(item);
		},
		setPosition: function(left, top) {
			if(mainPanel) {
				mainPanel.el().css({left: left, top: top});	
			}
		},
		center: function() {
			easyDAS.UI.moveToCenter(mainPanel.el());	
		},
		setItem: function(item) {
			var org = item.taxid || '';
			var auth = item.authority || '';
			var source = item.source || '';
			var version = item.version || '';
						
			$('#coordSelCurrentOrganism').html(org);
			$('#coordSelCurrentSource').html(source);
			$('#coordSelCurrentAuthority').html(auth);
			$('#coordSelCurrentVersion').html(version);
			
			//And store the whole data in the fieldset
			$('#coordSelCurrent').data('coordSys', item);
		},
		/**Filter the available coodinate systems using the selected filters*/
		updateFilteredList: function() {
			//Get the filters and filter
			var filtered = coordinates;
			if(filterOrg && filterOrg != "") {
				var new_filtered = [];
				jQuery.each(filtered, function(ind, val) {if(val.taxid && val.taxid==filterOrg)	new_filtered.push(val);});
				filtered = new_filtered;
			}
			if(filterSource && filterSource != "") {
				var new_filtered = [];
				jQuery.each(filtered, function(ind, val) {if(val.source && val.source==filterSource)	new_filtered.push(val);});
				filtered = new_filtered;
			}
			if(filterAuth && filterAuth != "") {
				var new_filtered = [];
				jQuery.each(filtered, function(ind, val) {if(val.authority && val.authority==filterAuth) new_filtered.push(val);});
				filtered = new_filtered;
			}
			//clear the list
			var list = $('#coordSelAvailableCoords');
			$('option', list).remove();
			
			//populate the list
			for(var i=0, l=filtered.length; i<l; ++i) {
				var c = filtered[i];
				$('<option value="'+c.uri+'">'+c.content+'</option>').data('coordSys', c).appendTo(list);
			}
		}
	};
	easyDAS.coordinatesSelector = cs;
}());
	
