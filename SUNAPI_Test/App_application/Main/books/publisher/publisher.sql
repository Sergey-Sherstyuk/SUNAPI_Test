-------------------
----- Publishers -----
-------------------

------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.SEQUENCES where SEQUENCE_SCHEMA=N'books' and SEQUENCE_NAME=N'SQ_Publishers')
	create sequence books.SQ_Publishers as bigint start with 100 increment by 1;
go
------------------------------------------------
if not exists(select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = N'Publishers' and TABLE_SCHEMA = N'books')
begin
	create table books.Publishers (
		Id bigint not null constraint PK_Publishers primary key
			constraint DF_Publishers_PK default(next value for books.SQ_Publishers),
		[Name] nvarchar(255),
		BookAmount  nvarchar(255),
		Memo nvarchar(255),
		DateCreated datetime not null constraint DF_Publishers_DateCreated default(getdate()),
		UserCreated bigint not null
			constraint FK_Publishers_UserCreated_Users foreign key references a2security.Users(Id),
		DateModified datetime not null constraint DF_Publishers_DateModified default(getdate()),
		UserModified bigint not null
			constraint FK_Publishers_UserModified_Users foreign key references a2security.Users(Id)
	)
end
go

-- Book.Book
if (not exists (select 1 from INFORMATION_SCHEMA.COLUMNS where TABLE_SCHEMA=N'books' and TABLE_NAME=N'Publishers' and COLUMN_NAME=N'BookAmount'))
begin
	alter table books.Publishers add BookAmount  nvarchar(255);
end
go

------------------------------------------------
----- Publishers data
if not exists(select * from books.Publishers) 
begin
	insert into books.Publishers ([Name], UserCreated, UserModified)
		values 
		(N'Pearson', 0, 0),
		(N'Reed Elsevier', 0, 0),
		(N'Pearson', 0, 0),
		(N'Thomson-Reuters', 0, 0),
		(N'Wolters Kluwer', 0, 0),
		(N'Random House', 0, 0),
		(N'Hachette Livre', 0, 0),
		(N'Grupo Planeta', 0, 0);
end
go

----- New Publishers
if ((select count(*) from books.Publishers) < 10) 
begin
	insert into books.Publishers([Name], UserCreated, UserModified)
		values 
		(N'China Publishing Group', 0, 0),
		(N'Houghton Mifflin Harcourt', 0, 0),
		(N'HarperCollins', 0, 0),
		(N'Springer Science and Business Media', 0, 0),
		(N'Shueisha', 0, 0),
		(N'Cengage*', 0, 0),
		(N'McGraw-Hill Education', 0, 0),
		(N'Scholastic', 0, 0),
		(N'Wiley', 0, 0),
		(N'De Agostini Editore*', 0, 0),
		(N'Informa', 0, 0);
end
go
------------------------------------------------
create or alter procedure books.[Publisher.Index]
@UserId bigint,
@Id bigint = null,
@Offset int = 0,
@PageSize int = 10,
@Order nvarchar(255) = N'Name',
@Dir nvarchar(20) = N'asc'
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	declare @Asc nvarchar(10), @Desc nvarchar(10), @RowCount int;
	set @Asc = N'asc'; set @Desc = N'desc';
	set @Dir = isnull(@Dir, @Asc);
	with T ([Id!!Id], [Name], BookAmount, Memo, [!!RowNumber])
	as(
		select [Id!!Id] = Id, [Name], BookAmount, Memo,
		[!!RowNumber] = row_number() over (
		order by
			case when @Order=N'Id' and @Dir = @Asc then b.Id end asc,
			case when @Order=N'Id' and @Dir = @Desc  then b.Id end desc,
			case when @Order=N'Name' and @Dir = @Asc then b.[Name] end asc,
			case when @Order=N'Name' and @Dir = @Desc then b.[Name] end desc
		)
		from books.Publishers as b
	)

	select [Publishers!TPublisher!Array] = null, *, [!!RowCount] = (select count(1) from T)
	from T
	where [!!RowNumber] > @Offset and [!!RowNumber] <= @Offset + @PageSize
	order by [!!RowNumber];

	select [!$System!] = null, 
		[!Publishers!PageSize] = @PageSize, 
		[!Publishers!SortOrder] = @Order, 
		[!Publishers!SortDir] = @Dir,
		[!Publishers!Offset] = @Offset,
		[!Publishers!HasRows] = case when exists(select * from books.Publishers) then 1 else 0 end;

----------------Publishers-----------------------------------------------
	--select COUNT(Authors)
   -- from books.Books
   -- group by Publisher
   -- having COUNT(Authors) > 0;
end
go
------------------------------------------------
create or alter procedure books.[Publisher.Load]
@UserId bigint,
@Id bigint = null,
@Text nvarchar(255) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	select [Publisher!TPublisher!Object] = null, [Id!!Id] = Id, [Name], Memo
	from books.Publishers
	where Id = @Id;

	select [Params!TParam!Object] = null, [Text] = @Text;

end
go
------------------------------------------------
if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_SCHEMA=N'books' and ROUTINE_NAME=N'Publisher.Update')
	drop procedure books.[Publisher.Update];
go
------------------------------------------------
if exists(select * from INFORMATION_SCHEMA.DOMAINS where DOMAIN_SCHEMA=N'books' and DOMAIN_NAME=N'Publisher.TableType' and DATA_TYPE=N'table type')
	drop type books.[Publisher.TableType];
go
------------------------------------------------
create type books.[Publisher.TableType]
as table(
	Id bigint null,
	[Name] nvarchar(255),
	Memo nvarchar(255)
)
go
-------------------------------------------------
create or alter procedure books.[Publisher.Metadata]
as
begin
	set nocount on;
	declare @Publisher books.[Publisher.TableType];
	select [Publisher!Publisher!Metadata] = null, * from @Publisher;
end
go
-------------------------------------------------
create or alter procedure books.[Publisher.Update]
@UserId bigint,
@Publisher books.[Publisher.TableType] readonly,
@RetId bigint = null output
as
begin
	set nocount on;
	set transaction isolation level serializable;
	set xact_abort on;

	declare @output table(op nvarchar(150), id bigint);

	merge books.Publishers as target
	using @Publisher as source
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

	exec books.[Publisher.Load] @UserId = @UserId, @Id = @RetId;
end
go
-------------------------------------------------
create or alter procedure books.[Publisher.Delete]
@UserId bigint,
@Id bigint = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	delete from books.Publishers
	where Id = @Id;

end
go
------------------------------------------------
create or alter procedure books.[Publisher.Fetch]
@UserId bigint,
@Search nvarchar(255) = null
as
begin
	set nocount on;
	set transaction isolation level read uncommitted;

	if @Search is not null 
		set @Search = N'%' + upper(@Search) + N'%';

	select [Publishers!TPublisher!Array] = null, [Id!!Id] = Id, [Name], Memo
	from books.Publishers
	where upper(Name) like @Search or cast(Id as nvarchar) like @Search;

end
go