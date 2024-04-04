if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_GoAml]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_GoAml]
GO

SET QUOTED_IDENTIFIER ON 
SET ANSI_NULLS ON 
GO
CREATE procedure sp_GoAml @ReportType Nvarchar(3), @Br Nvarchar(6),  @TrnDate Datetime       
As  

/*  
   Procedure to generate sp_GoAml 
   PROJECT      : FAO/GTZ MICROBANKING SYSTEM (MBNepal)   
   PROGRAM NAME : sp_GoAml_TTR   
   CREATED BY   : Ajay G Shrestha  
   DATE         : 16 Oct 2023 
   DESCRIPTION  : To Generate GoAML report 
   SYNTAX		: Exec sp_GoAml 'TTR', '000001', '2022-11-05' 
				  Exec sp_GoAml 'TTR', 'A', '2022-11-05' 

   Drop Table #TempGoAmlTTR1

   Note: 
   >> If Citizenship Issued by is Null then passing "Government of Nepal". 
   
 
   MODIFIED ON  : Dec 05, 2023 Ajay: Used #TempGoAmlTTR1 instead of TempGoAmlTTR table.
				  Dec 11, 2023 Ajay: Added Source Fund and fixed for t_from. Added Citizenship Issued District.
				  Jan 04, 2024 Ajay: Replace & as &amp; to support in XML file. 
				  March 04, 2024 Ajay: Added Entity. 
				  March 05, 2024 Ajay: Added Account Person Role Type
				  March 28, 2024 Ajay: Added Transactions of same account and TrnType into single XML file. Previously, each XML file represented a single transaction. 

   
   
   @ReportType: TTR, 
   @Br: A= All Branches 

   this is just a test
*/

Create Table #GoAML
(
Br Nvarchar(6),
TrnDate Date,
TrnType Nvarchar(1),
Acc Nvarchar(11),
--Trn Int,
GoAMLData Nvarchar(max)
)

CREATE TABLE #TempGoAmlTTR1(
	[recid] [bigint] NULL,
	[rentity_id] [numeric](10, 0) NULL,
	[rentity_branch] [nvarchar](50) NULL,
	[submission_code] [varchar](1)  NULL,
	[report_code] [varchar](3)  NULL,
	[report_date] [datetime]  NULL,
	[currency_code_local] [varchar](3)  NULL,
	[reporting_user_code] [nvarchar](20) NULL,
	[address_type] [nvarchar](50) NULL,
	[address] [nvarchar](50) NULL,
	[town] [nvarchar](50) NULL,
	[city] [nvarchar](50) NULL,
	[zip] [varchar](12) NULL,
	[country_code] [varchar](2)  NULL,
	[state] [nvarchar](20) NULL,
	[transactionnumber] [int]  NULL,
	[transaction_location] [nvarchar](50) NULL,
	[date_transaction] [datetime]  NULL,
	[transmode_code] [varchar](1) NULL,
	[amount_local] [numeric](24, 6) NULL,
	[from_funds_code] [varchar](1)  NULL,
	[from_funds_comment] [varchar](100)  NULL,
	[gender1] [varchar](1) NULL,
	[first_name1] [nvarchar](50) NULL,
	[last_name1] [nvarchar](50) NULL,
	[birthdate1] [datetime] NULL,
	[birth_place1] [nvarchar](50) NULL,
	[nationality1] [varchar](2)  NULL,
	[residence1] [varchar](2)  NULL,
	[tph_contact_type1] [varchar](1)  NULL,
	[tph_communication_type1] [varchar](1)  NULL,
	[tph_number1] [nvarchar](15) NULL,
	[address_type1] [varchar](1)  NULL,
	[address1] [nvarchar](50) NULL,
	[town1] [nvarchar](50) NULL,
	[city1] [nvarchar](50) NULL,
	[zip1] [nvarchar](36) NULL,
	[country_code1] [varchar](2)  NULL,
	[occupation1] [varchar](50)  NULL,
	[type1] [varchar](1)  NULL,
	[number1] [nvarchar](24) NULL,
	[issued_by1] [varchar](19)  NULL,
	[issue_country1] [varchar](2)  NULL,
	[to_funds_code] [varchar](1)  NULL,
	[institution_name] [nvarchar](100) NULL,
	[swift] [varchar](2)  NULL,
	[branch] [nvarchar](50) NULL,
	[account] [nvarchar](12) NULL,
	[currency_code] [varchar](3)  NULL,
	[account_name] [nvarchar](100) NULL,
	[account_type] [varchar](1)  NULL,
	[gender2] [varchar](1) NULL,
	[first_name2] [nvarchar](50) NULL,
	[last_name2] [nvarchar](50) NULL,
	[birthdate2] [datetime] NULL,
	[birth_place2] [nvarchar](50) NULL,
	[nationality2] [varchar](2)  NULL,
	[residence2] [varchar](2)  NULL,
	[tph_contact_type2] [varchar](1)  NULL,
	[tph_communication_type2] [varchar](1)  NULL,
	[tph_number2] [nvarchar](15) NULL,
	[address_type2] [varchar](1)  NULL,
	[address2] [nvarchar](24) NULL,
	[town2] [nvarchar](24) NULL,
	[city2] [nvarchar](24) NULL,
	[zip2] [nvarchar](36) NULL,
	[country_code2] [varchar](2)  NULL,
	[occupation2] [nvarchar](100) NULL,
	[type2] [varchar](1)  NULL,
	[number2] [nvarchar](24) NULL,
	[issued_by2] [varchar](19)  NULL,
	[issue_country2] [varchar](2)  NULL,
	[opendate] [datetime] NULL,
	[balance] [numeric](18, 0) NULL,
	[date_balance] [datetime]  NULL,
	[status_code] [varchar](1) NULL,
	[FundSource] [Int] Null,
	[FundSourceSubType] [Int] Null,
	[BR] [nvarchar](6)  NULL,
	[CID] [nvarchar](6) Null,
	[AccCustType] [nvarchar](3) Null,
	[InitCustType] [nvarchar](3) Null,
	[TrnType1] [nvarchar](1) Null, 
	[incorporation_number1] [nvarchar](50) Null,
	[incorporation_date1] [datetime] Null,
	[tax_number1] [nvarchar](10) Null,
	[incorporation_state1] [nvarchar](50) Null,
	[incorporation_legal_from1] [nvarchar](50) Null,
	[business1] [nvarchar](24) Null,
	[incorporation_number2] [nvarchar](50) Null,
	[incorporation_date2] [datetime] Null,
	[tax_number2] [nvarchar](10) Null,
	[incorporation_state2] [nvarchar](50) Null,
	[incorporation_legal_from2] [nvarchar](50) Null,
	[business2] [nvarchar](24) Null, 
	[Role] [Nvarchar](36) Null,
	[RelPrName1] [Nvarchar](50) Null,
	[RelPrName2] [Nvarchar](50) Null,
	[RelPrCtzNo] [Nvarchar](24) Null,
	[RelPrDOB] [DateTime] Null, 
	[RelPrOcc] [Nvarchar](24) Null, 
	[RelGender] [Nvarchar](1) Null, 
	[RelFatherName] [Nvarchar](24) Null,
	[RelMobile1] [Nvarchar](20) Null,
	[RelBirthPlace] [Nvarchar](24) Null,
	[RelAddress] [Nvarchar](24) Null,
	[RelTown] [Nvarchar](24) Null,
	[RelCity] [Nvarchar](24) Null,
	[RelZip] [Nvarchar](24) Null,
	[AccRoleType] [Nvarchar](5) Null


) 

If @ReportType='TTR'
Begin



If @Br='A'
Insert Into #TempGoAmlTTR1
Exec sp_GoAml_TTR 'A', @TrnDate, 2,'F' 
Else 
Insert Into #TempGoAmlTTR1
Exec sp_GoAml_TTR @Br, @TrnDate, 2,'F' 

--Select Distinct Br,Account,TrnType1 rentity_id, rentity_branch, submission_code, report_code,report_date, currency_code_local, reporting_user_code,
--	address_type, address, 	town,city,zip, country_code,state Into #TempGoAmlTTR2 From #TempGoAmlTTR1
		

--Select Br,Account,TrnType1, * From #TempGoAmlTTR1
DECLARE @XML Nvarchar (Max)
DECLARE @Acc Nvarchar(11) 
DECLARE @BR1 Nvarchar(6) 
DECLARE @TRNTYPE Nvarchar(1) 
DECLARE  ACC CURSOR LOCAL FOR 
SELECT Distinct Br,Account,TrnType1 From #TempGoAmlTTR1 
OPEN     ACC
FETCH  NEXT FROM ACC INTO @BR1,@ACC,@TRNTYPE
WHILE (@@FETCH_STATUS = 0 )     
BEGIN 



	--Declare @XML Nvarchar (Max) 
	--Declare @CNT Integer=(Select Max(RecID) From #TempGoAmlTTR1)
	--Declare @I Integer=1
	--While @I<=@CNT
	--Begin
	

   set @XML=(
		
		--Select 	rentity_id As 'rentity_id', rentity_branch As 'rentity_branch', submission_code As 'submission_code', report_code As 'report_code',
		--		report_date As 'report_date', currency_code_local As 'currency_code_local', reporting_user_code As 'reporting_user_code',
		Select 	GoAml_EntityID As 'rentity_id', GoAml_RepEntityHO As 'rentity_branch', 'E' As 'submission_code', 'TTR' As 'report_code',
				@TrnDate As 'report_date', 'NPR' As 'currency_code_local', GoAml_RepUserCode As 'reporting_user_code',
		
			--Location 
			--(Select 
			--	address_type As 'address_type', Replace(address,'&','&amp;') As 'address', 	Replace(town,'&','&amp;') As 'town', Replace(city,'&','&amp;') As 'city',
			--	zip As 'zip', country_code As 'country_code', Replace(state,'&','&amp;') As 'state' From T_BrParmsNep Where Br=@BR1 
			--	FOR XML PATH('location'), Type
			--),
			(Select 
				TypeAddr As 'address_type', Replace(Addr,'&','&amp;') As 'address', 	Replace(Municipality,'&','&amp;') As 'town', Replace(District,'&','&amp;') As 'city',
				WardNo As 'zip', 'NP' As 'country_code', Replace(states,'&','&amp;') As 'state' From T_BrParmsNep Where Br=@BR1 
				FOR XML PATH('location'), Type
			),
				
			
			--Transaction
			(
			Select 
				transactionnumber As 'transactionnumber', transaction_location As 'transaction_location', date_transaction As 'date_transaction',
				transmode_code As 'transmode_code', amount_local As 'amount_local',
			
--------******** For Deposit Case -------------- From 
			Case When FundSource IN (1,2) And TrnType1=1 And InitCustType<>'002' Then							--11 Dec, Changed for Own Client 
				--t_from_my_client
				(Select 
					from_funds_code As 'from_funds_code', from_funds_comment As 'from_funds_comment',

					--from_person
					(Select
						gender1 As 'gender', Replace(first_name1,'&','&amp;') As 'first_name', Replace(last_name1,'&','&amp;') As 'last_name',
						birthdate1 As 'birthdate', IsNull(birth_place1,'NP') As 'birth_place', number1 As 'ssn',
						nationality1 As 'nationality1', residence1 As 'residence',

						--phones
							--phone
							(Select 
								tph_contact_type1 As 'tph_contact_type', tph_communication_type1 As 'tph_communication_type', tph_number1 As 'tph_number'
							FOR XML PATH ('phone'),Type, root ('phones')
							),

						--addresses
							--address
								(Select
									'1' As 'address_type', Replace(address1,'&','&amp;') As 'address', Replace(town1,'&','&amp;') As 'town',
									Replace(city1,'&','&amp;') As 'city', Replace(zip1,'&','&amp;') As 'zip', country_code1 As 'country_code'
								FOR XML PATH ('address'),Type, root('addresses')),

								--occupation
								occupation1 As 'occupation',

						--identifications
							--identification
							(Select 
								type1 As 'type', number1 As 'number', IsNull(issued_by1,'Government of Nepal') As 'issued_by', issue_country1 As 'issue_country'
							FOR XML PATH ('identification'),Type, root('identifications'))


					FOR XML PATH ('from_person'),Type),

					--from_country
					'NP' As 'from_country'
				
				FOR XML PATH ('t_from_my_client'), Type
				)

		When FundSource IN (1,2) And TrnType1=1 And InitCustType='002' Then								--11 Dec, Changed for Own Client 
				--t_from_my_client
				(Select 
					from_funds_code As 'from_funds_code', from_funds_comment As 'from_funds_comment',

					--from_entity
					(Select
						Replace(first_name1,'&','&amp;') As 'name', incorporation_legal_from1 As 'incorporation_legal_form',
						incorporation_number1 As 'incorporation_number',business1 As 'business',
						
						--phones
							--phone
							(Select 
								tph_contact_type1 As 'tph_contact_type', tph_communication_type1 As 'tph_communication_type', tph_number1 As 'tph_number'
							FOR XML PATH ('phone'),Type, root ('phones')
							),

						--addresses
							--address
								(Select
									'2' As 'address_type', Replace(address1,'&','&amp;') As 'address', Replace(town1,'&','&amp;') As 'town',
									Replace(city1,'&','&amp;') As 'city', Replace(zip1,'&','&amp;') As 'zip', country_code1 As 'country_code'
								FOR XML PATH ('address'),Type, root('addresses')),
					incorporation_state1 As 'incorporation_state', 'NP' As 'incorporation_country_code', incorporation_date1 As 'incorporation_date', tax_number1 As 'tax_number'
			
					FOR XML PATH ('from_entity'),Type),

					--from_country
					'NP' As 'from_country'
				
				FOR XML PATH ('t_from_my_client'), Type
				)

		When FundSource IN (3) And TrnType1=1 And FundSourceSubType=1 Then											--11 Dec, Changed for Other person. 
					--t_person
				(Select 
					from_funds_code As 'from_funds_code', Replace(from_funds_comment,'&','&amp;') As 'from_funds_comment',

					--from_person
					(Select
						Replace(first_name1,'&','&amp;') As 'first_name', Replace(last_name1,'&','&amp;') As 'last_name'
					FOR XML PATH ('from_person'),Type),

				
					--from_country
					'NP' As 'from_country'
				
				FOR XML PATH ('t_from'), Type
				)
		When FundSource IN (3) And TrnType1=1 And FundSourceSubType=2 Then											--11 Dec, Changed for Other person. 
					--t_person
				(Select 
					from_funds_code As 'from_funds_code', Replace(from_funds_comment,'&','&amp;') As 'from_funds_comment',

					--from_entity
					(Select
						Replace(first_name1,'&','&amp;')+' '+Replace(last_name1,'&','&amp;') As 'name'
					FOR XML PATH ('from_entity'),Type),

				
					--from_country
					'NP' As 'from_country'
				
				FOR XML PATH ('t_from'), Type
				)
				End ,

----------**** For Withdraw Case --------------- From 
			Case When TrnType1=0 And AccCustType<>'002' Then					---For Individual
				(Select
					to_funds_code As 'from_funds_code',

					--to_account
					(Select 
						Replace(institution_name,'&','&amp;') As 'institution_name', swift As 'swift', branch As 'branch', account As 'account',
						currency_code As 'currency_code', account_name As 'account_name', account_type As 'account_type',
					

						--related_person
							--account_related_person
								(Select 
									--t_person
									(Select 
										gender2 As 'gender', Replace(first_name2,'&','&amp;') As 'first_name', Replace(last_name2,'&','&amp;') As 'last_name',
										birthdate2 As 'birthdate', IsNull(birth_place2,'NP') As 'birth_place', number2 As 'ssn',
										nationality2 As 'nationality1', residence2 As 'residence',

									--phones
										--phone
											(Select 
												tph_contact_type2 As 'tph_contact_type', tph_communication_type2 As 'tph_communication_type', tph_number2 As 'tph_number'
											FOR XML PATH ('phone'), Type, root('phones')
											),

									--addresses
										--address
											(Select 
												'1' As 'address_type', Replace(address2,'&','&amp;') As 'address', Replace(town2,'&','&amp;') As 'town',
												Replace(city2,'&','&amp:') As 'city', zip2 As 'zip', country_code2 As 'country_code'
											FOR XML PATH ('address'),Type, root ('addresses')
											),

										--occupation
										occupation2 As 'occupation',

								--identifications
									--identification
										(Select 
											type2 As 'type', number2 As 'number', IsNull(issued_by2,'Government of Nepal') As 'issued_by', issue_country2 As 'issue_country'
										FOR XML PATH ('identification'),Type, root('identifications')
										)
							
									FOR XML PATH ('t_person'),Type
									),

									--role
									AccRoleType As 'role'

							FOR XML PATH ('account_related_person'),Type, root('related_persons')
							),
							opendate As 'opened', balance As 'balance', date_balance As 'date_balance', status_code As 'status_code'

						FOR XML PATH ('from_account'),Type),						
						
						--to_country
						'NP' As 'from_country'

				FOR XML PATH ('t_from_my_client'),Type
				) 
				--End ,


	When TrnType1=0 And AccCustType='002' Then					---For Entity
				(Select
					to_funds_code As 'from_funds_code',

					--from_account
					(Select 
						Replace(institution_name,'&','&amp;') As 'institution_name', swift As 'swift', branch As 'branch', account As 'account',
						currency_code As 'currency_code', account_name As 'account_name', account_type As 'account_type',
					

							--t_entity
									(Select 
										Replace(first_name1,'&','&amp;') As 'name',--+' '+Replace(last_name1,'&','&amp;') As 'Name',											--Need to change fields
										incorporation_legal_from2  As 'incorporation_legal_form', incorporation_number2 As 'incorporation_number',
										business2 As 'business',

									--phones
										--phone
											(Select 
												tph_contact_type2 As 'tph_contact_type', tph_communication_type2 As 'tph_communication_type', tph_number2 As 'tph_number'
											FOR XML PATH ('phone'), Type, root('phones')
											),

									--addresses
										--address
											(Select 
												'2' As 'address_type', Replace(address2,'&','&amp;') As 'address', Replace(town2,'&','&amp;') As 'town',
												Replace(city2,'&','&amp:') As 'city', zip2 As 'zip', country_code2 As 'country_code'
											FOR XML PATH ('address'),Type, root ('addresses')
											),

									incorporation_state2 As 'incorporation_state', 'NP' As 'incorporation_country_code', incorporation_date2 As 'incorporation_date',
									tax_number2 As 'tax_number'
							
									FOR XML PATH ('t_entity'),Type),

									--related_person
										--account_related_person
												--t_person
								(Select 
									(Select 
										RelGender As 'gender', Replace(RelPrName1,'&','&amp;') As 'first_name', Replace(RelprName2,'&','&amp;') As 'last_name',
										RelPrDOB As 'birthdate',Replace(RelBirthPlace,'&','&amp;') As 'birth_place',
										RelPrCtzNo As 'ssn',
										'NP' As 'nationality1', 'NP' As 'residence',

									--phones
										--phone
											(Select 
												'5' As 'tph_contact_type', 'M' As 'tph_communication_type', RelMobile1 As 'tph_number'    --tph_contact_type and tph_communication_type fixed as 2 and M
											FOR XML PATH ('phone'), Type, root('phones')
											),
								
									--addresses
										--address
											(Select 
												'1' As 'address_type', 
												Replace(RelAddress,'&','&amp;') As 'address', Replace(RelTown,'&','&amp;') As 'town',
												Replace(RelCity,'&','&amp:') As 'city', Replace(RelZip,'&','&amp;') As 'zip', 'NP' As 'country_code'
												--'address' As 'address', --'town' As 'town',
												--'city' As 'city', 'zip' As 'zip', 'NP' As 'country_code'
											FOR XML PATH ('address'),Type, root ('addresses')
											),
							
										--occupation
										Replace(RelPrOcc,'&','&amp;') As 'occupation'--,

							/*	--identifications
									--identification
										(Select 
											type2 As 'type', number2 As 'number', IsNull(issued_by2,'Government of Nepal') As 'issued_by', issue_country2 As 'issue_country'
										FOR XML PATH ('identification'),Type, root('identifications')
										)
							*/
									FOR XML PATH ('t_person'),Type
									),

									--role
									AccRoleType As 'role'

							FOR XML PATH ('account_related_person'),Type, root('related_persons')
							),
							opendate As 'opened', balance As 'balance', date_balance As 'date_balance', status_code As 'status_code'

						FOR XML PATH ('from_account'),Type),						
						
						--to_country
						'NP' As 'from_country'

				FOR XML PATH ('t_from_my_client'),Type
				) 
				End ,


----------******* For Deposit Case --------------- To 
			Case When TrnType1=1 And AccCustType<>'002' Then				---For Individual 	
				--t_to_my_client
				(Select
					to_funds_code As 'to_funds_code',
				--to_account
					(Select 
						Replace(institution_name,'&','&amp;') As 'institution_name', swift As 'swift', branch As 'branch', account As 'account',
						currency_code As 'currency_code', account_name As 'account_name', account_type As 'account_type',
				
						--related_person
							--account_related_person
								(Select 
									--t_person
									(Select 
										gender2 As 'gender', Replace(first_name2,'&','&amp;') As 'first_name', Replace(last_name2,'&','&amp;') As 'last_name',
										birthdate2 As 'birthdate', IsNull(birth_place2,'NP') As 'birth_place', number2 As 'ssn',
										nationality2 As 'nationality1', residence2 As 'residence',

									--phones
										--phone
											(Select 
												tph_contact_type2 As 'tph_contact_type', tph_communication_type2 As 'tph_communication_type', tph_number2 As 'tph_number'
											FOR XML PATH ('phone'), Type, root('phones')
											),

									--addresses
										--address
											(Select 
												'1' As 'address_type', Replace(address2,'&','&amp;') As 'address', Replace(town2,'&','&amp;') As 'town',
												Replace(city2,'&','&amp:') As 'city', zip2 As 'zip', country_code2 As 'country_code'
											FOR XML PATH ('address'),Type, root ('addresses')
											),

										--occupation
										occupation2 As 'occupation',

								--identifications
									--identification
										(Select 
											type2 As 'type', number2 As 'number', IsNull(issued_by2,'Government of Nepal') As 'issued_by', issue_country2 As 'issue_country'
										FOR XML PATH ('identification'),Type, root('identifications')
										)
							
									FOR XML PATH ('t_person'),Type
									),
									--role
									AccRoleType As 'role'

							FOR XML PATH ('account_related_person'),Type, root('related_persons')
							),
							opendate As 'opened', balance As 'balance', date_balance As 'date_balance', status_code As 'status_code'

						FOR XML PATH ('to_account'),Type),						
						
						--to_country
						'NP' As 'to_country'

				FOR XML PATH ('t_to_my_client'),Type
				) 

	When TrnType1=1 And AccCustType='002' Then				---For Entity 	
				--t_to_my_client
				(Select
					to_funds_code As 'to_funds_code',
				--to_account
					(Select 
						Replace(institution_name,'&','&amp;') As 'institution_name', swift As 'swift', branch As 'branch', account As 'account',
						currency_code As 'currency_code', account_name As 'account_name', account_type As 'account_type',
				
								--t_entity
								--(Select 
								(Select 
										Replace(first_name2,'&','&amp;') As 'name',--+' '+Replace(last_name1,'&','&amp;') As 'Name',											--Need to change fields
										incorporation_legal_from2  As 'incorporation_legal_form', incorporation_number2 As 'incorporation_number',
										business2 As 'business',

									--phones
										--phone
											(Select 
												'5' As 'tph_contact_type', 'M' As 'tph_communication_type', tph_number2 As 'tph_number'					--tph_contact_type, tph_communication_type are fixed 5,M and mobile1
											FOR XML PATH ('phone'), Type, root('phones')
											),

									--addresses
										--address
											(Select 
												'2' As 'address_type', Replace(address2,'&','&amp;') As 'address', Replace(town2,'&','&amp;') As 'town',
												Replace(city2,'&','&amp:') As 'city', zip2 As 'zip', country_code2 As 'country_code'
											FOR XML PATH ('address'),Type, root ('addresses')
											),

									incorporation_state2 As 'incorporation_state', 'NP' As 'incorporation_country_code', incorporation_date2 As 'incorporation_date',
									tax_number2 As 'tax_number'
							
									FOR XML PATH ('t_entity'),Type), 
									--related_persons
										--account_related_person
											--t_person
										(Select 
											(Select RelGender As 'gender', Replace(RelPrName1,'&','&amp;') As 'first_name', Replace(RelPrName2,'&','&amp;') As 'last_name', RelPrDOB as 'birthdate',
												Replace(RelBirthPlace,'&','&amp;') As 'birth_place', RelPrCtzNo As 'ssn', 'NP' As 'nationality1', 'NP' As 'residence',
											

											--phones
										--phone
											(Select 
												'5' As 'tph_contact_type', 'M' As 'tph_communication_type', RelMobile1 As 'tph_number'					--tph_contact_type, tph_communication_type are fixed 5,M and mobile1
											FOR XML PATH ('phone'), Type, root('phones')
											),

												--addresses
													--address
														(Select 
															'1' As 'address_type', Replace(RelAddress,'&','&amp;') As 'address', Replace(RelTown,'&','&amp;') As 'town',
															Replace(RelCity,'&','&amp:') As 'city', Replace(RelZip,'&','&amp:') As 'zip', country_code2 As 'country_code'
														FOR XML PATH ('address'),Type, root ('addresses')
														),
													Replace(RelPrOcc,'&','&amp;') As 'occupation'

											FOR XML PATH ('t_person'),Type
									),
									--role
									AccRoleType As 'role'

						
							FOR XML PATH ('account_related_person'),Type, root('related_persons')
							),
							opendate As 'opened', balance As 'balance', date_balance As 'date_balance', status_code As 'status_code'

						FOR XML PATH ('to_account'),Type),						
						
						--to_country
						'NP' As 'to_country'

				FOR XML PATH ('t_to_my_client'),Type
				)		
				End,

----------******* For Withdrawal Case --------------- To 
Case When FundSource IN (1,2) And TrnType1=0 And InitCustType<>'002' Then							
				--t_to_my_client
				(Select 
					from_funds_code As 'to_funds_code', Rtrim(Replace(from_funds_comment,'&','&amp;')) As 'to_funds_comment',

					--to_person
					(Select
						gender1 As 'gender', Replace(first_name1,'&','&amp;') As 'first_name', Replace(last_name1,'&','&amp;') As 'last_name',
						birthdate1 As 'birthdate', IsNull(birth_place1,'NP') As 'birth_place', number1 As 'ssn',
						nationality1 As 'nationality1', residence1 As 'residence',

						--phones
							--phone
							(Select 
								tph_contact_type1 As 'tph_contact_type', tph_communication_type1 As 'tph_communication_type', tph_number1 As 'tph_number'
							FOR XML PATH ('phone'),Type, root ('phones')
							),

						--addresses
							--address
								(Select
									'1' As 'address_type', Replace(address1,'&','&amp;') As 'address', Replace(town1,'&','&amp;') As 'town',
									Replace(city1,'&','&amp;') As 'city', Replace(zip1,'&','&amp;') As 'zip', country_code1 As 'country_code'
								FOR XML PATH ('address'),Type, root('addresses')),

								--occupation
								occupation1 As 'occupation',

						--identifications
							--identification
							(Select 
								type1 As 'type', number1 As 'number', IsNull(issued_by1,'Government of Nepal') As 'issued_by', issue_country1 As 'issue_country'
							FOR XML PATH ('identification'),Type, root('identifications'))


					FOR XML PATH ('to_person'),Type),

					--from_country
					'NP' As 'to_country'
				
				FOR XML PATH ('t_to_my_client'), Type
				)

		When FundSource IN (1,2) And TrnType1=0 And InitCustType='002' Then								--11 Dec, Changed for Own Client 
				--t_to_my_client
				(Select 
					from_funds_code As 'to_funds_code', Rtrim(Replace(from_funds_comment,'&','&amp;')) As 'to_funds_comment',

					--to_entity
					(Select
						Replace(first_name1,'&','&amp;')+' '+Replace(first_name2,'&','&amp;') As 'name', incorporation_legal_from1 As 'incorporation_legal_form',
						incorporation_number1 As 'incorporation_number', business2 As 'business', 
						
						--phones
							--phone
							(Select 
								tph_contact_type1 As 'tph_contact_type', tph_communication_type1 As 'tph_communication_type', tph_number1 As 'tph_number'
							FOR XML PATH ('phone'),Type, root ('phones')
							),

						--addresses
							--address
								(Select
									'2' As 'address_type', Replace(address1,'&','&amp;') As 'address', Replace(town1,'&','&amp;') As 'town',
									Replace(city1,'&','&amp;') As 'city', Replace(zip1,'&','&amp;') As 'zip', country_code1 As 'country_code'
								FOR XML PATH ('address'),Type, root('addresses')),
					incorporation_state1 As 'incorporation_state', 'NP' As 'incorporation_country_code', incorporation_date1 As 'incorporation_date', tax_number1 As 'tax_number'
					
					FOR XML PATH ('to_entity'),Type),

					--from_country
					'NP' As 'to_country'
				
				FOR XML PATH ('t_to_my_client'), Type
				)

		When FundSource IN (3) And TrnType1=0 And FundSourceSubType=1 Then											--11 Dec, Changed for Other person. 
					--t_to
				(Select 
					from_funds_code As 'to_funds_code', Rtrim(Replace(from_funds_comment,'&','&amp;')) As 'to_funds_comment',

					--to_person
					(Select
						Replace(first_name1,'&','&amp;') As 'first_name', Replace(last_name1,'&','&amp;') As 'last_name'
					FOR XML PATH ('to_person'),Type),

				
					--from_country
					'NP' As 'to_country'
				
				FOR XML PATH ('t_to'), Type
				)
		When FundSource IN (3) And TrnType1=0 And FundSourceSubType=2 Then											--11 Dec, Changed for Other person. 
					--t_to
				(Select 
					from_funds_code As 'to_funds_code', Rtrim(Replace(from_funds_comment,'&','&amp;')) As 'to_funds_comment',

					--to_entity
					(Select
						Replace(first_name1,'&','&amp;')+' '+Replace(last_name1,'&','&amp;') As 'name'
					FOR XML PATH ('to_entity'),Type),

				
					--from_country
					'NP' As 'to_country'
				
				FOR XML PATH ('t_to'), Type
				)
				End	



			--From #TempGoAmlTTR1 Where Account=@Acc AND BR=@BR AND TrnType1=@TRNTYPE
			--Where Recid=@I 		
			From #TempGoAmlTTR1 Where Account=@Acc AND BR=@BR AND TrnType1=@TRNTYPE
			FOR XML PATH('transaction'), Type
			) 
		
		From MBNPARMS 
		--Where Recid=@I 
		FOR XML PATH('report')--)  --report
		)

Insert Into #GoAML
select @Br,@TrnDate,Case When @TRNTYPE=0 Then 'D' When @TRNTYPE=1 THEN 'C' END AS TrnType,@Acc,@XML 

Delete From #GoAML Where Br='A'

FETCH   NEXT FROM ACC INTO @BR,@ACC,@TRNTYPE
END
CLOSE      ACC
DEALLOCATE ACC

Select * From #GoAML
		
		--Insert Into #GoAML
		--select Br,Transactionnumber,@XML From #TempGoAmlTTR1 Where REcid=@I
		--select Br,TrnType1,account,@XML From #TempGoAmlTTR1 Where REcid=@I


	--Set @I=@I+1
	--End
--Select * From #GoAML


End


--Exec sp_GoAml 'TTR', '000001', '2022-11-05' 
--Exec sp_GoAml 'TTR', 'A', '2022-11-05' 


