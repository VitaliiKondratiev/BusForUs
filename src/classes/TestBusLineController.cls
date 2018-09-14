@isTest
private class TestBusLineController {
	
	@testSetup static void fillDataBaseForBusControl() {

	System.debug(LoggingLevel.INFO, 'Start creating BusLine data');

	Profile withoutRights = [SELECT Id FROM Profile WHERE Name='BusPartner'];

	User busPartner = new User(Alias = 'standt', Email='BusPartner@BusForUs.com', 
		EmailEncodingKey='UTF-8', LastName='NoRights', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = withoutRights.Id, 
		TimeZoneSidKey='America/Los_Angeles', UserName='BusPartner@BusForUs.com');
	

	Profile withRights = [SELECT Id FROM Profile WHERE Name='System Administrator'];

	User sysAdmin = new User(Alias = 'standt', Email='sysAdmin@BusForUs.com', 
		EmailEncodingKey='UTF-8', LastName='WithRights', LanguageLocaleKey='en_US', 
		LocaleSidKey='en_US', ProfileId = withRights.Id, 
		TimeZoneSidKey='America/Los_Angeles', UserName='sysAdmin@BusForUs.com');

	Database.insert(busPartner);
	Database.insert(sysAdmin);

	List<Account> testBusOwners = new List<Account>();
	for (integer i = 0 ; i<3 ; i++ ) {
		Account testBusOwner = new Account();
		testBusOwner.name    = 'R'+i+'D'+i;

		testBusOwners.add(testBusOwner);
	}
	Database.insert(testBusOwners);

	List<Bus__c> testBuses = new List<Bus__c>();
	for (integer i = 0 ; i<9 ; i++ ) {
		Bus__c testBus       = new Bus__c();
		testBus.name         = 'BusNumber: '+i;	
		integer index        = Math.mod(i,3);			
		testBus.Account__c   = testBusOwners.get(index).Id;
		testBus.Available__c = true;				
		testBuses.add(testBus);
	}	
	Database.insert(testBuses);

	List<Line__c> testLines = new List<Line__c>();
	for (integer i = 0 ; i<3 ; i++ ) {
		Line__c testLine = new Line__c();				
		testLines.add(testLine);
	}			
	Database.insert(testLines);
	
	List<Bus_Line__c> testBusLines = new List<Bus_Line__c>();
	for (integer i = 0 ; i<3 ; i++ ) {
		Bus_Line__c testBusLine = new Bus_Line__c();
		testBusLine.Bus__c  = [SELECT ID FROM Bus__c WHERE name = 'BusNumber: 0'].Id;
		testBusLine.Line__c = testLines.get(i).Id;				
		testBusLines.add(testBusLine);
	}			
	Database.insert(testBusLines);
	
	System.debug(LoggingLevel.INFO, 'Stop creating BusLine data');
	}
	
	@isTest static void testSuccessGetBusLines() {
				
	User sysAdmin = [SELECT ID FROM USER WHERE LastName = 'WithRights' LIMIT 1];
	
		System.RunAs(sysAdmin){
			Account busPartnerAcc         = [Select id from account where name = 'R2D2'];
			Boolean available             = true;			
			Map<String, Object> mapResult = new Map<String, Object>();

			test.startTest();
			System.debug(LoggingLevel.INFO, 'Start testSuccessGetBusLines');
			try{
				System.debug(LoggingLevel.INFO, 'Try to get BusLine info');

				mapResult                       = BusLineController.getBusLines(busPartnerAcc.Id);

				List<ModelBox.Bus> resultBuses  = (List<ModelBox.Bus>) mapResult.get('buses');
				System.assertEquals(resultBuses.size(),3);

				List<ModelBox.Line> resultLines = (List<ModelBox.Line>) mapResult.get('lines');	
				System.assertEquals(resultLines.size(),3);
				
				System.debug(LoggingLevel.FINE, 'Success result');
			}
			catch(Exception e){
				System.debug(LoggingLevel.ERROR, 'Failed');
				System.debug(LoggingLevel.ERROR, e.getMessage());

				System.assert(false);
			}
			System.debug(LoggingLevel.FINE, 'Stop testSuccessGetBusLines');
			test.stopTest();
		}		
	}
	
	@isTest static void testFailedGetBusLines() {
				
	User busPartnerWithoutRights = [SELECT ID FROM USER WHERE LastName = 'NoRights' LIMIT 1];
	
		System.RunAs(busPartnerWithoutRights){
			Account busPartnerAcc = [Select id from account where name = 'R2D2'];
			Boolean available     = true;			
			Map<String, Object> mapResult = new Map<String, Object>();

			test.startTest();
			System.debug(LoggingLevel.INFO, 'Start testFailedGetBusLines');
			try{
				System.debug(LoggingLevel.INFO, 'Try to get BusLine info'); 

				mapResult = BusLineController.getBusLines(busPartnerAcc.Id);
				List<ModelBox.Bus> resultBuses  = (List<ModelBox.Bus>) mapResult.get('buses');
				List<ModelBox.Line> resultLines = (List<ModelBox.Line>) mapResult.get('lines');

				System.debug(LoggingLevel.ERROR, 'Got BusLine info without rights');
				System.assert(false);				
			}
			catch(Exception e){
				System.assert(true);

				System.debug(LoggingLevel.FINE, 'Success result');
				System.debug(LoggingLevel.FINER, 'CustomException thrown');
			}
			System.debug(LoggingLevel.FINE, 'Stop testFailedGetBusLines');
			test.stopTest();
		}		
	}

	@isTest static void testSuccessInsertRoute() {
		User sysAdmin = [SELECT ID FROM USER WHERE LastName = 'WithRights' LIMIT 1];
	
		System.RunAs(sysAdmin){
			Id testNewBus  = [Select id From Bus__c Where name ='BusNumber: 1' LIMIT 1].Id;
			Id testNewLine = [Select id From Line__c ][0].Id;
			
			test.startTest();
			System.debug(LoggingLevel.INFO, 'Start testSuccessInsertRoute');
			try{
				System.debug(LoggingLevel.INFO, 'Try to insert into BusLine');

				BusLineController.insertRoute(testNewBus,testNewLine);				
				System.assertEquals([ SELECT ID 
				FROM Bus_Line__c
				WHERE Bus__c = :testNewBus 
				AND Line__c  =:testNewLine].size(),1);

				System.debug(LoggingLevel.FINE, 'Success result');
			}
			catch(Exception e){
				System.debug(LoggingLevel.ERROR, 'Failed');
				System.debug(LoggingLevel.FINER, e.getMessage());

				System.assert(false);
			}
			System.debug(LoggingLevel.FINE, 'Stop testSuccessInsertRoute');
			test.stopTest();
		}
	}
	
	@isTest static void testFailedInsertRoute() {
			
		User busPartnerWithoutRights = [SELECT ID FROM USER WHERE LastName = 'NoRights' LIMIT 1];
	
		System.RunAs(busPartnerWithoutRights){
			Id testNewBus  = [Select id From Bus__c Where name ='BusNumber: 1' LIMIT 1].Id;
			Id testNewLine = [Select id From Line__c ][0].Id;			

			test.startTest();
			System.debug(LoggingLevel.INFO, 'Start testFailedInsertRoute');
			try{
				System.debug(LoggingLevel.INFO, 'Try to insert BusLine');
				
				BusLineController.insertRoute(testNewBus,testNewLine);
				System.debug(LoggingLevel.ERROR, 'Failed');				
			}
			catch(Exception e){
				System.debug(LoggingLevel.FINE, 'Success result');
				System.debug(LoggingLevel.FINER, 'CustomException thrown');

				System.assert(true);
			}
			System.debug(LoggingLevel.FINE, 'Stop testFailedInsertRoute');
			test.stopTest();
		}
	}

	@isTest static void testSuccessDeleteBusRoute() {
			
		User sysAdmin = [SELECT ID FROM USER WHERE LastName = 'WithRights' LIMIT 1];		
	
		System.RunAs(sysAdmin){
			Id testRemoveBus  = [Select id From Bus__c Where name ='BusNumber: 0' LIMIT 1].Id;
			Id testRemoveLine = [Select id From Line__c ][0].Id;

			test.startTest();
			System.debug(LoggingLevel.INFO, 'Start testSuccessRemoveBus');
			try{
				System.debug(LoggingLevel.INFO, 'Try to remove Route');			
				BusLineController.deleteBusRoute(testRemoveBus,testRemoveLine);
				System.assertEquals([
				Select ID
				FROM Bus_Line__c 
				WHERE Bus__c  =: testRemoveBus
				AND   Line__c =: testRemoveLine].size(),0);
				System.debug(LoggingLevel.FINE, 'Success result');
			}
			catch(Exception e){
				System.debug(LoggingLevel.ERROR, 'Failed');
				System.debug(LoggingLevel.FINER, e.getMessage());

				System.assert(false);
			}
			System.debug(LoggingLevel.FINE, 'Stop testSuccessRemoveBus');
			test.stopTest();
		}
	}
	
	@isTest static void testFailedDeleteBusRoute() {
				User busPartnerWithoutRights = [SELECT ID FROM USER WHERE LastName = 'NoRights' LIMIT 1];		
	
		System.RunAs(busPartnerWithoutRights){
			Id testRemoveBus  = [Select id From Bus__c Where name ='BusNumber: 0' LIMIT 1].Id;
			Id testRemoveLine = [Select id From Line__c ][0].Id;

			test.startTest();
			System.debug(LoggingLevel.INFO, 'Start testFailedDeleteBusRoute');
			try{
				System.debug(LoggingLevel.INFO, 'Try to remove Route');			
				BusLineController.deleteBusRoute(testRemoveBus,testRemoveLine);
				System.debug(LoggingLevel.ERROR, 'Failed');

				System.assert(false);
			}
			catch(Exception e){
				System.debug(LoggingLevel.FINE, 'Success result');
				System.debug(LoggingLevel.FINER,'CustomException thrown');
				System.assert(true);
			}
			System.debug(LoggingLevel.FINE, 'Stop testFailedDeleteBusRoute');
			test.stopTest();
		}  
	}
}