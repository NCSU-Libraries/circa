# JSON API documentation

The core of the application is a JSON API, which is responsible for all interactions between the front end and the database.

## General conventions

### HTTP status

If a request is successful, the API will respond with HTTP status 200. If unsuccessful, API will respond with appropriate HTTP status (usually 400, 403, 404 or 500).


### Errors

Any response with HTTP status indicating an error will include information about the error in the returned JSON object, eg:

```
{ 'error': 'status': 404, 'detail": 'Record not found' }
```

### Pagination

For any GET request that returns a list of records, the results will be paginated. Pagination parameters can be passed as URL parameters. The following parameters are supported:

* `page` - the results page, default = 1
* `per_page` - number of records per page, default = 20
* `sort` - attribute on which to sort, default varies per request, and not all attributes are supported for sorting

The JSON object returned will include these and additional pagination details within the `meta` element as follows:

```
{
  ...
  'meta': {
    'pagination': {
      'page': <the current results page, integer>,
      'per_page': <number of results returned per page, integer>,
      'sort': <the attribute used for sorting, string>,
      'total': <total records in results set, integer>,
      'pages': <total number of pages, integer>
    }
  }
}
```


## Orders


### List all orders

**HTTP verb**: `GET`

**Path**: `/orders`

**Response data format**:

```
{
  'orders': [ { <order attributes> }, { <order attributes> }, ... ],
}
```

Order attributes will conform to the response format for a single order, described below.


### Show single order

**HTTP verb**: `GET`

**Path**: `/orders/:id`

**Response data format**:

```
{ 'order':
  {
    'id': <integer>,
    'access_date_start': <ISO 8601 (date only)>,
    'access_date_end': <ISO 8601 (date only)>,
    'created_at': <ISO 8601 (full date/time)>,
    'updated_at': <ISO 8601 (full date/time)>,
    'archivesspace_records': <array of ArchivesSpace URIs>,
    'items': [ { <item attributes> }, { <item attributes> }, ... ],
    'users': [ { <user attributes> }, { <user attributes> }, ... ],
    'assignees': [ { <user attributes> }, { <user attributes> }, ... ]
  }
}
```


### Create a new order

**HTTP verb**: `POST`

**Path**: `/orders`

**Request data format** (NOTE: all request parameters are optional):

```
{
  'order': {
    'access_date_start': <ISO 8601 (date only)>,
    'access_date_end': <ISO 8601 (date only)>,
    'items': [ <ArchivesSpace URIs> ],
    'users': [ <user emails> ],
    'assignees': [ <user emails> ]
  }
}
```

**Response data format**: Same as 'Show single order' above



### Update order

NOTE: This request should only be used to update native attributes (currently just access_date_start), not to update associations - see association requests below.

**HTTP verb**: `PUT`

**Path**: `/orders/:id`

**Request data format** (NOTE: all request parameters are optional):

```
{
  'order': {
    'access_date_start': <ISO 8601 (date only)>,
    'access_date_end': <ISO 8601 (date only)>,
    'temporary_location_id': <location id (integer)>,
    'order_type_id': <order_type id (integer)>,
    'items': [ <Item attributes - same format as hash used to create Item below> ]
  }
}
```

**Response data format**: Same as 'Show single order' above

More TK...

### Delete order

**HTTP verb**: `DELETE`

**Path**: `/orders/:id`

**Response data format**: Response body is empty; returns status 200 if successful



### Add associated records to order

**HTTP verb**: `POST`

**Path**: `/orders/:id/associations`

**Request data format** (NOTE: one or more top-level keys is required):

```
{
  'items': [ <ArchivesSpace URIs> ],
  'users': [ <User IDs or emails> ], # user must already exist
  'assignees': [ <User IDs or emails> ] # user must already exist
}
```

**Response data format**: Same as 'Show single order' above

**Additional association-specific paths are also available:**

* `/orders/:id/items`
* `/orders/:id/users`
* `/orders/:id/assignees`

In each case, the POST data must include the corresponding key and array of values.



### Delete associations from order

NOTE: Associated records are not destroyed, only the association itself.

**HTTP verb**: `DELETE`

**Path**: `/orders/:id/associations`

**Request data format** (NOTE: one or more top-level keys is required):

```
{
  'items': [ <Item IDs or ArchivesSpace URIs> ],
  'users': [ <User IDs or emails> ],
  'assignees': [ <User IDs or emails> ]
}
```

**Response data format**: Same as 'Show single order' above

**Additional association-specific paths are also available:**

* `/orders/:id/items`
* `/orders/:id/users`
* `/orders/:id/assignees`

In each case, the POST data must include the corresponding key and array of values.



### Trigger event to update state

**HTTP verb**: `PUT`

**Path**: `/orders/:id/:event`
