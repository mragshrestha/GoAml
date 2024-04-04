 --ConnectBr '000002'
--Declare @TrnDate Date

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_GoAml_TTR]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_GoAml_TTR]
GO

SET QUOTED_IDENTIFIER ON 
SET ANSI_NULLS ON 
GO
CREATE procedure sp_GoAml_TTR @Br Nvarchar(6),  @TrnDate Datetime, @RepType Nvarchar(1), @Grid Nvarchar(1)      
As    
/*  
   Procedure to generate Threshold transaction report for GoAml  
   PROJECT      : FAO/GTZ MICROBANKING SYSTEM (MBNepal)   
   PROGRAM NAME : sp_GoAml_TTR   
   CREATED BY   : Ajay G Shrestha  
   DATE         : 31 Oct, 2023 
   DESCRIPTION  : Threshold transaction report for GoAml 
   SYNTAX		: Exec sp_GoAml_TTR 'A', '2022-10-17',1,'F'		Exec sp_GoAml_TTR '000001', '2022-11-05',1,'F'
				  Exec sp_GoAml_TTR 'A', '2022-11-05',2,'F'		Exec sp_GoAml_TTR '000001', '2022-11-05',2,'F'
				  Exec sp_GoAml_TTR 'A', '2022-10-17',2,'T'		Exec sp_GoAml_TTR '000001', '2022-10-17',2,'T'
   Note			:
   @Br: A = For All Branches
   @RepType:	1 = To insert values on MBNGOAMLExtendedInfo table 
				2 = To view the reports.
   @Grid:		T = For Grid
				F = No Grid
	 --Used All Loans are Loan-Non Revolving in Account_Type.
 
   MODIFIED ON  : November 26, 2023 Ajay: Added MBNGOAMLExtendedInfo Details for Fund Source. 
				  December 5, 2023 Ajay: Corrected the SourceofFund and Occupation. Used #TempGoAmlTTR instead of TempGoAmlTTR table.  
				  December 11, 2023 Ajay: Added FundSource in #TempGoAmlTTR to separate t_from_my_client and t_from. Added CitizenshipIssuedPlace too.  
				  January 17, 2024 Ajay: Added CID,AccCustType,InitCustType,TrnType1
				  January 25, 2024 Ajay: Filter FundSourceSubType to distinguish Individual and Entity. 
				  February 11, 2024 Ajay: Changed Balance Amount as previous balance as guided by Karmath Samudayik Coop. 
				  February 27, 2024 Ajay: Filter RepType='P' for only posted transaction.
				  March 04, 2024 Ajay: Added Entity.
				  March 05, 2024 Ajay: Added Account Person Role Type. 
   
*/
/*
Drop Table #TEMPTRNFILE1
Drop Table #TEMPTRNFILE
Drop Table #TempSV
Drop Table #TEMPSV1
*/


--Set @TrnDate='2022-10-17'
Declare @Amount Numeric(18,0)
SET @AMOUNT = 100000000  

SELECT T.* -- ,CASE WHEN TRNMODE='001' THEN 1 ELSE 2 END AS TRNMODE1 
INTO #TEMPTRNFILE1 FROM  
(  
SELECT Br,CID,ACC,CHD,RECID,TRNAMT,TRNPRIAMT,TRNINTAMT,TRNTAXAMT,TRNDESC,RECONKEY,  
       TRNDATE,APPTYPE,TRNMODE,GLCODE,TRNTYPE,SEQ,BALAMT,TLR, TRNTYPE%2 AS TrnType1, NULL AS AccCustType,
	   Case When AppType IN ('1','2','3') And Accstatus='00' Then 'O' When  AppType IN ('1','2','3') And Accstatus Between '01' And '97' Then 'A' 
			When AppType IN ('1','2','3') And Accstatus='98' Then 'D' When  AppType IN ('1','2','3') And Accstatus='99' Then 'C'
			When AppType IN ('4') And Accstatus In ('00','01') Then 'O' When  AppType IN ('4') And Accstatus Between '11' And '89' Then 'A' 
			When AppType IN ('4') And Accstatus='90' Then 'M' When  AppType IN ('4') And Accstatus='99' Then 'C' End As 'status_code'	   
	 FROM T_TRNDAILY   
			WHERE ((APPTYPE='4' AND TRNTYPE BETWEEN '401' AND '460') OR (APPTYPE='3' AND TRNTYPE BETWEEN '301' AND '360') OR (APPTYPE='1' AND TRNTYPE BETWEEN '101' AND '160'))   
				AND CANCELLEDBYTRN IS NULL  And RTrim(AppType)+Rtrim(LTrim(GLCode))+Ltrim(BR) In 
					(Select Left(TableID,1)+Code+Br From T_GLLink Where TableID IN ('10','30') And DepWithdrawal='Y'
					Union
					Select Left(TableID,1)+Code+BR From T_GLLink Where TableID IN ('40')) 
				And Br=(Case When @BR='A' Then Br Else @BR End)
UNION all
SELECT Br,CID,ACC,CHD,RECID, TRNAMT,TRNPRIAMT,TRNINTAMT,TRNTAXAMT,TRNDESC, RECONKEY,   
       TRNDATE,APPTYPE,TRNMODE,GLCODE,TRNTYPE,SEQ,BALAMT,TLR, TRNTYPE%2 AS TrnType1, '001' As AccCustType,
	   Case When AppType IN ('1','2','3') And Accstatus='00' Then 'O' When  AppType IN ('1','2','3') And Accstatus Between '01' And '97' Then 'A' 
			When AppType IN ('1','2','3') And Accstatus='98' Then 'D' When  AppType IN ('1','2','3') And Accstatus='99' Then 'C'
			When AppType IN ('4') And Accstatus In ('00','01') Then 'O' When  AppType IN ('4') And Accstatus Between '11' And '89' Then 'A' 
			When AppType IN ('4') And Accstatus='90' Then 'M' When  AppType IN ('4') And Accstatus='99' Then 'C' End As 'status_code'
	FROM T_TRNHIST  
			WHERE ((APPTYPE='4' AND TRNTYPE BETWEEN '401' AND '460') OR (APPTYPE='3' AND TRNTYPE BETWEEN '301' AND '360') OR (APPTYPE='1' AND TRNTYPE BETWEEN '101' AND '160'))   
				AND CANCELLEDBYTRN IS NULL AND TRNDATE=@TrnDate  And RTrim(AppType)+Rtrim(LTrim(GLCode))+Ltrim(BR) In 
					(Select Left(TableID,1)+Code+BR From T_GLLink Where TableID IN ('10','30') And DepWithdrawal='Y'
					Union
					Select Left(TableID,1)+Code+BR From T_GLLink Where TableID IN ('40')) 
				And Br=(Case When @BR='A' Then Br Else @BR End)
 )T  

 Update T Set T.AccCustType=C.Type From #TEMPTRNFILE1 T, T_CIF C Where T.CID=C.CID And T.BR=C.BR 

 
SELECT T.*, CASE WHEN (TRNMODE='001' or TRNMODEABT ='001') THEN 1 ELSE 2 END AS TRNMODE1 
INTO #TEMPTRNFILE FROM  
(    
SELECT T.* ,T1.TRNMODE as TRNMODEABT FROM #TEMPTRNFILE1 T
LEFT JOIN 
(   
	SELECT Br,ACC,CHD,TRNAMT,RECID,RECONKEY,TRNMODE,TRNDATE FROM T_TRNDAILY WHERE APPTYPE='5' AND USERTRNTYPE ='MBR' AND CANCELLEDBYTRN IS NULL 
	AND TRNDATE=@TrnDate 
	UNION ALL
	SELECT Br,ACC,CHD,TRNAMT,RECID,RECONKEY,TRNMODE,TRNDATE FROM T_TRNHIST WHERE APPTYPE='5' AND USERTRNTYPE ='MBR' AND CANCELLEDBYTRN IS NULL 
	AND TRNDATE=@TrnDate 
) T1 ON CAST(T.RECID AS NVARCHAR (10))=REPLACE(T1.RECONKEY,'-MB','') 
AND T.TRNAMT =T1.TRNAMT AND
T.TRNDATE =T1.TRNDATE ) T


SELECT T1.BR,T1.Apptype,T1.trndate,t1.CID, Sum(t1.DepAmt) as DepAmt, Sum(t1.WdlAmt) as WdlAmt, sum(t1.NonDep) as NonDep, sum(T1.Nonwith) as NonWith,  
       Sum(t1.TrnPriAmt) as TrnPriAmt, 0 as IntAmt,trnmode,  
       sum(t1.TaxAmt) as TAXAMT into #TempSV FROM  
       (SELECT Br,apptype,trndate,CID, sum(TrnAmt) as DepAmt, 0 As WdlAmt, 0 as NonDep, 0 as NonWith,  
			0 as TrnPriAmt,sum(TrnIntAmt)AS INTAMT,trnmode, sum(abs(TrnTaxAmt)) as TAXAMT from #TEMPTRNFILE  
				WHERE ((apptype ='3' and trntype%2=1 and trntype<=359 and trntype not in ('305','307','357','327'))   
                or (apptype='1' and trntype<=159 and trntype%2=1 and  trntype not in ('105','107','157','127','159'))   
                or (apptype='4' and trntype<=459 and trntype%2=1 and  trntype not in ('407')))   
				 --  and ((trnmode ='001' or TRNMODEABT ='001') 
				and (trnmode1=1 and trndate=@TrnDate)   
			Group By Br,apptype,trndate,trnmode,CID  
        UNION  
		SELECT Br,Apptype,trndate,CID, 0 As DepAmt,sum(trnamt) as WdlAmt,0 as NonDep, 0 as NonWith,   
			sum(TrnPriAmt) as TrnPriAmt,sum(TrnIntAmt)AS INTAMT, trnmode,   
			sum(abs(TrnTaxAmt)) as TAXAMT from #TEMPTRNFILE   
				 WHERE ((apptype='3' and trntype%2=0 and trntype%2=0 and trntype not in ( '308','328'))  
					or (apptype='1' and trntype<=159 and trntype%2=0 and trntype not in ('108','128'))  
					or (apptype='4' and trntype<=459 and trntype%2=0 and  trntype not in ('408')) )  
					--- and ((trnmode ='001' or TRNMODEABT ='001') 
					and (trnmode1=1 and trndate=@TrnDate)  
			Group By Br,apptype,trndate,trnmode,CID    --) t1  
			-- GROUP by t1.apptype,t1.trndate,t1.trnmode, t1.acc  
        UNION  
		SELECT Br,Apptype,trndate,cid, 0 as DepAmt, 0 As WdlAmt, sum(TrnAmt) as NonDep, 0 as NonWith,  
			0 as TrnPriAmt,sum(TrnIntAmt)AS INTAMT, trnmode, sum(abs(TrnTaxAmt)) as TAXAMT from #TEMPTRNFILE  
				WHERE ((apptype ='3' and trntype%2=1 and trntype<=359 and trntype not in ('305','307','357','327'))   
					or (apptype='1' and trntype<=159 and trntype%2=1 and  trntype not in ('105','107','157','127','159'))   
					or (apptype='4' and trntype<=459 and trntype%2=1 and  trntype not in ('407')))   
					---and ( (trnmode <>'001' and TRNMODEABT <>'001') 
					and (trnmode1<>1 and trndate=@TrnDate)  
			Group by Br,Apptype,trndate,trnmode, cid  
        UNION  
		SELECT Br,Apptype,trndate,cid, 0 As DepAmt,0 as WdlAmt,0 as NonDep, sum(trnamt) as NonWith,   
			sum(TrnPriAmt) as TrnPriAmt,sum(TrnIntAmt)AS INTAMT, trnmode,   
			sum(abs(TrnTaxAmt)) as TAXAMT from #TEMPTRNFILE   
				WHERE ((apptype='3' and trntype%2=0 and trntype%2=0 and trntype not in ( '308','328'))  
					or (apptype='1' and trntype<=159 and trntype%2=0 and trntype not in ('108','128'))  
					or (apptype='4' and trntype<=459 and trntype%2=0 and  trntype not in ('408')))  
					--- and ((trnmode <>'001' and TRNMODEABT <>'001')  
					and (trnmode1<>1 and trndate=@TrnDate)  
			Group by Br,Apptype,trndate,trnmode,CID) t1  
GROUP BY T1.BR,T1.AppType,T1.TrnDate,T1.TrnMode, T1.CID    
  
--Select '#TempSv', * From #TempSV Where CID='003831'-- And Recid=5913581

Select 'D' as Type,Cid,TrnDate,DepAmt,0 as WDLAmt,NonDep,0 as NonWith Into #TEMPSV1
	From #TempSV Where DepAmt+NonDep>=@amount
Union All
Select 'W' as Type,Cid,TrnDate,0 as DepAmt,WDLAmt,0 as NonDep,NonWith 
	From #TempSV Where WdlAmt+NonWith>=@amount
Order by Cid

--Select '#TempSv1', * From #TEMPSV1 Where CID='003831'



/* 
Select * From #TEMPTRNFILE1
Select * From #TEMPTRNFILE
Select * From #TempSV
Select * From #TEMPSV1
*/

--Select * From #TEMPTRNFILE Where CID IN (Select  CID From #TempSv1) Order By Recid

--Select B1.*, M.GoAml_EntityID, M.GoAml_RepEntityHO From MBNPARMS M, BrParmsNep B1

--Select * From MBNGOAMLExtendedInfo
--Select * From TempGoAmlTTR

If @RepType=1
Begin
	Insert Into MBNGOAMLExtendedInfo (BR,Acc,Chd,Trn,TrnDate,AppType,TrnAmt,TrnDesc) 
	Select @Br,Acc,Chd,Recid,TrnDate,AppType,TrnAmt/100,TrnDesc From #TEMPTRNFILE Where Recid Not In (Select Trn From MBNGOAMLExtendedInfo)
		And CID IN (Select  CID From #TempSv1)

	If @Br<>'A' 
	Select * From MBNGOAMLExtendedInfo where Br=@Br and TrnDate=@TrnDate Order By Trn 
	Else
	Select * From MBNGOAMLExtendedInfo where Br=Br and TrnDate=@TrnDate Order By Trn 

End

If @RepType=2 
Begin 

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME =N'#TempGoAmlTTR')
DROP TABLE #TempGoAmlTTR

--Select '#TempTrnFile', * From #TEMPTRNFILE Where Acc='1102379' And Recid=5913581

Select Row_Number () over (order by T.recid) as 'recid',
	M.GoAml_EntityID As 'rentity_id', M.GoAml_RepEntityHO As 'rentity_branch', 'E' As 'submission_code', 'TTR' As 'report_code',T.TrnDate As 'report_date', 
		'NPR' As 'currency_code_local', M.GoAml_RepUserCode as 'reporting_user_code',

	Rtrim(B1.TypeAddr) As 'address_type', Rtrim(B1.Addr) As 'address', Rtrim(B1.Municipality) As 'town', Rtrim(B1.District) As 'city', Rtrim(B1.WardNo) As 'zip',
		'NP' As 'country_code', Rtrim(B1.States) As 'state',

	T.Recid As 'transactionnumber',Rtrim(B1.Addr) As 'transaction_location',T.TrnDate As 'date_transaction', M1.TrnMode As 'transmode_code', T.TrnAmt/100 As 'amount_local',
	'A' As 'from_funds_code', M1.SourceOfFund As 'from_funds_comment',

	M1.Gender As 'gender1',Rtrim(M1.ExtendedName1) As 'first_name1', Rtrim(M1.ExtendedName2) As 'last_name1',M1.BirthDate As 'birthdate1', Rtrim(M1.CitizenshipIssuedPlace) As 'birth_place1',
		'NP' As 'nationality1', 'NP' As 'residence1', 
		'3' As 'tph_contact_type1',																	--Used only Personal Phone (5) as Contact Type
		'M' As 'tph_communication_type1', Rtrim(M1.Mobile1) As 'tph_number1',						--Used only Mobile (M) As Communication Type

	'1' As 'address_type1',																			--Used only Permanent Address (1) as Address Type
	Rtrim(M1.address2) As 'address1', Rtrim(M1.town2) As 'town1', Rtrim(M1.city2) As 'city1', Rtrim(M1.zip2) As 'zip1',
		'NP' As 'country_code1',

	M1.FullDesc as 'occupation1',

	'B' As 'type1', Case When M1.CitizenshipNo is not Null Or M1.CitizenshipNo<>'' Then Rtrim(M1.CitizenshipNo)			--Used only Citizenship (B) As Identification 
						When M1.Nid is Not Null or M1.NID<>'' Then Rtrim(M1.NID) Else Null End As 'number1', 
		M1.CitizenshipIssuedPlace As 'issued_by1', 	'NP' As 'issue_country1',

	Case When T.TrnMode='001' Then 'K' When T.TrnMode<>'001' And T.TrnType%2=0 Then 'A' When T.TrnMode<>'001' And T.TrnType%2=1 Then 'C' End As 'to_funds_code',   --Used only Cash (K), Deposit (A) and Withdraw (C) Code as Fund Type

	O.OrgName As 'institution_name', 'NA' As 'swift', B1.Addr As 'branch', Rtrim(T.Acc)+Ltrim(T.Chd) As 'account', 'NPR' As 'currency_code', C.Displayname As 'account_name',
		Case When T.AppType=1 Then 'C' When T.AppType=2 Then 'B' When T.AppType='3' Then 'A' When T.AppType='4' Then 'D' End As 'account_type',       --Used All Loans are Loan-Non Revolving. 

	L.Gender As 'gender2', Rtrim(C.Name1) As 'first_name2', Rtrim(C.Name2) As 'last_name2', C.BirthDate As 'birthdate2', Rtrim(C1.CitizenshipIssuedPlace) As 'birth_place2',
		'NP' As 'nationality2', 'NP' As 'residence2',
		'5' As 'tph_contact_type2',																		--Used only Personal Phone (5) as Contact Type
		'M' As 'tph_communication_type2', Rtrim(C.Mobile1) As 'tph_number2',							--Used only Mobile (M) As Communication Type

	'1' As 'address_type2',																				--Used only Permanent Address (1) as Address Type
	Rtrim(A.Line1) As 'address2', Rtrim(A.Line2) As 'town2', Rtrim(A.Line3) As 'city2', Rtrim(C1.Addr2LocalLang) As 'zip2', 
		'NP' As 'country_code2',

	U1.FullDesc As 'occupation2',

	'B' As 'type2', Case When C1.CitizenshipNo is not Null Or C1.CitizenshipNo<>'' Then Rtrim(C1.CitizenshipNo)			--Used only Citizenship (B) As Identification 
						When C.Nid is Not Null or C.NID<>'' Then Rtrim(C.NID) Else Null End As  'number2',
		C1.CitizenshipIssuedPlace As 'issued_by2', 'NP' As 'issue_country2', 
	
	T1.OpenDate As 'opendate',Case When T.TrnType1=1 And T.AppType IN ('1','3') Then (T.BalAmt+T.TrnPriAmt)/100
								When T.TrnType1=0 And T.AppType IN ('1','3') Then (T.TrnPriAmt-T.BalAmt)/100 
								When T.TrnType1=1 And T.AppType IN ('4') Then (T.TrnPriAmt-T.BalAmt)/100 
								When T.TrnType1=0 And T.AppType IN ('4') Then (T.BalAmt+T.TrnPriAmt)/100 End As 'balance', 
	
	
	T.TrnDate As 'date_balance',T.status_code,M1.FundSource,M1.FundSourceSubType,T.BR,T.CID,T.AccCustType,M1.InitCustType,T.TrnType1,

	Rtrim(M1.RegNumber) As 'incorporation_number1', Rtrim(M1.BirthDate) As 'incorporation_date1', Rtrim(M1.PANNo) As 'tax_number1', Rtrim(M1.RegistrationIssuedAuthority) As 'incorporation_state1', 
	Rtrim(K2.LookupCode) As 'incorporation_legal_from1',Rtrim(M1.business) As 'business1',				

	Rtrim(C.RegNumber) As 'incorporation_number2', C.BirthDate As 'incorporation_date2', C1.PANNo As 'tax_number2', C1.RegistrationIssuedAuthority As 'incorporation_state2', 
	Rtrim(K1.LookupCode) As 'incorporation_legal_from2',C1.Business As 'business2',

	Rtrim(K.LookupCode) As [Role], Rtrim(C4.Name1) As RelPrName1, Rtrim(C4.Name2) As RelPrName2, Rtrim(C4.CitizenshipNo) As RelPrCtzNo, 
	C4.BirthDate As RelPrDOB, Rtrim(C4.RelOccupation) As RelPrOcc, Rtrim(C4.Gender) As RelGender,Null As RelFatherName, C4.Mobile1 As RelMobile1,
	C4.birth_place As RelBirthPlace,C4.address As RelAddress,C4.town As RelTown,
	C4.city As RelCity,C4.Zip As RelZip, U2.ShortDesc As AccRoleType
	
	
	Into #TempGoAmlTTR

	From MBNPARMS M, Orgparms O, (Select * From #TEMPTRNFILE Where CID IN (Select  CID From #TempSv1)) T
	Left Join T_CIF C On T.CID=C.CID And T.BR=C.BR
	Left Join T_CIFExtendedInfo C1 On C.CID=C1.CID And C.BR=C1.BR
	Left join ( Select Br,Acc,Chd,OpenDate,AccStatus From T_SvAcc
				Union
				Select Br,Acc,Chd,OpenDate,AccStatus  From T_TDAcc
				Union
				Select Br,Acc,Chd,OpenDate,AccStatus  From T_LnAcc 
				) T1 On T.Acc=T1.Acc And T.BR=T1.BR
	Left Join (Select * From T_Address Where PrimaryTF='T') A On T.CID=A.CID And T.BR=A.BR
	Left Join (Select LookUpCode,Case When FullDesc='Male' Then 'M' 
									When FullDesc='Female' Then 'F' Else 'T' End As Gender 
				From Lookup Where LookupID='GT' And LangType='001') L On C.GenderType=L.LookUpCode		--Gender of To Client 
	Left Join T_BrParmsNep B1 On T.BR=B1.BR
	Left Join (Select * From T_UserLookup Where LookupID='61') U1 On C.CIFCode1=U1.LookupCode And C.BR=U1.BR    --Occupation of To Client
	Left Join (Select C.Name1 As ExtendedName1, C.Name2 As ExtendedName2, C.BirthDate, L.Gender,
					Rtrim(A.Line1) As 'address2', Rtrim(A.Line2) As 'town2', Rtrim(A.Line3) As 'city2', Rtrim(C1.Addr2LocalLang) As 'zip2', 
					U.FullDesc,C1.CitizenshipNo,C1.CitizenshipIssuedDate,C1.CitizenshipIssuedPlace,C.NID,C.Mobile1,C.Type As 'InitCustType',
					C.RegNumber, C.RegisterDate, C1.PANNo, C1.RegistrationIssuedAuthority, C1.LegalStatus,C1.Business As 'business',
					M.* 
				From MBNGOAMLExtendedInfo M
				Left Join T_RelAcc R On M.Acc=R.Acc And M.BR=R.BR
				Left Join T_CIF C On R.CID=C.CID And R.BR=C.BR
				Left Join (Select LookUpCode,Case When FullDesc='Male' Then 'M' 
									When FullDesc='Female' Then 'F' Else 'T' End As Gender 
							From Lookup Where LookupID='GT' And LangType='001') L On C.GenderType=L.LookUpCode 
				Left Join (Select * From T_ADDRESS Where PrimaryTF='T') A On C.CID=A.CID And C.BR=A.BR
				Left Join T_CIFExtendedInfo C1 On C.CID=C1.CID And C.BR=C1.BR
				Left Join (Select * From T_UserLookup Where LookupID='61') U On C.CIFCode1=U.LookupCode And C.BR=U.BR
				Where FundSource=1

				Union

				Select C.Name1 As ExtendedName1, C.Name2 As ExtendedName2, C.BirthDate, L.Gender,
					Rtrim(A.Line1) As 'address2', Rtrim(A.Line2) As 'town2', Rtrim(A.Line3) As 'city2', Rtrim(C1.Addr2LocalLang) As 'zip2',
					U.FullDesc,C1.CitizenshipNo,C1.CitizenshipIssuedDate,C1.CitizenshipIssuedPlace,C.NID,C.Mobile1,C.Type As 'InitCustType',
					C.RegNumber, C.RegisterDate, C1.PANNo, C1.RegistrationIssuedAuthority, C1.LegalStatus,C1.Business As 'business',
					M.* 
				From MBNGOAMLExtendedInfo M
				Left Join T_CIF C On M.OwnClientCID=C.CID And M.OwnClientBr=C.BR
				Left Join (Select LookUpCode,Case When FullDesc='Male' Then 'M' 
									When FullDesc='Female' Then 'F' Else 'T' End As Gender 
						From Lookup Where LookupID='GT' And LangType='001') L On C.GenderType=L.LookUpCode 
				Left Join (Select * From T_ADDRESS Where PrimaryTF='T') A On C.CID=A.CID And C.BR=A.BR
				Left Join T_CIFExtendedInfo C1 On C.CID=C1.CID And C.BR=C1.BR
				Left JOin (Select * From T_UserLookup Where LookupID='61') U On C.CIFCode1=U.LookupCode And C.BR=U.BR
				Where FundSource=2

				Union

				Select Name1 As ExtendedName1, Name2 As ExtendedName2, Null As BirthDate,Null AS Gender,
					Null As 'address2', Null 'town2', Null As 'city2', Null As 'zip2',Null As FullDesc,Null AS CitizenshipNo
					,Null As CitizenshipIssuedDate,Null As CitizenshipIssuedPlace,Null As NID,Null As Mobile1,
					Case When FundSourceSubType=1 Then '001' When FundSourceSubType=2 Then '002' End As InitCustType, 
					Null As 'RegNumber', Null As 'RegisterDate', Null As 'PANNo', Null As 'RegistrationIssuedAuthority', 
					Null As 'LegalStatus',Null As 'business',
					M.* 
				From MBNGOAMLExtendedInfo M
				Where FundSource=3 Or FundSource Is Null
				) M1 ON T.Acc=M1.Acc and T.BR=M1.BR And T.Recid=M1.Trn
	Left Join (Select ROW_NUMBER() over (partition By BR,CID order by CID) As SNo,  * From T_CIFExtendedInfoDetail3) C3 On T.CID=C3.CID And T.BR=C3.BR And C3.SNo=1
	Left Join (Select C3.RelBr,C3.RelCID,Case When L.FullDesc='Male' Then 'M' When L.FullDesc='Female' Then 'F' Else 'T' End As Gender,C.Name1,C.Name2,C.BirthDate,  
				Rtrim(C1.CitizenshipIssuedPlace) As 'birth_place',C1.CitizenshipNo,U.FullDesc AS RelOccupation,
				Rtrim(A.Line1) As 'address', Rtrim(A.Line2) As 'town', Rtrim(A.Line3) As 'city', Rtrim(Left(A.Line4,CHARINDEX(' ',Line4)-1)) As 'zip', Rtrim(C.Mobile1) As Mobile1
					From T_CIFExtendedInfoDetail3 C3
				Left Join T_CIF C ON C3.RelBr=C.Br And C3.RelCID=C.CID
				Left Join T_Address A On C3.RelBR=A.BR And C3.RelCID=A.CID
				Left Join T_CIFExtendedInfo C1 On  C3.RelCID=C1.CID And C3.RelBR=C1.BR
				Left Join LOOKUP L ON L.LookUpId='GT' And L.LangType='001' And C.GenderType=L.LookUpCode
				Left Join (Select * From T_UserLookup Where LookupID='61') U On C.CIFCode1=U.LookupCode And C.BR=U.BR
				) C4 On C3.RelBr=C4.RelBr And C3.RelCID=C4.RelCID 
	Left Join KYCLookup K On C3.RelationID=K.FullDesc And K.LookupID='ER'
	Left Join KYCLookup K2 On M1.LegalStatus=K2.FullDesc And K2.LookupID='LS'				--For Conductor
	Left Join KYCLookup K1 On C1.LegalStatus=K1.FullDesc And K1.LookupID='LS'				--For Account Holder 
	Left Join T_SIGNRULE S On T.Acc=S.Acc And T.BR=S.BR
	Left Join T_USERLOOKUP U2 On S.BR=U2.BR And S.SignCode=U2.LookUpCode And U2.LookUpId='SC'


	Where RepStatus='P'

If @Grid='F'
		Select * From #TempGoAmlTTR Where report_date=@TrnDate And Br=(Case When @BR='A' Then Br Else @BR End) Order By transactionnumber

If @Grid='T'
Select * From #TempGoAmlTTR Where report_date=@TrnDate And Br=(Case When @BR='A' Then Br Else @BR End) Order By transactionnumber
--Exec sp_GoAml_TTR '000002', '2022-10-17',2,'T'
End



