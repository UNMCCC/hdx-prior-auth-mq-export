# Overview
The hdx-prior-auth-mq-export contains the SQL query files to export data for the prior auth service offered by HDX-Siemens-Cerner.

The workflow entails proper timing, as the idea is to call the services automatically as soon as the day begins, so the staff has a result file ready for processing when the staff day begins.

One piece of information that is valuable: Insurance providers update the insurance validity records as of the first of the month.  I.e, you cannot trust the validity of insurance for any day of the NEXT month.  This constrains the look-ahead -- for the first days of the month, specially the first day, you only have a few hours at best. 

Given the restrictions above, plus the instabilities of HDX on the first of the month (a mad dash for all providers), There are three types of very similar queries, all of them are date-parametrized.

1) A Daily query that looks up appointments 14 days from the date the appointment is
2) A query for today
3) A Monthly query that looks up the first 14 some days of the month on day 1.

The workflow is triggered by a windows task scheduler instance that combines an auntomated SFTP upload to remote secure HDX servers.
