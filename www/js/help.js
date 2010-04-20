/**
 * @author bernat
 */

 /**Defines and manages the help system*/

var easyDAS = (easyDAS)?easyDAS:{};

(function() {
	//Private Attributes
		var _dialog; //the object containing the dialog references
		var _tooltip; //The object maintaining the tooltip references
	//Private functions
		//Initializes the help system
		var initHelp = function() {
			$('.help').live('click', function(ev) {
				//var el = ev.target;
				if(ev.which == 1) { //if left click (cross-browser normalized by jquery)
					help.showHelp($(this).attr('help_id') || 'no_topic');	
				}
			});
			$('.contextual_help').live('click', function(ev) {
				//var el = ev.target;
				if(ev.which == 1) { //if left click (cross-browser normalized by jquery)
					help.showTooltip($(this).attr('help_id') || 'no_topic', ev.pageX+15, ev.pageY-15);	
				}
			});
		};
		//The "Big" dialog for real help
		var dialog = function() {
			if(!_dialog) {
				createDialog();
			}
			return _dialog;
		};
		var createDialog = function() {
			_dialog = {};
			_dialog.panel = $('<div class="dialog floating round shadow"></div>').appendTo($('body'));
			_dialog.title = $('<div class="title_bar round">Help</div>').appendTo(_dialog.panel);
			_dialog.content = $('<div class="content"></div>').appendTo(_dialog.panel);
			_dialog.panel.append('<div class="buttons"><button id="closeHelp">Close</button></div>');
			//initialize
			$('#closeHelp').click(function(){_dialog.panel.hide();});
			_dialog.panel.draggable();
			_dialog.panel.width('40%');
		};
		//The Small pseudo-tooltip for contextual help
		var tooltip = function() {
			if(!_tooltip) {
				createTooltip();
			}
			return _tooltip;
		};
		var createTooltip = function() {
			_tooltip = {};
			_tooltip.panel = $('<div class="tooltip floating round shadow"></div>').appendTo($('body'));
			_tooltip.content = $('<div class="content"></div>').appendTo(_tooltip.panel);
			_tooltip.panel.append('<div class="buttons"><div class="close" alt="close"></div></div>');
			//initialize
			_tooltip.panel.find('.buttons>.close').click(function(){_tooltip.panel.hide();});
			_tooltip.panel.draggable({
				cancel: '.tooltip>.content'
			});
			_tooltip.panel.width('20%');
		};
		
	//Public API
	var help = {
		/************REGULAR HELP**********/
		showHelp: function(help_id) {
			var help_data = helpContent[help_id] || helpContent['topic_not_found'];
			dialog().title.html("Help - "+help_data.title);
			dialog().content.html(help_data.content);
			dialog().panel.show();
			//TODO: Move to the mouse position
		},
		/**Closes the help*/
		closeHelp: function() {
			dialog().panel.hide();
		},
		/**Return the HTML to create a help button pointing to the given help topic id
		 * 
		 * @param {Object} help_id
		 */
		helpButton: function(help_id) {
			help_id = help_id || 'no_topic';
			return $('<span class="help link_like" help_id="'+help_id+'">?</span>').click(function(ev) {
				if(ev.which == 1) { //if left click (cross-browser normalized by jquery)
					help.showHelp(help_id);	
				}
			});	
		},
		/************TOOLTIP (contextual) HELP*****************/
		showTooltip: function(help_id, x, y) {
			var help_data = tooltipsContent[help_id] || tooltipsContent['topic_not_found'];
			tooltip().content.html(help_data.content);
			if(x && y) tooltip().panel.css({left: x+'px', top: y+'px'})
			tooltip().panel.show();
			//TODO: Move to the mouse position
		},
		/**Closes the help*/
		closeTooltip: function() {
			tooltip().panel.hide();
		},
		/**Return the HTML to create a help button pointing to the given CONTEXTUAL help (actually, tooltip-like) topic id
		 * 
		 * @param {Object} help_id
		 */
		tooltipButtonHTML: function(help_id) {
			return '<span class="contextual_help link_like" help_id="'+help_id+'">?</span>';	
		}
	}
	easyDAS.Help = help;
	//Initialize Help System
	initHelp();
	
	//Tooltips content
	tooltipsContent = {
		'topic_not_found': {
			title: 'Topic Not Found',
			content: 'The specified help topic was not found. Please, report it at easydas@easydas.com'
		},
		'no_topic': {
			title: 'No Help Id',
			content: 'No specific help topic was specfied. Have you clicked in a help button? please, report it at easydas@easydas.com'
		},
		'define_source_name': {
			title: 'Name of the Source',
			content: 'The name of the source is the identifier of the source in the server. It will be used in the URLs used to access the source.\
					 For example, in "http://hostname.com/server/das/source_name", "source_name" is the name of the source. Note that since \
					 it will be used in a URL, it should only containg letters, numbers, \'_\' and \'-\'.'
		},
		'define_source_title': {
			title: 'Title of the Source',
			content: 'The title of the source is short sentence defining the content of the source. It does not have the same restrictions as the source name.'
		},
		'define_source_maintainer': {
			title: 'Maintainer of the Source',
			content: 'The maintainer is the person to be contacted if there\'s any problem with the source or its data. Please, provide a valid email address.'
		},
		'define_source_description': {
			title: 'Description of the Source',
			content: 'The description of the source is a short definition of the data contained in that source. It does not have the same restrictions as the source name.'
		},
		'mapping_num_lines': {
			content: 'The number of lines to show in the table below. Increase this number if you need more lines to identify the columns.'
		}
	};
	
	//Help Content
	//TODO: could be extracted to the server and loaded only if needed via AJAX
	helpContent = {
		'topic_not_found': {
			title: 'Topic Not Found',
			content: 'The specified help topic was not found. Please, report it at easydas@easydas.com'
		},
		'no_topic': {
			title: 'No Help Id',
			content: 'No specific help topic was specfied. Have you clicked in a help button? please, report it at easydas@easydas.com'
		},
		'define_source_name': {
			title: 'Name of the Source',
			content: 'The name of the source is the identifier of the source in the server. It will be used in the URLs used to access the source.\
					 For example, in "http://hostname.com/server/das/source_name", "source_name" is the name of the source. Note that since \
					 it will be used in a URL, it should only containg letters, numbers, \'_\' and \'-\'.'
		},
		'define_source_title': {
			title: 'Title of the Source',
			content: 'The title of the source is short sentence defining the content of the source. It does not have the same restrictions as the source name.'
		},
		'define_source_maintainer': {
			title: 'Maintainer of the Source',
			content: 'The maintainer is the person to be contacted if there\'s any problem with the source or its data. Please, provide a valid email address.'
		},
		'define_source_description': {
			title: 'Description of the Source',
			content: 'The description of the source is a short definition of the data contained in that source. It does not have the same restrictions as the source name.'
		}
	};
	
}());



