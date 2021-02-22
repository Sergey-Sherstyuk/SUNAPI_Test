--------------------
----- Partners -----
--------------------

------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'sunapi' and SEQUENCE_NAME=N'SQ_Partners')
	create sequence sunapi.SQ_Partners as bigint start with 150 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Partners')
begin
	create table sunapi.Partners
	(
		Id	bigint not null constraint PK_Partners primary key
			constraint DF_Partners_PK default(next value for sunapi.SQ_Partners),
		[Name] nvarchar(255) null,
		PrintName nvarchar(255) null,
		LegalAddress nvarchar(255) null,
		Phone nvarchar(64) null,
		Memo nvarchar(255) null,
		DateCreated datetime not null constraint DF_Partners_DateCreated default(getdate()),
		UserCreated bigint not null 
			constraint FK_Partners_UserCreated_Users foreign key references a2security.Users(Id),
		DateModified datetime not null constraint DF_Partners_DateModified default(getdate()),
		UserModified bigint not null
			constraint FK_Partners_UserModified_Users foreign key references a2security.Users(Id)
	);
end
go

if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Partners' and COLUMN_NAME=N'PrintName'))
begin
	alter table sunapi.Partners add PrintName nvarchar(255) null;
end
go

if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'sunapi' and TABLE_NAME=N'Partners' and COLUMN_NAME=N'LegalAddress'))
begin
	alter table sunapi.Partners add LegalAddress nvarchar(255) null;
end
go

-------------------------------------------------
create or alter procedure sunapi.[Partner.Index]
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
	set @Asc = N'asc'; 
	set @Desc = N'desc';
	set @Dir = isnull(@Dir, @Asc);

	with T([Id!!Id], [Name], Phone, Memo, [!!RowNumber])
	as(
		select p.Id, p.[Name], p.Phone, p.Memo, [!!RowNumber] = row_number() over (
			 order by
				case when @Order=N'Id' and @Dir = @Asc then p.Id end asc,
				case when @Order=N'Id' and @Dir = @Desc  then p.Id end desc,
				case when @Order=N'Name' and @Dir = @Asc then p.[Name] end asc,
				case when @Order=N'Name' and @Dir = @Desc then p.[Name] end desc,
				case when @Order=N'Phone' and @Dir = @Asc then p.Phone end asc,
				case when @Order=N'Phone' and @Dir = @Desc then p.Phone end desc,
				case when @Order=N'Memo' and @Dir = @Asc then p.Memo end asc,
				case when @Order=N'Memo' and @Dir = @Desc then p.Memo end desc
			)
			from sunapi.Partners as p
			where (@Fragment is null or upper(p.[Name]) like @Fragment or upper(p.[Phone]) like @Fragment or cast(p.Id as nvarchar) like @Fragment)
	)
	select [Partners!TPartner!Array]=null, *, [!!RowCount] = (select count(1) from T)
		from T
		where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
		order by [!!RowNumber];

	select [!$System!] = null, 
		[!Partners!PageSize] = @PageSize, 
		[!Partners!SortOrder] = @Order, 
		[!Partners!SortDir] = @Dir,
		[!Partners!Offset] = @Offset,
		[!Partners!HasRows] = case when exists(select * from sunapi.Partners) then 1 else 0 end,
		[!Partners.Fragment!Filter] = @InitFragment

end
go
------------------------------------------------
create or alter procedure sunapi.[Partner.Load]
	@UserId bigint,
	@Id bigint = null,
	@Text nvarchar(255) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;
	select [Partner!TPartner!Object] = null, [Id!!Id] = Id, [Name!!Name] = [Name], PrintName, LegalAddress, Phone, Memo, 
		DateCreated, DateModified, [UserCreated!TUser!RefId] = UserCreated, [UserModified!TUser!RefId] = UserModified
		from sunapi.Partners where Id=@Id;

	select [!TUser!Map] = null, [Id!!Id] = u.Id,  [Name!!Name] = isnull(u.PersonName, u.UserName)
		from a2security.ViewUsers u
		inner join sunapi.Partners a on u.Id in (a.UserCreated, a.UserModified)
		where a.Id=@Id;

	select [Params!TParam!Object] = null, [Text] = @Text;
end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'sunapi' and ROUTINE_NAME=N'Partner.Metadata')
	drop procedure sunapi.[Partner.Metadata]
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'sunapi' and ROUTINE_NAME=N'Partner.Update')
	drop procedure sunapi.[Partner.Update]
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'sunapi' and DOMAIN_NAME=N'Partner.TableType' and DATA_TYPE=N'table type')
	drop type sunapi.[Partner.TableType];
go
------------------------------------------------
create type sunapi.[Partner.TableType]
as table(
	Id bigint null,
	[Name] nvarchar(255),
	PrintName nvarchar(255) null,
	LegalAddress nvarchar(255) null,
	Phone nvarchar(64) null,
	Memo nvarchar(255)
)
go
-------------------------------------------------
create or alter procedure sunapi.[Partner.Metadata]
as
begin
	set nocount on;
	declare @Partner sunapi.[Partner.TableType];
	select [Partner!Partner!Metadata] = null, * from @Partner;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Partner.Update]
@UserId bigint,
@Partner sunapi.[Partner.TableType] readonly,
@RetId bigint = null output
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;

	declare @output table(op nvarchar(150), id bigint);

	merge sunapi.Partners as target
	using @Partner as source
	on (target.Id = source.Id)
	when matched then
		update set 
			target.[Name] = source.[Name],
			target.PrintName = source.PrintName,
			target.LegalAddress = source.LegalAddress,
			target.Phone = source.Phone,
			target.Memo = source.Memo,
			target.[DateModified] = getdate(),
			target.[UserModified] = @UserId
	when not matched by target then 
		insert ([Name], PrintName, LegalAddress, Phone, Memo, UserCreated, UserModified)
		values ([Name], PrintName, LegalAddress, Phone, Memo, @UserId, @UserId)
	output 
		$action op,
		inserted.Id id
	into @output(op, id);

	select top(1) @RetId = id from @output;

	exec sunapi.[Partner.Load] @UserId, @RetId;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Partner.Delete]
@UserId bigint,
@Id bigint
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;
	delete from sunapi.Partners where Id=@Id;
end
go
-------------------------------------------------
create or alter procedure sunapi.[Partner.Fetch]
	@UserId bigint,
	@Search nvarchar(255) = null
as
begin
	set nocount on
	set nocount on;
	set transaction isolation level read uncommitted;

	if @Search is not null
		set @Search = N'%' + upper(@Search) + N'%';

	select [Partners!TPartner!Array]=null, [Id!!Id] = Id, [Name!!Name] = [Name], Phone, Memo
	from sunapi.Partners
		where (upper([Name]) like @Search or upper(Phone) like @Search
			or upper(Memo) like @Search or cast(Id as nvarchar) like @Search)
	order by [Name]
end
go
-------------------------------------------------
