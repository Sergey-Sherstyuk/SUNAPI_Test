---------------------
----- Contracts -----
---------------------

------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'sunapi' and SEQUENCE_NAME=N'SQ_Contracts')
	create sequence sunapi.SQ_Contracts as bigint start with 150 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'Contracts' and TABLE_SCHEMA = N'sunapi')
begin
	create table sunapi.Contracts (
		Id	bigint not null constraint PK_Contracts primary key
			constraint DF_Contracts_PK default(next value for sunapi.SQ_Contracts),
		Company bigint not null
			constraint FK_Contracts_Company_Companies foreign key references sunapi.Companies(Id),
		[Partner] bigint not null
			constraint FK_Contracts_Partner_Partners foreign key references sunapi.Partners(Id),
		[Name] nvarchar(255),
		Number nvarchar(16) null,
		[Date] date null,
		Memo nvarchar(255),
		DateCreated datetime not null constraint DF_Contracts_DateCreated default(getdate()),
		UserCreated bigint not null
			constraint FK_Contracts_UserCreated_Users foreign key references a2security.Users(Id),
		DateModified datetime not null constraint DF_Contracts_DateModified default(getdate()),
		UserModified bigint not null
			constraint FK_Contracts_UserModified_Users foreign key references a2security.Users(Id)
	)
end
go


if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Contracts' and COLUMN_NAME=N'Number'))
begin
	alter table sunapi.Contracts add Number nvarchar(16) null;
end
go

if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Contracts' and COLUMN_NAME=N'Date'))
begin
	alter table sunapi.Contracts add [Date] date null;
end
go



-------------------------------------------------
/*
create or alter procedure sunapi.[Contract.Index]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Contracts!TContract!Array] = null, [Id!!Id] = Id, [Name], Memo
	from sunapi.Contracts
	order by Name asc;
end
go
*/
-------------------------------------------------
create or alter procedure sunapi.[Contract.Index]
@UserId bigint,
@Id bigint = null,
@Offset int = 0,
@PageSize int = 20,
@Order nvarchar(255) = N'Partner.Name',
@Dir nvarchar(20) = N'asc',
@Fragment nvarchar(255) = null

as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @InitFragment nvarchar(255) = @Fragment;

	if @Fragment is not null
		set @Fragment = N'%' + upper(@Fragment) + N'%';

	declare @Asc nvarchar(10), @Desc nvarchar(10), @RowCount int;
	set @Asc = N'asc'; set @Desc = N'desc';
	set @Dir = isnull(@Dir, @Asc);

	with T([Id!!Id], [Name], Number, [Date], Memo, [Company.Id!TCompany!Id], [Company.Name!TCompany!], [Partner.Id!TPartner!Id], [Partner.Name!TPartner!], [!!RowNumber])
	as(
		select c.Id, c.[Name], c.Number, c.[Date], c.Memo, com.Id, com.[Name], p.Id, p.[Name], [!!RowNumber] = row_number() over (
			 order by
				case when @Order=N'Id' and @Dir = @Asc then c.Id end asc,
				case when @Order=N'Id' and @Dir = @Desc  then c.Id end desc,
				case when @Order=N'Name' and @Dir = @Asc then c.[Name] end asc,
				case when @Order=N'Name' and @Dir = @Desc then c.[Name] end desc,
				case when @Order=N'Company.Name' and @Dir = @Asc then com.[Name] end asc,
				case when @Order=N'Company.Name' and @Dir = @Desc then com.[Name] end desc,
				case when @Order=N'Partner.Name' and @Dir = @Asc then p.[Name] end asc,
				case when @Order=N'Partner.Name' and @Dir = @Desc then p.[Name] end desc
			)
			from sunapi.Contracts as c
			left join sunapi.Companies as com on c.Company = com.Id
			left join sunapi.Partners as p on c.[Partner] = p.Id
			where (@Fragment is null or upper(c.[Name]) like @Fragment or cast(c.Id as nvarchar) like @Fragment)
	)
	select [Contracts!TContract!Array]=null, *, [!!RowCount] = (select count(1) from T)
		from T
		where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
		order by [!!RowNumber];

	select [!$System!] = null, 
		[!Contracts!PageSize] = @PageSize, 
		[!Contracts!SortOrder] = @Order, 
		[!Contracts!SortDir] = @Dir,
		[!Contracts!Offset] = @Offset,
		[!Contracts!HasRows] = case when exists(select * from sunapi.Contracts) then 1 else 0 end,
		[!Contracts.Fragment!Filter] = @InitFragment
end
go
-------------------------------------------------
create or alter procedure sunapi.[ContractByCompanyPartner.Index]
@UserId bigint,
@Id bigint = null,
@Offset int = 0,
@PageSize int = 10,
@Order nvarchar(255) = N'Name',
@Dir nvarchar(20) = N'asc',
@Company bigint = null,
@Partner bigint = null,
@Fragment nvarchar(255) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @InitFragment nvarchar(255) = @Fragment;

	if @Fragment is not null
		set @Fragment = N'%' + upper(@Fragment) + N'%';

	declare @Asc nvarchar(10), @Desc nvarchar(10), @RowCount int;
	set @Asc = N'asc'; set @Desc = N'desc';
	set @Dir = isnull(@Dir, @Asc);

	with T([Id!!Id], [Name], Number, [Date], Memo, [Company.Id!TCompany!Id], [Company.Name!TCompany!], [Partner.Id!TPartner!Id], [Partner.Name!TPartner!], [!!RowNumber])
	as(
		select c.Id, c.[Name], c.Number, c.[Date], c.Memo, com.Id, com.[Name], p.Id, p.[Name], [!!RowNumber] = row_number() over (
			 order by
				case when @Order=N'Id' and @Dir = @Asc then c.Id end asc,
				case when @Order=N'Id' and @Dir = @Desc  then c.Id end desc,
				case when @Order=N'Name' and @Dir = @Asc then c.[Name] end asc,
				case when @Order=N'Name' and @Dir = @Desc then c.[Name] end desc,
				case when @Order=N'Company.Name' and @Dir = @Asc then com.[Name] end asc,
				case when @Order=N'Company.Name' and @Dir = @Desc then com.[Name] end desc
			)
			from sunapi.Contracts as c
			left join sunapi.Companies as com on c.Company = com.Id
			left join sunapi.Partners as p on c.[Partner] = p.Id
			where c.Company = @Company and c.[Partner] = @Partner and (@Fragment is null or upper(c.[Name]) like @Fragment or cast(c.Id as nvarchar) like @Fragment)
	)
	select [Contracts!TContract!Array]=null, *, [!!RowCount] = (select count(1) from T)
		from T
		where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
		order by [!!RowNumber];

	select [Params!TParam!Object] = null, [Company!TCompany!RefId] = @Company, [Partner!TPartner!RefId] = @Partner;
	
	select [!TCompany!Map] = null, [Id!!Id] = Id, [Name]
	from sunapi.Companies where Id=@Company;

	select [!TPartner!Map] = null, [Id!!Id] = Id, [Name]
	from sunapi.Partners where Id=@Partner;

	select [!$System!] = null, 
		[!Contracts!PageSize] = @PageSize, 
		[!Contracts!SortOrder] = @Order, 
		[!Contracts!SortDir] = @Dir,
		[!Contracts!Offset] = @Offset,
		[!Contracts!HasRows] = case when exists(select * from sunapi.Contracts) then 1 else 0 end
end
go
-------------------------------------------------
create or alter procedure sunapi.[Contract.Load]
@UserId bigint,
@Id bigint = null,
@Text nvarchar(255) = null,
@Company bigint = null,
@Partner bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Contract!TContract!Object] = null, [Id!!Id] = Id, [Name], Number, [Date], Memo, [Company!TCompany!RefId] = Company, [Partner!TPartner!RefId] = [Partner]
	from sunapi.Contracts
	where Id=@Id;

	select [!TCompany!Map] = null, [Id!!Id] = com.Id, [Name!!Name] = com.[Name]
	from sunapi.Companies as com
	inner join sunapi.Contracts as c on c.Company = com.Id
	where c.Id=@Id;

	select [!TPartner!Map] = null, [Id!!Id] = p.Id, [Name!!Name] = p.[Name]
	from sunapi.Partners as p
	inner join sunapi.Contracts as c on c.[Partner] = p.Id
	where c.Id=@Id;

	-- Parameters to set Company and Partner value when creating a new Contract
	select [Params!TParam!Object] = null, [Text] = @Text, [Company!TCompany!RefId] = @Company, [Partner!TPartner!RefId] = @Partner;

	select [!TCompany!Map] = null, [Id!!Id] = Id, [Name!!Name] = [Name]
	from sunapi.Companies
	where Id = @Company;

	select [!TPartner!Map] = null, [Id!!Id] = Id, [Name!!Name] = [Name]
	from sunapi.Partners
	where Id = @Partner;

end
go
-------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'sunapi' and ROUTINE_NAME=N'Contract.Update')
	drop procedure sunapi.[Contract.Update]
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'sunapi' and DOMAIN_NAME=N'Contract.TableType' and DATA_TYPE=N'table type')
	drop type sunapi.[Contract.TableType];
go
------------------------------------------------
create type sunapi.[Contract.TableType]
as table(
	Id bigint null,
	[Name] nvarchar(255),
	Number nvarchar(16) null,
	[Date] date null,
	Memo nvarchar(255),
	Company bigint,
	[Partner] bigint
)
go
-------------------------------------------------
create or alter procedure sunapi.[Contract.Metadata]
as
begin
	set nocount on;
	declare @Contract sunapi.[Contract.TableType];
	select [Contract!Contract!Metadata] = null, * from @Contract;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Contract.Update]
@UserId bigint,
@Contract sunapi.[Contract.TableType] readonly,
@RetId bigint = null output
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;

	declare @output table(op nvarchar(150), id bigint);

	merge sunapi.Contracts as target
	using @Contract as source
	on (target.Id = source.Id)
	when matched then
		update set 
			target.[Name] = source.[Name],
			target.[Number] = source.[Number],
			target.[Date] = source.[Date],
			target.[Memo] = source.[Memo],
			target.[Company] = source.[Company],
			target.[Partner] = source.[Partner],
			target.UserModified = @UserId
	when not matched by target then 
		insert ([Name], Number, [Date], Memo, Company, [Partner], UserCreated, UserModified)
		values ([Name], Number, [Date], Memo, Company, [Partner], @UserId, @UserId)
	output 
		$action op,
		inserted.Id id
	into @output(op, id);

	select top(1) @RetId = id from @output;

	exec sunapi.[Contract.Load] @UserId, @RetId;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Contract.Delete]
@UserId bigint,
@Id bigint
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;
	delete from sunapi.Contracts where Id=@Id;
end
go
-------------------------------------------------
create or alter procedure sunapi.[ContractByCompanyPartner.Delete]
@UserId bigint,
@Id bigint
as
begin
	exec sunapi.[Contract.Delete] @UserId, @Id;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Contract.Fetch]
	@UserId bigint,
	@Search nvarchar(255) = null
as
begin
	set nocount on
	set transaction isolation level read uncommitted;

	if @Search is not null
		set @Search = N'%' + upper(@Search) + N'%';

	select [Contracts!TContract!Array]=null, [Id!!Id] = Id, [Name!!Name] = [Name], Number, [Date], Memo
	from sunapi.Contracts
		where (upper([Name]) like @Search or upper(Memo) like @Search or cast(Id as nvarchar) like @Search)
	order by [Name]
end
go
-------------------------------------------------
create or alter procedure sunapi.[Contract.List.Load]
	@UserId bigint,
	@Id bigint = 0
as
begin
	select [Contracts!TContract!Array] = null, [Id!!Id] = Id, [Name], Number, [Date], Memo, Company
	from sunapi.Contracts
	order by Name asc;
end
go
-------------------------------------------------
