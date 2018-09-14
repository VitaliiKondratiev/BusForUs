@isTest(SeeAllData=false) 
private class TestBusController {

	@testSetup static void fillDataBaseForBusControl() {

	System.debug(LoggingLevel.INFO, 'Start creating data');

	Profile withoutRights = [SELECT Id FROM Profile WHERE Name = 'BusPartner'];
	
	User busPartnerWithoutRights = new User(Alias = 'standt', Email ='BusPartner@BusForUs.com', 
		EmailEncodingKey ='UTF-8', LastName ='NoRights', LanguageLocaleKey ='en_US', 
		LocaleSidKey = 'en_US', ProfileId = withoutRights.Id, 
		TimeZoneSidKey ='America/Los_Angeles', UserName = 'BusPartner@BusForUs.com');
	
	Profile withRights = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

	User sysAdmin = new User(Alias = 'standt', Email ='sysAdmin@BusForUs.com', 
		EmailEncodingKey ='UTF-8', LastName ='WithRights', LanguageLocaleKey='en_US', 
		LocaleSidKey = 'en_US', ProfileId = withRights.Id, 
		TimeZoneSidKey = 'America/Los_Angeles', UserName ='sysAdmin@BusForUs.com');

	Database.insert(busPartnerWithoutRights);
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
			testBus.Account__c   = testBusOwners.get(Math.mod(i,3)).Id;
			testBus.Available__c = true;				
			testBuses.add(testBus);
		}		
		Database.insert(testBuses);
		System.debug(LoggingLevel.INFO, 'Stop creating data');
	}

	@isTest static void testSuccessGetBuses() {
		
		User sysAdmin = [SELECT ID FROM USER WHERE LastName = 'WithRights' LIMIT 1];
	
		System.RunAs(sysAdmin){
			Account busPartnerAcc         = [SELECT id FROM account WHERE name = 'R2D2'];
			Boolean available             = true;			
			Map<String, Object> mapResult = new Map<String, Object>();

			test.startTest();
			System.debug(LoggingLevel.INFO, 'Start testSuccessGetBuses');

			try{
				System.debug(LoggingLevel.INFO, 'Try to get Bus info');

				mapResult                    = BusController.getBuses(busPartnerAcc.Id,available);
				List<ModelBox.Bus> resultBus = (List<ModelBox.Bus>) mapResult.get('buses');
				System.assertEquals(mapResult.get('total') , resultBus.size());

				System.debug(LoggingLevel.FINE, 'Success result');
			}
			catch(Exception e){
				System.assert(false);
				
				System.debug(LoggingLevel.ERROR, 'Failed');
				System.debug(LoggingLevel.ERROR, e.getMessage());
			}

			System.debug(LoggingLevel.FINE, 'Stop testSuccessGetBuses');
			test.stopTest();
		}		
	}

	@isTest static void testFailedGetBuses() {
		
		User busPartnerWithoutRights = [SELECT ID FROM USER WHERE LastName = 'NoRights' LIMIT 1];
	
		System.RunAs(busPartnerWithoutRights){
			Account busPartnerAcc         = [SELECT id FROM account WHERE name = 'R2D2'];
			Boolean available             = true;			
			Map<String, Object> mapResult = new Map<String, Object>();

			test.startTest();
			System.debug(LoggingLevel.INFO, 'Start testFailedGetBuses');

			try{
				System.debug(LoggingLevel.INFO, 'Try to get Bus info');

				mapResult                    = BusController.getBuses(busPartnerAcc.Id,available);
				List<ModelBox.Bus> resultBus = (List<ModelBox.Bus>) mapResult.get('buses');

				System.debug(LoggingLevel.ERROR, 'Got Bus info without rights');
				System.assert(false);				
			}
			catch(Exception e){
				System.assert(true);

				System.debug(LoggingLevel.FINE, 'Success result');
				System.debug(LoggingLevel.FINER, 'CustomException thrown');
			}

			System.debug(LoggingLevel.FINE, 'Stop testFailedGetBuses');
			test.stopTest();
		}	
	}

	@isTest static void testSuccessInsertBus() {
		
		User sysAdmin = [SELECT ID FROM USER WHERE LastName = 'WithRights' LIMIT 1];
	
		System.RunAs(sysAdmin){
			Account busPartnerAcc = [Select id from account where name = 'R2D2'];
			String testNewBusName = 'BOGDAN';			

			test.startTest();
			System.debug(LoggingLevel.INFO, 'Start testSuccessInsertBus');
			try{
				System.debug(LoggingLevel.INFO, 'Try to insert Bus');

				BusController.insertBus(busPartnerAcc.Id, testNewBusName);
				System.assertEquals([SELECT ID FROM Bus__c WHERE name = 'BOGDAN'].size(),1);

				System.debug(LoggingLevel.FINE, 'Success result');
				}
			catch(Exception e){
				System.debug(LoggingLevel.ERROR, 'Failed');
				System.debug(LoggingLevel.FINER, e.getMessage());

				System.assert(false);
			}
			System.debug(LoggingLevel.FINE, 'Stop testSuccessInsertBus');
			test.stopTest();
		}			
	}

	@isTest static void testFailedInsertBus() {
	
		User busPartnerWithoutRights = [SELECT ID FROM USER WHERE LastName = 'NoRights' LIMIT 1];
	
		System.RunAs(busPartnerWithoutRights){
			Account busPartnerAcc = [Select id from account where name = 'R2D2'];
			String testNewBusName = 'BOGDAN';			

			test.startTest();
			System.debug(LoggingLevel.INFO, 'Start testFailedInsertBus');
			try{
				System.debug(LoggingLevel.INFO, 'Try to insert Bus');

				BusController.insertBus(busPartnerAcc.Id, testNewBusName);
				System.assert(false);

				System.debug(LoggingLevel.ERROR, 'Failed');				
			}
			catch(Exception e){
				System.debug(LoggingLevel.FINE, 'Success result');
				System.debug(LoggingLevel.FINER, 'CustomException thrown');

				System.assert(true);
			}
			System.debug(LoggingLevel.FINE, 'Stop testFailedInsertBus');
			test.stopTest();
		}	
	}

	@isTest static void testSuccessUpdateBus() {
	
		User sysAdmin = [SELECT ID FROM USER WHERE LastName = 'WithRights' LIMIT 1];		
	
		System.RunAs(sysAdmin){
			Bus__c testBusFOrUpd      = [SELECT ID,NAME,Account__c FROM Bus__c WHERE NAME='BusNumber: 0' LIMIT 1];
			testBusFOrUpd.name        = 'Test';
			String jsonToSendToMethod = JSON.serialize(new ModelBox.Bus(testBusFOrUpd));

			test.startTest();
			System.debug(LoggingLevel.INFO, 'Start testSuccessUpdateBus');
			try{
				System.debug(LoggingLevel.INFO, 'Try to upd Bus');
				System.debug(LoggingLevel.INFO, jsonToSendToMethod);

				BusController.updateBus(jsonToSendToMethod);
				System.assertEquals([Select ID FROM Bus__c WHERE name = 'Test'].size(),1);

			}
			catch(Exception e){
				System.debug(LoggingLevel.FINE, e.getMessage());
				System.debug(LoggingLevel.FINER, 'CustomException thrown');
				System.assert(false);
			}
			System.debug(LoggingLevel.FINE, 'Stop testSuccessUpdateBus');
			test.stopTest();
		}		
	}

	@isTest static void testFailedUpdateBus() {

		User busPartnerWithoutRights = [SELECT ID FROM USER WHERE LastName = 'NoRights' LIMIT 1];		
	
		System.RunAs(busPartnerWithoutRights){
			Bus__c testBusFOrUpd = [Select ID,NAME,Account__c FROM Bus__c WHERE NAME='BusNumber: 0' LIMIT 1];
			testBusFOrUpd.name = 'Test';
			String jsonToSendToMethod = JSON.serialize(new ModelBox.Bus(testBusFOrUpd));

			test.startTest();
			System.debug(LoggingLevel.INFO, 'Start testFailedUpdateBus');
			try{
				System.debug(LoggingLevel.INFO, 'Try to upd Bus');

				BusController.updateBus(jsonToSendToMethod);
				System.assert(false);

				System.debug(LoggingLevel.ERROR, 'Failed');
			}
			catch(Exception e){
				System.debug(LoggingLevel.FINE, 'Success result');
				System.debug(LoggingLevel.FINER, 'CustomException thrown');

				System.assert(true);
			}
			System.debug(LoggingLevel.FINE, 'Stop testFailedUpdateBus');
			test.stopTest();
		}	
	}


	@isTest static void testSuccessRemoveBus() {

		User sysAdmin = [SELECT ID FROM USER WHERE LastName = 'WithRights' LIMIT 1];		
	
		System.RunAs(sysAdmin){

			Bus__c testBusFOrUpd      = [Select ID,NAME,Account__c,Available__c FROM Bus__c WHERE NAME='BusNumber: 0' LIMIT 1];
			String jsonToSendToMethod = JSON.serialize(new ModelBox.Bus(testBusFOrUpd));

			test.startTest();
			System.debug(LoggingLevel.INFO, 'Start testSuccessRemoveBus');
			try{
				System.debug(LoggingLevel.INFO, 'Try to remove Bus');

				BusController.removeBus(jsonToSendToMethod);
				System.assertEquals([Select ID FROM Bus__c WHERE name = 'BusNumber: 0'].size(),0);

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

	@isTest static void testFailedRemoveBus() {
	
		User busPartnerWithoutRights = [SELECT ID FROM USER WHERE LastName = 'NoRights' LIMIT 1];		
	
		System.RunAs(busPartnerWithoutRights){
			Bus__c testBusFOrUpd      = [Select ID,NAME,Account__c,Available__c FROM Bus__c WHERE NAME='BusNumber: 0' LIMIT 1];
			String jsonToSendToMethod = JSON.serialize(new ModelBox.Bus(testBusFOrUpd));

			test.startTest();
			System.debug(LoggingLevel.INFO, 'Start testFailedRemoveBus');
			try{
				System.debug(LoggingLevel.INFO, 'Try to remove Bus');

				BusController.removeBus(jsonToSendToMethod);
				System.assert(false);

				System.debug(LoggingLevel.ERROR, 'Failed');
			}
			catch(Exception e){
				System.debug(LoggingLevel.FINE, 'Success result');
				System.debug(LoggingLevel.FINER,'CustomException thrown');

				System.assert(true);
			}
			System.debug(LoggingLevel.FINE, 'Stop testFailedRemoveBus');
			test.stopTest();
		}	
	}			
} 