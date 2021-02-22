-------------------------
----- Dev functions -----
-------------------------

------------------------------------------------
create or alter procedure sunapi.ReApplyMoneyDocs
as
begin
	declare @DocId bigint;
	declare cur cursor local for
		select Id from sunapi.Documents where [Type] in ('INCOME_PAYMENT', 'OUTGOING_PAYMENT', 'MONEY_MOVE');
	open cur;
	fetch next from cur into @DocId;
	while @@FETCH_STATUS = 0 
	begin
		exec sunapi.[Document.UnApply] 99, @DocId;
		exec sunapi.[Document.Apply] 99, @DocId;
		fetch next from cur into @DocId;
	end;
	close cur;
	deallocate cur;
end
go
------------------------------------------------