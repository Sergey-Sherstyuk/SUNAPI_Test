---------------------
----- Documents -----
---------------------

-- TODO: type sunapi.[Document.TableType] - field Type - need or not?

------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'sunapi' and SEQUENCE_NAME=N'SQ_Documents')
	create sequence sunapi.SQ_Documents as bigint start with 200 increment by 1;
go
--------------------------------
if not exists(select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'Documents' and TABLE_SCHEMA = N'sunapi')
begin
	create table sunapi.Documents (
		Id	bigint not null constraint PK_Documents primary key
			constraint DF_Documents_PK default(next value for sunapi.SQ_Documents),
		[Type] nvarchar(32) not null,
		ParentId bigint null constraint FK_Documents_ParentId_Documents references sunapi.Documents(Id),
		[Date] datetime,
		[Number] bigint,
		[Partner] bigint null constraint FK_Documents_Partner_Partners references sunapi.Partners(Id),
		Company bigint null constraint FK_Documents_Company_Companies foreign key references sunapi.Companies (Id),
		[Contract] bigint null constraint FK_Documents_Contract_Contracts foreign key references sunapi.Contracts(Id),
		CashAccount bigint null constraint FK_Documents_CashAccount_CashAccounts foreign key references sunapi.CashAccounts(Id),
		CashAccountFrom bigint null constraint FK_Documents_CashAccountFrom_CashAccounts foreign key references sunapi.CashAccounts(Id),
		CashAccountTo bigint null constraint FK_Documents_CashAccountTo_CashAccounts foreign key references sunapi.CashAccounts(Id),
		Expenditure bigint null constraint FK_Documents_Expenditure_Expenditures foreign key references sunapi.Expenditures(Id),
		Operation bigint null constraint FK_Documents_Operation_Operations foreign key references sunapi.Operations(Id),
		PriceType bigint null constraint FK_Documents_PriceType_PriceTypes foreign key references sunapi.PriceTypes(Id),
		[Sum] money,
		Comment nvarchar(255),
		StoreFrom bigint null constraint FK_Documents_StoreFrom_Stores foreign key references sunapi.Stores(Id),
		StoreTo bigint null constraint FK_Documents_StoreTo_Stores foreign key references sunapi.Stores(Id),
		Done bit not null constraint DF_Documents_Done default(0),
		Deleted bit not null constraint DF_Documents_Deleted default(0),
		DateCreated datetime not null constraint DF_Documents_DateCreated default(getdate()),
		UserCreated bigint not null constraint FK_Documents_UserCreated_Users foreign key references a2security.Users(Id),
		DateModified datetime not null constraint DF_Documents_DateModified default(getdate()),
		UserModified bigint not null constraint FK_Documents_UserModified_Users foreign key references a2security.Users(Id)
	);
end
go

-- Documents.ParentId
if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Documents' and COLUMN_NAME=N'ParentId'))
begin
	alter table sunapi.Documents add ParentId bigint null constraint FK_Documents_ParentId_Documents references sunapi.Documents(Id);
end
go

-- Convert Number to bigint
if (exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Documents' and COLUMN_NAME=N'Number')
	and not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Documents' and COLUMN_NAME=N'Number' and DATA_TYPE=N'bigint'))
begin
	-- TODO: convert values with letters
	alter table sunapi.Documents alter column [Number] bigint;
end
go

-- Documents.Expenditure
if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Documents' and COLUMN_NAME=N'Expenditure'))
begin
	alter table sunapi.Documents add Expenditure bigint null constraint FK_Documents_Expenditure_Expenditures foreign key references sunapi.Expenditures(Id);
end
go

-- Documents.Operation
if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Documents' and COLUMN_NAME=N'Operation'))
begin
	alter table sunapi.Documents add Operation bigint null constraint FK_Documents_Operation_Operations foreign key references sunapi.Operations(Id);
end
go

-- Documents.PriceType
if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Documents' and COLUMN_NAME=N'PriceType'))
begin
	alter table sunapi.Documents add PriceType bigint null constraint FK_Documents_PriceType_PriceTypes foreign key references sunapi.PriceTypes(Id);
end
go

-- Documents.CashAccount
if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Documents' and COLUMN_NAME=N'CashAccount'))
begin
	alter table sunapi.Documents add CashAccount bigint null constraint FK_Documents_CashAccount_CashAccounts foreign key references sunapi.CashAccounts(Id);
end
go

-- Documents.CashAccountFrom
if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Documents' and COLUMN_NAME=N'CashAccountFrom'))
begin
	alter table sunapi.Documents add CashAccountFrom bigint null constraint FK_Documents_CashAccountFrom_CashAccounts foreign key references sunapi.CashAccounts(Id);

	--if (exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Documents' and COLUMN_NAME=N'CashAccount'))
	--begin
	--	update sunapi.Documents 
	--	set CashAccountFrom = CashAccount
	--	where [Type]=N'OUTGOING_PAYMENT';
	--end;

end
go

-- Documents.CashAccountTo
if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Documents' and COLUMN_NAME=N'CashAccountTo'))
begin
	alter table sunapi.Documents add CashAccountTo bigint null constraint FK_Documents_CashAccountTo_CashAccounts foreign key references sunapi.CashAccounts(Id);

	--if (exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Documents' and COLUMN_NAME=N'CashAccount'))
	--begin
	--	update sunapi.Documents 
	--	set CashAccountTo = CashAccount
	--	where [Type]=N'INCOME_PAYMENT';
	--end;

end
go

-- Delete Documents.CashAccount
--if (exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Documents' and COLUMN_NAME=N'CashAccount'))
--begin
--	alter table sunapi.Documents drop constraint FK_Documents_CashAccount_CashAccounts;
--	alter table sunapi.Documents drop column CashAccount;
--end
--go

-- Documents.Deleted
if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Documents' and COLUMN_NAME=N'Deleted'))
begin
	alter table sunapi.Documents add Deleted bit not null constraint DF_Documents_Deleted default(0);
end
go


------------------------------------------------
create or alter procedure sunapi.[Document.Index]
@UserId bigint,
@Type nchar(32),
@Offset int = 0,
@PageSize int = 20,
@Order nvarchar(255) = N'Id',
@Dir nvarchar(20) = N'desc',
@From datetime = null,
@To datetime = null,
@Partner bigint = null
as
begin
	set nocount on;

	declare @currentDate DATE = GETDATE();

	if (@From IS NULL)
		set @From = DATEADD(DAY, 1, EOMONTH(@currentDate, -1));
	
	if (@To IS NULL)
		set @To = EOMONTH(@currentDate);

	declare @Asc nvarchar(10), @Desc nvarchar(10);
	set @Asc = N'asc'; set @Desc = N'desc';
	set @Dir = isnull(@Dir, @Asc);


/*	
	select [Documents!TDocument!Array] = null, [Id!!Id] = d.Id, [Type], [Date], [Sum], Comment,
		[Partner.Id!TPartner] = pr.Id, [Partner.Name!TPartner] = pr.[Name],
		[StoreFrom.Id!TStore] = sf.Id, [StoreFrom.Name!TStore] = sf.[Name],
		[StoreTo.Id!TStore] = st.Id, [StoreTo.Name!TStore] = st.[Name],
		Done,
		d.DateCreated, [UserCreated.Id!TUser!Id] = uc.Id, [UserCreated.Name!TUser] = uc.UserName,
		d.DateModified, [UserModified.Id!TUser!Id] = um.Id, [UserModified.Name!TUser] = um.UserName
	from sunapi.Documents d
		left join sunapi.Partners pr on d.Partner = pr.Id
		left join sunapi.Stores sf on d.StoreFrom = sf.Id
		left join sunapi.Stores st on d.StoreTo = st.Id
		left join a2security.Users uc on d.UserCreated = uc.Id
		left join a2security.Users um on d.UserModified = um.Id
	where Type = @Type
	order by d.Id desc;
*/

	with T([Id!!Id], [Type], [Date], Number, [Sum], Comment, 
		[Partner.Id!TPartner!Id], [Partner.Name!TPartner!Name],
		[Company.Id!TCompany!Id], [Company.Name!TCompany!Name],
		[Contract.Id!TContract!Id], [Contract.Name!TContract!Name],
		[CashAccount.Id!TCashAccount!Id], [CashAccount.Name!TCashAccount!Name],
		[CashAccountFrom.Id!TCashAccount!Id], [CashAccountFrom.Name!TCashAccount!Name],
		[CashAccountTo.Id!TCashAccount!Id], [CashAccountTo.Name!TCashAccount!Name],
		[Expenditure.Id!TExpenditure!Id], [Expenditure.Name!TExpenditure!Name],
		[Operation.Id!TOperation!Id], [Operation.Name!TOperation!Name],
		[PriceType.Id!TPriceType!Id], [PriceType.Name!TPriceType!Name],
		[StoreFrom.Id!TStore], [StoreFrom.Name!TStore],
		[StoreTo.Id!TStore], [StoreTo.Name!TStore],
		Done, Deleted,
		DateCreated, [UserCreated.Id!TUser!Id], [UserCreated.Name!TUser],
		DateModified, [UserModified.Id!TUser!Id], [UserModified.Name!TUser],
		[!!RowNumber])
	as(
		select d.Id, d.[Type], d.[Date], d.Number, d.[Sum], d.[Comment], 
			pr.Id, pr.[Name],
			comp.Id, comp.[Name],
			c.Id, c.[Name],
			ca.Id, ca.[Name],
			caf.Id, caf.[Name],
			cat.Id, cat.[Name],
			e.Id, e.[Name],
			op.Id, op.[Name],
			pt.Id, pt.[Name],
			sf.Id, sf.[Name],
			st.Id, st.[Name],
			Done, Deleted,
			d.DateCreated, uc.Id, uc.UserName,
			d.DateModified, um.Id, um.UserName,
			[!!RowNumber] = row_number() over (
			 order by
				case when @Order=N'Id' and @Dir = @Asc then d.Id end asc,
				case when @Order=N'Id' and @Dir = @Desc  then d.Id end desc,
				case when @Order=N'Date' and @Dir = @Asc then d.[Date] end asc,
				case when @Order=N'Date' and @Dir = @Desc  then d.[Date] end desc,
				case when @Order=N'Number' and @Dir = @Asc then d.[Number] end asc,
				case when @Order=N'Number' and @Dir = @Desc  then d.[Number] end desc,
				case when @Order=N'Sum' and @Dir = @Asc then d.[Sum] end asc,
				case when @Order=N'Sum' and @Dir = @Desc then d.[Sum] end desc,
				case when @Order=N'Comment' and @Dir = @Asc then d.Comment end asc,
				case when @Order=N'Comment' and @Dir = @Desc then d.Comment end desc,
				case when @Order=N'StoreFrom.Name' and @Dir = @Asc then sf.[Name] end asc,
				case when @Order=N'StoreFrom.Name' and @Dir = @Desc then sf.[Name] end desc,
				case when @Order=N'StoreTo.Name' and @Dir = @Asc then st.[Name] end asc,
				case when @Order=N'StoreTo.Name' and @Dir = @Desc then st.[Name] end desc,
				case when @Order=N'Partner.Name' and @Dir = @Asc then pr.[Name] end asc,
				case when @Order=N'Partner.Name' and @Dir = @Desc then pr.[Name] end desc,
				case when @Order=N'Company.Name' and @Dir = @Asc then comp.[Name] end asc,
				case when @Order=N'Company.Name' and @Dir = @Desc then comp.[Name] end desc

			)
		from sunapi.Documents d
			left join sunapi.Partners pr on d.Partner = pr.Id
			left join sunapi.Companies comp on d.Company = comp.Id
			left join sunapi.Contracts c on d.[Contract] = c.Id
			left join sunapi.CashAccounts ca on d.CashAccount = ca.Id
			left join sunapi.CashAccounts caf on d.CashAccountFrom = caf.Id
			left join sunapi.CashAccounts cat on d.CashAccountTo = cat.Id
			left join sunapi.Expenditures e on d.Expenditure = e.Id
			left join sunapi.Operations op on d.Operation = op.Id
			left join sunapi.PriceTypes pt on d.PriceType = pt.Id
			left join sunapi.Stores sf on d.StoreFrom = sf.Id
			left join sunapi.Stores st on d.StoreTo = st.Id
			left join a2security.Users uc on d.UserCreated = uc.Id
			left join a2security.Users um on d.UserModified = um.Id
		where Type = @Type and (@Partner is null or d.Partner = @Partner)
	)
	select [Documents!TDocument!Array]=null, *,
		[!!RowCount] = (select count(1) from T)
	into #tmp
	from T
	where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize

	select * from #tmp
	order by [!!RowNumber];

	select [!$System!] = null,
		[!Documents!PageSize] = @PageSize, 
		[!Documents!SortOrder] = @Order, 
		[!Documents!SortDir] = @Dir,
		[!Documents!Offset] = @Offset,
		[!Documents.Partner.Id!Filter] = @Partner,
		[!Documents.Partner.Name!Filter] = (select [Name] from sunapi.Partners where Id=@Partner),
		[!Documents.Period.From!Filter] = @From,
		[!Documents.Period.To!Filter] = @To

end
go
--------------------------------
if not exists(select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'Details' and TABLE_SCHEMA = N'sunapi')
begin
	create table sunapi.Details (
		Id bigint identity(200,1) not null constraint PK_Details primary key,
		[Document] bigint null constraint FK_Details_Document_Documents references sunapi.Documents(Id),
		Product bigint null constraint FK_Details_Product_Products references sunapi.Products(Id),
		Price float,
		Qty float,
		[Sum] money
	);
end
go
------------------------------------------------
/*
create or alter view sunapi.DetailsView
as
	select det.Id, det.Document as DocId, det.Product as ProductId, det.Price, det.Qty, det.Sum, 
		doc.Date as DocDate, doc.Type as DocType, doc.Done as Done, 
		prod.IsService as ProductIsService, prod.Name as ProductName,  prod.Article as ProductArticle,
		prod.Unit as ProductUnitId, unit.Name as UnitName,
		doc.Partner as PartnerId, p.Name as PartnerName,
		prod.Section as SectionId, sect.Name as SectionName, 
		doc.Company as CompanyId, c.Name as CompanyName, 
		doc.StoreFrom as StoreFromId, sf.Name as StoreFromName, 
		doc.StoreTo as StoreToId, st.Name as StoreToName
	from sunapi.Details as det
	left join sunapi.Documents as doc on doc.Id = det.Document
	left join sunapi.Products as prod on prod.Id = det.Product
	left join sunapi.Units as unit on unit.Id = prod.Unit
	left join sunapi.Stores as sf on sf.Id = doc.StoreFrom
	left join sunapi.Stores as st on st.Id = doc.StoreTo
	left join sunapi.Partners as p on p.Id = doc.Partner
	left join sunapi.Companies as c on c.Id = doc.Company
	left join sunapi.Sections as sect on sect.Id = prod.Section
go
*/
------------------------------------------------
create or alter function sunapi.GetNextDay(@Date datetime)
returns date
as
begin
	return (DATEADD(DAY, 1, cast(@Date as Date)));
end
go

------------------------------------------------
create or alter function sunapi.CheckDocNumber (@Type nvarchar(32), @Company bigint, @Number bigint, @Id bigint)
returns bigint
as
begin
	if (@Number <= 0)
		begin
			select top 1 @Number=Number+1 from sunapi.Documents where [Type]=@Type and Company=@Company order by Number desc;
			set @Number = IIF(@Number > 0, @Number, 1);
		end;
	else 
		if (exists (select 1 from sunapi.Documents where [Type] = @Type and Company = @Company and Number = @Number and Id <> @Id))
			set @Number = -1;
	return(@Number);
end
go

-- TODO: Update existing documents numbers
-- TODO: Add trigger to check documents numbers

------------------------------------------------
create or alter function sunapi.FormatNumber8 (@DocId bigint = 0, @DocType nvarchar(32) null = N'')
returns nvarchar(16)
as
begin

	-- Prefix
	-- TODO: add function parameter @DocType nvarchar(16) null = N''
	declare @Prefix nvarchar(max);
	set @DocType = rtrim(ltrim(@DocType)) + N'_';
	while charindex(N'_', ltrim(@DocType)) > 0
	begin;
		set @Prefix = isnull(@Prefix, N'') + left(ltrim(@DocType), 1);
		set @DocType = stuff(ltrim(@DocType), 1, charindex('_', ltrim(@DocType)), N'');
	end;
	set @Prefix = isnull(upper(@Prefix + N'_'), N'');

	-- Id
	declare @FormattedId nvarchar(8);
	set @FormattedId = RIGHT(REPLICATE('0', 8) + cast(@DocId as nvarchar(8)), 8);

	return(@Prefix + @FormattedId);
end;
go
------------------------------------------------
create or alter function sunapi.GetDocumentRootId (@DocId bigint)
returns bigint
as
begin
	declare @RootDocId bigint;
	with Documents as 
	(
		select Id, ParentId, [Type]
			from sunapi.Documents where Id = @DocId
		union all 
		select c.Id, c.ParentId, c.[Type]
			from Documents as p
			join sunapi.Documents as c
			on p.ParentId = c.Id
	)
	select @RootDocId = Id
	from Documents
	where ParentId is null;
	return(@RootDocId);
end
go
------------------------------------------------
create or alter function sunapi.GetDocumentTree (@DocId bigint)
returns @DocumentTree 
	table (Id bigint, ParentId bigint, [Type] nvarchar(32), Done bit, Deleted bit, [Date] date, [Sum] money, IsCurrent bit, [Name] nvarchar(32), Level int, Sort nvarchar(255), TypeEditUrl nvarchar(64))
as
begin

	declare @RootDocId bigint;
	set @RootDocId = sunapi.GetDocumentRootId(@DocId);

	WITH Documents( Id, ParentId, [Type], Done,  Deleted, [Date], [Sum], IsCurrent, [Name], Level, Sort)
	AS (SELECT d.Id, d.ParentId, d.[Type], d.Done, d.Deleted, d.[Date], d.[Sum], IIF(d.Id = @DocId, 1, 0), CONVERT(nvarchar(255), sunapi.FormatNumber8(d.Number, d.[Type])), 1,
			CONVERT(nvarchar(255), RTRIM(d.[Type]) + sunapi.FormatNumber8(d.Number, d.[Type]))
		FROM sunapi.Documents AS d
		WHERE d.Id = @RootDocId
		UNION ALL
		SELECT d.Id, d.ParentId, d.[Type], d.Done, d.Deleted, d.[Date], d.[Sum], IIF(d.Id = @DocId, 1, 0), CONVERT(nvarchar(255), REPLICATE ('……' , Level) + sunapi.FormatNumber8(d.Number, d.[Type])), Level + 1,
			CONVERT (nvarchar(255), RTRIM(Sort) + '>' + d.[Type] + sunapi.FormatNumber8(d.Number, d.[Type]))
		FROM sunapi.Documents AS d
		JOIN Documents AS docs ON d.ParentId = docs.Id
		)
	INSERT INTO @DocumentTree
	SELECT Id, ParentId, [Type], Done, Deleted, [Date], [Sum], IsCurrent, [Name], Level, Sort, TypeEditUrl = N'/document/' + trim(lower([Type])) + N'/edit/'
	FROM Documents
	ORDER BY Sort;

	RETURN;

end
go
--------------------------------
create or alter procedure sunapi.[Document.Load]
@UserId bigint,
@Id bigint = null,
@Type nchar(32)
as
begin
	set nocount on;

	select [Document!TDocument!Object] = null, [Id!!Id] = d.Id, [Type], [Date], Number, [Sum], Comment, 
		d.DateCreated, [UserCreated.Id!TUser!] = uc.Id, [UserCreated.Name!TUser!] = uc.UserName,
		d.DateModified, [UserModified.Id!TUser!] = um.Id, [UserModified.Name!TUser!] = um.UserName,
		[Partner!TPartner!RefId] = [Partner],
		[StoreFrom!TStore!RefId] = StoreFrom,
		[StoreTo!TStore!RefId] = StoreTo,
		[Company!TCompany!RefId] = [Company],
		[Contract!TContract!RefId] = [Contract],
		[CashAccount!TCashAccount!RefId] = CashAccount,
		[CashAccountFrom!TCashAccount!RefId] = CashAccountFrom,
		[CashAccountTo!TCashAccount!RefId] = CashAccountTo,
		[Expenditure!TExpenditure!RefId] = Expenditure,
		[Operation!TOperation!RefId] = Operation,
		[PriceType!TPriceType!RefId] = PriceType,
		Done, Deleted,
		[Rows!TRow!Array] = null
	from sunapi.Documents d
		left join sunapi.Partners pr on d.Partner = pr.Id
		left join sunapi.Stores sf on d.StoreFrom = sf.Id
		left join sunapi.Stores st on d.StoreTo = st.Id
		left join a2security.Users uc on d.UserModified = uc.Id
		left join a2security.Users um on d.UserModified = um.Id
	where d.Id = @Id;

	select [!TPartner!Map] = null, [Id!!Id] = Id, [Name], Phone, Memo, PrintName, LegalAddress
	from sunapi.Partners where Id in (select Partner from sunapi.Documents where Id=@Id);

	select [!TStore!Map] = null, [Id!!Id] = Id, [Name]
	from sunapi.Stores where Id in (select StoreFrom from sunapi.Documents where Id=@Id);

	select [!TStore!Map] = null, [Id!!Id] = Id, [Name]
	from sunapi.Stores where Id in (select StoreTo from sunapi.Documents where Id=@Id);

	select [!TCompany!Map] = null, [Id!!Id] = Id, [Name], PrintName, LegalAddress, Phone, EDRPOU, VatText
	from sunapi.Companies where Id in (select Company from sunapi.Documents where Id=@Id);

	select [!TContract!Map] = null, [Id!!Id] = Id, [Name], Number, [Date]
	from sunapi.Contracts where Id in (select [Contract] from sunapi.Documents where Id=@Id);

	select [!TCashAccount!Map] = null, [Id!!Id] = Id, [Name], BankAccount, BankName, BankMFO, IsCash
	from sunapi.CashAccounts;
	--from sunapi.CashAccounts where Id in (select CashAccount from sunapi.Documents where Id=@Id);

	select [!TExpenditure!Map] = null, [Id!!Id] = Id, [Name]
	from sunapi.Expenditures where Id in (select Expenditure from sunapi.Documents where Id=@Id);

	select [!TOperation!Map] = null, [Id!!Id] = Id, [Name]
	from sunapi.Operations where Id in (select Operation from sunapi.Documents where Id=@Id);

	select [!TPriceType!Map] = null, [Id!!Id] = Id, [Name]
	from sunapi.PriceTypes where Id in (select PriceType from sunapi.Documents where Id=@Id);

	select [!TRow!Array] = null, [Id!!Id] = Id, [!TDocument.Rows!ParentId] = Document,
		[Product!TProduct!RefId] = Product, Price, Qty, [Sum]
	from sunapi.Details where Document = @Id;

	-- TODO: Note! Product.Price is only for adding new row
	select [!TProduct!Map] = null, [Id!!Id] = p.Id, p.[Name], p.Article, p.Memo, [Unit.Id!TUnit!Id] = u.Id, [Unit.Name!TUnit!] = u.Name, p.IsService, Price = null
	from sunapi.Products p left join sunapi.Units as u on p.Unit = u.Id
	where p.Id in (select Product from sunapi.Details where Document=@Id);

	select [DocumentsTree!TDocTreeItem!Array] = null, [Id!!Id] = Id, ParentDocId = ParentId, [Type], Done, Deleted, [Date], [Sum], IsCurrent, [Name!!Name] = [Name], [Level], TypeEditUrl
	from sunapi.GetDocumentTree (@Id) as t
	order by Sort asc;

	select [!$System!] = null, [!!ReadOnly] = case when (Done = 1) then 1 when (Deleted = 1) then 1 else 0 end
	from sunapi.Documents where Id=@Id;

end
go
--------------------------------
create or alter procedure sunapi.[Document.Report]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	exec sunapi.[Document.Load] @UserId, @Id, null;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'sunapi' and ROUTINE_NAME=N'Document.Update')
	drop procedure sunapi.[Document.Update]
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'sunapi' and ROUTINE_NAME=N'Document.Metadata')
	drop procedure sunapi.[Document.Metadata]
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'sunapi' and DOMAIN_NAME=N'Document.TableType' and DATA_TYPE=N'table type')
	drop type sunapi.[Document.TableType];
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'sunapi' and DOMAIN_NAME=N'Detail.TableType' and DATA_TYPE=N'table type')
	drop type sunapi.[Detail.TableType];
go
------------------------------------------------
create type sunapi.[Document.TableType]
as table(
	Id bigint null,
	-- [Type] nvarchar(32),
	[Date] datetime,
	[Number] bigint,
	[Partner] bigint,
	Company bigint,
	[Contract] bigint,
	CashAccount bigint,
	CashAccountFrom bigint,
	CashAccountTo bigint,
	Expenditure bigint,
	Operation bigint,
	PriceType bigint,
	[Sum] money,
	Comment nvarchar(255),
	StoreFrom bigint null, 
	StoreTo bigint null
)
go
------------------------------------------------
create type sunapi.[Detail.TableType]
as table(
	Id bigint null,
	[Document] bigint,
	Product bigint,
	Price float,
	Qty float,
	[Sum] money
)
go
------------------------------------------------
create or alter procedure sunapi.[Document.Metadata]
as
begin
	set nocount on;
	declare @Doc sunapi.[Document.TableType];
	declare @Rows sunapi.[Detail.TableType];
	select [Document!Document!Metadata] = null, * from @Doc;
	select [Rows!Document.Rows!Metadata] = null, * from @Rows;
end
go
------------------------------------------------
create or alter procedure sunapi.[Document.Update]
@UserId bigint,
@Type nvarchar(32),
@Document sunapi.[Document.TableType] readonly,
@Rows sunapi.[Detail.TableType] readonly
as
begin
	set nocount on;

	-- declare @xml nvarchar(max);
	-- select @xml = (select * from @Document for xml auto);
	-- throw 60000, @xml, 0;

	declare @output table(op nvarchar(150), id bigint);
	declare @RetId bigint;

	declare @Number bigint;
	set @Number = sunapi.CheckDocNumber(@Type, (select Company from @Document), (select Number from @Document), (select Id from @Document));
	if (@Number = -1)
		throw 60000, N'UI:Не коректний номер документа. \nТакий номер вже є у іншого документа цього типу і цієї організації.', 0;

	merge sunapi.Documents as target
	using @Document as source
	on (target.Id = source.Id)
	when matched then
		update set 
			target.[Date] = source.[Date],
			target.[Number] = @Number,
			target.Partner = source.Partner,
			target.StoreFrom = source.StoreFrom,
			target.StoreTo = source.StoreTo,
			target.Company = source.Company,
			target.[Contract] = source.[Contract],
			target.CashAccount = source.CashAccount,
			target.CashAccountFrom = source.CashAccountFrom,
			target.CashAccountTo = source.CashAccountTo,
			target.Expenditure = source.Expenditure,
			target.Operation = source.Operation,
			target.PriceType = source.PriceType,
			target.[Sum] = source.[Sum],
			target.Comment = source.Comment,
			target.DateModified = getdate(),
			target.UserModified = @UserId
	when not matched by target then 
		insert ([Type], [Date], Number,  [Partner], Company, StoreFrom, StoreTo, 
			[Contract], CashAccount, CashAccountFrom, CashAccountTo,
			Expenditure, Operation, PriceType, [Sum], Comment, UserCreated, DateCreated, UserModified, DateModified)
		values ( @Type, [Date], @Number, [Partner], Company, StoreFrom, StoreTo, 
			[Contract], CashAccount, CashAccountFrom, CashAccountTo,
			Expenditure, Operation, PriceType, [Sum], Comment, @UserId, getdate(), @UserId, getdate())
	output 
		$action op,
		inserted.Id id
	into @output(op, id);

	select top(1) @RetId = id from @output;

	merge sunapi.Details as target
	using @Rows as source
	on (target.Id = source.Id and target.Document = @RetId)
	when matched then 
		update set
			target.Product = source.Product,
			target.Qty = source.Qty,
			target.Price = source.Price,
			target.[Sum] = source.[Sum]
	when not matched by target then
		insert (Document, Product, Qty, Price, [Sum])
		values (@RetId, Product, Qty, Price, [Sum])
	when not matched by source and target.Document = @RetId then delete;

	exec sunapi.[Document.Load] @UserId, @RetId, @Type
end
go
------------------------------------------------
create or alter procedure sunapi.[Document.Delete]
	@UserId bigint,
	@Id bigint = null,
	@Type nvarchar(32) = null
as
begin
	set nocount on;
	set transaction isolation level read committed;
	set xact_abort on;
	declare @Done bit;
	select @Done = Done from sunapi.Documents where Id=@Id;
	if @Done = 1
		throw 60000, N'UI:Нельзя удалить проведенный документ.', 0;
	else
	begin
		-- delete from sunapi.Details where Document=@Id;
		-- delete from sunapi.Documents where Id=@Id;
		update sunapi.Documents 
		set Deleted = 1
		where Id=@Id;
	end
end
go

------------------------------------------------










------------------
----- Stocks -----
------------------

------------------------------------------------
if not exists(select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'Stocks' and TABLE_SCHEMA = N'sunapi')
begin
	create table sunapi.Stocks (
		Id bigint identity(150,1) not null constraint PK_Stocks primary key,
		[Date] datetime not null,
		DocId bigint not null constraint FK_Stocks_DocId_Documents foreign key references sunapi.Documents(Id),
		CompanyId bigint not null constraint FK_Stocks_CompanyId_Companies references sunapi.Companies(Id),
		StoreId bigint not null constraint FK_Stocks_StoreId_Stores foreign key references sunapi.Stores(Id),
		ProductId bigint not null constraint FK_Stocks_ProductId_Products foreign key references sunapi.Products(Id),
		Qty decimal(10,3) not null,
		Price decimal(10,2) null,
		Profit decimal(10,2) null
	);
end
go


-- Stocks.CompanyId
if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Stocks' and COLUMN_NAME=N'CompanyId'))
begin
	alter table sunapi.Stocks add CompanyId bigint null constraint FK_Stocks_CompanyId_Companies references sunapi.Companies(Id);

	update tgt 
	set tgt.CompanyId = src.Company
	from sunapi.Stocks as tgt
	inner join sunapi.Documents as src 
	on tgt.DocId = src.Id;

	alter table sunapi.Stocks alter column CompanyId bigint not null;
end
go

-- Convert Price to decimal
if (exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Stocks' and COLUMN_NAME=N'Price')
	and not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Stocks' and COLUMN_NAME=N'Price' and DATA_TYPE=N'decimal'))
begin
	alter table sunapi.Stocks alter column Price decimal(10,2);
end
go

-- Convert Profit to decimal
if (exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Stocks' and COLUMN_NAME=N'Profit')
	and not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Stocks' and COLUMN_NAME=N'Profit' and DATA_TYPE=N'decimal'))
begin
	alter table sunapi.Stocks alter column Profit decimal(10,2);
end
go

-- Convert Qty to decimal
if (exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Stocks' and COLUMN_NAME=N'Qty')
	and not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Stocks' and COLUMN_NAME=N'Qty' and DATA_TYPE=N'decimal'))
begin
	alter table sunapi.Stocks alter column Qty decimal(10,3);
end
go

------------------------------------------------
-- TODO:  Refactoring view after adding Company column

create or alter view sunapi.StocksView
as
	select s.Id, s.[Date], s.DocId, s.StoreId, s.ProductId, s.Qty, s.Price, s.Profit, d.[Type], 
		sect.Id as SectionId, sect.[Name] as SectionName,
		pt.[Name] as ProductName, pr.Id as PartnerId, pr.[Name] as PartnerName, 
		stor.[Name] as StoreName, c.Id as CompanyId, c.[Name] as CompanyName, 
		ct.Id as ContractId, ct.[Name] as ContractName
	from sunapi.Stocks as s
	left join sunapi.Documents as d on d.Id = s.DocId
	left join sunapi.Stores as stor on stor.Id = s.StoreId
	left join sunapi.Products as pt on pt.Id = s.ProductId
	left join sunapi.Partners as pr on pr.Id = d.[Partner]
	left join sunapi.Companies as c on c.Id = d.Company
	left join sunapi.Contracts as ct on ct.Id = d.[Contract]
	left join sunapi.Sections as sect on sect.Id = pt.Section
go
------------------------------------------------


---------------------
----- CashFlows -----
---------------------

------------------------------------------------
if not exists(select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'CashFlows' and TABLE_SCHEMA = N'sunapi')
begin
	create table sunapi.CashFlows (
		Id bigint identity(150,1) not null constraint PK_CashFlows primary key,
		[Date] datetime not null,
		DocId bigint not null constraint FK_CashFlows_DocId_Documents foreign key references sunapi.Documents(Id),
		CashAccountId bigint not null constraint FK_CashFlows_CashAccountId_CashAccounts references sunapi.CashAccounts(Id),
		Sum decimal(10,3) not null,
		SumIn decimal(10,3) not null,
		SumOut decimal(10,3) not null
	);
end
go
------------------------------------------------
create or alter view sunapi.CashFlowsView
as
	select cf.Id, cf.Date, cf.DocId, cf.CashAccountId, cf.Sum, cf.SumIn, cf.SumOut, 
		d.Type as DocType, ca.Name as CashAccountName, op.Id as OperationId, op.Name as OperationName, 
		e.Id as ExpenditureId, e.Name as ExpenditureName, c.Id as CompanyId, c.Name as CompanyName,
		p.Id as PartnerId, p.Name as PartnerName
	from sunapi.CashFlows as cf
	left join sunapi.Documents as d on d.Id = cf.DocId
	left join sunapi.CashAccounts as ca on ca.Id = cf.CashAccountId
	left join sunapi.Operations as op on op.Id = d.Operation
	left join sunapi.Expenditures as e on e.Id = d.Expenditure
	left join sunapi.Companies as c on c.Id = d.Company
	left join sunapi.Partners as p on p.Id = d.[Partner]
go
------------------------------------------------


--------------------
----- Balances -----
--------------------

------------------------------------------------
if not exists(select 1 from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'Balances' and TABLE_SCHEMA = N'sunapi')
begin
	create table sunapi.Balances (
		Id bigint identity(150,1) not null constraint PK_Balances primary key,
		DocId bigint not null constraint FK_Balances_DocId_Documents foreign key references sunapi.Documents(Id),
		[Sum] decimal(10,3) not null,
		SumIn decimal(10,3) not null,
		SumOut decimal(10,3) not null
	);
end
go
------------------------------------------------
create or alter view sunapi.BalancesView
as
	select b.Id, b.DocId, b.Sum, b.SumIn, b.SumOut, d.Type, d.Date, d.Number, 
		d.Partner as PartnerId, p.Name as PartnerName, d.Company as CompanyId, 
		d.Operation as OperationId, op.Name as OperationName, 
		d.Expenditure as ExpenditureId, ex.Name as ExpenditureName,
		comp.Name as CompanyName, d.Contract as ContractId, ct.Name as ContractName
	from sunapi.Balances as b
	left join sunapi.Documents as d on d.Id = b.DocId
	left join sunapi.Partners as p on p.Id = d.Partner
	left join sunapi.Operations as op on op.Id = d.Operation
	left join sunapi.Expenditures as ex on ex.Id = d.Expenditure
	left join sunapi.Companies as comp on comp.Id = d.Company
	left join sunapi.Contracts as ct on ct.Id = d.Contract
go
------------------------------------------------

--------------------------------------
----- Document apply, unapply... -----
--------------------------------------

------------------------------------------------
create or alter procedure sunapi.[Document.Apply]
	@UserId bigint,
	@Id bigint = null
as
begin
	set nocount on;

	declare 
		@Done bit,
		@Deleted bit,
		@Type nvarchar(32),
		@CompanyId bigint;

	select @Done = Done, @Deleted = Deleted, @Type = [Type] from sunapi.Documents where Id=@Id;
	select @CompanyId = Company from sunapi.Documents where Id = @Id;

	if @Deleted = 1
		throw 60000, N'UI:Нельзя провести удаленный документ.', 0;
	else


	if @Done = 0
	begin try  
		begin transaction;
			---- set Done flag
			update sunapi.Documents set Done = 1, DateModified = getdate(), UserModified = @UserId where Id=@Id;

			---- add information to Stocks table

			if @Type = N'INCOME_INVOICE'
			begin
				insert into sunapi.Stocks ([Date], DocId, CompanyId, StoreId, ProductId, Qty, Price)
					select doc.[Date], doc.Id, doc.Company, doc.StoreTo, det.Product, det.Qty, det.Price
					from sunapi.Details as det 
						left join sunapi.Documents as doc on doc.Id = det.Document
						left join sunapi.Products as prod on prod.Id = det.Product
					where Document = @Id and prod.IsService = 0;

				insert into sunapi.Balances(DocId, [Sum], SumIn, SumOut)
					select doc.Id, doc.Sum, doc.Sum, 0
					from sunapi.Documents as doc
					where doc.Id = @Id;
			end
			else if @Type = N'OUTGOING_INVOICE'
			begin
				insert into sunapi.Stocks ([Date], DocId, CompanyId, StoreId, ProductId, Qty, Price)
					select doc.[Date], doc.Id, doc.Company, doc.StoreFrom, det.Product, det.Qty * -1 as qty, det.Price 
					from sunapi.Details as det 
						left join sunapi.Documents as doc on doc.Id = det.Document
						left join sunapi.Products as prod on prod.Id = det.Product
					where Document = @Id and prod.IsService = 0;

				insert into sunapi.Balances(DocId, [Sum], SumIn, SumOut)
					select doc.Id, - doc.Sum, 0, doc.Sum
					from sunapi.Documents as doc
					where doc.Id = @Id;
			end
			else if @Type = N'STOCKS_MOVE'
			begin
				insert into sunapi.Stocks ([Date], DocId, CompanyId, StoreId, ProductId, Qty, Price)
					select doc.[Date], doc.Id as DocId, doc.Company, doc.StoreFrom, det.Product, det.Qty * -1 as qty, null 
					from sunapi.Details as det 
						left join sunapi.Documents as doc on doc.Id = det.Document
						left join sunapi.Products as prod on prod.Id = det.Product
					where Document = @Id and prod.IsService = 0;
				insert into sunapi.Stocks ([Date], DocId, CompanyId, StoreId, ProductId, Qty, Price)
					select doc.[Date], doc.Id as DocId, Company, doc.StoreTo, det.Product, det.Qty, null
					from sunapi.Details as det 
						left join sunapi.Documents as doc on doc.Id = det.Document
						left join sunapi.Products as prod on prod.Id = det.Product
					where Document = @Id and prod.IsService = 0;
			end
			if @Type = N'INCOME_PAYMENT'
			begin
				update sunapi.Documents set CashAccountTo = CashAccount, CashAccountFrom = null where Id=@Id;

				insert into sunapi.CashFlows([Date], DocId, CashAccountId, Sum, SumIn, SumOut)
					select doc.[Date], doc.Id, doc.CashAccountTo, doc.Sum, doc.Sum, 0
					from sunapi.Documents as doc
					where doc.Id = @Id;

				insert into sunapi.Balances(DocId, [Sum], SumIn, SumOut)
					select doc.Id, doc.Sum, doc.Sum, 0
					from sunapi.Documents as doc
					where doc.Id = @Id;

			end
			if @Type = N'OUTGOING_PAYMENT'
			begin
				update sunapi.Documents set CashAccountFrom = CashAccount, CashAccountTo = null where Id=@Id;

				insert into sunapi.CashFlows([Date], DocId, CashAccountId, Sum, SumIn, SumOut)
					select doc.[Date], doc.Id, doc.CashAccountFrom, -1 * doc.Sum, 0, doc.Sum
					from sunapi.Documents as doc
					where doc.Id = @Id;

				insert into sunapi.Balances(DocId, [Sum], SumIn, SumOut)
					select doc.Id, - doc.Sum, 0, doc.Sum
					from sunapi.Documents as doc
					where doc.Id = @Id;

			end
			if @Type = N'MONEY_MOVE'
			begin
				insert into sunapi.CashFlows([Date], DocId, CashAccountId, Sum, SumIn, SumOut)
					select doc.[Date], doc.Id, doc.CashAccountFrom, -1 * doc.Sum, 0, doc.Sum
					from sunapi.Documents as doc
					where doc.Id = @Id;
				insert into sunapi.CashFlows([Date], DocId, CashAccountId, Sum, SumIn, SumOut)
					select doc.[Date], doc.Id, doc.CashAccountTo, doc.Sum, doc.Sum, 0
					from sunapi.Documents as doc
					where doc.Id = @Id;
			end

			---- get products from document
			declare @ProductsToRecalculate table
			(
				ProductId bigint not null
			);
			insert into @ProductsToRecalculate (ProductId)
				select distinct ProductId from sunapi.Stocks where DocId = @Id;

			---- recalculate profit for products
			declare @ProductId bigint = null;
			declare cur cursor local for
				select ProductId from @ProductsToRecalculate;
			open cur;
			fetch next from cur into @ProductId;
			while @@FETCH_STATUS = 0 
			begin
				exec sunapi.[Stocks.Profit.Update] @ProductId, @CompanyId;
				fetch next from cur into @ProductId;
			end;
			close cur;
			deallocate cur;

			-- todo: log


		commit transaction;
	end try
	begin catch
		rollback transaction; 
		declare @ErrorMsg nvarchar(255);
		set @ErrorMsg = ERROR_MESSAGE();
		throw 60000, @ErrorMsg, 0;
	end catch;

end
go
------------------------------------------------
create or alter procedure sunapi.[Document.UnApply]
	@UserId bigint,
	@Id bigint = null
as
begin
	set nocount on;
	declare @Done bit,
		@CompanyId bigint;

	select @Done = Done from sunapi.Documents where Id=@Id;
	select @CompanyId = Company from sunapi.Documents where Id = @Id;

	if @Done = 1
	begin try  
		begin transaction;
			-- if exists(select * from a2demo.Documents where Parent=@Id)
			-- 	throw 60000, N'UI:Проведение отменить невозможно.\nСуществуют дочерние документы.', 0;
			-- else 
			-- begin
			-- 	update a2demo.Documents set Done = 0, DateModified = getdate(), UserModified = @UserId  where Id=@Id;
			-- end

			update sunapi.Documents set Done = 0, DateModified = getdate(), UserModified = @UserId  where Id=@Id;

			---- get products from document
			declare @ProductsToRecalculate table
			(
				ProductId bigint not null
			);
			insert into @ProductsToRecalculate (ProductId)
				select distinct ProductId from sunapi.Stocks where DocId = @Id;

			---- delete information from Stocks table
			delete from sunapi.Stocks where DocId = @Id;

			---- recalculate profit for products
			declare @ProductId bigint = null;
			declare cur cursor local for
				select ProductId from @ProductsToRecalculate;
			open cur;
			fetch next from cur into @ProductId;
			while @@FETCH_STATUS = 0 
			begin
				exec sunapi.[Stocks.Profit.Update] @ProductId, @CompanyId;
				fetch next from cur into @ProductId;
			end;
			close cur;
			deallocate cur;

			---- delete information from CashFlows table
			delete from sunapi.CashFlows where DocId = @Id;

			---- delete information from Balances table
			delete from sunapi.Balances where DocId = @Id;

			-- todo: log


		commit transaction;
	end try
	begin catch
		rollback transaction; 
		declare @ErrorMsg nvarchar(255);
		set @ErrorMsg = ERROR_MESSAGE();
		throw 60000, @ErrorMsg, 0;
	end catch;
end
go
------------------------------------------------
create or alter procedure sunapi.[Document.CheckIsDone]
	@Id bigint = null
as
begin
	set nocount on;
	declare @Done bit;
	select @Done = Done from sunapi.Documents where Id=@Id;
	if @Done = 0 
	begin;
		throw 60000, N'UI:Для создания подчиненного документа исходный документ должен быть проведен', 0;
	end;
end
go
------------------------------------------------
create or alter procedure sunapi.[Document.Copy]
	@UserId bigint,
	@Id bigint,
	@Type nvarchar(32),
	@CopyAsChild bit,
	@CopyDetails bit = 1,
	@NewId bigint output
as
begin

	set nocount on;
	declare @Output table(Id bigint);
	declare @Number bigint;
	set @Number = sunapi.CheckDocNumber (@Type, (select Company from sunapi.Documents where Id = @Id), 0, 0);
	-- Document
	insert into sunapi.Documents (ParentId, [Type], [Date], [Number], [Partner], Company, [Contract], CashAccount, Expenditure, Operation, PriceType, [Sum], Comment, StoreFrom, StoreTo, DateCreated, UserCreated, DateModified, UserModified)
		output inserted.Id into @Output(Id)
	select IIF(@CopyAsChild = 1, @Id, null), @Type, getdate(), @Number, [Partner], Company, [Contract], CashAccount, Expenditure, Operation, PriceType, [Sum], Comment, StoreFrom, StoreTo, getdate(), @UserId, getdate(), @UserId
		from sunapi.Documents where Id=@Id;

	select top(1) @NewId = Id from @Output;

	-- Details
	if @CopyDetails = 1
		insert into sunapi.Details (Document, Product, Qty, Price, [Sum])
			select @NewId, Product, Qty, Price, [Sum]
			from sunapi.Details where Document=@Id;

end
go
------------------------------------------------
create or alter procedure sunapi.[Document.AddChildCopy]
	@UserId bigint,
	@Id bigint = null,
	@Type nvarchar(32)
as
begin
	set nocount on;
	exec sunapi.[Document.CheckIsDone] @Id;
	declare @NewId bigint;
	exec sunapi.[Document.Copy] @UserId, @Id, @Type, 1, 1, @NewId output;
	select [Document!TDocChild!Object] = null, [Id!!Id] = Id, [Type], [Date], [Number], [Partner], Company, [Contract], CashAccount, [Sum], Comment
	from sunapi.Documents where Id=@NewId;
end
go
------------------------------------------------
create or alter procedure sunapi.[Document.AddChildCopyWithoutDetails]
	@UserId bigint,
	@Id bigint = null,
	@Type nvarchar(32)
as
begin
	set nocount on;
	exec sunapi.[Document.CheckIsDone] @Id;
	declare @NewId bigint;
	exec sunapi.[Document.Copy] @UserId, @Id, @Type, 1, 0, @NewId output;
	select [Document!TDocChild!Object] = null, [Id!!Id] = Id, [Type], [Date], [Number], [Partner], Company, [Contract], CashAccount, [Sum], Comment
	from sunapi.Documents where Id=@NewId;
end
go
------------------------------------------------

create or alter procedure sunapi.[Stocks.Profit.Update]
@ProductId bigint null,
@CompanyId bigint null
as
begin
	set nocount on;
	-- set transaction isolation level read uncommitted; -- TODO: choose correct isolation level!!!

	-- declare @ProductId bigint = 115;
	-- throw 60000, @CompanyId, 0;

	declare
		@Id as bigint,
		@DocId as bigint, 
		@StoreId as bigint, 
		@Qty as decimal(10,3),
		@Price as decimal(10,2),
		@Profit as decimal(10,2), 
		@Type as nvarchar(32),
		@Date as datetime;

	declare
		@PrevResQty as decimal(10,3) = 0,
		@PrevAvgPrice as decimal(10,2) = 0,
		@CurResQty as decimal(10,3) = 0,
		@CurAvgPrice as decimal(10,2) = 0,
		@CurProfit as decimal(10,2) = 0;

	declare C cursor fast_forward for

		select s.Id, s.DocId, s.StoreId, s.Qty, s.Price, s.Profit, d.Type, d.Date from 
			sunapi.Stocks as s
			left join sunapi.Documents as d on d.Id = s.DocId
			where 
				s.ProductId = @ProductId
				and ( s.CompanyId = @CompanyId ) 
				and (d.Type in (N'INCOME_INVOICE', N'OUTGOING_INVOICE'))
			order by d.Date asc, d.Id asc;
			-- order by d.Date asc, CASE WHEN d.Type = N'INCOME_INVOICE' THEN 1 WHEN d.Type = N'OUTGOING_INVOICE' THEN 2 ELSE 999 END asc;

	open C;

	fetch next from C into	@Id, @DocId, @StoreId, @Qty, @Price, @Profit, @Type, @Date;

	while @@FETCH_STATUS = 0
	begin
		set @CurResQty = @PrevResQty + @Qty;

		if @Type = N'INCOME_INVOICE'
			set @CurAvgPrice = (@PrevResQty * @PrevAvgPrice + @Qty * @Price) / (@PrevResQty + @Qty);
		else
			set @CurAvgPrice = @PrevAvgPrice;

		-- print @CurAvgPrice;
		-- print @CurResQty;

		if @Type = N'OUTGOING_INVOICE'
		begin;

			---- Check negative quantity
			if @CurResQty < 0
			begin
				declare @ErrorMsg nvarchar(255);
				set @ErrorMsg = concat_ws(
					N'', N'UI:Отрицательный остаток!\n Документ ', @DocId, N' от ', convert(varchar, @Date, 23), 
					', товар ', (select [Name] from sunapi.Products where Id=@ProductId), N': ', @CurResQty);
				throw 60000, @ErrorMsg, 0;
			end

			set @CurProfit = (@Price - @CurAvgPrice) * abs(@Qty);

			if @Profit is null or @CurProfit <> @Profit
				update sunapi.Stocks set Profit = @CurProfit where Id = @Id;
		end;

		-- print concat_ws(N' ', @Id, @DocId, @StoreId, @Qty, @Price, @Profit, @Type, @CurResQty, @CurAvgPrice, @CurProfit);

		set @PrevAvgPrice = @CurAvgPrice;
		set @PrevResQty = @CurResQty;

		fetch next from C into @Id, @DocId, @StoreId, @Qty, @Price, @Profit, @Type, @Date;
	end
	close C;
	deallocate C;

	print @CurAvgPrice;

end
go
------------------------------------------------
create or alter procedure sunapi.[CashAccountByCompany.Index]
@UserId bigint,
@Id bigint = null,
@Offset int = 0,
@PageSize int = 10,
@Order nvarchar(255) = N'Name',
@Dir nvarchar(20) = N'asc',
@Company bigint = null,
@Date datetime,
@ShowBalance bit = 0
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @Asc nvarchar(10), @Desc nvarchar(10), @RowCount int;
	set @Asc = N'asc'; set @Desc = N'desc';
	set @Dir = isnull(@Dir, @Asc);

	with T([Id!!Id], [Name], Memo, [Company.Id!TCompany!Id], [Company.Name!TCompany!], [!!RowNumber])
	as(
		select ca.Id, ca.[Name], ca.Memo, com.Id, com.[Name], [!!RowNumber] = row_number() over (
			 order by
				case when @Order=N'Id' and @Dir = @Asc then ca.Id end asc,
				case when @Order=N'Id' and @Dir = @Desc  then ca.Id end desc,
				case when @Order=N'Name' and @Dir = @Asc then ca.[Name] end asc,
				case when @Order=N'Name' and @Dir = @Desc then ca.[Name] end desc,
				case when @Order=N'Company.Name' and @Dir = @Asc then com.[Name] end asc,
				case when @Order=N'Company.Name' and @Dir = @Desc then com.[Name] end desc
			)
			from sunapi.CashAccounts as ca
			left join sunapi.Companies as com on ca.Company = com.Id
			where ca.Company = @Company
	)
	select [CashAccounts!TCashAccount!Array]=null, *, 
		Balance = IIF(@ShowBalance = 1, sunapi.GetCashAccountBalanceOnDateBegin ([Id!!Id], DATEADD(DAY, 1, cast(@Date as Date))), -9999999),
		[!!RowCount] = (select count(1) from T)
		from T
		where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
		order by [!!RowNumber];

	select [Params!TParam!Object] = null, 
		[Company!TCompany!RefId] = @Company,
		[ShowBalance!!] = @ShowBalance;
	
	select [!TCompany!Map] = null, [Id!!Id] = Id, [Name]
	from sunapi.Companies where Id=@Company;

	select [!$System!] = null, 
		[!CashAccounts!PageSize] = @PageSize, 
		[!CashAccounts!SortOrder] = @Order, 
		[!CashAccounts!SortDir] = @Dir,
		[!CashAccounts!Offset] = @Offset,
		[!CashAccounts!HasRows] = case when exists(select * from sunapi.CashAccounts) then 1 else 0 end
end
go
------------------------------------------------
