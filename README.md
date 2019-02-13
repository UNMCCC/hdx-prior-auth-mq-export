Overview
========

The hdx-prior-auth-mq-export contains the SQL query files against the UNMCCC
Mosaiq scheduler instance. The SQL scripts allows us to send data for insurance
eligibility checks offered by HDX-Siemens-Cerner.

Timing is of the essence, we want to use the HDX services automatically as soon
as the day begins, so our insurance eligibility staff has results ready for
processing when the working day begins.

One piece of information that is valuable: Insurance providers update the
insurance validity records as of the first of the month. I.e, you cannot trust
the validity of insurance for any day of the NEXT month. This constrains the
look-ahead -- for the first days of the month, specially the first day, you only
have a few hours at best.

Given the restrictions above, plus the instabilities of HDX on the first of the
month (a mad dash for all providers) and the fact that you pay-per-record check,
we minimize the amount of verifications we send, using two very similar queries,
all of them are date-parametrized.

1.  A one-time query for the first of the month; this query gathers patient
    insurances who will have an encounter in the current month. This query will
    exclude non-applicable payers and duplicate visits, as well as some other
    common exclusions.

2.  A daily query, from day 2 to last day of the month. This query gather
    insurance data for add-on appointments (that is appointments created
    yesterday for a date within the current month).

A windows task controls the execution of these tasks, combining them with an
automated SFTP upload to remote secure HDX servers.

You should know that this SQL queries work against Elekta's Mosaiq backend
database and take into account the UNMCCC in-house customizations of our EHS.
You can use these queries for other Mosaiq instances that use the scheduling and
eligibility framework, some adjustments would have to be made to obtain accurate
lists. That is, we cannot promise this will work out of the box, almost the
opposite, it will not work, is a more reasonable expectation. Contact us for
more info, leave an issue in this Github repo.
