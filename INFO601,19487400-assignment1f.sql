--Instruction for one time sucessfully testing the code.
--1. unlock all 'drop trigger' and 'drop sequence'.
--2. run them individually.
--3. lock them as comments.
--4. run the code throughly for success. thanks.

drop table supplier cascade CONSTRAINTS;
CREATE TABLE supplier (
    sup_id             INTEGER NOT NULL,
    sup_code           VARCHAR2(50),
    sup_name           VARCHAR2(50),
    sup_contactlname   VARCHAR2(50),
    sup_contactfname   VARCHAR2(50),
    sup_phone          NUMBER not null,
    sup_street         VARCHAR2(100),
    sup_suburb         VARCHAR2(50),
    sup_city           VARCHAR2(50)
);

ALTER TABLE supplier ADD CONSTRAINT supplier_pk PRIMARY KEY ( sup_id );

drop table sales cascade CONSTRAINTS;
CREATE TABLE sales (
    s_code         VARCHAR2(20) NOT NULL,
    s_lname        VARCHAR2(50),
    s_fname        VARCHAR2(50),
    s_phone        NUMBER NOT NULL,
    s_onboardate   DATE NOT NULL,
    s_position     VARCHAR2(20),
    s_comrate      VARCHAR2(20),
    sales_s_code   VARCHAR2(20) NOT NULL
);


ALTER TABLE sales ADD CONSTRAINT sales_pk PRIMARY KEY ( s_code );
ALTER TABLE sales
    ADD CONSTRAINT sales_sales_fk FOREIGN KEY ( sales_s_code )
        REFERENCES sales ( s_code );

drop table "Order" cascade CONSTRAINTS;
CREATE TABLE "Order" (
    po_no             INTEGER NOT NULL,
    po_date           DATE,
    authrby           VARCHAR2(50),
    authrdate         DATE,
    totalqty          INTEGER,
    subtotal          NUMBER (10,2),
    supplier_sup_id   INTEGER NOT NULL,
    sales_s_code      VARCHAR2(20) NOT NULL
);



ALTER TABLE "Order" ADD CONSTRAINT order_pk PRIMARY KEY ( po_no );
ALTER TABLE "Order"
    ADD CONSTRAINT order_sales_fk FOREIGN KEY ( sales_s_code )
        REFERENCES sales ( s_code );

ALTER TABLE "Order"
    ADD CONSTRAINT order_supplier_fk FOREIGN KEY ( supplier_sup_id )
        REFERENCES supplier ( sup_id );

--drop sequence ord_seq;
create sequence ord_seq
start with 80000000
increment by 1;

--drop trigger ord_seq_trg;
create or replace trigger ord_seq_trg
BEFORE insert on "Order"
referencing new as new
for each row
begin
select ord_seq.nextval into :New.po_no from dual;
End;
/
        
drop table product_type cascade CONSTRAINTS;
CREATE TABLE product_type (
    typeid         INTEGER NOT NULL,
    make           VARCHAR2(20),
    model          VARCHAR2(20),
    uniprice       NUMBER (10,2),
    year           NUMBER (4),
    items_itemno   INTEGER NOT NULL
);


ALTER TABLE product_type ADD CONSTRAINT product_type_pk PRIMARY KEY ( typeid );
ALTER TABLE product_type
    ADD CONSTRAINT product_type_items_fk FOREIGN KEY ( items_itemno )
        REFERENCES items ( itemno );

drop table items cascade CONSTRAINTS;
CREATE TABLE items (
    itemno                INTEGER NOT NULL,
    i_desc                VARCHAR2(50),
    i_price               NUMBER (10,2),
    product_type_typeid   INTEGER NOT NULL
);


ALTER TABLE items ADD CONSTRAINT items_pk PRIMARY KEY ( itemno );
ALTER TABLE items
    ADD CONSTRAINT items_product_type_fk FOREIGN KEY ( product_type_typeid )
        REFERENCES product_type ( typeid );

drop table line_item cascade CONSTRAINTS;
CREATE TABLE line_item (
    i_price                 NUMBER (10,2),
    i_desc                  VARCHAR2(50),
    li_qty                  INTEGER CHECK (li_qty > 0),
    li_total                NUMBER (10,2),
    order_po_no             INTEGER NOT NULL,
    items_itemno            INTEGER NOT NULL
);

ALTER TABLE line_item ADD CONSTRAINT line_item_pk PRIMARY KEY ( order_po_no,
                                                                items_itemno );
ALTER TABLE line_item
    ADD CONSTRAINT line_item_items_fk FOREIGN KEY ( items_itemno )
        REFERENCES items ( itemno );

ALTER TABLE line_item
    ADD CONSTRAINT line_item_order_fk FOREIGN KEY ( order_po_no )
        REFERENCES "Order" ( po_no );

drop table product cascade CONSTRAINTS;
CREATE TABLE product (
    regisno                       VARCHAR2(20) NOT NULL,
    por                           NUMBER,
    ownerno                       INTEGER,
    wof                           DATE,
    sprice                        NUMBER (10,2),
    addcost                       NUMBER (10,2),
    make                          VARCHAR2(20),
    model                         VARCHAR2(20),
    year                          NUMBER (4),
    salespurchase_invoiceno       INTEGER NOT NULL
);


ALTER TABLE product ADD CONSTRAINT product_pk PRIMARY KEY ( regisno );
ALTER TABLE product
    ADD CONSTRAINT product_salespurchase_fk FOREIGN KEY ( salespurchase_invoiceno )
        REFERENCES salespurchase ( invoiceno );

drop table salespurchase cascade CONSTRAINTS;
CREATE TABLE salespurchase (
    invoiceno         INTEGER NOT NULL,
    sp_subtotal       NUMBER (10,2),
    deposit           NUMBER (10,2),
    netprice          NUMBER (10,2),
    balance           NUMBER (10,2),
    trader            VARCHAR2(50),
    tdate             DATE,
    sales_s_code      VARCHAR2(20) NOT NULL,
    product_regisno   VARCHAR2(20) NOT NULL,
    customer_c_id     INTEGER NOT NULL
);


ALTER TABLE salespurchase ADD CONSTRAINT salespurchase_pk PRIMARY KEY ( invoiceno );

ALTER TABLE salespurchase
    ADD CONSTRAINT salespurchase_customer_fk FOREIGN KEY ( customer_c_id )
        REFERENCES customer ( c_id );

ALTER TABLE salespurchase
    ADD CONSTRAINT salespurchase_product_fk FOREIGN KEY ( product_regisno )
        REFERENCES product ( regisno );

ALTER TABLE salespurchase
    ADD CONSTRAINT salespurchase_sales_fk FOREIGN KEY ( sales_s_code )
        REFERENCES sales ( s_code );

--drop sequence sp_seq;
create sequence sp_seq
start with 10000000
increment by 1;

--drop trigger sp_seq_trg;
create or replace trigger sp_seq_trg
BEFORE insert on salespurchase
referencing new as new
for each row
begin
select sp_seq.nextval into :New.invoiceno from dual;
End;
/


drop table p_color cascade CONSTRAINTS;
CREATE TABLE p_color (
    colname           VARCHAR2(20) NOT NULL,
    product_regisno   VARCHAR2(20) NOT NULL
);

ALTER TABLE p_color ADD CONSTRAINT p_color_pk PRIMARY KEY ( colname );
ALTER TABLE p_color
    ADD CONSTRAINT p_color_product_fk FOREIGN KEY ( product_regisno )
        REFERENCES product ( regisno );


drop table payinvrect cascade CONSTRAINTS;
CREATE TABLE payinvrect (
    receiptno                     NUMBER NOT NULL,
    sp_no                         NUMBER,
    "Date"                        DATE,
    amount                        NUMBER (10,2),
    approver                      VARCHAR2(50),
    receiver                      VARCHAR2(50),
    customer_c_id                 INTEGER NOT NULL,
    salespurchase_invoiceno       INTEGER NOT NULL
);

ALTER TABLE payinvrect ADD CONSTRAINT payinvrect_pk PRIMARY KEY ( receiptno );
ALTER TABLE payinvrect
    ADD CONSTRAINT payinvrect_customer_fk FOREIGN KEY ( customer_c_id )
        REFERENCES customer ( c_id );

ALTER TABLE payinvrect
    ADD CONSTRAINT payinvrect_salespurchase_fk FOREIGN KEY ( salespurchase_invoiceno )
        REFERENCES salespurchase ( invoiceno );
        
drop table customer cascade CONSTRAINTS;
CREATE TABLE customer (
    c_id       INTEGER NOT NULL,
    c_lname    VARCHAR2(50),
    c_fname    VARCHAR2(50),
    c_street   VARCHAR2(100),
    c_suburb   VARCHAR2(50),
    c_city     VARCHAR2(50),
    c_phone    NUMBER,
    c_title    VARCHAR2(20)
);

ALTER TABLE customer ADD CONSTRAINT customer_pk PRIMARY KEY ( c_id );





