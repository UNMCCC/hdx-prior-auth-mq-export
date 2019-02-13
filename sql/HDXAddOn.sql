/*Feb 2019, Large query revamp. Goal: Minimize the cases we send to HDX*/
/*  Send only scheduled patients on current month that have not been verified (Eligibility)*/
/*  Send only one appointment per pat month w min date */
/*  Do not distinguish department longer */
/*7.15.14 HDXpress Batch looks 14 days ahead*/
/*Jan.17.2017. Adds condition to avoid sending NULL payerID*/
DECLARE @Yesterday VARCHAR(8);
DECLARE @EndOfMonth VARCHAR(8);
DECLARE @Today VARCHAR(8);
Set @EndOfMonth = CONVERT(VARCHAR(10),EOMONTH(GETDATE()),112);
Set @Yesterday = CONVERT(VARCHAR(10),DATEADD(DAY, CASE (DATEPART(WEEKDAY, GETDATE()) + @@DATEFIRST) % 7 
                        WHEN 1 THEN -2 
                        WHEN 2 THEN -3 
                        ELSE -1 
                    END, DATEDIFF(DAY, 0, GETDATE())),112);
Set @Today = CONVERT(VARCHAR(10),GETDATE(),112);

Set nocount on;


/*----------------------------------1 PRIMARY-----------------------------------------*/
SELECT distinct
 Payer.HCFA_PAYERID as [Payer Enrollee#],
'' as [Payer Alias],
 MIN(CONVERT(CHAR(8),App_DtTm,112)) as [Begin Date of Service],
 '' as [End Date of Service],
 PAT.LAST_NAME as [Patient Last Name],
 PAT.First_Name as [Patient First Name],
 '' as [Patient Middle Name],
 '' as [Patient NameSuffix-(Medicare)],/*no saluation in Mosiaq\Demographics*/
Replace(
    Replace(
    Replace(ADM.Gender,'Female','F'),'Male','M'),'','U') as [Patient Gender],
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
  PAT.IDA as [Medical Record Number],                                                                                          
   payer.code as [Plan Code],
--Case when sch.Inst_ID = 1 then 'CRTC' 
--	 when sch.Inst_ID = 2 then 'MO'
--	 when sch.Inst_ID = 3 then 'LODO' End AS [Dept],
'CTRC/MO/LODO' as [Dept],
'' as [User Def 3],
-- SCH.sch_id as [SCH ID], -- this was added to match with PA system, not needed, commented out Jan 2019
'' as [User Def 4],
--General_Primary_Payer_Name as [PrimPayerUsrDef4],
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
LEFT JOIN Schedule SCH ON ADM.Pat_ID1 = SCH.Pat_ID1
LEFT OUTER JOIN vw_Patient PAT WITH(NOLOCK) ON Sch.PAT_ID1 = PAT.pat_id1
LEFT JOIN Pat_Pay INS ON PAT.Pat_ID1 = INS.Pat_ID1
LEFT JOIN vw_PatientInsurances VWPAT ON INS.Pat_ID1 = VWPAT.Pat_ID1
left join Payer on VWPAT.General_Primary_Payer_ID = payer.Payer_ID
LEFT JOIN  EligWrkLst  on ADM.pat_id1=EligWrkLst.pat_id1


where 
CONVERT(CHAR(8),SCH.APP_DTTM,112) >= @Today
AND CONVERT(CHAR(8),SCH.APP_DTTM,112) <= @EndOfMonth
AND CONVERT(CHAR(8),SCH.Create_DtTm,112) = @Yesterday
and VWPAT.General_Primary_Payer_ID = INS.Payer_ID
and PAT.IDA not in ('','0000','00000000000','001123456')/*take out junk MRN*/
and (INS.Expiration_DtTm is null
OR INS.Expiration_DtTm >= SCH.App_DtTm)
and INS.Payer_Type = 4000 /*GENERAL_INSURANCE*/
and INS.Inactive = 0
and VWPAT.General_Primary_payer_name like '**%' 
and Payer.HCFA_PAYERID like '0%'
AND EligWrkLst.EligibilityStatus=1            -- No one has worked the elig of this pat...
AND EligWrkLst.Edit_DtTm >= DATEADD(DAY,1,EOMONTH(GETDATE(),-1)) -- .. since this date.

group by
  Payer.HCFA_PAYERID, PAT.LAST_NAME, PAT.First_Name ,ADM.Gender, PAT.Birth_DtTm, Policy_No, IDA,payer.code 

/*-----------------------------1 SECONDARY---------------------------------------*/
								  UNION
/*-------------------------------------------------------------------------------*/


SELECT distinct  
  Payer.HCFA_PAYERID as [Payer Enrollee#],
'' as [Payer Alias],
 MIN(CONVERT(CHAR(8),App_DtTm,112)) as [Begin Date of Service],
 '' as [End Date of Service],
 PAT.LAST_NAME as [Patient Last Name],
 PAT.First_Name as [Patient First Name],
 '' as [Patient Middle Name],
 '' as [Patient NameSuffix-(Medicare)],/*no saluation in Mosiaq\Demographics*/
Replace(
    Replace(
    Replace(ADM.Gender,'Female','F'),'Male','M'),'','U') as [Patient Gender],
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
--Case when sch.Inst_ID = 1 then 'CRTC' 
--	 when sch.Inst_ID = 2 then 'MO'
--	 when sch.Inst_ID = 3 then 'LODO' End AS [Dept],
'CTRC/MO/LODO' as [Dept],
'' as [User Def 3],
-- SCH.sch_id as [SCH ID],
'' as [User Def 4],
--General_Primary_Payer_Name as [PrimPayerUsrDef4],
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
LEFT JOIN Schedule SCH ON ADM.Pat_ID1 = SCH.Pat_ID1
LEFT OUTER JOIN vw_Patient PAT WITH(NOLOCK) ON Sch.PAT_ID1 = PAT.pat_id1
LEFT JOIN Pat_Pay INS ON PAT.Pat_ID1 = INS.Pat_ID1
LEFT JOIN vw_PatientInsurances VWPAT ON INS.Pat_ID1 = VWPAT.Pat_ID1
left join Payer on VWPAT.General_Secondary_Payer_ID = payer.Payer_ID
LEFT JOIN  EligWrkLst  on ADM.pat_id1=EligWrkLst.pat_id1
where 
CONVERT(CHAR(8),SCH.APP_DTTM,112) >= @Today
AND CONVERT(CHAR(8),SCH.APP_DTTM,112) <= @EndOfMonth
AND CONVERT(CHAR(8),SCH.Create_DtTm,112) = @Yesterday
and VWPAT.General_Secondary_Payer_ID = INS.Payer_ID
and PAT.IDA not in ('','0000','00000000000','001123456')/*take out junk MRN*/
and (INS.Expiration_DtTm is null
OR INS.Expiration_DtTm >= SCH.App_DtTm)
and INS.Payer_Type = 4000 /*GENERAL_INSURANCE*/
and INS.Inactive = 0
and VWPAT.General_Secondary_Payer_Name like '**%' 
and Payer.HCFA_PAYERID like '0%'
AND EligWrkLst.EligibilityStatus=1            -- No one has worked the elig of this pat...
AND EligWrkLst.Edit_DtTm >= DATEADD(DAY,1,EOMONTH(GETDATE(),-1)) -- .. since this date.
group by
  Payer.HCFA_PAYERID, PAT.LAST_NAME, PAT.First_Name ,ADM.Gender, PAT.Birth_DtTm, Policy_No, IDA,payer.code 
  order by IDA