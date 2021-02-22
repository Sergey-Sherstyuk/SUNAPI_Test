------------------------
----- CashAccounts -----
------------------------

------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'sunapi' and SEQUENCE_NAME=N'SQ_CashAccounts')
	create sequence sunapi.SQ_CashAccounts as bigint start with 150 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'CashAccounts' and TABLE_SCHEMA = N'sunapi')
begin
	create table sunapi.CashAccounts (
		Id bigint not null constraint PK_CashAccounts primary key
			constraint DF_CashAccounts_PK default(next value for sunapi.SQ_CashAccounts),
		Company bigint not null
			constraint FK_CashAccounts_Company_Companies foreign key references sunapi.Companies(Id),
		[Name] nvarchar(255),
		IsCash bit not null constraint DF_CashAccounts_IsCash default(0),
		BankAccount nvarchar(128) null,
		BankName nvarchar(128) null,
		BankMFO nvarchar(128) null,
		Memo nvarchar(255),
		DateCreated datetime not null constraint DF_CashAccounts_DateCreated default(getdate()),
		UserCreated bigint not null
			constraint FK_CashAccounts_UserCreated_Users foreign key references a2security.Users(Id),
		DateModified datetime not null constraint DF_CashAccounts_DateModified default(getdate()),
		UserModified bigint not null
			constraint FK_CashAccounts_UserModified_Users foreign key references a2security.Users(Id)
	)
end
go

if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'CashAccounts' and COLUMN_NAME=N'IsCash'))
begin
	alter table sunapi.CashAccounts add IsCash bit not null constraint DF_CashAccounts_IsCash default(0);
end
go

if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'CashAccounts' and COLUMN_NAME=N'BankAccount'))
begin
	alter table sunapi.CashAccounts add BankAccount nvarchar(128) null;
end
go

if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'CashAccounts' and COLUMN_NAME=N'BankName'))
begin
	alter table sunapi.CashAccounts add BankName nvarchar(128) null;
end
go

if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'CashAccounts' and COLUMN_NAME=N'BankMFO'))
begin
	alter table sunapi.CashAccounts add BankMFO nvarchar(128) null;
end
go

-------------------------------------------------
/*
create or alter procedure sunapi.[CashAccount.Index]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [CashAccounts!TCashAccount!Array] = null, [Id!!Id] = Id, [Name], Memo
	from sunapi.CashAccounts
	order by Name asc;
end
go
*/
-------------------------------------------------
create or alter procedure sunapi.[CashAccount.Index]
@UserId bigint,
@Id bigint = null,
@Offset int = 0,
@PageSize int = 10,
@Order nvarchar(255) = N'Name',
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
			where (@Fragment is null or upper(ca.[Name]) like @Fragment or cast(ca.Id as nvarchar) like @Fragment)
	)
	select [CashAccounts!TCashAccount!Array]=null, *, [!!RowCount] = (select count(1) from T)
		from T
		where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
		order by [!!RowNumber];

	select [!$System!] = null, 
		[!CashAccounts!PageSize] = @PageSize, 
		[!CashAccounts!SortOrder] = @Order, 
		[!CashAccounts!SortDir] = @Dir,
		[!CashAccounts!Offset] = @Offset,
		[!CashAccounts!HasRows] = case when exists(select * from sunapi.CashAccounts) then 1 else 0 end,
		[!CashAccounts.Fragment!Filter] = @InitFragment
end
go
-------------------------------------------------
create or alter procedure sunapi.[CashAccount.Load]
@UserId bigint,
@Id bigint = null,
@Text nvarchar(255) = null,
@Company bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [CashAccount!TCashAccount!Object] = null, [Id!!Id] = Id, [Name], IsCash, BankAccount, BankName, BankMFO, Memo, [Company!TCompany!RefId] = Company
	from sunapi.CashAccounts
	where Id=@Id;

	select [!TCompany!Map] = null, [Id!!Id] = com.Id, [Name!!Name] = com.[Name]
	from sunapi.Companies as com
	inner join sunapi.CashAccounts as ca on ca.Company = com.Id
	where ca.Id=@Id;

	-- Parameters to set Company value when creating a new CashAccount
	select [Params!TParam!Object] = null, [Text] = @Text, [Company!TCompany!RefId] = @Company;

	select [!TCompany!Map] = null, [Id!!Id] = Id, [Name!!Name] = [Name]
	from sunapi.Companies
	where Id = @Company;

end
go
-------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'sunapi' and ROUTINE_NAME=N'CashAccount.Update')
	drop procedure sunapi.[CashAccount.Update]
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'sunapi' and DOMAIN_NAME=N'CashAccount.TableType' and DATA_TYPE=N'table type')
	drop type sunapi.[CashAccount.TableType];
go
------------------------------------------------
create type sunapi.[CashAccount.TableType]
as table(
	Id bigint null,
	[Name] nvarchar(255),
	IsCash bit not null,
	BankAccount nvarchar(128) null,
	BankName nvarchar(128) null,
	BankMFO nvarchar(128) null,
	Memo nvarchar(255),
	Company bigint
)
go
-------------------------------------------------
create or alter procedure sunapi.[CashAccount.Metadata]
as
begin
	set nocount on;
	declare @CashAccount sunapi.[CashAccount.TableType];
	select [CashAccount!CashAccount!Metadata] = null, * from @CashAccount;
end
go
-------------------------------------------------
create or alter procedure sunapi.[CashAccount.Update]
@UserId bigint,
@CashAccount sunapi.[CashAccount.TableType] readonly,
@RetId bigint = null output
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;

	declare @output table(op nvarchar(150), id bigint);

	merge sunapi.CashAccounts as target
	using @CashAccount as source
	on (target.Id = source.Id)
	when matched then
		update set 
			target.[Name] = source.[Name],
			target.IsCash = source.IsCash,
			target.BankAccount = source.BankAccount,
			target.BankName = source.BankName,
			target.BankMFO = source.BankMFO,
			target.[Memo] = source.[Memo],
			target.Company = source.Company,
			target.UserModified = @UserId
	when not matched by target then 
		insert ([Name], IsCash, BankAccount, BankName, BankMFO, Memo, Company, UserCreated, UserModified)
		values ([Name], IsCash, BankAccount, BankName, BankMFO, Memo, Company, @UserId, @UserId)
	output 
		$action op,
		inserted.Id id
	into @output(op, id);

	select top(1) @RetId = id from @output;

	exec sunapi.[CashAccount.Load] @UserId, @RetId;
end
go
-------------------------------------------------
create or alter procedure sunapi.[CashAccount.Delete]
@UserId bigint,
@Id bigint
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;
	delete from sunapi.CashAccounts where Id=@Id;
end
go
-------------------------------------------------
create or alter procedure sunapi.[CashAccountByCompany.Delete]
@UserId bigint,
@Id bigint
as
begin
	exec sunapi.[CashAccount.Delete] @UserId, @Id;
end
go
-------------------------------------------------
create or alter procedure sunapi.[CashAccount.Fetch]
	@UserId bigint,
	@Search nvarchar(255) = null
as
begin
	set nocount on
	set transaction isolation level read uncommitted;

	if @Search is not null
		set @Search = N'%' + upper(@Search) + N'%';

	select [CashAccounts!TCashAccount!Array]=null, [Id!!Id] = Id, [Name!!Name] = [Name], Memo
	from sunapi.CashAccounts
		where (upper([Name]) like @Search or upper(Memo) like @Search or cast(Id as nvarchar) like @Search)
	order by [Name]
end
go
-------------------------------------------------
create or alter procedure sunapi.[CashAccount.List.Load]
	@UserId bigint,
	@Id bigint = 0
as
begin
	select [CashAccounts!TCashAccount!Array] = null, [Id!!Id] = Id, [Name], Memo, Company
	from sunapi.CashAccounts
	order by Name asc;
end
go
-------------------------------------------------
