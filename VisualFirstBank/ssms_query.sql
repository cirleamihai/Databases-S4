select * from CreditCards;
select * from CustomerAccount;
select * from Purchases;
select * from CustomerCreditCards;
select * from BankAccounts;

insert into CustomerAccount values (2, 'Cirlea Tudor Gabriel', 14, '2024-01-19', 1)

create table CustomerCreditCards(
	custId int foreign key references CustomerAccount(id),
	cardId int foreign key references CreditCards(card_id)
)

insert into CustomerCreditCards values (1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (2, 7)

create table BankAccounts(
	IBAN varchar(15) primary key,
	custId int foreign key references CustomerAccount(id)
)

insert into BankAccounts values ('RO42 BTRL 1111', 1), ('REVL RONL 1923', 1), ('SW11 SWIS 1922', 2)