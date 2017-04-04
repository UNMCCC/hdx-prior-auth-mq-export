/* HDX Express Batch
   for the next business day till 14 days from now, end on a business day
*/
DECLARE @BeginDate VARCHAR(8);
DECLARE @EndDate VARCHAR(8);
Set @BeginDate = CONVERT(VARCHAR(10),DATEADD(DAY, CASE (DATEPART(WEEKDAY, GETDATE()) + @@DATEFIRST) % 7 
                        WHEN 6 THEN 3 
                        WHEN 0 THEN 2 
                        ELSE 1 
                    END, DATEDIFF(DAY, 0, GETDATE())),112);
Set @EndDate = CONVERT(VARCHAR(10),DATEADD(DAY, CASE (DATEPART(WEEKDAY, GETDATE()) + @@DATEFIRST) % 7 
                        WHEN 6 THEN 16 
                        WHEN 0 THEN 15 
                        ELSE 14 
                    END, DATEDIFF(DAY, 0, GETDATE())),112);
Set nocount on

/*----------------------------------1 PRIMARY-----------------------------------------*/
SELECT distinct
 Payer.HCFA_PAYERID as [Payer Enrollee#],
'' as [Payer Alias],
 CONVERT(CHAR(8),App_DtTm,112) as [Begin Date of Service],
 '' as [End Date of Service],
 PAT.LAST_NAME as [Patient Last Name],
 PAT.First_Name as [Patient First Name],
 '' as [Patient Middle Name],
 '' as [Patient NameSuffix-(Medicare)],/*no saluation in Mosiaq\Demographics*/
Replace(
    Replace(
    Replace(Gender,'Female','F'),'Male','M'),'','U') as [Patient Gender],
 CONVERT(CHAR(8),PAT.Birth_DtTm,112) as [Patient DOB],   
  '' as [Patient SSN],
  '' as [Patient Relationship],
  REPLACE(
	REPLACE(
	REPLACE(Policy_No,'',''),'-',''),'/','') as [Member Number],/*use policy number*/
  '' as [Group/Policy Number],
  '' as [Plan Number],
  '' as [Dependent Number],
  '' as [Service Type Code],
  '' as [Subscriber Last Name],
  '' as [Subscriber First Name],
  '' as [Subscriber Middle],
  '' as [Subscriber Name Suffix],
  '' as [Subscriber Gender],
  '' as [Subscriber DOB],
  '' as [Subscriber SSN],
  '' as [Subscriber Policy Number],
  '' as [Subscriber Member ID],
  '' as [Subscriber Group Number],
  '' as [Address Line 1],
  '' as [Address Line 2],
  '' as [City],
  '' as [County Code],
  '' as [State],
  '' as [Zip Code],
  '' as [Phone Number],
  '' as [Subscriber Plan Number],
  '' as [Specialty Code],
  '' as [Transaction Type],
  '' as [Beginning/Card Issue Date],
  '' as [Fiscal Intermediary Code],
  '' as [Medicare HIC Number],
  '' as [ID Card],
  '' as [ID Card Serial Number],
  '' as [Card Issue Number],
  '' as [Patient Account Number],
  IDA as [Medical Record Number],                                                                                          
  --VWPAT.General_Primary_Payer_ID as [Plan Code],/*do like MPV trading partner which is the payer ID*/
   payer.code as [Plan Code],
Case when sch.Inst_ID = 1 then 'CRTC' 
	 when sch.Inst_ID = 2 then 'MO'
	 when sch.Inst_ID = 3 then 'LODO' End AS [Dept],
'' as [Patient Type],
'' as [User Defined 4],
'' as [DIV Code],
'' as [Payer User New PSWD],
'' as [SC Case Number],
'' as [SC Procedure Cd],
'' as [SC Billed Amt],
'' as [SC Applied Amt],
'' as [SC Reversal],
'' as [Cov Level],
'' as [Provider Plan Cd],
'' as [Provider Number],
'' as [Ins Type Cd],
'' as [Payer User ID],
'' as [Payer User PSWD]

FROM Admin ADM
LEFT JOIN vw_Schedule SCH ON ADM.Pat_ID1 = SCH.Pat_ID1
LEFT JOIN PATIENT PAT ON SCH.PAT_ID1 = PAT.PAT_ID1
LEFT JOIN Pat_Pay INS ON PAT.Pat_ID1 = INS.Pat_ID1
LEFT JOIN vw_PatientInsurances VWPAT ON INS.Pat_ID1 = VWPAT.Pat_ID1
left join Payer on VWPAT.General_Primary_Payer_ID = payer.Payer_ID

where 
CONVERT(CHAR(8),SCH.APP_DTTM,112) >= @BeginDate
and CONVERT(CHAR(8),SCH.APP_DTTM,112) <= @EndDate
and VWPAT.General_Primary_Payer_ID = INS.Payer_ID
and SCH.IDA not in ('','0000','00000000000','001123456')/*take out junk MRN*/
and (INS.Expiration_DtTm is null
OR INS.Expiration_DtTm >= SCH.App_DtTm)
and INS.Payer_Type = 4000 /*GENERAL_INSURANCE*/
and INS.Inactive = 0
and VWPAT.General_Primary_payer_name like '**%' 
and Payer.HCFA_PAYERID like '0%'

/*-----------------------------1 SECONDARY---------------------------------------*/
								  UNION
/*-------------------------------------------------------------------------------*/
SELECT distinct  
  Payer.HCFA_PAYERID as [Payer Enrollee#],
'' as [Payer Alias],
 CONVERT(CHAR(8),App_DtTm,112) as [Begin Date of Service],
 '' as [End Date of Service],
 PAT.LAST_NAME as [Patient Last Name],
 PAT.First_Name as [Patient First Name],
 '' as [Patient Middle Name],
 '' as [Patient NameSuffix-(Medicare)],/*no saluation in Mosiaq\Demographics*/
Replace(
    Replace(
    Replace(Gender,'Female','F'),'Male','M'),'','U') as [Patient Gender],
 CONVERT(CHAR(8),PAT.Birth_DtTm,112) as [Patient DOB],   
  '' as [Patient SSN],
  '' as [Patient Relationship],
  REPLACE(
	REPLACE(
	REPLACE(Policy_No,'',''),'-',''),'/','') as [Member Number],/*use policy number*/
  '' as [Group/Policy Number],
  '' as [Plan Number],
  '' as [Dependent Number],
  '' as [Service Type Code],
  '' as [Subscriber Last Name],
  '' as [Subscriber First Name],
  '' as [Subscriber Middle],
  '' as [Subscriber Name Suffix],
  '' as [Subscriber Gender],
  '' as [Subscriber DOB],
  '' as [Subscriber SSN],
  '' as [Subscriber Policy Number],
  '' as [Subscriber Member ID],
  '' as [Subscriber Group Number],
  '' as [Address Line 1],
  '' as [Address Line 2],
  '' as [City],
  '' as [County Code],
  '' as [State],
  '' as [Zip Code],
  '' as [Phone Number],
  '' as [Subscriber Plan Number],
  '' as [Specialty Code],
  '' as [Transaction Type],
  '' as [Beginning/Card Issue Date],
  '' as [Fiscal Intermediary Code],
  '' as [Medicare HIC Number],
  '' as [ID Card],
  '' as [ID Card Serial Number],
  '' as [Card Issue Number],
  '' as [Patient Account Number],
  IDA as [Medical Record Number],                                                                                          
   payer.code as [Plan Code],
Case when sch.Inst_ID = 1 then 'CRTC' 
	 when sch.Inst_ID = 2 then 'MO'
	 when sch.Inst_ID = 3 then 'LODO' End AS [Dept],
'' as [Patient Type],
'' as [User Defined 4],
'' as [DIV Code],
'' as [Payer User New PSWD],
'' as [SC Case Number],
'' as [SC Procedure Cd],
'' as [SC Billed Amt],
'' as [SC Applied Amt],
'' as [SC Reversal],
'' as [Cov Level],
'' as [Provider Plan Cd],
'' as [Provider Number],
'' as [Ins Type Cd],
'' as [Payer User ID],
'' as [Payer User PSWD]

FROM Admin ADM
LEFT JOIN vw_Schedule SCH ON ADM.Pat_ID1 = SCH.Pat_ID1
LEFT JOIN PATIENT PAT ON SCH.PAT_ID1 = PAT.PAT_ID1
LEFT JOIN Pat_Pay INS ON PAT.Pat_ID1 = INS.Pat_ID1
LEFT JOIN vw_PatientInsurances VWPAT ON INS.Pat_ID1 = VWPAT.Pat_ID1
left join Payer on VWPAT.General_Secondary_Payer_ID = payer.Payer_ID

where 
CONVERT(CHAR(8),SCH.APP_DTTM,112) >= @BeginDate
and CONVERT(CHAR(8),SCH.APP_DTTM,112) <= @EndDate
and VWPAT.General_Secondary_Payer_ID = INS.Payer_ID
and SCH.IDA not in ('','0000','00000000000','001123456')/*take out junk MRN*/
and (INS.Expiration_DtTm is null
OR INS.Expiration_DtTm >= SCH.App_DtTm)
and INS.Payer_Type = 4000 /*GENERAL_INSURANCE*/
and INS.Inactive = 0
and VWPAT.General_Secondary_Payer_Name like '**%' 
and Payer.HCFA_PAYERID like '0%'