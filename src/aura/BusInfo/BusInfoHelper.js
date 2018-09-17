({
	showingToasts : function(title, type, message) {
		var showToast = $A.get("e.force:showToast");
		if(showToast != undefined){
			showToast.setParams({
				'title'   : title,
				'type'   : type,
				'message': message
			});
			showToast.fire();
		}
	}
})