/**
 * @author bernat
 */
/**publicsourcespanel.js
 * 
 * Defines a "widget" to show a table of sources. It is actually a singleton factory returning the widgets 
 * 
 */

var easyDAS = (easyDAS)?easyDAS:{};

(function() {
	//Private Attributes
		//config options

		//Get the ensembl coordinate systems.
		//This will fire the retrieving of the coordinates system on load and assign it to the variable.
		/*var ensembl_coords = undefined;
		var get_ensembl_coords = function() {
			$.get("js/config/ensembl_coords.json", null, function(response){
					ensembl_coords = response;
				},'json');
			return 1;
		}();
		*/	
		
		//DOM references
		
		
	//Private Methods
	//Sources Panel

	var createSourcesTable = function(sources_info, remove, edit) {
		if (sources_info.length == 0) {
			var table = $('<span class="centered notification">There are no data sources</span>');
		}
		else {
			var has_buttons = remove || edit;
			var table = $('<table class="source_table"><thead><tr><td '
+((has_buttons)?'colspan=2':'')+'>Name</td><td>View it</td><td>Title</td><td>Maintainer</td><td>Documentation</td><td>Coordinates System</td><td>Creation Date</td></thead></tr></table>');
			var tbody = $('<tbody></tbody>').appendTo(table);
			for (var i = 0, l = sources_info.length; i < l; ++i) {
				$(getSourcesTableRow(sources_info[i], remove, edit)).data('source_info', sources_info[i]).appendTo(tbody);
			};
		}
		initSourcesPanel(table);
		return table;
	};
	var initSourcesPanel = function(table) {
		$('.edit_source', table).click(function(ev) {editSource($(ev.target).parent().parent());});
		$('.remove_source', table).click(function(ev) {removeSource($(ev.target).parent().parent());});
		//$('.source_table .show_url').click(show_source_url);
		$('.show_description', table).click(show_source_description);
		$('.show_coord_info', table).click(show_coordinates_info);
		
		return;
	};
	var editSource = function(source_row) {
		alert("Show a panel to change description, maintainer, doc_href");
	};
	var removeSource = function(source_row) {
		var id=source_row.attr('source_id');
		var name = $('.name', source_row).text();
		
		var remove= confirm("Do you really want to remove the source \""+name+"\"?");
 		if (remove)
 		{
			easyDAS.Controller.removeSource(id, function(response) {
				//updateSourcesPanel(response.sources);
			});
		
 		}
	};
	
	var getSourcesTableRow = function(s, remove, edit) {
		var coord = (s.coordinates_system_info && s.coordinates_system_info.content)?s.coordinates_system_info.content:
							(s.coordinates_system_id)?s.coordinates_system_id:
							'';
		var coord_more = (coord!='')?' <span class="show_coord_info link_like">more...</span>':'';
		var show_desc = (s.description && s.description!='')?' <span class="show_description link_like">more...</span>':'';
		var buttons = "";
		if(remove || edit) {
			var ed = (edit)?'<div class="edit_button edit_type source_button" />':'';
			var rm = (remove)?'<div class="remove_button remove_source source_button" />':'';
			buttons = '<td>'+rm+ed+'</td>';
		}
		var url = s.base_url;

		//Create the viewer link

		var viewer_links = "";

	//IMPORTANT TODO FIX: We need to determine the organism of the coordinate system and map it to the right ensembl name! Right now all sources point to the Human viewer

		//ENSEMBL
		if(s.coordinates_system_info && s.coordinates_system_info.uri) {
			var coord_uri = s.coordinates_system_info.uri;
			var coord_id = coord_uri.substr(coord_uri.lastIndexOf("/")+1);
			var ensembl_link;
			//if(ensembl_coords && ensembl_coords[coord_id] != "Protein Sequence") {
			var ensembl_base_url = easyDAS.Config.EnsemblCoords[coord_id];
			if(ensembl_base_url) {
				ensembl_link = '<a '
			//+'href="http://www.ensembl.org/Homo_sapiens/Location/View?r='+s.test_range+';contigviewbottom=das:'
			+'href="'+ensembl_base_url+'Location/View?r='+s.test_range+';contigviewbottom=das:'
					+url+'=normal" target=_blank>'+
				//	+'View in Ensembl'
				'<img src="images/ensembl_20.png" alt="View in ensembl" />'
					+'</a>';
				viewer_links += ensembl_link;
			}
		}
		
		//End of viewer links

		var html = '<tr source_id="'+s.id+'">'
						+buttons
						+'<td><span class="source_name">'
						+s.name+'</span><br>'
						+'<span class="url"><a target="_blank" href="'
						+url+'">'+url
						+'</a></span></td>'
						+'<td>'+viewer_links+'</a>'
						+'<td>'+s.title+show_desc+'</td>'
						+'<td>'+s.maintainer+'</td>'
						+'<td><a href="'+s.doc_href+'" target="blank">'+s.doc_href+'</a></td>'
						+'<td>'+coord+coord_more+'</td>'
						+'<td>'+s.creation_date+'</td>'
					+'</tr>';
		return html;
	}
	
	var show_source_url = function(ev){
		var el = $(this);
		if (!$(el).data('url_visible')) {
			var url = el.parent().parent().parent().data('source_info').base_url;
			el.text('Hide URL...').parent().parent().append('<span class="url"><br>' + url + '</span>');
			el.data('url_visible', true);
		}
		else {
			$(".url", el.parent().parent()).remove();
			el.text('Show URL...');
			el.data('url_visible', false);
		}
	};
	
	var show_source_description = function(ev){
		var el = $(this);
		if (!el.data('desc_visible')) {
			var desc = el.parent().parent().data('source_info').description;
			el.text('hide...').parent().append('<div class="source_description extended_info">' + desc + '</div>');
			el.data('desc_visible', true);
		}
		else {
			$(".source_description", el.parent()).remove();
			el.text('more...');
			el.data('desc_visible', false);
		}
	};
	
	var show_coordinates_info = function(ev){
		var el = $(this);
		if (!el.data('cinfo_visible')) {
			var c = el.parent().parent().data('source_info').coordinates_system_info;
			var info = '';
			if(c) {
				info = '<ul>'
							+'<li><span class="name">organism</span>: <span class="value">'+c.organism+'</span></li>'
							+'<li><span class="name">taxid</span>: <span class="value">'+c.taxid+'</span></li>'
							+'<li><span class="name">authority</span>: <span class="value">'+c.authority+'</span></li>'
							+'<li><span class="name">version</span>: <span class="value">'+c.version+'</span></li>'
							+'<li><span class="name">source</span>: <span class="value">'+c.source+'</span></li>'
							+'<li><span class="name">uri</span>: <span class="value">'+c.uri+'</span></li>'
							+'<li><span class="name">test range</span>: <span class="value">'+c.test_range+'</span></li>'
						+'</ul>';
				el.text('hide...').parent().append('<div class="coords_info extended_info">' + info + '</div>');
				el.data('cinfo_visible', true);
			}
		}
		else {
			$(".coords_info", el.parent()).remove();
			el.text('more...');
			el.data('cinfo_visible', false);
		}
	};

		
	//Public Attributes
		
	var self = {
		//Public Methods
		init: function(params){
		
			
		},
		createTable: function(sources, remove, edit){
			remove = remove || false;
			edit = edit || false;
			return createSourcesTable(sources, remove, edit);
		}
	};
	
	//Save it into the easyDAS namespace
	easyDAS.SourcesTable = self;
}());


