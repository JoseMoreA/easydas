/**
 * @author bernat gel
 */

/* ontologyPick is a package providing a simple interface to select a term from an ontology using the OLS webservices
 */
var easyDAS = (easyDAS)?easyDAS:{};

(function() {
	var createOntologyPicker = function(_ontology) {
		//Options
		var ontology = _ontology;

		//Private 
		var callback;
		var positionX;
		var positionY;
			
		var dialog;
		var dialog_el;
		var ok_button;
		
		var content_panel;

		var browser_panel;
		var tree_viewer;

		var search_panel;
		var search_input;
		var search_results; 
		
		
		//Private functions
			//Used as described by Douglas Crockford to create real prototyping.
			//var newobj = object(oldobj) creates new object using oldobject as its prototype.
			var object = function(o){
				function F(){
				}
				F.prototype = o;
				return new F();
			};
		
			//Network
			var getRootTerms = function(callback) {
				$.get("cgi-bin/ontology.pl", {cmd: 'roots', ont: ontology}, function(response){
					callback(response.terms)
				},'json');
			};
			var getTermChildren = function(key, callback) {
				$.get("cgi-bin/ontology.pl", {cmd: 'term_children', term: key, ont: ontology}, function(response){
					callback(response.terms)
				},'json');
			};
			
			var searchTerm = function(str, ontology, callback) {
				$.get("cgi-bin/ontology.pl", {cmd: 'search', term: str, ont: ontology}, function(response){
					callback(response.terms)
				},'json');
			}
							
			
			
			//UI
			var setItem = function(item) {
				$('.type_name', dialog_el).text(item.name);
				$('.oPick_current_label', dialog_el).val(item.label);
				$('.oPick_current_cvId', dialog_el).val(item.cvId);
			};
			var getItem = function() {
				return {
					name: $('.type_name', dialog_el).text(),
					label: $('.oPick_current_label', dialog_el).val(),
					cvId: $('.oPick_current_cvId', dialog_el).val()
				};
			};
			var setCallback = function(callback) {
				ok_button.unbind('click').click(function() {
					callback(getItem());
					dialog.hide();
				})
			};
			var showUI = function(item, callback) {
				if(!dialog) {
					createDialog();
				}
				setItem(item);
				setCallback(callback);
				op.setPosition();
				dialog.show();
			};
			var createDialog = function() {
				dialog = easyDAS.UI.dialog({
					title: "Ontology Terms ("+ontology+")",
					modal: true,
					draggable: true,
					base_zindex: 600
				});
				dialog_el = dialog.el();
				dialog_el.data('onto', ontology); //HACK: Some problems wuth the scope prevented this to work. Trying to attach the actual data to the element.
				dialog.addButton($('<button>Cancel</button>').click(dialog.hide));
				ok_button = $('<button>Ok</button>');
				dialog.addButton(ok_button);
			 
				var panel = dialog.body($('<div class="body oPick" />'));
				
				//$('<div id="oPick" class="floating round shadow dialog"></div>').appendTo($('body'));
				//panel.append('<div class="title_bar round">Select and Edit your type</div>');
				panel.append('<p>Type: <span class="type_name"></span></p>');
				var tabs = $('<ul class="tabs" />').appendTo(panel);
				$('<li class="oPick_browse">Browse</li>')
					.click(function(ev){
						$('.oPick .tabs .selected',dialog).removeClass('selected');
						$(ev.target).addClass('selected');
						op.showBrowsePanel();
					})
					.appendTo(tabs);
				$('<li class="oPick_search">Search</li>')
					.click(function(ev){
						$('.oPick .tabs .selected',dialog).removeClass('selected');
						$(ev.target).addClass('selected');
						op.showSearchPanel();
					})
					.appendTo(tabs);
				content_panel= $('<div class="oPick_content"></div>').appendTo(panel);
				panel.append('<br>');
				panel.append('<label for="type_label">Label</label><input class="oPick_current_label" /><br>');
				panel.append('<label for="type_cvId">cvId</label><input class="oPick_current_cvId" /><br>');
				//panel.append('<button id="oPick_cancel">Cancel</button> <button id="oPick_ok">Ok</button>');
				//initialize
				//begin showing the browse panel
				op.showBrowsePanel();
				
				
				return dialog;
			};
			

			var createSearchPanel = function() {
				var search_panel = $('<div class="onto_search"></div>');
				var label = $('<label for="ontoS_search_term">Type: </label>').appendTo(search_panel);
				search_input = $('<input class="ontoS_search_term" />')
					.keypress(function(ev) {if(ev.keyCode == 13) search(ontology);})
					.appendTo(search_panel);
				var search_button = $('<button class="ontoS_search_button">Search</button>')
					.click(function(){search(ontology);})
					.appendTo(search_panel);
				search_panel.append('<br>');
				search_results = $('<div class="search_results" />').appendTo(search_panel);
				return search_panel; //There's something wrong with the closures here... search_panel is not shared with all the functions so we have to return it.
			};
			var initSearchPanel = function() {
				//$('.ontoS_search_button', dialog_el).click(search);
				//$('.ontoS_search_term', dialog_el).keypress(function(ev) {if(ev.keyCode == 13) search();});
				$('.ontoS_res_table tbody tr', search_panel).live('click', function(ev) {
					//$('.ontoS_res_table .selected',search_panel).removeClass('selected');
					var row = $(ev.target).closest('tr');
					row.addClass('selected')
						.siblings().removeClass('selected');
					op.setTerm({name: row.find('.name').text(), key: row.find('.key').text()});
				});
				/* * /
				$('.ontoS_res_table .ontoS_plus', dialog_el).live('click', function(ev){
					showTermInfo($(ev.target).parent().parent().attr('termKey'));
				});
				//*/
			};
			
			
			//Tree
			/**Definition of the class Node used by the TreeViewer */
			var TreeNode = {
				/**Initializes the Node with the info in par
				 * 
				 * @param {Object} par - of the form: {id (String), value (String), children (Array of TreeNode), parent (TreeNode), expanded (Bool)} 
				 */
				init: function(par) {
					par = par || {}; 
					this.key = par.key || "",
					this.name = par.name || "",
					this.children = par.children, //undefined (children unknown), empty aray (no children), populated arra (children)
					this.parent = par.parent,
					this.expanded = par.expanded || false,
					this.childrenFetched = (par.children != undefined)
					this.isLeaf = false;
					tree_viewer.nodes().push(this);
					return this;
				},
				addChild: function(node) {
					this.children = this.children || new Array();
					this.children.push(node);
				},
				setChildrenFromTerms: function(terms) {
					for(var i=0, l=terms.length; i<l; ++i) {
						var nc = terms[i];
						var n = object(TreeNode).init({key:nc.key, name: nc.name, parent: this});
						this.addChild(n);
					}
					if(terms.length ==0) this.isLeaf = 1;
					//redraw the tree (might not be necessary, but will usually be)
					this.childrenFetched = true;
				},
				toogleExpanded: function() {
					if(this.expanded) {
						this.expanded = false;
						tree_viewer.drawTree();
					} else {
						if (this.childrenFetched) {
							this.expanded = true;
							tree_viewer.drawTree();
						}
						else {
							var n=this;
							$('span[termKey='+n.key+']', dialog_el).addClass('loading');
							this.fetchChildren(function(terms){
								n.setChildrenFromTerms(terms);
								n.toogleExpanded();
								$('span[termKey='+n.key+']', dialog_el).removeClass('loading');
							});
						}
					}
				},
				fetchChildren: function(callback) {
					getTermChildren(this.key, callback);
				}
			};

			var createTreeViewer = function() {
				//private Attributes
				var showKeys;
				var tv_container;
				var nodes;
				var root;
				var tree;
				
				var onto = ontology;
			
			    var self = {
				onto: function() {return onto;},
				init: function(container){
					easyDAS.markAsWaiting(container, "Loading...");
					showKeys = true;
					tv_container=$('<div class="oPickTV_canvas"></div>')
						.appendTo(container);

					nodes = new Array();
					root = object(TreeNode).init({name: 'Root_'+ontology, expanded: false,parent: undefined});
					tree = root;
					//Init event handlers: (using jQuery live technology)
						//expand/collapse a node
				//HACK && FIX: For some reason, I had problems with the clousures and I was unable to 
				//have two fully functional tree viewers in the same page. defining the "live" event inside
				//an anonymous function solved the problem
						var onToogleExpanded = function(ev, tv) {
							var key = $(ev.target).attr('termKey')
							var n = tv.findNode(key);

							if(n!=undefined) {
								n.toogleExpanded();
							}
							return false; //do not propagate the event
						};
						(function() {
							var s = self;
							$('.expander', tv_container).live('click', function(ev)
							{
								onToogleExpanded(ev, s);
							});
						}());
						//OLD implementation
						/*$('.expander', tv_container).live('click', function(ev){
							var key = $(ev.target).attr('termKey')
							var n = self.findNode(key);

							if(n!=undefined) {
								n.toogleExpanded();
							}
							return false;
						});*/

						var onSelect = function(ev, tv){
							//$('.selected', tv_container).removeClass('selected');
							$(ev.target).addClass('selected')
								.siblings().removeClass('selected');
							var n = tv.findNode($(ev.target).attr('termKey'));
							if (n != undefined) {
								op.setTerm(n);
							}
							return false; //do not propagate the event
						};
						(function() {
							var s = self;
							$('.term', tv_container).live('click', function(ev)
							{
								onSelect(ev, s);
							});
						}());
						//OLD IMPLEMENTATION
						/*$('.term', tv_container).live('click', function(ev){
							//$('.selected', tv_container).removeClass('selected');
							$(ev.target).addClass('selected')
								.siblings().removeClass('selected');
							var n = self.findNode($(ev.target).attr('termKey'));
							if (n != undefined) {
								op.setTerm(n);
							}
							return false; //do not propagate the event
						});*/
					////initialize the tree
					getRootTerms(function(root_terms) {
						self.setNodeChildren(root, root_terms)
					});
				},
				nodes: function() {
					return nodes;
				},
				findNode: function(key) {
					var n = nodes;
					for(var i=0, l=n.length; i<l; ++i) {if(n[i].key === key) return n[i];}
					return undefined;
				},
				setNodeChildren: function(node, new_childs) {
					for(var i=0, l=new_childs.length; i<l; ++i) {
						var nc = new_childs[i];
						var n = object(TreeNode).init({key:nc.key, name: nc.name, parent: node});
						node.addChild(n);
					}
					//redraw the tree (might not be necessary, but will usually be)
					node.childrenFetched = true;
					self.drawTree();
				},
				//TODO: Create the tree OFF the DOM and then insert it
				drawTree: function() {
					//we do NOT want to draw the real root but start with its children, the ontology roots
					$(".waiting", tv_container.parent()).remove();
					var html = '<table><tbody>'
					var r = root;
					var nc = r.children;
					if (nc === undefined) { //if the root has no children, we've got no ontology!
						return;
					}
					else {
						var l = nc.length;
						for (var i = 0; i < l; ++i) {
							html += '<tr><td></td><td>';
							html += self.recDraw(nc[i], i==l-1);
							html += '</td></tr>';
						}
					}
					html += '</tbody></table>';				
					$(tv_container).html(html);				
				},
				/**Recursively create the HTML structure to draw the tree*/
				recDraw: function(node, last) {
					var lastcls = (last)?' last':'';
					var html = '<table><tbody>';
					var nc = node.children;
					if (nc === undefined || !node.expanded) {//we know nothing about the nodes children or the node is explicitly collapsed
						html += self.nodeHTML(node, 'collapsed'+lastcls);
					} else {
						html += self.nodeHTML(node, 'expanded'+lastcls);
						var l = nc.length;
						for(var i=0; i<l; ++i) {
							html+='<tr><td class="vline '+lastcls+'"></td><td>';
							html+=self.recDraw(nc[i], i==l-1);
							html+='</td></tr>';
						}	
					}
					html+='</tbody></table>';
					return html;				
				},
				nodeHTML: function(node, cl) {
					var leafcls = (node.isLeaf)?' leaf':'';
					return '<tr><td><a class="'+cl+' tree_structure expander'+leafcls+'" termKey="'+node.key+'"></td>'
						 +'<td><span class="term" termKey="'+node.key+'">'+node.name+(showKeys ? ' (' + node.key + ')' : '') +
						'</span></td></tr>'
				}
			};
				return self;
			};			
			//Search
			var search = function(ontology) {
				var term = search_input.val();
				if(!term) {
					$('.error_message').remove();
					search_results.html('<div class="error_message">You must specify a search term</div>');
				} else {
					//searchPanel.find('.error_message', dialog_el).remove();
					easyDAS.markAsWaiting(search_results, "Searching ontology...");
					searchTerm(term, ontology, processSearchResults);
				}
			}
			var processSearchResults = function(results) {
				//remove any existing table...
				$('.ontoS_res_table', dialog_el).remove();
				if(results.length >0) {
					var table = $('<table class="ontoS_res_table"></table>');
					table.append('<thead><tr><th>Name</th><th>Key</th></tr></thead>');
					//<td>More</td>
					var tbody = $('<tbody></tbody>').appendTo(table);
					for(var i=0, l=results.length; i<l; ++i) {
						var t = results[i];
						tbody.append(getSearchResultHTML(t, i));
					}
					search_results.html(table);
				} else {
					search_results.html('<span class="message">Sorry, the search did not produce any result</span>');
				}
			};
			var getSearchResultHTML = function(t, nline) {
				return '<tr termKey="'+t.key+'" class="'+((nline%2)?'odd':'even')+'"><td class="name first">'+t.name+'</td><td class="key">'+t.key+'</td></tr>';
				//<td><button class="ontoS_plus">+</button></td>
			};
			var showTermInfo = function(key) {
				alert("implementation pending");
			};
			
				
		//Public Interface
		var op = {
			select: function(item, callback) {
				showUI(item, callback);
			},
			setPosition: function(X, Y) {
				if(X) {positionX=X;}
				if(Y) {positionY=Y;}
				if(dialog) dialog_el.css({left: positionX+'px', top: positionY+'px'});	
			},
			setTerm: function(term) {
				$(".oPick_current_label", dialog_el).val(term.name);
				$(".oPick_current_cvId", dialog_el).val(term.key);
			},
			showSearchPanel: function() {
				//'select' the tab
				$('.oPick .tabs .selected', dialog_el).removeClass('selected');
				$('.oPick_search', dialog_el).addClass('selected');
				//and show the panel
				if(!search_panel) {
					search_panel = createSearchPanel();
					search_panel.appendTo(content_panel);
					initSearchPanel();
				}
				if(browser_panel) browser_panel.hide();
				search_panel.show();
			},
			showBrowsePanel: function() {
				//'select' the tab
				$('.oPick .tabs .selected', dialog_el).removeClass('selected');
				$('.oPick_browse', dialog_el).addClass('selected');
				//and show the panel
				if(!browser_panel) {
					browser_panel = $('<div class="tree_viewer"></div>')
						.appendTo(content_panel);
					tree_viewer = createTreeViewer();
					tree_viewer.init(browser_panel);
				}
				if(search_panel) search_panel.hide();
				browser_panel.show();
			}
		};
		return op;
	};
	easyDAS.ontologyPicker = createOntologyPicker;
}());
	
