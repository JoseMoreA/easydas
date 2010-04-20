/**
 * @author bernat gel
 */

/**Contains the definition of some UI related utility methods*/ 

var easyDAS = (easyDAS)?easyDAS:{};


(function() {
	//Private Attributes
	var ids = 0;
	
	//Private functions
		//DIALOG
		var createDialog = function(closable) {
			
			
			var dialog = $('<div id="easyDAS_dialog_'+(ids++)+'" class="dialog"></div>');
			var inner = $('<div class="inner_panel" />').appendTo(dialog);
			var title_bar = $('<div class="title_bar"></div>').appendTo(inner);
			var title_container = $('<div class="title_container"></div>').appendTo(title_bar);
			var close_button = undefined;
			if(closable) {
				close_button = $('<div class="close_button" />').appendTo(title_bar);
			}
			var body_container = $('<div class="body_container"></div>').appendTo(inner);
			var buttons_container = $('<div class="buttons_container"></div>').appendTo(dialog);
			return {
				body_container: body_container,
				title_container: title_container,
				buttons_container: buttons_container,
				close_button: close_button,
				main: dialog
			};
		}
		
	
	
	
	
	var self = {
		//Public Attributes
		
		
		//Public Methods
		dialog: function(params, base_zindex) {
			var title = params.title || "Dialog";
			var draggable = (params.draggable!=undefined)?params.draggable:true;
			var closable = (params.closable!=undefined)?params.closable:true;
			var modal = (params.modal!=undefined)?params.modal:false;
			var base_zindex = params.base_zindex || 500;
			var mask;
			
			//MASKING FOR MODAL DIALOGS
			var showMask = function(){
				if(!mask) {
					mask = $('<div class="mask z'+base_zindex+'" \>').appendTo('body');
				}
				mask.css({
					'width': $(window).width(),
					'height': $(document).height(),
					'z-index': base_zindex
					}); //Set height and width to mask to fill up the whole screen		  
				mask.fadeIn(400);
				mask.fadeTo(400,0.4);    
				mask.click(function(e) {
					e.preventDefault();
					return;
				});
			};    
       		
			var removeMask = function() {
				mask.fadeOut(400); //, function() {mask.remove();}
			};
			
			
			var els = createDialog(closable);
			var body_container = els.body_container;
			var title_container = els.title_container;
			var buttons_container = els.buttons_container;
			var close_button = els.close_button;
			var el = els.main;
			el.css({'z-index': (base_zindex+1)});
			$('body').append(el);
			draggable && el.draggable();
			var dialog = {
				body_container: body_container,
				el: function() {return el;},
				body: function(val) {
					if (val != undefined) {
						body = val;
						$(body_container).html(body);
					}
					return body;
				},
				show: function() {
					if(modal) {
						showMask();	
					}
					$(el).show(); //Why doesn't 'fast' work anymore?
				},
				hide: function() {
					if(modal) {
						removeMask();
					}
					$(el).hide(); //somehow 'normal' doesn't work anymore
				},
				close: function() {
					dialog.hide();
				},
				addButton: function(button) {
					$(button).appendTo(buttons_container);
				},
				setPosition: function(left, top) {
					if(left!=undefined && top!=undefined) {
						el.css({left: left, top: top});
					}
				},
				center: function() {
					self.moveToCenter(el);
				},
				moveToTopLeft: function() {
					el.css({'left': 100, 'top':100});
				},
				title: function(val) {
					if (val != undefined) {
						title = val;
						$(title_container).html(title);
					}
					return title;
				}
			};
			dialog.title(title);
			if(closable) $(close_button).click(dialog.close);
			return dialog;
		},
		
		/**returns the HTML for a select element with the given options
		 *
		 * a params Hash containing:
		 * @param {String} id (Optional)- the id of the new select element
		 * @param {Array} options - the array of options. Each option MUST have a 'name' and an 'id'
		 * @param {String} selected (Optional) - the id of the selected element. If no one is provided, no option is explicitrely selected
		 * @param {Array} cls (Optional) - an array of classes to be applied to the select element
		 */
		selector: function(params){
			var html = '<select ' + ((params.id) ? ' id="' + params.id + '" name="' + params.id + '" ' : '') + ' class="selector ' + ((params.cls) ? params.cls.join(' ') : '') + '">';
			if (params.add_none) {
				html += '<option value="none" ' + ((params.selected && params.selected == 'none') ? 'selected="true"' : '') + '>None</option>';
			}
			for (var i = 0, l = params.options.length; i < l; i++) {
				var opt = params.options[i];
				html += '<option value="' + opt.id + '" ' + (params.selected && opt.id == params.selected ? 'selected="true"' : '') + '>' + opt.name + '</option>';
			}
			html += '</select>';
			return html;
		},
		easyDASFieldsSelector: function(params){
			params.options = easyDAS.Config.FeatureDataFields;
			return self.selector(params);
		},
		fileTypesSelector: function(params){
			params.options = easyDAS.Config.FileTypes;
			params.add_none = params.add_none || false;
			return self.selector(params);
		},
		
		
		/**Popup**/
		getCenteredCoords: function(width, height){
			var xPos = null;
			var yPos = null;
			if (window.ActiveXObject) {
				xPos = window.event.screenX - (width / 2) + 100;
				yPos = window.event.screenY - (height / 2) - 100;
			}
			else {
				var parentSize = [window.outerWidth, window.outerHeight];
				var parentPos = [window.screenX, window.screenY];
				xPos = parentPos[0] +
				Math.max(0, Math.floor((parentSize[0] - width) / 2));
				yPos = parentPos[1] +
				Math.max(0, Math.floor((parentSize[1] - (height * 1.25)) / 2));
			}
			return [xPos, yPos];
		},

		/**Moves the element el to the center of the screen. It assumes el is absolutely positioned*/
		moveToCenter: function(el) {
			el = $(el); //extend with jquery
			var coords = self.getCenteredCoords(el.width(), el.height());
			el.css({left: coords[0], top: coords[1]});
		},
		
		openPopupWindow: function(src, name){
			var w = window.open(src, name, 'width=450,height=500,location=1,status=1,resizable=yes');
			var coords = self.getCenteredCoords(450, 500);
			w.moveTo(coords[0], coords[1]);
		}		
	};
	easyDAS.UI = self;
}());

	
