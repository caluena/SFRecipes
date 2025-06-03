@IsTest
public class QueryBuilderTests {
	private static Boolean isValid = true;

	@IsTest
	public static void testEntityName() {
		SObjectType entity = new QueryBuilder(Contact.SObjectType)
			.selectField(Contact.Id)
			.getEntity();

		Assert.areEqual(Contact.SObjectType, entity);
	}

	@IsTest
	public static void testBasicSelectQuery() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectFields(new SObjectField[] {
				Opportunity.Id,
				Opportunity.Name,
				Opportunity.CloseDate,
				Opportunity.StageName
			})
			.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual('SELECT Id, Name, CloseDate, StageName FROM Opportunity', query);
	}

	@IsTest
	public static void testBasicSelectQueryWithStringSet() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectFields(new Set<String>{
				'Id',
				'Name',
				'CloseDate',
				'StageName'
			})
			.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual('SELECT Id, Name, CloseDate, StageName FROM Opportunity', query);
	}

	@IsTest
	public static void testBasicSelectQueryWithSubQuery() {
		QueryBuilder contactQuery = new QueryBuilder(Contact.SObjectType)
        	.selectFields(new SObjectField[] {
				Contact.Id,
				Contact.FirstName,
				Contact.LastName,
				Contact.Email
			});

		String query = new QueryBuilder(Account.SObjectType)
			.selectFields(new SObjectField[] {
				Account.Id,
				Account.Name,
				Account.Phone
			})
			.subQuery(Account.SObjectType, contactQuery)
			.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual('SELECT Id, Name, Phone, (SELECT Id, FirstName, LastName, Email FROM Contacts) FROM Account', query);
	}

	@IsTest
	public static void testBasicSelectQueryWithStringList() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectFields(new List<String>{
				'Id',
				'Name',
				'CloseDate',
				'StageName'
			})
			.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual('SELECT Id, Name, CloseDate, StageName FROM Opportunity', query);
	}

	@IsTest
	public static void testBasicSelectQueryWithObjectField() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectFields(new List<Object>{
				(Object)Opportunity.Id,
				(Object)'Name',
				(Object)Opportunity.CloseDate,
				(Object)'StageName'
			})
			.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual('SELECT Id, Name, CloseDate, StageName FROM Opportunity', query);
	}

	@IsTest
	public static void testBasicSelectQueryWithObjectsField() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectCountField(Opportunity.Id)
			.selectField(Opportunity.Name, 'Nome')
            .selectField((Object)Opportunity.AccountId, 'Conta')
			.selectField('CloseDate', 'Fechamento')
			.selectField((Object)'StageName', 'Fase')
			.selectField((Object)'IsClosed')
			.groupBy('Name')
            .groupBy((Object)Opportunity.AccountId)
			.groupBy((Object)Opportunity.CloseDate)
			.groupBy(Opportunity.StageName)
            .groupBy((Object)'IsClosed')
			.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual('SELECT COUNT(Id), Name Nome, AccountId Conta, CloseDate Fechamento, StageName Fase, IsClosed FROM Opportunity GROUP BY Name, AccountId, CloseDate, StageName, IsClosed', query);
	}
    
    @IsTest
	public static void testGroupSelectQueryWithObjectsField() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectCountField(Opportunity.Id)
			.selectField(Opportunity.Name, 'Nome')
			.selectField('CloseDate', 'Fechamento')
			.selectField((Object)'StageName', 'Fase')
			.selectField((Object)'IsClosed')
            .groupBy(new List<Object>{ (Object)'Name',(Object)Opportunity.CloseDate,(Object)Opportunity.StageName,(Object)'IsClosed' })
			.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual('SELECT COUNT(Id), Name Nome, CloseDate Fechamento, StageName Fase, IsClosed FROM Opportunity GROUP BY Name, CloseDate, StageName, IsClosed', query);
	}

	@IsTest
	public static void testRelatedFieldSelectQuery() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectFields(new SObjectField[] {
				Opportunity.Id
			})
            .selectField((Object)Opportunity.StageName)
			.selectRelatedField(Account.SObjectType, Account.Name)
			.selectRelatedField(Opportunity.MainContact__c, Account.Name)
		.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual('SELECT Id, StageName, Account.Name, MainContact__r.Name FROM Opportunity', query);
	}
    
    @IsTest
	public static void testRelatedFieldSelectQueryWithException() {
		
        
		Test.startTest();
        try {
            String query = new QueryBuilder(Opportunity.SObjectType)
					.selectFields(new SObjectField[] {
						Opportunity.Id
					})
           			.selectField((Object)Opportunity.StageName)
					.selectRelatedField(Account.Name, Account.Industry)
					.toString();
            
            new SOQLTester().tryQuery(query);
        } catch (Exception e) {
            Assert.areEqual('O campo fornecido não é um relacionamento válido: Name', e.getMessage());
        }		
		Test.stopTest();		
	}
    
    @IsTest
	public static void testBasicSelectQueryWithOrderBySObjectTypeAndSObjectField() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectFields(new SObjectField[] {
				Opportunity.Id
			})
			.selectRelatedField(Account.SObjectType, Account.Name)
            .orderBy(Account.SObjectType, Account.Name)
		.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual('SELECT Id, Account.Name FROM Opportunity ORDER BY Account.Name', query);
	}
    
    @IsTest
	public static void testBasicSelectQueryWithOrderBySObjectTypeAndSObjectFieldAndSortingOption() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectFields(new SObjectField[] {
				Opportunity.Id
			})
			.selectRelatedField(Account.SObjectType, Account.Name)
            .orderBy(Account.SObjectType, Account.Name, QueryBuilder.DESCENDING)
		.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual('SELECT Id, Account.Name FROM Opportunity ORDER BY Account.Name DESC', query);
	}
    
    @IsTest
	public static void testBasicSelectQueryWithOrderBySObjectField() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectFields(new SObjectField[] {
				Opportunity.Id
			})
			.selectRelatedField(Account.SObjectType, Account.Name)
            .orderBy(Opportunity.Name)
		.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual('SELECT Id, Account.Name FROM Opportunity ORDER BY Name', query);
	}
    
    @IsTest
	public static void testBasicSelectQueryWithOrderByStringField() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectFields(new SObjectField[] {
				Opportunity.Id
			})
			.selectRelatedField(Account.SObjectType, Account.Name)
            .orderBy('Account.Name')
		.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual('SELECT Id, Account.Name FROM Opportunity ORDER BY Account.Name', query);
	}
    
    @IsTest
	public static void testBasicSelectQueryWithOrderByStringFieldAndSortingOption() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectFields(new SObjectField[] {
				Opportunity.Id
			})
			.selectRelatedField(Account.SObjectType, Account.Name)
            .orderBy('Account.Name', QueryBuilder.ASCENDING)
		.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual('SELECT Id, Account.Name FROM Opportunity ORDER BY Account.Name ASC', query);
	}
    
    @IsTest
	public static void testBasicSelectQueryWithOrderByObjectField() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectFields(new SObjectField[] {
				Opportunity.Id
			})
			.selectRelatedField(Account.SObjectType, Account.Name)
            .orderBy((Object)Opportunity.Name)
		.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual('SELECT Id, Account.Name FROM Opportunity ORDER BY Name', query);
	}
    
    @IsTest
	public static void testBasicSelectQueryWithOrderByObjectStringField() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectFields(new SObjectField[] {
				Opportunity.Id
			})
			.selectRelatedField(Account.SObjectType, Account.Name)
            .orderBy((Object)'Name')
		.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual('SELECT Id, Account.Name FROM Opportunity ORDER BY Name', query);
	}
    
    @IsTest
	public static void testBasicSelectQueryWithOrderByListObjectField() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectFields(new SObjectField[] {
				Opportunity.Id
			})
			.selectRelatedField(Account.SObjectType, Account.Name)
            .orderBy(new List<Object>{ (Object)'Name', (Object)Account.Name })
		.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual('SELECT Id, Account.Name FROM Opportunity ORDER BY Name, Account.Name', query);
	}
	
	@IsTest
	public static void testWhereClauseQuery() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectFields(new SObjectField[] {
				Opportunity.Id,
				Opportunity.Name,
				Opportunity.CloseDate,
				Opportunity.StageName
			})
			.whereClause(new QueryCondition()
				.equals(Opportunity.Name, 'Test Opportunity')
				.equals(Opportunity.CloseDate, Date.newInstance(2020, 07, 07))
				.notEquals(Opportunity.Name, 'My Opportunity')
				.notEquals(Opportunity.CloseDate, Date.newInstance(2020, 08, 08))
				.greaterThan(Opportunity.Amount, 100)
				.greaterThan(Opportunity.CloseDate, Date.newInstance(2020, 06, 06))
				.greaterThanAndEqualTo(Opportunity.Amount, 101)
				.greaterThanAndEqualTo(Opportunity.CloseDate, Date.newInstance(2020, 06, 07))
				.lessThan(Opportunity.Amount, 900)
				.lessThan(Opportunity.CloseDate, Date.newInstance(2020, 09, 09))
				.lessThanAndEqualTo(Opportunity.Amount, 899)
				.lessThanAndEqualTo(Opportunity.CloseDate, Date.newInstance(2020, 09, 08))
				.isFalse(Opportunity.IsPrivate)
				.isNull(Opportunity.NextStep)
				.isNotNull(Opportunity.LeadSource)
				.isLike(Opportunity.Name, '%Test%')
				.isIn(Opportunity.StageName, new List<String>{ 'Closed Won', 'Closed Lost' })
				.isIn(Opportunity.LeadSource, new Set<String>{ 'Web', 'Other' })
				.isIn('Id', new Set<Id>{ '0060q00000GqOOl', '0060q00000H30K1' })
				.isNotIn(Opportunity.StageName, new List<String>{ 'Proposal Made', 'Negotiation' })
				.isNotIn(Opportunity.LeadSource, new Set<String>{ 'Referral' })
				.isNotIn(Opportunity.Id, new Set<Id>{ '0060q00000ClJF4', '0060q00000G2evW' })
			)
			.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual(
				'SELECT Id, Name, CloseDate, StageName ' +
				'FROM Opportunity ' +
				'WHERE ' +
					'Name = \'Test Opportunity\' ' +
					'AND CloseDate = 2020-07-07 ' +
					'AND Name != \'My Opportunity\' ' +
					'AND CloseDate != 2020-08-08 ' +
					'AND Amount > 100 ' +
					'AND CloseDate > 2020-06-06 ' +
					'AND Amount >= 101 ' +
					'AND CloseDate >= 2020-06-07 ' +
					'AND Amount < 900 ' +
					'AND CloseDate < 2020-09-09 ' +
					'AND Amount <= 899 ' +
					'AND CloseDate <= 2020-09-08 ' +
					'AND IsPrivate = false ' +
					'AND NextStep = null ' +
					'AND LeadSource != null ' +
					'AND Name LIKE \'%Test%\' ' +
					'AND StageName IN (\'Closed Won\', \'Closed Lost\') ' +
					'AND LeadSource IN (\'Web\', \'Other\') ' +
					'AND Id IN (\'0060q00000GqOOl\', \'0060q00000H30K1\') ' +
					'AND StageName NOT IN (\'Proposal Made\', \'Negotiation\') ' +
					'AND LeadSource NOT IN (\'Referral\') ' +
					'AND Id NOT IN (\'0060q00000ClJF4\', \'0060q00000G2evW\')',
				query);
	}

	@IsTest
	public static void testWhereClauseQueryDayOnlyDate() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectFields(new SObjectField[] {
				Opportunity.Id,
				Opportunity.Name,
				Opportunity.CloseDate,
				Opportunity.StageName
			})
			.whereClause(new QueryCondition()
				.equals(Opportunity.Name, 'Test Opportunity')
				.equals(Opportunity.CloseDate, Date.newInstance(2020, 07, 07))
				.notEquals(Opportunity.Name, 'My Opportunity')
				.notEquals(Opportunity.CloseDate, Date.newInstance(2020, 08, 08))
				.greaterThan(Opportunity.Amount, 100)
				.greaterThan(Opportunity.CloseDate, Date.newInstance(2020, 06, 06))
				.greaterThanAndEqualTo(Opportunity.Amount, 101)
				.greaterThanAndEqualToDayOnly(Opportunity.CreatedDate, Date.newInstance(2020, 06, 07))
				.lessThan(Opportunity.Amount, 900)
				.lessThan(Opportunity.CloseDate, Date.newInstance(2020, 09, 09))
				.lessThanAndEqualTo(Opportunity.Amount, 899)
				.lessThanAndEqualToDayOnly(Opportunity.CreatedDate, Date.newInstance(2020, 09, 08))
				.isFalse(Opportunity.IsPrivate)
				.isNull(Opportunity.NextStep)
				.isNotNull(Opportunity.LeadSource)
				.isLike(Opportunity.Name, '%Test%')
				.isIn(Opportunity.StageName, new List<String>{ 'Closed Won', 'Closed Lost' })
				.isIn(Opportunity.LeadSource, new Set<String>{ 'Web', 'Other' })
				.isIn('Id', new Set<String>{ '0060q00000GqOOl', '0060q00000H30K1' })
				.isNotIn(Opportunity.StageName, new List<String>{ 'Proposal Made', 'Negotiation' })
				.isNotIn(Opportunity.LeadSource, new Set<String>{ 'Referral' })
				.isNotIn(Opportunity.Id, new Set<Id>{ '0060q00000ClJF4', '0060q00000G2evW' })
			)
			.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual(
				'SELECT Id, Name, CloseDate, StageName ' +
				'FROM Opportunity ' +
				'WHERE ' +
					'Name = \'Test Opportunity\' ' +
					'AND CloseDate = 2020-07-07 ' +
					'AND Name != \'My Opportunity\' ' +
					'AND CloseDate != 2020-08-08 ' +
					'AND Amount > 100 ' +
					'AND CloseDate > 2020-06-06 ' +
					'AND Amount >= 101 ' +
					'AND DAY_ONLY(CreatedDate) >= 2020-06-07 ' +
					'AND Amount < 900 ' +
					'AND CloseDate < 2020-09-09 ' +
					'AND Amount <= 899 ' +
					'AND DAY_ONLY(CreatedDate) <= 2020-09-08 ' +
					'AND IsPrivate = false ' +
					'AND NextStep = null ' +
					'AND LeadSource != null ' +
					'AND Name LIKE \'%Test%\' ' +
					'AND StageName IN (\'Closed Won\', \'Closed Lost\') ' +
					'AND LeadSource IN (\'Web\', \'Other\') ' +
					'AND Id IN (\'0060q00000GqOOl\', \'0060q00000H30K1\') ' + 
					'AND StageName NOT IN (\'Proposal Made\', \'Negotiation\') ' +
					'AND LeadSource NOT IN (\'Referral\') ' +
					'AND Id NOT IN (\'0060q00000ClJF4\', \'0060q00000G2evW\')',
				query);
	}

	@IsTest
	public static void testWhereClauseQueryWithStringField() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectFields(new SObjectField[] {
				Opportunity.Id,
				Opportunity.Name,
				Opportunity.CloseDate,
				Opportunity.StageName
			})
			.whereClause(new QueryCondition()
				.equals('Name', 'Test Opportunity')
				.equals(Opportunity.IsClosed, false)
				.equals(Opportunity.CloseDate, Date.newInstance(2020, 07, 07))
				.notEquals('Name', 'My Opportunity')
				.notEquals(Opportunity.CloseDate, Date.newInstance(2020, 08, 08))
				.greaterThan(Opportunity.Amount, 100)
				.greaterThan(Opportunity.CloseDate, Date.newInstance(2020, 06, 06))
				.greaterThanAndEqualTo(Opportunity.Amount, 101)
				.greaterThanAndEqualTo('CloseDate', Date.newInstance(2020, 06, 07))
				.lessThan(Opportunity.Amount, 900)
				.lessThan(Opportunity.CloseDate, Date.newInstance(2020, 09, 09))
				.lessThanAndEqualTo(Opportunity.Amount, 899)
				.lessThanAndEqualTo('CloseDate', Date.newInstance(2020, 09, 08))
				.isFalse(Opportunity.IsPrivate)
				.isNull('NextStep')
				.isNotNull('LeadSource')
				.isLike('Name', '%Test%')
				.isIn(Opportunity.StageName, new List<String>{ 'Closed Won', 'Closed Lost' })
				.isIn(Opportunity.CloseDate, new List<Date>{ Date.newInstance(2020, 09, 10), Date.newInstance(2020, 09, 09) })
				.isIn(Opportunity.LeadSource, new Set<String>{ 'Web', 'Other' })
				.isIn(Opportunity.Id, new Set<String>{ '0060q00000GqOOl', '0060q00000H30K1' })
				.isNotIn(Opportunity.StageName, new List<String>{ 'Proposal Made', 'Negotiation' })
				.isNotIn(Opportunity.LeadSource, new Set<String>{ 'Referral' })
				.isNotIn(Opportunity.Id, new Set<Id>{ '0060q00000ClJF4', '0060q00000G2evW' })
			)
			.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual(
				'SELECT Id, Name, CloseDate, StageName ' +
				'FROM Opportunity ' +
				'WHERE ' +
					'Name = \'Test Opportunity\' ' +
					'AND IsClosed = false ' +
					'AND CloseDate = 2020-07-07 ' +
					'AND Name != \'My Opportunity\' ' +
					'AND CloseDate != 2020-08-08 ' +
					'AND Amount > 100 ' +
					'AND CloseDate > 2020-06-06 ' +
					'AND Amount >= 101 ' +
					'AND CloseDate >= 2020-06-07 ' +
					'AND Amount < 900 ' +
					'AND CloseDate < 2020-09-09 ' +
					'AND Amount <= 899 ' +
					'AND CloseDate <= 2020-09-08 ' +
					'AND IsPrivate = false ' +
					'AND NextStep = null ' +
					'AND LeadSource != null ' +
					'AND Name LIKE \'%Test%\' ' +
					'AND StageName IN (\'Closed Won\', \'Closed Lost\') ' +
					'AND CloseDate IN (2020-09-10, 2020-09-09) ' +
					'AND LeadSource IN (\'Web\', \'Other\') ' +
					'AND Id IN (\'0060q00000GqOOl\', \'0060q00000H30K1\') ' +
					'AND StageName NOT IN (\'Proposal Made\', \'Negotiation\') ' +
					'AND LeadSource NOT IN (\'Referral\') ' +
					'AND Id NOT IN (\'0060q00000ClJF4\', \'0060q00000G2evW\')',
				query);
	}

	@IsTest
	public static void testWhereClauseQueryWithStringValues() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectFields(new SObjectField[] {
				Opportunity.Id,
				Opportunity.Name,
				Opportunity.CloseDate,
				Opportunity.StageName
			})
			.whereClause(new QueryCondition()
				.equals('Name', 'Test Opportunity')
				.equals(Opportunity.IsClosed, false)
				.equals(Opportunity.CloseDate, Date.newInstance(2024, 07, 07))
				.notEquals('Name', 'My Opportunity')
				.notEquals(Opportunity.CloseDate, Date.newInstance(2024, 08, 08))
				.greaterThan(Opportunity.Amount, 100)
				.greaterThan(Opportunity.CloseDate, Date.newInstance(2024, 06, 06))
				.greaterThanAndEqualTo(Opportunity.Amount, 101)
				.greaterThanAndEqualToDayOnly('CreatedDate', Date.newInstance(2024, 09, 08))
				.greaterThanAndEqualTo('CloseDate',Date.newInstance(2024, 09, 08))
				.lessThan(Opportunity.Amount, 900)
				.lessThan(Opportunity.CloseDate, Date.newInstance(2024, 09, 09))
				.lessThanAndEqualTo(Opportunity.Amount, 899)
				.lessThanAndEqualToDayOnly('CreatedDate', Date.newInstance(2024, 09, 08))
				.isFalse(Opportunity.IsPrivate)
				.isNull('NextStep')
				.isNotNull('LeadSource')
				.isLike('Name', '%Test%')
				.isIn(Opportunity.StageName, new List<String>{ 'Closed Won', 'Closed Lost' })
				.isIn(Opportunity.LeadSource, new Set<String>{ 'Web', 'Other' })
				.isIn(Opportunity.Id, new Set<Id>{ '0060q00000GqOOl', '0060q00000H30K1' })
				.isNotIn(Opportunity.StageName, new List<String>{ 'Proposal Made', 'Negotiation' })
				.isNotIn(Opportunity.LeadSource, new Set<String>{ 'Referral' })
				.isNotIn(Opportunity.Id, new Set<Id>{ '0060q00000ClJF4', '0060q00000G2evW' })
			)
			.toString();
        
		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual(
				'SELECT Id, Name, CloseDate, StageName ' +
				'FROM Opportunity ' +
				'WHERE ' +
					'Name = \'Test Opportunity\' ' +
					'AND IsClosed = false ' +
					'AND CloseDate = 2024-07-07 ' +
					'AND Name != \'My Opportunity\' ' +
					'AND CloseDate != 2024-08-08 ' +
					'AND Amount > 100 ' +
					'AND CloseDate > 2024-06-06 ' +
					'AND Amount >= 101 ' +
					'AND DAY_ONLY(CreatedDate) >= 2024-09-08 ' +
					'AND CloseDate >= 2024-09-08 ' +
					'AND Amount < 900 ' +
					'AND CloseDate < 2024-09-09 ' +
					'AND Amount <= 899 ' +
					'AND DAY_ONLY(CreatedDate) <= 2024-09-08 ' +
					'AND IsPrivate = false ' +
					'AND NextStep = null ' +
					'AND LeadSource != null ' +
					'AND Name LIKE \'%Test%\' ' +
					'AND StageName IN (\'Closed Won\', \'Closed Lost\') ' +
					'AND LeadSource IN (\'Web\', \'Other\') ' +
					'AND Id IN (\'0060q00000GqOOl\', \'0060q00000H30K1\') ' +
					'AND StageName NOT IN (\'Proposal Made\', \'Negotiation\') ' +
					'AND LeadSource NOT IN (\'Referral\') ' +
					'AND Id NOT IN (\'0060q00000ClJF4\', \'0060q00000G2evW\')',
				query);
	}

	@IsTest
	public static void testMultiPicklistQuery() {
		String query = new QueryBuilder(Idea.SObjectType)
			.selectField(Idea.Id)
			.whereClause(new QueryCondition()
				.including(Idea.Categories, new List<String>{ 'Finance', 'Product' })
				.excluding(Idea.Categories, new List<String>{ 'Marketing' })
			)
			.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual(
			'SELECT Id ' +
			'FROM Idea ' +
			'WHERE ' +
				'Categories INCLUDES (\'Finance\', \'Product\') ' +
				'AND Categories EXCLUDES (\'Marketing\')',
			query);
	}

	@IsTest
	public static void testAndGroupedOrQuery() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectFields(new SObjectField[] {
				Opportunity.Id,
				Opportunity.Name,
				Opportunity.CloseDate,
				Opportunity.StageName
			})
			.whereClause(new QueryCondition()
				.group(new QueryCondition()
					.isNotNull(Opportunity.NextStep)
					.isFalse(Opportunity.IsPrivate)
				)
				.orCondition(new QueryCondition().isNotNull(Opportunity.ForecastCategoryName))
				.orGroup(new QueryCondition().
					isFalse(Opportunity.IsClosed))
			)
			.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual('SELECT Id, Name, CloseDate, StageName '+
						'FROM Opportunity ' +
						'WHERE (NextStep != null AND IsPrivate = false) ' + 
						'OR ForecastCategoryName != null ' +
						'OR (IsClosed = false)', 
						query);
	}

	@IsTest
	public static void testTodayQuery() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectFields(new SObjectField[] {
				Opportunity.Id,
				Opportunity.Name,
				Opportunity.CloseDate,
				Opportunity.StageName
			})
			.whereClause(new QueryCondition()
				.isNotNull(Opportunity.NextStep)
				.equals(Opportunity.CloseDate, Date.today())
			)
			.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Date today = Date.today();
		Assert.areEqual('SELECT Id, Name, CloseDate, StageName FROM Opportunity WHERE NextStep != null AND CloseDate = ' + String.valueOf(today), query);
	}

	@IsTest
	public static void testSortAscending() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectFields(new SObjectField[] {
				Opportunity.Id,
				Opportunity.Name,
				Opportunity.CloseDate,
				Opportunity.StageName
			})
			.whereClause(new QueryCondition()
				.isNotNull(Opportunity.NextStep)
			)
			.orderBy(Opportunity.Name, QueryBuilder.ASCENDING)
            .orderBy(Opportunity.StageName, QueryBuilder.ASCENDING)
			.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual('SELECT Id, Name, CloseDate, StageName FROM Opportunity WHERE NextStep != null ORDER BY Name ASC, StageName ASC', query);
	}

	@IsTest
	public static void testLimitQuery() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectFields(new SObjectField[] {
				Opportunity.Id,
				Opportunity.Name,
				Opportunity.CloseDate,
				Opportunity.StageName
			})
			.whereClause(new QueryCondition()
				.isNotNull(Opportunity.NextStep)
			)
			.take(5)
			.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual('SELECT Id, Name, CloseDate, StageName FROM Opportunity WHERE NextStep != null LIMIT 5', query);
	}

	@IsTest
	public static void basicSelectAggregateFunctions() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectAverageField(Opportunity.Amount)
			.selectMinField(Opportunity.Amount)
			.selectMaxField(Opportunity.Amount)
			.selectSumField(Opportunity.Amount)
			.selectCountField(Opportunity.Id)
			.selectCountDistinctField(Opportunity.Type)
			.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual('SELECT AVG(Amount), MIN(Amount), MAX(Amount), SUM(Amount), COUNT(Id), COUNT_DISTINCT(Type) FROM Opportunity', query);
	}

	@IsTest
	public static void basicSelectAggregateFunctionsCount() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectCount()
			.toString();

		Test.startTest();
		new SOQLTester().countQuery(query);
		Test.stopTest();

		Date today = Date.today();
		Assert.areEqual('SELECT COUNT() FROM Opportunity', query);
	}

	@IsTest
	public static void basicSelectAggregateFunctionsWithAlias() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectAverageField(Opportunity.Amount, 'Average_Amount')
			.selectMinField(Opportunity.Amount, 'Min_Amount')
			.selectMaxField(Opportunity.Amount, 'Max_Amount')
			.selectSumField(Opportunity.Amount, 'Total_Amount')
			.selectCountField(Opportunity.Id, 'Id_Count')
			.selectCountDistinctField(Opportunity.Type, 'Unique_Type_Count')
			.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Assert.areEqual('SELECT AVG(Amount) Average_Amount, MIN(Amount) Min_Amount, MAX(Amount) Max_Amount, SUM(Amount) Total_Amount, COUNT(Id) Id_Count, COUNT_DISTINCT(Type) Unique_Type_Count FROM Opportunity', query);
	}

	@IsTest
	public static void testComplexSingleObjectQuery() {
		String query = new QueryBuilder(Opportunity.SObjectType)
			.selectFields(new SObjectField[] {
				Opportunity.Id,
				Opportunity.Name,
				Opportunity.CloseDate,
				Opportunity.StageName
			})
			.whereClause(new QueryCondition()
				.isToday(Opportunity.CloseDate)
				.equals(Opportunity.StageName, 'Closed Won')
				.greaterThan(Opportunity.Amount, 100)
				.andCondition(new QueryCondition().isNotNull(Opportunity.LeadSource))
				.andGroup(new QueryCondition()
					.group(new QueryCondition()
						.isNotNull(Opportunity.NextStep)
						.isTrue(Opportunity.IsPrivate)
						.isLike(Opportunity.Name, '%(IT)%')
					)
					.orCondition(new QueryCondition().isNotNull(Opportunity.Type))
				)
			)
			.orderBy(Opportunity.Name, QueryBuilder.ASCENDING)
			.take(5)
			.skip(3)
		.toString();

		Test.startTest();
		new SOQLTester().tryQuery(query);
		Test.stopTest();

		Date today = Date.today();
		Assert.areEqual(
			'SELECT Id, Name, CloseDate, StageName ' +
			'FROM Opportunity ' +
			'WHERE ' +
				'CloseDate = ' + String.valueOf(today) + ' ' +
				'AND StageName = \'Closed Won\' ' +
				'AND Amount > 100 ' +
				'AND LeadSource != null ' +
				'AND ((NextStep != null ' +
				'AND IsPrivate = true ' +
				'AND Name LIKE \'%(IT)%\') OR Type != null) ' +
				'ORDER BY Name ASC ' +
				'LIMIT 5 ' +
				'OFFSET 3',
			query);
	}

	public class SOQLTester {
		private void countQuery(String query){			
			try {
				Database.countQuery(query);
			} catch (QueryException ex) {
				isValid = false;
			}
			Assert.areEqual(true, isValid);
		}

		private void tryQuery(String query) {
			try {
				Database.query(query);
			} catch (QueryException ex) {
				isValid = false;
			}
			Assert.areEqual(true, isValid);
		}
	}
}