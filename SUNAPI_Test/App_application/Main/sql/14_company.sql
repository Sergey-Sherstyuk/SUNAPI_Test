-------------------------
----- Companies -----
-------------------------

------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'sunapi' and SEQUENCE_NAME=N'SQ_Companies')
	create sequence sunapi.SQ_Companies as bigint start with 150 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'Companies' and TABLE_SCHEMA = N'sunapi')
begin
	create table sunapi.Companies (
		Id	bigint not null constraint PK_Companies primary key
			constraint DF_Companies_PK default(next value for sunapi.SQ_Companies),
		[Name] nvarchar(255),
		PrintName nvarchar(255) null,
		LegalAddress nvarchar(255) null,
		Phone nvarchar(128) null,
		EDRPOU nvarchar(64) null,
		VatText nvarchar(128) null,
		Memo nvarchar(255),
		DateCreated datetime not null constraint DF_Companies_DateCreated default(getdate()),
		UserCreated bigint not null
			constraint FK_Companies_UserCreated_Users foreign key references a2security.Users(Id),
		DateModified datetime not null constraint DF_Companies_DateModified default(getdate()),
		UserModified bigint not null
			constraint FK_Companies_UserModified_Users foreign key references a2security.Users(Id)
	)
end
go


if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Companies' and COLUMN_NAME=N'PrintName'))
begin
	alter table sunapi.Companies add PrintName nvarchar(255) null;
end
go

if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Companies' and COLUMN_NAME=N'LegalAddress'))
begin
	alter table sunapi.Companies add LegalAddress nvarchar(255) null;
end
go

if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Companies' and COLUMN_NAME=N'Phone'))
begin
	alter table sunapi.Companies add Phone nvarchar(128) null;
end
go

if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Companies' and COLUMN_NAME=N'EDRPOU'))
begin
	alter table sunapi.Companies add EDRPOU nvarchar(64) null;
end
go

if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Companies' and COLUMN_NAME=N'VatText'))
begin
	alter table sunapi.Companies add VatText nvarchar(128) null;
end
go



-------------------------------------------------
/*
create or alter procedure sunapi.[Company.Index]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Companies!TCompany!Array] = null, [Id!!Id] = Id, [Name], Memo
	from sunapi.Companies
	order by Name asc;
end
go
*/
-------------------------------------------------
create or alter procedure sunapi.[Company.Index]
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

	with T([Id!!Id], [Name], Memo, [!!RowNumber])
	as(
		select c.Id, c.[Name], c.Memo, [!!RowNumber] = row_number() over (
			 order by
				case when @Order=N'Id' and @Dir = @Asc then c.Id end asc,
				case when @Order=N'Id' and @Dir = @Desc  then c.Id end desc,
				case when @Order=N'Name' and @Dir = @Asc then c.[Name] end asc,
				case when @Order=N'Name' and @Dir = @Desc then c.[Name] end desc
			)
			from sunapi.Companies as c
			where (@Fragment is null or upper(c.[Name]) like @Fragment or cast(c.Id as nvarchar) like @Fragment)
	)
	select [Companies!TCompany!Array]=null, *, [!!RowCount] = (select count(1) from T)
		from T
		where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
		order by [!!RowNumber];

	select [!$System!] = null, 
		[!Companies!PageSize] = @PageSize, 
		[!Companies!SortOrder] = @Order, 
		[!Companies!SortDir] = @Dir,
		[!Companies!Offset] = @Offset,
		[!Companies!HasRows] = case when exists(select * from sunapi.Companies) then 1 else 0 end,
		[!Companies.Fragment!Filter] = @InitFragment
end
go
-------------------------------------------------
create or alter procedure sunapi.[Company.Load]
@UserId bigint,
@Id bigint = null,
@Text nvarchar(255) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Company!TCompany!Object] = null, [Id!!Id] = Id, [Name], PrintName, LegalAddress, Phone, EDRPOU, VatText, Memo
	from sunapi.Companies
	where Id=@Id;

	select [Params!TParam!Object] = null, [Text] = @Text;
end
go
-------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'sunapi' and ROUTINE_NAME=N'Company.Update')
	drop procedure sunapi.[Company.Update]
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'sunapi' and DOMAIN_NAME=N'Company.TableType' and DATA_TYPE=N'table type')
	drop type sunapi.[Company.TableType];
go
------------------------------------------------
create type sunapi.[Company.TableType]
as table(
	Id bigint null,
	[Name] nvarchar(255),
	PrintName nvarchar(255) null,
	LegalAddress nvarchar(255) null,
	Phone nvarchar(128) null,
	EDRPOU nvarchar(64) null,
	VatText nvarchar(128) null,
	Memo nvarchar(255) null
)
go
-------------------------------------------------
create or alter procedure sunapi.[Company.Metadata]
as
begin
	set nocount on;
	declare @Company sunapi.[Company.TableType];
	select [Company!Company!Metadata] = null, * from @Company;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Company.Update]
@UserId bigint,
@Company sunapi.[Company.TableType] readonly,
@RetId bigint = null output
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;

	declare @output table(op nvarchar(150), id bigint);

	merge sunapi.Companies as target
	using @Company as source
	on (target.Id = source.Id)
	when matched then
		update set 
			target.[Name] = source.[Name],
			target.PrintName = source.PrintName,
			target.LegalAddress = source.LegalAddress,
			target.Phone = source.Phone,
			target.EDRPOU = source.EDRPOU,
			target.VatText = source.VatText,
			target.[Memo] = source.[Memo],
			target.UserModified = @UserId
	when not matched by target then 
		insert ([Name], PrintName, LegalAddress, Phone, EDRPOU, VatText, Memo, UserCreated, UserModified)
		values ([Name], PrintName, LegalAddress, Phone, EDRPOU, VatText, Memo, @UserId, @UserId)
	output 
		$action op,
		inserted.Id id
	into @output(op, id);

	select top(1) @RetId = id from @output;

	exec sunapi.[Company.Load] @UserId, @RetId;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Company.Delete]
@UserId bigint,
@Id bigint
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;
	delete from sunapi.Companies where Id=@Id;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Company.Fetch]
	@UserId bigint,
	@Search nvarchar(255) = null
as
begin
	set nocount on
	set transaction isolation level read uncommitted;

	if @Search is not null
		set @Search = N'%' + upper(@Search) + N'%';

	select [Companies!TCompany!Array]=null, [Id!!Id] = Id, [Name!!Name] = [Name], Phone, EDRPOU, Memo
	from sunapi.Companies
		where (upper([Name]) like @Search or upper(Memo) like @Search or cast(Id as nvarchar) like @Search)
	order by [Name]
end
go
-------------------------------------------------
