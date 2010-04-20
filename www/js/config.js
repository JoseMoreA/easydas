/**
 * @author bernat
 */

 /**Stores the configuratin information for easyDAS*/

var easyDAS = (easyDAS)?easyDAS:{};

(function() {
	var conf = {
		FileTypes: [
			{id: 'GFF',	name: 'GFF'},
			{id: 'CSV', name: 'Column Based (DAT, CSV, TSV...)'},
			{id: 'XLS', name: 'Excel XLS file'}
		],
		FeatureDataFields: [
			{id: 'id', name: 'Identifier'},
			{id: 'name', name: 'Name'},
			{id: 'start', name: 'Start'},
			{id: 'end', name: 'End'},
			{id: 'score', name: 'Score'},
			{id: 'orientation', name: 'Orientation'},
			{id: 'phase', name: 'Phase'},
			{id: 'method_id', name: 'Method Id'},
			{id: 'note', name: 'Note'},
			{id: 'segment_id', name: 'Segment Id'},
			{id: 'type_id', name: 'Type Id'},
			{id: 'parent', name: 'Parent'},
			{id: 'part', name: 'Part'}
		],
		CSV_Separators: [
			{id: 'comma', name: 'Comma (,)'},
			{id: 'tab', name: 'Tab (\\t)'},
			{id: 'semicolon', name: 'Semicolon (;)'},
			{id: 'colon', name: 'Colon (:)'}
//			{id: 'other', name: 'Other'}  TODO: ReAdd the "Other" separator option 
		],
		EnsemblCoords: { //FIX TODO: While no better implementation is found, simply hardcoded association between ensembl urls and Coordinate systems
			'CS_DS311': 'http://www.ensembl.org/Homo_sapiens/',
			'CS_DS313': 'http://www.ensembl.org/Homo_sapiens/',
			'CS_DS108': 'http://www.ensembl.org/Mus_musculus/',
			'CS_DS139': 'http://www.ensembl.org/Mus_musculus/',
			'CS_DS312': 'http://www.ensembl.org/Caenorhabditis_elegans/'
			//TODO: Extend
		}
	};
			
	easyDAS.Config = conf;
})();
 
