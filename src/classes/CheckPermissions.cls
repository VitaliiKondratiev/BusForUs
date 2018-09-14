public with sharing class CheckPermissions {

	public static Boolean checkAccessFLS(String sObjectName, List<String> sObjectFieldsName){
		
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
		Schema.SObjectType ctype           = gd.get(sObjectName);
		Boolean checkAccess   			   = ctype.getDescribe().isAccessible();

		if(!checkAccess){
			return checkAccess;
		}

		for(String fieldName: sObjectFieldsName){
			checkAccess = ctype.getDescribe().fields.getMap().get(fieldName).getDescribe().isAccessible();
				System.debug(LoggingLevel.INFO, 'check your rights to access '+sObjectName+'.'+fieldName);    
				if(!checkAccess){
					System.debug(LoggingLevel.ERROR ,'you do not have access rights to '+sObjectName+'.'+fieldName);     
					return checkAccess;
				}
			else{
				System.debug(LoggingLevel.FINE, 'you have access rights to '+sObjectName+'.'+fieldName); 
			}
		}
		return checkAccess;
	}

	public static Boolean checkUpdateRights(String sObjectName){
		
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
		Schema.SObjectType ctype 		   = gd.get(sObjectName);
		Boolean checkAccess 			   = ctype.getDescribe().isUpdateable();

		System.debug(LoggingLevel.INFO,'check your rights to Insert records to ' + sObjectName);

		if(!checkAccess){
			System.debug(LoggingLevel.FINE,'You have rights to Insert records to ' + sObjectName);
		}
		else{
			System.debug(LoggingLevel.ERROR,'You do not have to Insert records to ' + sObjectName);
		}

		return checkAccess;
	
	}

		public static Boolean checkInsertRights(String sObjectName){

		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
		Schema.SObjectType ctype           = gd.get(sObjectName);
		Boolean checkAccess 			   = ctype.getDescribe().isCreateable();
		
		System.debug(LoggingLevel.INFO,'check your rights to Insert records to ' + sObjectName);
		
		if(!checkAccess){
			System.debug(LoggingLevel.FINE,'You have rights to Insert records to ' + sObjectName);
		}
		else{
			System.debug(LoggingLevel.ERROR,'You do not have to Insert records to ' + sObjectName);
		}

		return checkAccess;
	}

		public static Boolean checkDeleteRights(String sObjectName){

		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
		Schema.SObjectType ctype		   = gd.get(sObjectName);
		Boolean checkAccess 			   = ctype.getDescribe().isDeletable();
		
		System.debug(LoggingLevel.INFO,'check your rights to delete records from ' + sObjectName);
		
		if(!checkAccess){
			System.debug(LoggingLevel.FINE,'You have rights to delete records from ' + sObjectName);
		}
		else{
			System.debug(LoggingLevel.ERROR,'You do not have rights to delete records from ' + sObjectName);
		}
		return checkAccess;
	}

	

}