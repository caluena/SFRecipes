/**
 * A class utilselectCountg the builder design pattern to abstract the building of queries.
 */
public class QueryBuilder {
	// The fully built SOQL query
	private String query;

	// The fields used in the 'SELECT' clause
	private Set<String> selectedFields;

	// The SObject were applying the query to used in the 'FROM' clause
	private SObjectType entity;

	// The 'WHERE' clause
	private QueryCondition conditionExpression;

	// The 'ORDER BY' clause
	private List<String> orderBy;

	// The 'GROUP BY' clause
	private List<String> groupBy;

	// The 'LIMIT' clause amount
	private Integer limitAmount;

	// The 'OFFSET' clause amount
	private Integer offsetAmount;

	// The chosen sorting direction i.e. ASC/DSC
	private List<String> sortingOption;

	// Sorting options
	public final static String ASCENDING = 'ASC';
	public final static String DESCENDING = 'DESC';

	public QueryBuilder(SObjectType objectType) {
		query = '';
		entity = objectType;
		selectedFields = new Set<String>();
		groupBy = new List<String>();
		orderBy = new List<String>();
		sortingOption = new List<String>();
	}

	/**
	 * Adds a field reference to the current selection of applied fields
	 *
	 * @param field		A field reference
	 *
	 * @return		The current instance of the QueryBuilder
	 */
	public QueryBuilder selectField(SObjectField field) {
		selectedFields.add(field.getDescribe().getName());
		return this;
	}

	/**
	 * Adds a field reference to the current selection of applied fields
	 *
	 * @param field		A field reference
	 *
	 * @return		The current instance of the QueryBuilder
	 */
	public QueryBuilder selectField(String field) {
		selectedFields.add(field);
		return this;
	}

	/**
	 * Adds a field reference to the current selection of applied fields
	 *
	 * @param field		A field reference
	 *
	 * @return		The current instance of the QueryBuilder
	 */
	public QueryBuilder selectField(Object field) {
		if(field instanceof SObjectField)
		{
			selectField((SObjectField) field);
		}
		else if(field instanceof String)
		{
			selectField((String) field);
		}
		return this;
	}

	/**
	 * Adds a field reference to the current selection of applied fields
	 *
	 * @param field		A field reference
	 * @param alias		A field alias
	 *
	 * @return		The current instance of the QueryBuilder
	 */
	public QueryBuilder selectField(SObjectField field, String alias) {
		selectedFields.add(field.getDescribe().getName() + ' ' + alias);
		return this;
	}

	/**
	 * Adds a field reference to the current selection of applied fields
	 *
	 * @param field		A field reference
	 * @param alias		A field alias
	 *
	 * @return		The current instance of the QueryBuilder
	 */
	public QueryBuilder selectField(String field, String alias) {
		selectedFields.add(field + ' ' + alias);
		return this;
	}

	/**
	 * Adds a field reference to the current selection of applied fields
	 *
	 * @param field		A field reference
	 * @param alias		A field alias
	 *
	 * @return		The current instance of the QueryBuilder
	 */
	public QueryBuilder selectField(Object field, String alias) {
		String fieldName;

		if(field instanceof SObjectField)
		{
			fieldName = ((SObjectField) field).getDescribe().getName();
		}
		else if(field instanceof String)
		{
			fieldName = (String) field;
		}

		selectedFields.add(fieldName + ' ' + alias);
		return this;
	}

	/**
	 * Adds a list of field references to the current selection of applied fields
	 *
	 * @param fields	A list of field references
	 *
	 * @return		The current instance of the QueryBuilder
	 */
	public QueryBuilder selectFields(List<SObjectField> fields) {
		for(SObjectField field : fields) {
			selectField(field);
		}

		return this;
	}

	/**
	 * Adds a list of field references to the current selection of applied fields
	 *
	 * @param fields	A list of field references
	 *
	 * @return		The current instance of the QueryBuilder
	 */
	public QueryBuilder selectFields(Set<String> fields) {
		for(String field : fields) {
			selectField(field);
		}

		return this;
	}

	/**
	 * Adds a list of field references to the current selection of applied fields
	 *
	 * @param fields	A list of field references
	 *
	 * @return		The current instance of the QueryBuilder
	 */
	public QueryBuilder selectFields(List<Object> fields) {
		for(Object field : fields) {
			if(field instanceof SObjectField)
			{
				selectField((SObjectField) field);
			}
			else if(field instanceof String)
			{
				selectField((String) field);
			}
		}

		return this;
	}

	/**
	 * Adds a list of field references to the current selection of applied fields
	 *
	 * @param fields	A list of field references
	 *
	 * @return		The current instance of the QueryBuilder
	 */
	public QueryBuilder selectFields(List<String> fields) {
		for(String field : fields) {
			selectField(field);
		}

		return this;
	}

	/**
	 * Allows cross-object SOQL queries to be constructed on standard relationships
	 *
	 * @param objectType	An object type reference to the relation object
	 * @param field	A field reference from the related object
	 *
	 * @return		The current instance of the QueryBuilder
	 */
	public QueryBuilder selectRelatedField(SObjectType objectType, SObjectField field) {
		selectedFields.add(objectType.getDescribe().getName() + '.' + field.getDescribe().getName());
		return this;
	}

	/**
	 * Allows cross-object SOQL queries to be constructed on custom relationships
	 *
	 * @param lookupField		A field reference to the relation object
	 * @param field		A field reference from the related object
	 *
	 * @return		The current instance of the QueryBuilder
	 */
	public QueryBuilder selectRelatedField(SObjectField lookupField, SObjectField field) {
        Schema.DescribeFieldResult describe = lookupField.getDescribe();
        
		if (describe.getType() != Schema.DisplayType.REFERENCE) {
        	throw new IllegalArgumentException('O campo fornecido não é um relacionamento válido: ' + describe.getName());
    	}
        
        String relationshipName = describe.getRelationshipName();        
		selectedFields.add(relationshipName + '.' + field.getDescribe().getName());
		return this;
	}

	@TestVisible
	private SObjectType getEntity() {
		return entity;
	}

	/* -=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=--=-=-=-=-=-=-
	 * 				Aggregate Functions
	/* -=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=--=-=-=-=-=-=-
	*/
	public QueryBuilder selectAverageField(SObjectField field) {
		selectedFields.add('AVG(' + field.getDescribe().getName() + ')');
		return this;
	}

	public QueryBuilder selectAverageField(SObjectField field, String alias) {
		selectedFields.add('AVG(' + field.getDescribe().getName() + ') ' + alias);
		return this;
	}

	public QueryBuilder selectCount() {
		selectedFields.add('COUNT()');
		return this;
	}

	public QueryBuilder selectCountField(SObjectField field) {
		selectedFields.add('COUNT(' + field.getDescribe().getName() + ')');
		return this;
	}

	public QueryBuilder selectCountField(SObjectField field, String alias) {
		selectedFields.add('COUNT(' + field.getDescribe().getName() + ') ' + alias);
		return this;
	}

	public QueryBuilder selectCountDistinctField(SObjectField field) {
		selectedFields.add('COUNT_DISTINCT(' + field.getDescribe().getName() + ')');
		return this;
	}

	public QueryBuilder selectCountDistinctField(SObjectField field, String alias) {
		selectedFields.add('COUNT_DISTINCT(' + field.getDescribe().getName() + ') ' + alias);
		return this;
	}

	public QueryBuilder selectMinField(SObjectField field) {
		selectedFields.add('MIN(' + field.getDescribe().getName() + ')');
		return this;
	}

	public QueryBuilder selectMinField(SObjectField field, String alias) {
		selectedFields.add('MIN(' + field.getDescribe().getName() + ') ' + alias);
		return this;
	}

	public QueryBuilder selectMaxField(SObjectField field) {
		selectedFields.add('MAX(' + field.getDescribe().getName() + ')');
		return this;
	}

	public QueryBuilder selectMaxField(SObjectField field, String alias) {
		selectedFields.add('MAX(' + field.getDescribe().getName() + ') ' + alias);
		return this;
	}

	public QueryBuilder selectSumField(SObjectField field) {
		selectedFields.add('SUM(' + field.getDescribe().getName() + ')');
		return this;
	}

	public QueryBuilder selectSumField(SObjectField field, String alias) {
		selectedFields.add('SUM(' + field.getDescribe().getName() + ') ' + alias);
		return this;
	}

	/**
 	* Adds a dynamic subquery to a SOQL query, identifying the relationship name
 	* between a given parent entity and the subquery entity.
 	*
 	* This method replaces the object name in the subquery with the appropriate relationship
 	* name, based on the metadata between the parent and child SObject types, enabling
 	* nested queries to be constructed dynamically.
 	*
 	* @param   parentType      The SObjectType of the parent object (e.g. Account.SObjectType)
 	* @param   aQueryBuilder   A QueryBuilder instance representing the subquery to be added
 	* @return  QueryBuilder    The current QueryBuilder instance with the subquery included
 	*/
	public QueryBuilder subQuery(SObjectType parentType, QueryBuilder aQueryBuilder) {
		String subQuery = aQueryBuilder.toString();
		SObjectType childType = aQueryBuilder.getEntity();
	
		String childTypeName = childType.getDescribe().getName();
	
		for (ChildRelationship rel : parentType.getDescribe().getChildRelationships()) {
			if (rel.getChildSObject() == childType) {
				subQuery = subQuery.replace('FROM ' + childTypeName, 'FROM ' + rel.getRelationshipName());
				break;
			}
		}
	
		selectedFields.add('(' + subQuery + ')');
		return this;
	}

	/**
	 * Builds out the string by concatenating the various clauses together to put together the SOQL query
	 *
	 * @return		A string representation of the SOQL query
	 */
	public override String toString() {
		// 'SELECT' clause
		query += 'SELECT ';
		query += String.join(new List<String>(selectedFields), ', ');

		// 'FROM' clause
		query += ' FROM ' + entity.getDescribe().getName();

		// 'WHERE' clause
		if(conditionExpression != null) {
			query += ' WHERE ' + conditionExpression.toString();
		}

		// 'GROUP BY' clause
		if(!groupBy.isEmpty()) {
			query += ' GROUP BY ' + String.join(groupBy, ', ');
		}

		// 'ORDER BY' clause
		if(!orderBy.isEmpty()) {
			query += ' ORDER BY ';

			for(Integer i = 0; i < orderBy.size(); i++)
			{
				query += orderBy[i];

				// ASC / DSC
				if(sortingOption[i] != null) {
					query += ' ' + sortingOption[i];
				}

				// Add comma for all records but the last
				if(i + 1 != orderBy.size()) {
					query += ', ';
				}
			}
		}

		// 'LIMIT' clause
		if(limitAmount != null) {
			query += ' LIMIT ' + this.limitAmount;
		}

		// 'OFFSET' clause
		if(offsetAmount != null) {
			query += ' OFFSET ' + this.offsetAmount;
		}

		return query;
	}

	/**
	 * Handles the creation of the 'WHERE' clause segment
	 *
	 * @param conditionExpression		A reference to a QueryCondition containing logical statements
	 *
	 * @return	The current instance of the QueryBuilder
	 */
	public QueryBuilder whereClause(QueryCondition conditionExpression) {
		this.conditionExpression = conditionExpression;
		return this;
	}

	/**
	 * Handles the creation of the 'LIMIT' clause segment
	 *
	 * @param limitAmount		The amount of records to return in the query
	 *
	 * @return	The current instance of the QueryBuilder
	 */
	public QueryBuilder take(Integer limitAmount) {
		this.limitAmount = limitAmount;
		return this;
	}

	/**
	 * Handles the creation of the 'OFFSET' clause segment
	 *
	 * @param offsetAmount		The amount of records to skip in the query
	 *
	 * @return	The current instance of the QueryBuilder
	 */
	public QueryBuilder skip(Integer offsetAmount) {
		this.offsetAmount = offsetAmount;
		return this;
	}

	/**
	 * Handles the creation of the 'GROUP BY' clause segment
	 *
	 * @param field	The field reference to group by
	 *
	 * @return	The current instance of the QueryBuilder
	 */
	public QueryBuilder groupBy(SObjectField field) {
		this.groupBy.add(field.getDescribe().getName());
		return this;
	}

	/**
	 * Handles the creation of the 'GROUP BY' clause segment
	 *
	 * @param field	The field reference to group by
	 *
	 * @return	The current instance of the QueryBuilder
	 */
	public QueryBuilder groupBy(String field) {
		this.groupBy.add(field);
		return this;
	}

	/**
	 * Handles the creation of the 'GROUP BY' clause segment
	 *
	 * @param field	The field reference to group by
	 *
	 * @return	The current instance of the QueryBuilder
	 */
	public QueryBuilder groupBy(Object field) {
		if(field instanceof SObjectField)
		{
			groupBy((SObjectField) field);
		}
		else if(field instanceof String)
		{
			groupBy((String) field);
		}
		return this;
	}

	/**
	 * Handles the creation of the 'GROUP BY' clause segment
	 *
	 * @param fields			The fields reference to group by
	 *
	 * @return	The current instance of the QueryBuilder
	 */
	public QueryBuilder groupBy(List<Object> fields) {
		for(Object field : fields)
		{
			if(field instanceof SObjectField)
			{
				groupBy((SObjectField) field);
			}
			else if(field instanceof String)
			{
				groupBy((String) field);
			}
		}

		return this;
	}

	/**
	 * Handles the creation of the 'ORDER BY' clause segment with related fields
	 *
	 * @param objectType	An object type reference to the relation object
	 * @param field		A field reference from the related object
	 *
	 * @return		The current instance of the QueryBuilder
	 */
	public QueryBuilder orderBy(SObjectType objectType, SObjectField field) {
		this.orderBy.add(objectType.getDescribe().getName() + '.' + field.getDescribe().getName());
		this.sortingOption.add(null);
		return this;
	}

	/**
	 * Handles the creation of the 'ORDER BY' clause segment
	 *
	 * @param field	The field reference to order by
	 *
	 * @return	The current instance of the QueryBuilder
	 */
	public QueryBuilder orderBy(SObjectField field) {
		this.orderBy.add(field.getDescribe().getName());
		this.sortingOption.add(null);
		return this;
	}

	/**
	 * Handles the creation of the 'ORDER BY' clause segment
	 *
	 * @param field	The field reference to order by
	 *
	 * @return	The current instance of the QueryBuilder
	 */
	public QueryBuilder orderBy(String field) {
		this.orderBy.add(field);
		this.sortingOption.add(null);
		return this;
	}

	/**
	 * Handles the creation of the 'ORDER BY' clause segment
	 *
	 * @param field	The field reference to order by
	 *
	 * @return	The current instance of the QueryBuilder
	 */
	public QueryBuilder orderBy(Object field) {
		if(field instanceof SObjectField)
		{
			orderBy((SObjectField) field);
		}
		else if(field instanceof String)
		{
			orderBy((String) field);
		}

		this.sortingOption.add(null);
		return this;
	}

	/**
	 * Handles the creation of the 'ORDER BY' clause segment
	 *
	 * @param fields	The fields reference to order by
	 *
	 * @return	The current instance of the QueryBuilder
	 */
	public QueryBuilder orderBy(List<Object> fields) {
		for(Object field : fields)
		{
			if(field instanceof SObjectField)
			{
				orderBy((SObjectField) field);
			}
			else if(field instanceof String)
			{
				orderBy((String) field);
			}
		}

		return this;
	}

	/**
	 * Handles the creation of the 'ORDER BY' clause segment with an additional sorting option
	 *
	 * @param field		The field reference to order by
	 * @param sortingOption		The direction to order in i.e. ASC/DSC
	 *
	 * @return	The current instance of the QueryBuilder
	 */
	public QueryBuilder orderBy(String field, String sortingOption) {
		this.orderBy.add(field);
		this.sortingOption.add(sortingOption);
		return this;
	}

	/**
	 * Handles the creation of the 'ORDER BY' clause segment with an additional sorting option
	 *
	 * @param field		The field reference to order by
	 * @param sortingOption		The direction to order in i.e. ASC/DSC
	 *
	 * @return	The current instance of the QueryBuilder
	 */
	public QueryBuilder orderBy(SObjectField field, String sortingOption) {
		this.orderBy.add(field.getDescribe().getName());
		this.sortingOption.add(sortingOption);
		return this;
	}

	/**
	 * Handles the creation of the 'ORDER BY' clause segment with related fields and additional sorting option
	 *
	 * @param objectType	An object type reference to the relation object
	 * @param field	A field reference from the related object
	 *
	 * @return		The current instance of the QueryBuilder
	 */
	public QueryBuilder orderBy(SObjectType objectType, SObjectField field, String sortingOption) {
		this.orderBy.add(objectType.getDescribe().getName() + '.' + field.getDescribe().getName());
		this.sortingOption.add(sortingOption);
		return this;
	}
}