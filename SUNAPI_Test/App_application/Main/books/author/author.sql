-------------------
----- Authors -----
-------------------

------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'books' and SEQUENCE_NAME=N'SQ_Authors')
	create sequence books.SQ_Authors as bigint start with 100 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'Authors' and TABLE_SCHEMA = N'books')
begin
	create table books.Authors (
		Id bigint not null constraint PK_Authors primary key
			constraint DF_Authors_PK default(next value for books.SQ_Authors),
		[Name] nvarchar(255),
		BookAmount  nvarchar(255),
		Memo nvarchar(255),
		DateCreated datetime not null constraint DF_Authors_DateCreated default(getdate()),
		UserCreated bigint not null
			constraint FK_Authors_UserCreated_Users foreign key references a2security.Users(Id),
		DateModified datetime not null constraint DF_Authors_DateModified default(getdate()),
		UserModified bigint not null
			constraint FK_Authors_UserModified_Users foreign key references a2security.Users(Id)
	)
end
go

-- Book.Book
if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'books' and TABLE_NAME=N'Authors' and COLUMN_NAME=N'BookAmount'))
begin
	alter table books.Authors add BookAmount  nvarchar(255);
end
go

------------------------------------------------
----- Demo data
if not exists(select * from books.Authors) 
begin
	insert into books.Authors ([Name], UserCreated, UserModified)
		values 
		(N'Тарас Шевченко', 0, 0),
		(N'Леся Українка', 0, 0);
end
go
------------------------------------------------
create or alter procedure books.[Author.Index]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Authors!TAuthor!Array] = null, [Id!!Id] = a.Id, a.[Name], BookAmount = (SELECT count(b.Author) from books.Books as b where b.Author = a.Id), a.Memo
	from books.Authors as a;

end
go
------------------------------------------------
create or alter procedure books.[Author.Load]
@UserId bigint,
@Id bigint = null,
@Text nvarchar(255) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Author!TAuthor!Object] = null, [Id!!Id] = Id, [Name], Memo
	from books.Authors
	where Id = @Id;

	select [Params!TParam!Object] = null, [Text] = @Text;

end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'books' and ROUTINE_NAME=N'Author.Update')
	drop procedure books.[Author.Update];
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'books' and DOMAIN_NAME=N'Author.TableType' and DATA_TYPE=N'table type')
	drop type books.[Author.TableType];
go
------------------------------------------------
create type books.[Author.TableType]
as table(
	Id bigint null,
	[Name] nvarchar(255),
	Memo nvarchar(255)

)
go
-------------------------------------------------
create or alter procedure books.[Author.Metadata]
as
begin
	set nocount on;
	declare @Author books.[Author.TableType];
	select [Author!Author!Metadata] = null, * from @Author;
end
go
-------------------------------------------------
create or alter procedure books.[Author.Update]
@UserId bigint,
@Author books.[Author.TableType] readonly,
@RetId bigint = null output
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;

	declare @output table(op nvarchar(150), id bigint);

	merge books.Authors as target
	using @Author as source
	on (target.Id = source.Id)
	when matched then
		update set 
			target.[Name] = source.[Name],
			target.[Memo] = source.[Memo],
			target.UserModified = @UserId
	when not matched by target then 
		insert ([Name], Memo, UserCreated, UserModified)
		values ([Name], Memo, @UserId, @UserId)
	output 
		$action op,
		inserted.Id id
	into @output(op, id);

	select top(1) @RetId = id from @output;

	exec books.[Author.Load] @UserId = @UserId, @Id = @RetId;
end
go
-------------------------------------------------
create or alter procedure books.[Author.Delete]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	delete from books.Authors
	where Id = @Id;

end
go
------------------------------------------------
create or alter procedure books.[Author.Fetch]
@UserId bigint,
@Search nvarchar(255) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	if @Search is not null 
		set @Search = N'%' + upper(@Search) + N'%';

	select [Authors!TAuthor!Array] = null, [Id!!Id] = Id, [Name], Memo
	from books.Authors
	where upper(Name) like @Search or cast(Id as nvarchar) like @Search;

end
go