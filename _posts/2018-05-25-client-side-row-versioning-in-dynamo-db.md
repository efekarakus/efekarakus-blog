---
layout: post
title: Client-side row versioning in DynamoDB
tagline: "A pattern for maintaining record history in DynamoDB using two tables, one for current data and one for all versions."
tags: [distributed systems, design, versioning, AWS, DynamoDB, NoSQL, databases]
---

_Edit 12/14/2018: This document is out of date! One of the great things about
DynamoDB is that they are constantly improving it. They posted documentation on how to do
row versioning in [Using Sort Keys for Version Control](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-sort-keys.html#bp-sort-keys-version-control).
I'd also recommend watching [Advanced Design Patterns for DynamoDB](https://youtu.be/HaEPXoXVf2k?t=2296)
from re:Invent 2018. The speaker recommends using the new [TransactWriteItems](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_TransactWriteItems.html) operation to get rid of the complexity with ordering requests._

----------------------

Say your application needs to maintain the history of its records. 
There are multiple ways of achieving this with [DynamoDB](https://aws.amazon.com/dynamodb/). 
See [https://stackoverflow.com/a/24275045/1201381](https://stackoverflow.com/a/24275045/1201381) as an example solution.

Your architecture should be built around your application’s use-cases. The layout below can be used if you don’t expect your users to access older versions frequently.

We can maintain two separate tables for the resources that need versioning.

## Resource Table [#](#resource-table-)

The `resource` table contains only the latest version for each item. 
The [primary key](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.CoreComponents.html#HowItWorks.CoreComponents.PrimaryKey) of the table is just its partition key. 
In the table below, the primary and partition key is just a `hash` which is a String. The `version` is a Number. 
The remaining attributes define your resource. 
Since `hash` is the only attribute for the primary key, any new entry with the same `hash` will overwrite the row.

We assume that any operation that updates a record, a new update, or a rollback should **always increment the version number** of the item.

| hash     | version | attr1..attrN |
|:--------:|:--------|:-------------|
| 1c5815b2 | 2       | some values  |

## Resource History Table [#](#resource-history-table-)

The `resource-history` table contains every revision of the items. 
It will have more storage, but can have a lower read capacity if you do not expect the users to retrieve older entries frequently. 
The main difference is that the primary key is a composite key `(partitionKey: hash, sortKey: version)`, so every new `version` for the same hash will `have` its own row.

| hash     | version | attr1..attrN |
|:--------:|:--------|:-------------|
| 1c5815b2 | 2       | some values  |
| 1c5815b2 | 1       |  some old values  |

## Create [#](#create-)
![Create](/assets/client-side-row-versioning-in-dynamodb/create.jpeg){: .center-image }

Creating a new item involves first writing the item to the `resource-history` table, and then writing the same entry to the `resource` table.  
If the first step fails, then nothing has been written to the tables and the user can safely issue another request.  
If the second step fails, then there will be an extra record that’s in the `resource-history` table which won't be accessed by any user.

## Read [#](#read-)
![Read](/assets/client-side-row-versioning-in-dynamodb/read.jpeg){: .center-image }

Retrieving the latest item requires us just to fetch the record with that `hash` from the `resource` table. We are guaranteed to have either one or no record for a given `hash`.

## Update [#](#update-)
![Update](/assets/client-side-row-versioning-in-dynamodb/update.jpeg){: .center-image }

Updating an existing item requires us to first fetch the item’s latest version from the `resource` table, increment its version, and then write the new entry to both tables just like in CREATE.
The failure scenarios are similar to the CREATE operation. If the new entry is 
added only to the `resource-history` table, then when the user requests the same update operation,
the previously created entry with the key `(hash, v2)` in `resource-history` will be replaced.

## Delete [#](#delete)
![Delete](/assets/client-side-row-versioning-in-dynamodb/delete.jpeg){: .center-image }

Deleting an item requires us to only delete it from the main `resource` table.

## Alternatives [#](#alternatives-)
If you work with a single table and try to have immutable records, then the UPDATE operation is going to have a user experience trade-off.
 
For example, if you decide to implement the [stackoverflow](https://stackoverflow.com/questions/24274570/how-can-i-implement-versioning-without-replacing-with-previous-record-in-dynamod/24275045#24275045) answer listed in the introduction, you will have two writes to the same table. Depending on the order you’ve chosen, if the second write operation fails, then the user will either see their item deleted or you’ll lose a historical record.

Client side row versioning is not perfect. Our solution also has drawbacks as explained above, but the customer experience is better than actually losing data.