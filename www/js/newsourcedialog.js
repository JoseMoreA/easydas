/**
 * @author bernat gel
 */

/**Contains the definition of the new DAS source dialog*/ 

var easyDAS = (easyDAS)?easyDAS:{};


(function() {
	//Private Attributes
	var dialog = undefined;
	var can_finish;
	
	var next;
	var previous;
	var finish;

	
	var current_step;
	
	//Set the Steps array;
	var steps_ids = [
		'upload',
		'file_type',
		'source',
		'mapping',
		'defaults',
		'types',
		'methods'	
	];
	var steps =  [];
	//Private functions
	var createDialog = function() {
		dialog = easyDAS.UI.dialog({
			title: 'Create Source',
			modal: true
		});
		//Top Label
		
		//Buttons
		next = $('<button class="right">Next</button>').click(function(){
			self.setStep(current_step + 1)
		});
		finish = $('<button class="right">Finish</button>').click(function() {
			self.finishWizard();
		});
		previous = $('<button class="left">Previous</button>').click(function(){
			self.setStep(current_step - 1)
		});
		dialog.addButton(next);
		dialog.addButton(finish);
		dialog.addButton(previous);
	};
	var initSteps = function(){
		for (var i = 0, l = steps_ids.length; i < l; ++i) 
			steps[i] = easyDAS.NewSourceDialog.Steps[steps_ids[i]];
	};
	
	
	
	var self = {
		//Public Attributes
		metadata: undefined,
		
		//Public Methods
		start: function() {
			if(!dialog) {
				initSteps();
				createDialog();
			}
			//self.reset();
			self.setStep(0);
			dialog.show();
		},
		setStep: function(num) {
			//Save the info from the currrent one
			var error = false;
			if(current_step > 0 && num>current_step) {
				error = steps[current_step].getPanelData();
			}
			if (!error) {
				//and change
				current_step = num;
				var st = steps[num];
				dialog.body(st.getPanel(self));
				//set the buttons
				self.enablePrevious(num >= 1);
				self.enableNext(num < (steps.length - 1));
				
				st.initPanel(self.metadata);
				//set the top labels

				//move the dialog to 100:100 position again
				dialog.moveToTopLeft();
				
			}

			return;
		},
		finishWizard: function() {
			//check we can actually finish
			if(!self.canFinish()) return {error: {id: 'cant_finish', msg: "The new source wizard can't finish"}};
			if(typeof(steps[current_step].getPanelData)=='function') {
				steps[current_step].getPanelData();
			}
			var error = easyDAS.Controller.createSource(self.metadata);
			if(error) {
				alert("The source could not be created. Please, try it again.\n"+(error.error && error.error.msg)?error.msg:'');
			}
		},
		closeWizard: function() {
			dialog.hide();
		},
		canFinish: function(val) {
			if (val != undefined) {
				can_finish = val;
				finish.attr('disabled', (val) ? '' : 'disabled');
			}
			return can_finish;
		},
		enableNext: function(val) {
			next.attr('disabled', (val)?'':'disabled');
		},
		enablePrevious: function(val) {
			previous.attr('disabled', (val)?'':'disabled');
		},
		Steps: {}	
	}
	easyDAS.NewSourceDialog = self;
	
	
	
}());

	
