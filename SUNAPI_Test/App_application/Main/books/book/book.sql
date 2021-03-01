-----------------
----- Books -----
-----------------

------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'books' and SEQUENCE_NAME=N'SQ_Books')
	create sequence books.SQ_Books as bigint start with 100 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'Books' and TABLE_SCHEMA = N'books')
begin
	create table books.Books (
		Id bigint not null constraint PK_Books primary key
			constraint DF_Books_PK default(next value for books.SQ_Books),
		[Name] nvarchar(255),
		Code nvarchar(32) null,
		ISBN nvarchar(32) null,
		Author bigint null constraint FK_Books_Author_Authors foreign key references books.Authors(Id),
		Memo nvarchar(255),
		DateCreated datetime not null constraint DF_Books_DateCreated default(getdate()),
		UserCreated bigint not null
			constraint FK_Books_UserCreated_Users foreign key references a2security.Users(Id),
		DateModified datetime not null constraint DF_Books_DateModified default(getdate()),
		UserModified bigint not null
			constraint FK_Books_UserModified_Users foreign key references a2security.Users(Id)
	)
end
go

-- Book.Code
if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'books' and TABLE_NAME=N'Books' and COLUMN_NAME=N'Code'))
begin
	alter table books.Books add Code nvarchar(32) null;
end
go

-- Book.ISBN
if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'books' and TABLE_NAME=N'Books' and COLUMN_NAME=N'ISBN'))
begin
	alter table books.Books add ISBN nvarchar(32) null;
end
go

-- Book.Author
if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'books' and TABLE_NAME=N'Books' and COLUMN_NAME=N'Author'))
begin
	alter table books.Books add Author bigint null constraint FK_Books_Author_Authors foreign key references books.Authors(Id);
end
go


------------------------------------------------
----- Demo data
if not exists(select * from books.Books) 
begin
	insert into books.Books ([Name], UserCreated, UserModified)
		values 
		(N'Кобзар', 0, 0),
		(N'Лісова пісня', 0, 0);
end
go
------------------------------------------------
create or alter procedure books.[Book.Index]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Books!TBook!Array] = null, [Id!!Id] = b.Id, b.[Name], b.Code, b.ISBN, 
		[Author.Id!TAuthor!Id] = a.Id, [Author.Name!TAuthor] = a.[Name], b.Memo
	from books.Books as b
	left join books.Authors as a on a.Id = b.Author;

end
go
------------------------------------------------
create or alter procedure books.[Book.Load]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Book!TBook!Object] = null, [Id!!Id] = Id, [Name], Code, ISBN, [Author!TAuthor!RefId] = Author, Memo
	from books.Books
	where Id = @Id;

	select [!TAuthor!Map] = null, [Id!!Id] = Id, [Name]
	from books.Authors where Id in (select Author from books.Books where Id=@Id);

end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'books' and ROUTINE_NAME=N'Book.Update')
	drop procedure books.[Book.Update];
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'books' and DOMAIN_NAME=N'Book.TableType' and DATA_TYPE=N'table type')
	drop type books.[Book.TableType];
go
------------------------------------------------
create type books.[Book.TableType]
as table(
	Id bigint null,
	[Name] nvarchar(255),
	Code nvarchar(32),
	ISBN nvarchar(32),
	Author bigint,
	Memo nvarchar(255)
)
go
-------------------------------------------------
create or alter procedure books.[Book.Metadata]
as
begin
	set nocount on;
	declare @Book books.[Book.TableType];
	select [Book!Book!Metadata] = null, * from @Book;
end
go
-------------------------------------------------
create or alter procedure books.[Book.Update]
@UserId bigint,
@Book books.[Book.TableType] readonly,
@RetId bigint = null output
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;

	declare @output table(op nvarchar(150), id bigint);

	merge books.Books as target
	using @Book as source
	on (target.Id = source.Id)
	when matched then
		update set 
			target.[Name] = source.[Name],
			target.[Code] = source.[Code],
			target.[ISBN] = source.[ISBN],
			target.[Author] = source.[Author],
			target.[Memo] = source.[Memo],
			target.UserModified = @UserId
	when not matched by target then 
		insert ([Name], Code, ISBN, Author, Memo, UserCreated, UserModified)
		values ([Name], Code, ISBN, Author, Memo, @UserId, @UserId)
	output 
		$action op,
		inserted.Id id
	into @output(op, id);

	select top(1) @RetId = id from @output;

	exec books.[Book.Load] @UserId = @UserId, @Id = @RetId;
end
go
-------------------------------------------------
create or alter procedure books.[Book.Delete]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	delete from books.Books
	where Id = @Id;

end
go
-------------------------------------------------
